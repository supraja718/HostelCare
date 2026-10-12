import 'package:flutter/material.dart';
import 'complaint_repository.dart';
import 'hostel_database.dart';

class WardenAnnouncementItem {
  final String announcementId;
  final String title;
  final String message;
  final String createdBy;
  final String createdAt;
  final bool isImportant;
  final String status; // 'Published'

  WardenAnnouncementItem({
    required this.announcementId,
    required this.title,
    required this.message,
    required this.createdBy,
    required this.createdAt,
    required this.isImportant,
    required this.status,
  });

  Map<String, dynamic> toMap() => {
        'announcementId': announcementId,
        'title': title,
        'message': message,
        'createdBy': createdBy,
        'createdAt': createdAt,
        'isImportant': isImportant ? 1 : 0,
        'status': status,
      };

  factory WardenAnnouncementItem.fromMap(Map<String, dynamic> map) => WardenAnnouncementItem(
        announcementId: map['announcementId'],
        title: map['title'],
        message: map['message'],
        createdBy: map['createdBy'],
        createdAt: map['createdAt'],
        isImportant: map['isImportant'] == 1 || map['isImportant'] == true,
        status: map['status'] ?? 'Published',
      );
}

class WardenAnnouncementRepository extends ChangeNotifier {
  static final WardenAnnouncementRepository instance = WardenAnnouncementRepository._internal();
  WardenAnnouncementRepository._internal() {
    _loadFromDB();
  }

  final List<WardenAnnouncementItem> _announcements = [];
  List<WardenAnnouncementItem> get announcements => List.unmodifiable(_announcements);

  Future<void> _loadFromDB() async {
    try {
      final db = await HostelDatabase.instance.database;
      final maps = await db.query('announcements');
      _announcements.clear();
      for (var m in maps) {
        // Adapt schema from announcements table
        _announcements.add(WardenAnnouncementItem(
          announcementId: m['announcementId'] as String,
          title: m['title'] as String,
          message: m['content'] as String,
          createdBy: m['postedBy'] as String,
          createdAt: m['timestamp'] as String,
          isImportant: true,
          status: 'Published',
        ));
      }
      if (_announcements.isEmpty) {
        final demo = WardenAnnouncementItem(
          announcementId: 'AN-01',
          title: 'Water Supply Maintenance',
          message: 'Water supply will be unavailable from 2:00 PM to 5:00 PM today due to overhead tank cleaning.',
          createdBy: 'Warden Administrator',
          createdAt: 'Today, 08:00 AM',
          isImportant: true,
          status: 'Published',
        );
        await createAnnouncement(demo);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading warden announcements: $e');
    }
  }

  Future<void> createAnnouncement(WardenAnnouncementItem item) async {
    _announcements.insert(0, item);
    try {
      await HostelDatabase.instance.insert('announcements', {
        'announcementId': item.announcementId,
        'title': item.title,
        'content': item.message,
        'targetRole': 'Student',
        'postedBy': item.createdBy,
        'timestamp': item.createdAt,
      });
    } catch (e) {
      debugPrint('Error inserting announcement into DB: $e');
    }

    // Notify Students if important
    if (item.isImportant) {
      ComplaintRepository.instance.notifications.insert(
        0,
        HostelNotificationItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: 'Important Announcement 📢',
          description: item.title,
          date: 'Just now',
          type: 'Announcement',
        ),
      );
    }

    notifyListeners();
  }

  Future<void> deleteAnnouncement(String announcementId) async {
    _announcements.removeWhere((a) => a.announcementId == announcementId);
    try {
      await HostelDatabase.instance.delete('announcements', 'announcementId = ?', [announcementId]);
    } catch (e) {
      debugPrint('Error deleting announcement from DB: $e');
    }
    notifyListeners();
  }
}
