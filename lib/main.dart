import 'dart:async';

import 'network_diagnostics.dart';
import 'network_monitor.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const _teal = Color(0xFF12A9A5);

void main() => runApp(
  MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AppSettings()),
      ChangeNotifierProvider(create: (_) => NetworkDiagnostics()..start()),
    ],
    child: const PortfolioApp(),
  ),
);

class AppSettings extends ChangeNotifier {
  bool isDarkMode = true;
  String displayName = 'Julia';
  String studentId = 'BSCS 5B';
  void setDarkMode(bool value) {
    isDarkMode = value;
    notifyListeners();
  }

  void setDisplayName(String value) {
    displayName = value.trim().isEmpty ? 'Student' : value.trim();
    notifyListeners();
  }
}

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({super.key});
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final light = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: _teal),
      useMaterial3: true,
    );
    final dark = ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _teal,
        brightness: Brightness.dark,
        surface: const Color(0xFF1E202B),
      ),
      scaffoldBackgroundColor: const Color(0xFF161719),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF2B2D3A),
        foregroundColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF292B38),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      useMaterial3: true,
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Activity Lab',
      theme: light,
      darkTheme: dark,
      themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routes: {
        '/': (_) => const HomeDashboard(),
        '/activity-one': (_) => const ActivityOneScreen(),
        '/diagnostics': (_) => const NetworkDiagnosticDashboard(),
        '/network-monitor': (_) => const NetworkMonitorScreen(),
        '/settings': (_) => const SettingsScreen(),
      },
    );
  }
}

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});
  @override
  Widget build(BuildContext context) {
    final name = context.watch<AppSettings>().displayName;
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      bottomNavigationBar: const AppNav(index: 0),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          children: [
            Row(
              children: [
                const LabLogo(),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Activity Lab',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Your Laboratory Activities\nin One Place',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pushNamed(context, '/settings'),
                  icon: const Icon(Icons.account_circle, size: 34),
                ),
              ],
            ),
            const SizedBox(height: 34),
            Text(
              'Hello, $name!',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            const Text("Keep going! You're doing great."),
            const SizedBox(height: 28),
            LayoutBuilder(
              builder: (context, size) => GridView.count(
                crossAxisCount: size.maxWidth > 600 ? 4 : 2,
                childAspectRatio: size.maxWidth > 600 ? 1.25 : .95,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                children: const [
                  ActivityCard(
                    icon: Icons.science_outlined,
                    title: 'Activity 1',
                    subtitle: 'Data Structures\nand Algorithms',
                    route: '/activity-one',
                  ),
                  ActivityCard(
                    icon: Icons.monitor_heart_outlined,
                    title: 'Network Diagnostics',
                    subtitle: 'Connection health\nand performance',
                    route: '/diagnostics',
                  ),
                  ActivityCard(
                    icon: Icons.wifi_tethering_outlined,
                    title: 'Network Monitor',
                    subtitle: 'Live connection\nand request recovery',
                    route: '/network-monitor',
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LabLogo extends StatelessWidget {
  const LabLogo({super.key});
  @override
  Widget build(BuildContext context) => Container(
    width: 46,
    height: 46,
    decoration: BoxDecoration(
      color: _teal.withValues(alpha: .18),
      borderRadius: BorderRadius.circular(13),
    ),
    child: const Icon(
      Icons.science_outlined,
      color: Color(0xFF8BE5E2),
      size: 31,
    ),
  );
}

class ActivityCard extends StatelessWidget {
  const ActivityCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
    super.key,
  });
  final IconData icon;
  final String title, subtitle, route;
  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => Navigator.pushNamed(context, route),
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 28,
                ),
                const Spacer(),
                const Icon(Icons.chevron_right),
              ],
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 5),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    ),
  );
}

class MenuTile extends StatelessWidget {
  const MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    super.key,
  });
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Icon(icon),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
    ),
  );
}

class ActivityOneScreen extends StatefulWidget {
  const ActivityOneScreen({super.key});
  @override
  State<ActivityOneScreen> createState() => _ActivityOneScreenState();
}

