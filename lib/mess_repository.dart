import 'package:flutter/material.dart';
import 'hostel_database.dart';

class MessMenuItem {
  final String menuId;
  final String dayOfWeek; // 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  final String mealType; // 'Breakfast', 'Lunch', 'Snacks', 'Dinner'
  final String items;
  final String foodType; // 'VEG' or 'NON-VEG'
  final String? specialNote;

  MessMenuItem({
    required this.menuId,
    required this.dayOfWeek,
    required this.mealType,
    required this.items,
    required this.foodType,
    this.specialNote,
  });

  Map<String, dynamic> toMap() => {
        'menuId': menuId,
        'dayOfWeek': dayOfWeek,
        'mealType': mealType,
        'items': items,
        'foodType': foodType,
        'specialNote': specialNote,
      };

  factory MessMenuItem.fromMap(Map<String, dynamic> map) => MessMenuItem(
        menuId: map['menuId'],
        dayOfWeek: map['dayOfWeek'],
        mealType: map['mealType'],
        items: map['items'],
        foodType: map['foodType'] ?? 'VEG',
        specialNote: map['specialNote'],
      );
}

class MessRepository extends ChangeNotifier {
  static final MessRepository instance = MessRepository._internal();
  MessRepository._internal() {
    _seedSynchronousDefaults();
    _loadFromDB();
  }

  final List<MessMenuItem> _menuItems = [];
  List<MessMenuItem> get menuItems => List.unmodifiable(_menuItems);

