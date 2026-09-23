import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class NetworkMonitorScreen extends StatefulWidget {
  const NetworkMonitorScreen({super.key});

  @override
  State<NetworkMonitorScreen> createState() => _NetworkMonitorScreenState();
}

class _NetworkMonitorScreenState extends State<NetworkMonitorScreen> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  List<ConnectivityResult> _active = const [ConnectivityResult.none];
  bool _isRequesting = false;
  bool _isQueued = false;
  String _status = 'Checking current connection…';

  @override
  void initState() {
    super.initState();
    _connectivity.checkConnectivity().then(_onConnectionChanged);
    _subscription = _connectivity.onConnectivityChanged.listen(_onConnectionChanged);
  }

  bool get _online => _active.any((result) => result != ConnectivityResult.none);
  bool get _wifi => _active.contains(ConnectivityResult.wifi);
  bool get _cellular => _active.contains(ConnectivityResult.mobile);
  String get _interface => !_online ? 'Offline' : _wifi ? 'Wi-Fi' : _cellular ? 'Cellular' : 'Connected';

  void _onConnectionChanged(List<ConnectivityResult> results) {
    if (!mounted) return;
    setState(() {
      _active = results;
      _status = _online ? 'Connected through $_interface' : 'Offline — requests are safely queued.';
    });
    if (_online && _isQueued && !_isRequesting) _runLongRequest(recovery: true);
  }

  Future<void> _runLongRequest({bool recovery = false}) async {
    if (!_online) {
      setState(() { _isQueued = true; _status = 'Large dataset request queued until connection recovers.'; });
      return;
    }
    setState(() {
      _isRequesting = true;
      _isQueued = false;
      _status = recovery ? 'Connection restored — retrying queued dataset request…' : 'Fetching simulated large dataset…';
    });
    // Simulated chunked request: each chunk checks the latest stream state.
    for (var chunk = 1; chunk <= 8; chunk++) {
      await Future<void>.delayed(const Duration(milliseconds: 650));
      if (!mounted) return;
      if (!_online) {
        setState(() { _isRequesting = false; _isQueued = true; _status = 'Connection changed during transfer — request queued for retry.'; });
        return;
      }
      setState(() => _status = 'Fetching large dataset… chunk $chunk of 8');
    }
    if (!mounted) return;
    setState(() { _isRequesting = false; _status = 'Dataset request completed via $_interface.'; });
  }

  @override
  void dispose() { _subscription?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final color = _online ? Colors.green : Colors.red;
    return Scaffold(
      appBar: AppBar(title: const Text('Network Monitor')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Card(child: ListTile(
          contentPadding: const EdgeInsets.all(18),
          leading: Icon(_online ? (_wifi ? Icons.wifi : Icons.signal_cellular_alt) : Icons.wifi_off, color: color, size: 42),
          title: Text(_interface, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          subtitle: Text(_online ? 'Live stream listener is active' : 'Waiting for Wi-Fi or cellular'),
        )),
        const SizedBox(height: 18),
        Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Request recovery', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(_status),
          if (_isRequesting) const Padding(padding: EdgeInsets.only(top: 14), child: LinearProgressIndicator()),
          if (_isQueued) const Padding(padding: EdgeInsets.only(top: 14), child: Chip(avatar: Icon(Icons.schedule), label: Text('Queued — resumes automatically when online'))),
        ]))),
        const SizedBox(height: 20),
        FilledButton.icon(
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
          onPressed: _isRequesting ? null : _runLongRequest,
          icon: const Icon(Icons.cloud_download_outlined),
          label: const Text('Simulate large dataset request'),
        ),
      ]),
    );
  }
}
