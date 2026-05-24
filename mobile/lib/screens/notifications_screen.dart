import 'package:flutter/material.dart';

import '../models/app_notification.dart';
import '../services/app_controller.dart';
import '../theme/newsprint_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    try {
      await widget.controller.loadNotifications();
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _markRead(AppNotification notification) async {
    if (notification.read) {
      return;
    }
    try {
      await widget.controller.markNotificationRead(notification.notificationId);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not mark notification as read: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final notifications = widget.controller.notifications;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Notifications'),
            actions: <Widget>[
              IconButton(
                onPressed: _loading ? null : _refresh,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: _loading
              ? const Center(child: CircularProgressIndicator())
              : notifications.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No notifications yet. New task assignments will show up here.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: notifications.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return DecoratedBox(
                        decoration: BoxDecoration(
                          color: notification.read
                              ? NewsprintColors.background
                              : NewsprintColors.neutral100,
                          border: Border.all(color: NewsprintColors.ink),
                        ),
                        child: ListTile(
                          leading: Icon(
                            notification.read
                                ? Icons.notifications_none
                                : Icons.notifications_active,
                            color: notification.read
                                ? NewsprintColors.neutral500
                                : NewsprintColors.accent,
                          ),
                          title: Text(
                            notification.title.toUpperCase(),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(notification.message),
                              const SizedBox(height: 4),
                              Text(
                                notification.createdAt,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          onTap: () => _markRead(notification),
                        ),
                      );
                    },
                  ),
                ),
        );
      },
    );
  }
}