  void _seedSynchronousDefaults() {
    final sampleSchedule = [
      // Monday (Non-Veg Lunch)
      MessMenuItem(menuId: 'm1', dayOfWeek: 'Monday', mealType: 'Breakfast', items: 'Pongal, Medu Vadai, Coconut Chutney, Sambar, Tea, Milk', foodType: 'VEG'),
      MessMenuItem(menuId: 'm2', dayOfWeek: 'Monday', mealType: 'Lunch', items: 'Tamil Nadu Chettinad Chicken Gravy, Steamed Rice, Sambar, Rasam, Curd, Pappad', foodType: 'NON-VEG'),
      MessMenuItem(menuId: 'm3', dayOfWeek: 'Monday', mealType: 'Snacks', items: 'Tea, Milk, Onion Bajji', foodType: 'VEG'),
      MessMenuItem(menuId: 'm4', dayOfWeek: 'Monday', mealType: 'Dinner', items: 'Phulka, Paneer Butter Masala, Jeera Rice, Dal Fry', foodType: 'VEG'),

      // Tuesday (Non-Veg Dinner)
      MessMenuItem(menuId: 'm5', dayOfWeek: 'Tuesday', mealType: 'Breakfast', items: 'Masala Dosa, Tomato Chutney, Sambar, Tea, Milk', foodType: 'VEG'),
      MessMenuItem(menuId: 'm6', dayOfWeek: 'Tuesday', mealType: 'Lunch', items: 'Steamed Rice, Rajma Masala, Cabbage Poriyal, Rasam, Curd, Pickle', foodType: 'VEG'),
      MessMenuItem(menuId: 'm7', dayOfWeek: 'Tuesday', mealType: 'Snacks', items: 'Filter Coffee, Tea, Milk, Vegetable Samosa', foodType: 'VEG'),
      MessMenuItem(menuId: 'm8', dayOfWeek: 'Tuesday', mealType: 'Dinner', items: 'Parotta, Egg Curry, Plain Rice, Rasam, Curd', foodType: 'NON-VEG'),

      // Wednesday (Non-Veg Lunch)
      MessMenuItem(menuId: 'm9', dayOfWeek: 'Wednesday', mealType: 'Breakfast', items: 'Poori, Aloo Masala, Mint Chutney, Tea, Milk', foodType: 'VEG'),
      MessMenuItem(menuId: 'm10', dayOfWeek: 'Wednesday', mealType: 'Lunch', items: 'South Indian Fish Curry, Steamed Rice, Sambar, Rasam, Curd', foodType: 'NON-VEG'),
      MessMenuItem(menuId: 'm11', dayOfWeek: 'Wednesday', mealType: 'Snacks', items: 'Tea, Milk, Chana Sundal', foodType: 'VEG'),
      MessMenuItem(menuId: 'm12', dayOfWeek: 'Wednesday', mealType: 'Dinner', items: 'Chapati, Mushroom Matar Gravy, Veg Pulao, Dal Makhani', foodType: 'VEG'),

      // Thursday (Non-Veg Dinner)
      MessMenuItem(menuId: 'm13', dayOfWeek: 'Thursday', mealType: 'Breakfast', items: 'Uttapam, Peanut Chutney, Sambar, Tea, Milk', foodType: 'VEG'),
      MessMenuItem(menuId: 'm14', dayOfWeek: 'Thursday', mealType: 'Lunch', items: 'Tamil Nadu Veg Meals: Steamed Rice, Sambar, Kara Kuzhambu, Beans Poriyal, Rasam, Curd', foodType: 'VEG'),
      MessMenuItem(menuId: 'm15', dayOfWeek: 'Thursday', mealType: 'Snacks', items: 'Tea, Milk, Veg Puff / Biscuits', foodType: 'VEG'),
      MessMenuItem(menuId: 'm16', dayOfWeek: 'Thursday', mealType: 'Dinner', items: 'Chicken Pepper Fry & Chapati, Steamed Rice, Dal, Curd', foodType: 'NON-VEG'),

      // Friday (FULL VEG 100%)
      MessMenuItem(menuId: 'm17', dayOfWeek: 'Friday', mealType: 'Breakfast', items: 'Idli, Sambar, Coconut Chutney, Tea, Milk', foodType: 'VEG', specialNote: 'FULL VEG DAY'),
      MessMenuItem(menuId: 'm18', dayOfWeek: 'Friday', mealType: 'Lunch', items: 'Full Tamil Nadu Veg Meals: Rice, Sambar, Rasam, Vatha Kuzhambu, Potato Poriyal, Appalam, Curd', foodType: 'VEG', specialNote: 'FULL VEG DAY'),
      MessMenuItem(menuId: 'm19', dayOfWeek: 'Friday', mealType: 'Snacks', items: 'Tea, Milk, Medu Vada', foodType: 'VEG', specialNote: 'FULL VEG DAY'),
      MessMenuItem(menuId: 'm20', dayOfWeek: 'Friday', mealType: 'Dinner', items: 'Chapati, Kadai Paneer, Veg Fried Rice, Sweet Payasam', foodType: 'VEG', specialNote: 'FULL VEG DAY'),

      // Saturday (Non-Veg Lunch)
      MessMenuItem(menuId: 'm21', dayOfWeek: 'Saturday', mealType: 'Breakfast', items: 'Rava Upma, Coconut Chutney, Tea, Milk', foodType: 'VEG'),
      MessMenuItem(menuId: 'm22', dayOfWeek: 'Saturday', mealType: 'Lunch', items: 'Mutton / Chicken Gravy Meals, Steamed Rice, Rasam, Curd, Fryums', foodType: 'NON-VEG'),
      MessMenuItem(menuId: 'm23', dayOfWeek: 'Saturday', mealType: 'Snacks', items: 'Filter Coffee, Tea, Milk, Biscuits', foodType: 'VEG'),
      MessMenuItem(menuId: 'm24', dayOfWeek: 'Saturday', mealType: 'Dinner', items: 'Phulka, Shahi Paneer, Ghee Rice, Dal Tadka', foodType: 'VEG'),

      // Sunday (Non-Veg Special Lunch)
      MessMenuItem(menuId: 'm25', dayOfWeek: 'Sunday', mealType: 'Breakfast', items: 'Appam, Vegetable Stew, Tea, Milk', foodType: 'VEG'),
      MessMenuItem(menuId: 'm26', dayOfWeek: 'Sunday', mealType: 'Lunch', items: 'Tamil Nadu Special Chicken Biryani, Onion Raita, Boiled Egg, Gravy', foodType: 'NON-VEG', specialNote: 'Special Sunday Feast'),
      MessMenuItem(menuId: 'm27', dayOfWeek: 'Sunday', mealType: 'Snacks', items: 'Tea, Milk, Vegetable Cutlet', foodType: 'VEG'),
      MessMenuItem(menuId: 'm28', dayOfWeek: 'Sunday', mealType: 'Dinner', items: 'Chapati, Dal Tadka, Plain Rice, Gulab Jamun', foodType: 'VEG', specialNote: 'Special Sunday Sweet'),
    ];

    _menuItems.clear();
    _menuItems.addAll(sampleSchedule);
  }

