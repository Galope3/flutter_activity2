# Lab Portfolio

A multi-screen Flutter master-compilation app for laboratory activities.

## Included activities

- Responsive dashboard with named routes for two activity screens and Network Monitor.
- Provider global state: change the display name or light/dark theme in Settings; the dashboard updates immediately.
- Stateful activity-completion controls and reusable stateless dashboard cards.
- Network Monitor powered by `connectivity_plus`: it listens for Wi-Fi/cellular/offline changes, queues a simulated dataset request when offline or interrupted, and retries it automatically after connectivity returns.

## Run

```bash
flutter pub get
flutter run
```

## Recording checklist

1. Change the name and theme in Settings, then return home to show the immediate update.
2. Resize an emulator/window to show the dashboard adapting between one, two, and three columns.
3. Start a simulated dataset request, disable Wi-Fi/cellular while it runs, then restore either connection and show the queued request automatically retrying.
