import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:food_flow/users/splashscren.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:food_flow/data&theme/variable.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications>
    with TickerProviderStateMixin {
  final List<_NotificationItem> _notifications = [];
  late final AnimationController _listController;
  final Map<int, bool> _isRemoving = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _listController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fetchNotifications();
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  Future<void> _fetchNotifications() async {
    final token = await _getToken();
    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse("http://10.0.2.2:8000/api/notifications"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> notificationsJson = data['notifications'];

        setState(() {
          _notifications.clear();
          _notifications.addAll(
            notificationsJson
                .map((json) => _NotificationItem.fromJson(json))
                .toList(),
          );
          _listController.forward();
          _isLoading = false;
        });
      } else {
        print("Failed to fetch notifications: ${response.body}");
      }
    } catch (e) {
      print("Error fetching notifications: $e");
    }
  }

  Future<void> _markAsRead(int id, int index) async {
  final token = await _getToken();
  if (token == null) return;

  final response = await http.patch(
    Uri.parse("http://10.0.2.2:8000/api/notifications/$id/read"),
    headers: {
      "Authorization": "Bearer $token",
      "Accept": "application/json",
    },
  );

  if (response.statusCode == 200) {
    setState(() {
      _notifications[index].isRead = true;
    });
  } else {
    print("Failed to mark as read: ${response.body}");
  }
}
  Future<bool> _deleteNotification(int id) async {
    final token = await _getToken();
    if (token == null) return false;

    final response = await http.delete(
      Uri.parse("http://10.0.2.2:8000/api/notifications/$id"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print("Failed to delete: ${response.body}");
      return false;
    }
  }

  Widget _buildAnimatedNotification(_NotificationItem notification, int index) {
    final animation = CurvedAnimation(
      parent: _listController,
      curve: Interval(index * 0.1, 1.0, curve: Curves.easeOut),
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(animation),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 400),
          opacity: _isRemoving[index] == true ? 0 : 1,
          child: AnimatedSize(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            child: Dismissible(
              key: Key(notification.id.toString()),
              direction: DismissDirection.endToStart,
              confirmDismiss: (_) async {
                setState(() {
                  _isRemoving[index] = true;
                });
                await Future.delayed(const Duration(milliseconds: 400));
                final success = await _deleteNotification(notification.id);
                if (success) {
                  setState(() {
                    _notifications.removeAt(index);
                    _isRemoving.remove(index);
                  });
                } else {
                  setState(() {
                    _isRemoving.remove(index);
                  });
                }
                return false; // لا نترك Dismissible يحذف مباشرة
              },
              background: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.centerRight,
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              child: GestureDetector(
                onTap: () {
                  if (!notification.isRead) {
                    _markAsRead(notification.id, index);
                  }
                },
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: notification.isRead
                        ? LinearGradient(colors: [
                            Colors.grey.shade200,
                            Colors.grey.shade100
                          ])
                        : LinearGradient(colors: [
                            Color.fromARGB(255, 233, 175, 16),
                            Color.fromARGB(255, 233, 175, 16),
                          ]),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 4, right: 12),
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: notification.isRead
                              ? Colors.transparent
                              : Colors.orange,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: coltext,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notification.description,
                              style: TextStyle(
                                fontSize: 14,
                                color: coltext.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notification.createdAt,
                              style: TextStyle(
                                fontSize: 12,
                                color: coltext.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        notification.isRead ? Icons.done : Icons.markunread,
                        color:
                            notification.isRead ? Colors.green : Colors.orange,
                        size: 22,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: theTextDecoration,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: colbg,
          appBar: AppBar(
            backgroundColor: colbg,
            elevation: 0,
            title: Text(
              'الإشعارات',
              style: TextStyle(
                color: coltext,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            iconTheme: IconThemeData(color: coltext, size: 28),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                  });
                  _fetchNotifications();
                },
              ),
            ],
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _notifications.isEmpty
                  ? Center(
                      child: Text(
                        'لا توجد إشعارات حالياً',
                        style: TextStyle(
                            fontSize: 18, color: coltext.withOpacity(0.6)),
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: _notifications.length,
                      itemBuilder: (context, index) {
                        final notification = _notifications[index];
                        return _buildAnimatedNotification(notification, index);
                      },
                    ),
        ),
      ),
    );
  }
}

class _NotificationItem {
  final int id;
  final String title;
  final String description;
  bool isRead;
  final String createdAt;

  _NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.isRead,
    required this.createdAt,
  });

  factory _NotificationItem.fromJson(Map<String, dynamic> json) {
    return _NotificationItem(
      id: json['id'],
      title: json['type'] == 'wallet' ? 'محفظة' : 'فاتورة',
      description: json['message'],
      isRead: json['is_read'] == 1,
      createdAt: json['created_at'],
    );
  }
}