class _ActivityOneScreenState extends State<ActivityOneScreen> {
  int tab = 0;
  final lessons = const [
    ('1', 'Introduction', 'Overview of data structures'),
    ('2', 'Arrays', 'Working with arrays'),
    ('3', 'Linked List', 'Storing and building linked lists'),
    ('4', 'Stacks and Queues', 'LIFO and FIFO exercises'),
  ];
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Activity 1'),
      actions: const [Icon(Icons.more_vert), SizedBox(width: 12)],
    ),
    bottomNavigationBar: const AppNav(index: 1),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const ActivityHeader(
          icon: Icons.science_outlined,
          title: 'Data Structures\nand Algorithms',
          subtitle:
              'Learn the core concepts used to organize and process data.',
        ),
        const SizedBox(height: 24),
        SegmentTabs(
          labels: const ['Lessons', 'Exercises'],
          selected: tab,
          onChanged: (value) => setState(() => tab = value),
        ),
        const SizedBox(height: 18),
        ...lessons.map(
          (lesson) => NumberTile(
            number: lesson.$1,
            title: '${lesson.$1}. ${lesson.$2}',
            subtitle: lesson.$3,
          ),
        ),
      ],
    ),
  );
}

class ActivityHeader extends StatelessWidget {
  const ActivityHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    super.key,
  });
  final IconData icon;
  final String title, subtitle;
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(icon, size: 43),
      ),
      const SizedBox(width: 18),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(subtitle),
          ],
        ),
      ),
    ],
  );
}

class SegmentTabs extends StatelessWidget {
  const SegmentTabs({
    required this.labels,
    required this.selected,
    required this.onChanged,
    super.key,
  });
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: List.generate(
        labels.length,
        (index) => Expanded(
          child: InkWell(
            onTap: () => onChanged(index),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: selected == index ? _teal : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                labels[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: selected == index ? Colors.white : null,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class NumberTile extends StatelessWidget {
  const NumberTile({
    required this.number,
    required this.title,
    required this.subtitle,
    super.key,
  });
  final String number, title, subtitle;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      leading: CircleAvatar(backgroundColor: _teal, child: Text(number)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
    ),
  );
}

class TaskTile extends StatelessWidget {
  const TaskTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    super.key,
  });
  final IconData icon;
  final String title, subtitle;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      leading: CircleAvatar(
        backgroundColor: _teal.withValues(alpha: .75),
        child: Icon(icon, color: Colors.white),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
    ),
  );
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController controller;
  @override
  void initState() {
    super.initState();
    controller = TextEditingController(
      text: context.read<AppSettings>().displayName,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      bottomNavigationBar: const AppNav(index: 2),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SettingLabel(icon: Icons.account_circle, text: 'Profile'),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Name'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(settings.displayName),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  onTap: () => _editName(context),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Student ID'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(settings.studentId),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const SettingLabel(icon: Icons.contrast, text: 'Appearance'),
          Card(
            child: SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text(
                'Switch between light and dark colors.\nThis applies across the whole app.',
              ),
              value: settings.isDarkMode,
              onChanged: context.read<AppSettings>().setDarkMode,
              activeTrackColor: _teal,
            ),
          ),
          const SizedBox(height: 20),
          const SettingLabel(icon: Icons.info_outline, text: 'About'),
          Card(
            child: Column(
              children: const [
                ListTile(title: Text('App Version'), trailing: Text('v1.0.0')),
                Divider(height: 1),
                ListTile(
                  title: Text('About This App'),
                  trailing: Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.logout),
            label: const Text('Log Out'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              foregroundColor: _teal,
              side: const BorderSide(color: _teal),
            ),
          ),
        ],
      ),
    );
  }

  void _editName(BuildContext context) => showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Display name'),
      content: TextField(controller: controller, autofocus: true),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            context.read<AppSettings>().setDisplayName(controller.text);
            Navigator.pop(dialogContext);
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

class SettingLabel extends StatelessWidget {
  const SettingLabel({required this.icon, required this.text, super.key});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Row(
      children: [
        Icon(icon, color: _teal),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: _teal,
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
      ],
    ),
  );
}

