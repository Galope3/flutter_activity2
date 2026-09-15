import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const _teal = Color(0xFF12A9A5);

void main() => runApp(
  ChangeNotifierProvider(
    create: (_) => AppSettings(),
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
      title: 'LabMaster',
      theme: light,
      darkTheme: dark,
      themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routes: {
        '/': (_) => const HomeDashboard(),
        '/activity-one': (_) => const ActivityOneScreen(),
        '/activity-two': (_) => const ActivityTwoScreen(),
        '/network': (_) => const NetworkMonitorScreen(),
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
                        'LabMaster',
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
                    icon: Icons.code_rounded,
                    title: 'Activity 2',
                    subtitle: 'Mobile App\nDevelopment',
                    route: '/activity-two',
                  ),
                  ActivityCard(
                    icon: Icons.menu_book_outlined,
                    title: 'Activity 3',
                    subtitle: 'Database Systems',
                    route: '/activity-one',
                  ),
                  ActivityCard(
                    icon: Icons.cloud_outlined,
                    title: 'Activity 4',
                    subtitle: 'Web Development',
                    route: '/activity-two',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            MenuTile(
              icon: Icons.settings,
              title: 'Settings',
              subtitle: 'Theme, Profile, and more',
              onTap: () => Navigator.pushNamed(context, '/settings'),
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

class ActivityTwoScreen extends StatefulWidget {
  const ActivityTwoScreen({super.key});
  @override
  State<ActivityTwoScreen> createState() => _ActivityTwoScreenState();
}

class _ActivityTwoScreenState extends State<ActivityTwoScreen> {
  int tab = 0;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Activity 2'),
      actions: const [Icon(Icons.more_vert), SizedBox(width: 12)],
    ),
    bottomNavigationBar: const AppNav(index: 1),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const ActivityHeader(
          icon: Icons.code_rounded,
          title: 'Mobile App\nDevelopment',
          subtitle: 'Build Flutter projects, one practical task at a time.',
        ),
        const SizedBox(height: 24),
        SegmentTabs(
          labels: const ['Lab Tasks', 'Resources'],
          selected: tab,
          onChanged: (value) => setState(() => tab = value),
        ),
        const SizedBox(height: 18),
        const TaskTile(
          icon: Icons.document_scanner_outlined,
          title: 'Lab 1. Hello World',
          subtitle: 'Create a simple Flutter app',
        ),
        const TaskTile(
          icon: Icons.widgets_outlined,
          title: 'Lab 2. Widgets',
          subtitle: 'Build a responsive UI',
        ),
        const TaskTile(
          icon: Icons.mobile_screen_share_outlined,
          title: 'Lab 3. Navigation',
          subtitle: 'Implement multiple screens',
        ),
        const TaskTile(
          icon: Icons.account_tree_outlined,
          title: 'Lab 4. State Management',
          subtitle: 'Use Provider for global state',
        ),
        TaskTile(
          icon: Icons.network_check_outlined,
          title: 'Network Monitor',
          subtitle: 'View connectivity and queued requests',
          onTap: () => Navigator.pushNamed(context, '/network'),
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
      if (value == 1) Navigator.pushNamed(context, '/activity-two');
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

class NetworkMonitorScreen extends StatefulWidget {
  const NetworkMonitorScreen({super.key});
  @override
  State<NetworkMonitorScreen> createState() => _NetworkMonitorScreenState();
}

class _NetworkMonitorScreenState extends State<NetworkMonitorScreen> {
  final connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? subscription;
  List<ConnectivityResult> active = [ConnectivityResult.none];
  bool queued = false, requesting = false;
  String status = 'Checking connection…';
  @override
  void initState() {
    super.initState();
    connectivity.checkConnectivity().then(_onConnectionChanged);
    subscription = connectivity.onConnectivityChanged.listen(
      _onConnectionChanged,
    );
  }

  bool get online => active.any((item) => item != ConnectivityResult.none);
  String get interfaceName {
    if (!online) return 'Offline';
    if (active.contains(ConnectivityResult.wifi)) return 'Wi-Fi';
    if (active.contains(ConnectivityResult.mobile)) return 'Cellular';
    return 'Connected';
  }

  void _onConnectionChanged(List<ConnectivityResult> result) {
    if (!mounted) return;
    setState(() {
      active = result;
      status = online
          ? 'Connected through $interfaceName'
          : 'No connection — requests will be queued';
    });
    if (online && queued) _runRequest(recovery: true);
  }

  Future<void> _runRequest({bool recovery = false}) async {
    if (!online) {
      setState(() {
        queued = true;
        status = 'Request queued until a connection returns';
      });
      return;
    }
    setState(() {
      requesting = true;
      queued = false;
      status = recovery
          ? 'Connection restored — retrying request…'
          : 'Fetching simulated large dataset…';
    });
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      requesting = false;
      if (!online) {
        queued = true;
        status = 'Connection changed — safely queued';
      } else {
        status = 'Dataset request completed via $interfaceName';
      }
    });
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Network Monitor')),
    body: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(18),
              leading: Icon(
                online ? Icons.wifi : Icons.wifi_off,
                color: online ? Colors.green : Colors.red,
                size: 40,
              ),
              title: Text(
                interfaceName,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              subtitle: Text(
                online
                    ? 'Stable connection detected'
                    : 'Waiting for Wi-Fi or cellular',
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(status),
          const Spacer(),
          if (requesting) const Center(child: CircularProgressIndicator()),
          if (queued)
            const Chip(
              avatar: Icon(Icons.schedule),
              label: Text('1 request queued for recovery'),
            ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              backgroundColor: _teal,
            ),
            onPressed: requesting ? null : _runRequest,
            icon: const Icon(Icons.cloud_download_outlined),
            label: const Text('Simulate dataset request'),
          ),
        ],
      ),
    ),
  );
}
