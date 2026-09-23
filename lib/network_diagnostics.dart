import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

enum NetworkHealth { checking, excellent, fair, poor, degraded, offline }

class DiagnosticResult {
  const DiagnosticResult({
    required this.idlePingMs,
    required this.downloadPingMs,
    required this.uploadPingMs,
    required this.downloadMbps,
    required this.uploadMbps,
    required this.packetLoss,
    required this.completedAt,
  });

  final double idlePingMs, downloadPingMs, uploadPingMs;
  final double downloadMbps, uploadMbps, packetLoss;
  final DateTime completedAt;
}

/// Global Provider state. Tests run immediately and then every five minutes.
class NetworkDiagnostics extends ChangeNotifier {
  static final Uri _pingUrl = Uri.parse('https://www.google.com/generate_204');
  static final Uri _downloadUrl =
      Uri.parse('https://speed.cloudflare.com/__down?bytes=1000000');
  static final Uri _uploadUrl = Uri.parse('https://httpbin.org/post');

  final http.Client _client = http.Client();
  Timer? _timer;
  NetworkHealth health = NetworkHealth.checking;
  DiagnosticResult? latest;
  String message = 'Waiting for the first diagnostic run';
  bool isRunning = false;

  void start() {
    runDiagnostic();
    _timer = Timer.periodic(const Duration(minutes: 5), (_) => runDiagnostic());
  }

  Future<void> runDiagnostic() async {
    if (isRunning) return;
    isRunning = true;
    health = NetworkHealth.checking;
    message = 'Measuring idle latency…';
    notifyListeners();
    try {
      // Step 1: baseline latency when the connection is idle.
      final idle = await _ping();
      message = 'Measuring download bandwidth and loaded ping…';
      notifyListeners();

      // Step 2: keep pinging while a fixed-size payload is downloaded.
      final downloadMeasurements = <double>[];
      final download = _measureDownload();
      final downloadPing = _pingWhile(download, downloadMeasurements);
      final downloadMbps = await download;
      await downloadPing;

      message = 'Measuring upload bandwidth and loaded ping…';
      notifyListeners();
      // Step 3: repeat the concurrent measurement during upload.
      final uploadMeasurements = <double>[];
      final upload = _measureUpload();
      final uploadPing = _pingWhile(upload, uploadMeasurements);
      final uploadMbps = await upload;
      await uploadPing;

      final allPings = [idle, ...downloadMeasurements, ...uploadMeasurements];
      final loss = allPings.isEmpty ? 1.0 :
          allPings.where((ping) => ping.isInfinite).length / allPings.length;
      final result = DiagnosticResult(
        idlePingMs: idle,
        downloadPingMs: _average(downloadMeasurements, fallback: idle),
        uploadPingMs: _average(uploadMeasurements, fallback: idle),
        downloadMbps: downloadMbps,
        uploadMbps: uploadMbps,
        packetLoss: loss,
        completedAt: DateTime.now(),
      );
      latest = result;
      health = _categorize(result);
      message = healthLabel;
    } catch (_) {
      health = NetworkHealth.offline;
      message = 'Diagnostic server unavailable. Check your connection.';
    } finally {
      isRunning = false;
      notifyListeners();
    }
  }

  Future<double> _ping() async {
    final clock = Stopwatch()..start();
    try {
      final response = await _client.head(_pingUrl).timeout(const Duration(seconds: 8));
      return response.statusCode < 500 ? clock.elapsedMilliseconds.toDouble() : double.infinity;
    } catch (_) {
      return double.infinity;
    }
  }

  Future<void> _pingWhile(Future<double> transfer, List<double> samples) async {
    while (true) {
      final finished = await Future.any([transfer.then((_) => true), Future.delayed(const Duration(milliseconds: 450), () => false)]);
      if (finished as bool) return;
      samples.add(await _ping());
    }
  }

  Future<double> _measureDownload() async {
    final clock = Stopwatch()..start();
    final response = await _client.send(http.Request('GET', _downloadUrl)).timeout(const Duration(seconds: 20));
    final bytes = await response.stream.fold<int>(0, (total, chunk) => total + chunk.length);
    return _mbps(bytes, clock.elapsedMilliseconds);
  }

  Future<double> _measureUpload() async {
    final payload = Uint8List(512 * 1024);
    final random = Random();
    for (var i = 0; i < payload.length; i++) { payload[i] = random.nextInt(256); }
    final clock = Stopwatch()..start();
    final response = await _client.post(_uploadUrl, body: payload, headers: {'Content-Type': 'application/octet-stream'}).timeout(const Duration(seconds: 20));
    if (response.statusCode >= 400) throw StateError('Upload failed');
    return _mbps(payload.length, clock.elapsedMilliseconds);
  }

  double _mbps(int bytes, int milliseconds) => bytes * 8 / max(milliseconds, 1) / 1000;
  double _average(List<double> values, {required double fallback}) {
    final finite = values.where((value) => value.isFinite).toList();
    return finite.isEmpty ? fallback : finite.reduce((a, b) => a + b) / finite.length;
  }

  NetworkHealth _categorize(DiagnosticResult result) {
    final worstPing = max(result.idlePingMs, max(result.downloadPingMs, result.uploadPingMs));
    if (result.packetLoss >= .2 || worstPing >= 500 || !worstPing.isFinite) return NetworkHealth.degraded;
    if (result.downloadMbps > 10) return NetworkHealth.excellent;
    if (result.downloadMbps >= 2) return NetworkHealth.fair;
    return NetworkHealth.poor;
  }

  String get healthLabel => switch (health) {
    NetworkHealth.checking => 'Checking', NetworkHealth.excellent => 'Excellent',
    NetworkHealth.fair => 'Fair', NetworkHealth.poor => 'Poor',
    NetworkHealth.degraded => 'Degraded', NetworkHealth.offline => 'Offline',
  };

  @override
  void dispose() { _timer?.cancel(); _client.close(); super.dispose(); }
}