class AppNav extends StatelessWidget {
  const AppNav({required this.index, super.key});
  final int index;
  @override
  Widget build(BuildContext context) => NavigationBar(
    selectedIndex: index,
    onDestinationSelected: (value) {
      if (value == 0)
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      if (value == 1) Navigator.pushNamed(context, '/diagnostics');
      if (value == 2) Navigator.pushNamed(context, '/settings');
    },
    destinations: const [
      NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: 'Home',
      ),
      NavigationDestination(
        icon: Icon(Icons.format_list_bulleted),
        label: 'Activities',
      ),
      NavigationDestination(
        icon: Icon(Icons.settings_outlined),
        selectedIcon: Icon(Icons.settings),
        label: 'Settings',
      ),
    ],
  );
}

class NetworkDiagnosticDashboard extends StatelessWidget {
  const NetworkDiagnosticDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final diagnostic = context.watch<NetworkDiagnostics>();
    final result = diagnostic.latest;
    final color = switch (diagnostic.health) {
      NetworkHealth.excellent => Colors.green,
      NetworkHealth.fair => Colors.orange,
      NetworkHealth.poor || NetworkHealth.degraded || NetworkHealth.offline => Colors.red,
      NetworkHealth.checking => _teal,
    };
    return Scaffold(
      appBar: AppBar(title: const Text('Network Diagnostic Dashboard')),
      bottomNavigationBar: const AppNav(index: 1),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              Icon(Icons.monitor_heart_outlined, size: 48, color: color),
              const SizedBox(height: 10),
              Text(diagnostic.healthLabel, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: color, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(diagnostic.message, textAlign: TextAlign.center),
              if (diagnostic.isRunning) const Padding(padding: EdgeInsets.only(top: 14), child: LinearProgressIndicator()),
            ]),
          )),
          const SizedBox(height: 18),
          _MetricGrid(result: result),
          const SizedBox(height: 18),
          const Text('Test sequence', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Card(child: Column(children: [
            ListTile(leading: Icon(Icons.looks_one_outlined), title: Text('Idle ping'), subtitle: Text('Baseline latency before transfer')),
            Divider(height: 1),
            ListTile(leading: Icon(Icons.looks_two_outlined), title: Text('Download + ping'), subtitle: Text('Bandwidth and latency measured concurrently')),
            Divider(height: 1),
            ListTile(leading: Icon(Icons.looks_3_outlined), title: Text('Upload + ping'), subtitle: Text('Bandwidth and latency measured concurrently')),
          ])),
          const SizedBox(height: 18),
          FilledButton.icon(
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52), backgroundColor: _teal),
            onPressed: diagnostic.isRunning ? null : diagnostic.runDiagnostic,
            icon: const Icon(Icons.refresh),
            label: Text(diagnostic.isRunning ? 'Running diagnostics...' : 'Run diagnostic now'),
          ),
        ],
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.result});
  final DiagnosticResult? result;
  @override
  Widget build(BuildContext context) => GridView.count(
    crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
    childAspectRatio: 1.7, crossAxisSpacing: 12, mainAxisSpacing: 12,
    children: [
      _MetricCard('Idle ping', _ms(result?.idlePingMs), Icons.speed),
      _MetricCard('Download', _mbps(result?.downloadMbps), Icons.download_outlined),
      _MetricCard('Download ping', _ms(result?.downloadPingMs), Icons.downloading_outlined),
      _MetricCard('Upload', _mbps(result?.uploadMbps), Icons.upload_outlined),
      _MetricCard('Upload ping', _ms(result?.uploadPingMs), Icons.upload_file_outlined),
      _MetricCard('Packet loss', result == null ? 'N/A' : '${(result!.packetLoss * 100).toStringAsFixed(0)}%', Icons.warning_amber_outlined),
    ],
  );
  static String _ms(double? value) => value == null || !value.isFinite ? 'N/A' : '${value.toStringAsFixed(0)} ms';
  static String _mbps(double? value) => value == null ? 'N/A' : '${value.toStringAsFixed(1)} Mbps';
}

class _MetricCard extends StatelessWidget {
  const _MetricCard(this.label, this.value, this.icon);

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, size: 20, color: _teal),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    ),
  );
}