  String getTodayName() {
    final weekday = DateTime.now().weekday;
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
      default:
        return 'Sunday';
    }
  }

  List<MessMenuItem> getMenuForDay(String day) {
    return _menuItems.where((m) => m.dayOfWeek.toLowerCase() == day.toLowerCase()).toList();
  }

  List<MessMenuItem> getTodaysMenu() {
    final today = getTodayName();
    var list = getMenuForDay(today);
    if (list.isEmpty) {
      list = getMenuForDay('Monday');
    }
    return list;
  }

  String? validateMenuRules(List<MessMenuItem> candidateItems) {
    // 1. Friday Rule: Must be 100% FULL VEG
    final fridayItems = candidateItems.where((m) => m.dayOfWeek.toLowerCase() == 'friday').toList();
    for (var m in fridayItems) {
      if (m.foodType == 'NON-VEG') {
        return 'Friday must be 100% FULL VEG. No non-vegetarian food allowed on Friday.';
      }
    }

    // 2. Mon, Tue, Wed, Thu, Sat, Sun Rule: Exactly ONE NON-VEG Main Meal (Breakfast, Lunch, or Dinner)
    final otherDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Saturday', 'Sunday'];
    for (var day in otherDays) {
      final dayMainMeals = candidateItems.where((m) => m.dayOfWeek.toLowerCase() == day.toLowerCase() && m.mealType != 'Snacks').toList();
      final nonVegCount = dayMainMeals.where((m) => m.foodType == 'NON-VEG').length;
      if (nonVegCount != 1) {
        return '$day must have exactly ONE non-vegetarian main meal (Breakfast, Lunch, or Dinner). Currently has $nonVegCount.';
      }

      final snack = candidateItems.firstWhere((m) => m.dayOfWeek.toLowerCase() == day.toLowerCase() && m.mealType == 'Snacks', orElse: () => candidateItems.first);
      if (snack.foodType == 'NON-VEG') {
        return 'Snacks on $day must be Vegetarian.';
      }
    }

    return null; // All rules satisfied!
  }

  Future<void> saveFullWeeklySchedule(List<MessMenuItem> updatedSchedule) async {
    final error = validateMenuRules(updatedSchedule);
    if (error != null) {
      throw error; // Prevents saving if rules are violated!
    }

    _menuItems.clear();
    _menuItems.addAll(updatedSchedule);

    try {
      final db = await HostelDatabase.instance.database;
      for (var item in updatedSchedule) {
        await db.insert('mess', item.toMap());
      }
    } catch (e) {
      debugPrint('Error saving weekly schedule: $e');
    }

    notifyListeners();
  }

  Future<void> _loadFromDB() async {
    try {
      final db = await HostelDatabase.instance.database;
      final maps = await db.query('mess');
      if (maps.isNotEmpty) {
        _menuItems.clear();
        for (var m in maps) {
          _menuItems.add(MessMenuItem.fromMap(m));
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading weekly mess menu: $e');
    }
  }

  Future<void> upsertMenu(MessMenuItem item) async {
    final idx = _menuItems.indexWhere((m) => m.mealType == item.mealType && m.dayOfWeek.toLowerCase() == item.dayOfWeek.toLowerCase());
    if (idx != -1) {
      _menuItems[idx] = item;
    } else {
      _menuItems.add(item);
    }
    try {
      await HostelDatabase.instance.insert('mess', item.toMap());
    } catch (e) {
      debugPrint('Error inserting mess menu into DB: $e');
    }
    notifyListeners();
  }
}
