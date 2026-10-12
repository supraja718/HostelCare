import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'mess_repository.dart';

class WeeklyMessMenuPage extends StatefulWidget {
  const WeeklyMessMenuPage({super.key});

  @override
  State<WeeklyMessMenuPage> createState() => _WeeklyMessMenuPageState();
}

class _WeeklyMessMenuPageState extends State<WeeklyMessMenuPage> {
  final List<String> _days = const [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  void _openEditDialog(BuildContext context) {
    String selectedDay = 'Monday';
    final breakfastController = TextEditingController();
    final lunchController = TextEditingController();
    final snacksController = TextEditingController();
    final dinnerController = TextEditingController();

    String breakfastType = 'VEG';
    String lunchType = 'NON-VEG';
    String snacksType = 'VEG';
    String dinnerType = 'VEG';

    void loadDayData(String day, StateSetter setDialogState) {
      final existing = MessRepository.instance.getMenuForDay(day);
      for (var m in existing) {
        if (m.mealType == 'Breakfast') {
          breakfastController.text = m.items;
          breakfastType = m.foodType;
        } else if (m.mealType == 'Lunch') {
          lunchController.text = m.items;
          lunchType = m.foodType;
        } else if (m.mealType == 'Snacks') {
          snacksController.text = m.items;
          snacksType = m.foodType;
        } else if (m.mealType == 'Dinner') {
          dinnerController.text = m.items;
          dinnerType = m.foodType;
        }
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final isFriday = selectedDay == 'Friday';

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Edit Weekly Mess Menu 🍽️', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                if (isFriday)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFF86EFAC))),
                    child: const Text('FULL VEG DAY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF15803D))),
                  ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select Day to Edit:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    initialValue: selectedDay,
                    items: _days.map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 13)))).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          selectedDay = val;
                          loadDayData(val, setDialogState);
                        });
                      }
                    },
                    decoration: InputDecoration(isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                  ),
                  const SizedBox(height: 14),

                  _buildMealField('Breakfast', breakfastController, breakfastType, isFriday, (val) => setDialogState(() => breakfastType = val!)),
                  const SizedBox(height: 10),
                  _buildMealField('Lunch', lunchController, lunchType, isFriday, (val) => setDialogState(() => lunchType = val!)),
                  const SizedBox(height: 10),
                  _buildMealField('Snacks', snacksController, snacksType, isFriday, (val) => setDialogState(() => snacksType = val!)),
                  const SizedBox(height: 10),
                  _buildMealField('Dinner', dinnerController, dinnerType, isFriday, (val) => setDialogState(() => dinnerType = val!)),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7)),
                onPressed: () {
                  try {
                    final fullSchedule = List<MessMenuItem>.from(MessRepository.instance.menuItems);

                    void updateOrReplace(String meal, String items, String fType) {
                      final idx = fullSchedule.indexWhere((m) => m.dayOfWeek.toLowerCase() == selectedDay.toLowerCase() && m.mealType == meal);
                      final item = MessMenuItem(
                        menuId: 'm_${selectedDay}_$meal',
                        dayOfWeek: selectedDay,
                        mealType: meal,
                        items: items.trim().isNotEmpty ? items.trim() : 'Scheduled Item',
                        foodType: isFriday ? 'VEG' : fType,
                        specialNote: isFriday ? 'FULL VEG DAY' : null,
                      );
                      if (idx != -1) {
                        fullSchedule[idx] = item;
                      } else {
                        fullSchedule.add(item);
                      }
                    }

                    updateOrReplace('Breakfast', breakfastController.text, breakfastType);
                    updateOrReplace('Lunch', lunchController.text, lunchType);
                    updateOrReplace('Snacks', snacksController.text, snacksType);
                    updateOrReplace('Dinner', dinnerController.text, dinnerType);

                    MessRepository.instance.saveFullWeeklySchedule(fullSchedule);

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Weekly menu updated for $selectedDay!'), backgroundColor: const Color(0xFF0284C7)));
                  } catch (err) {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: const Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Menu Rule Violation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                        content: Text(err.toString(), style: const TextStyle(fontSize: 13, height: 1.4)),
                        actions: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Understand & Fix', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    );
                  }
                },
                child: const Text('Validate & Save Schedule', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMealField(String label, TextEditingController controller, String currentType, bool isFriday, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$label Menu', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            if (!isFriday && label != 'Snacks')
              DropdownButton<String>(
                value: currentType,
                isDense: true,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: currentType == 'NON-VEG' ? Colors.red.shade700 : const Color(0xFF15803D)),
                items: ['VEG', 'NON-VEG'].map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type == 'NON-VEG' ? 'NON-VEG 🍗' : 'VEG 🌿'),
                  );
                }).toList(),
                onChanged: onChanged,
              )
            else
              Text(isFriday ? 'FULL VEG 🌿' : 'VEG 🌿', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF15803D))),
          ],
        ),
        const SizedBox(height: 4),
        TextField(controller: controller, decoration: InputDecoration(hintText: 'Enter $label items...', isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isManagement = AuthService.instance.currentUser?.role == 'Management' || AuthService.instance.currentUser?.role == 'Warden';

    return ListenableBuilder(
      listenable: MessRepository.instance,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F6F8),
          appBar: AppBar(
            title: const Text('Weekly Mess Schedule 🍽️', style: TextStyle(color: Color(0xFF14532D), fontWeight: FontWeight.bold, fontSize: 18)),
            backgroundColor: const Color(0xFFDCFCE7),
            elevation: 0,
            iconTheme: const IconThemeData(color: Color(0xFF15803D)),
            actions: [
              if (isManagement)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: const Color(0xFF15803D)),
                    onPressed: () => _openEditDialog(context),
                    icon: const Icon(Icons.edit_calendar, size: 18),
                    label: const Text('Edit Menu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
            ],
          ),
          body: SafeArea(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _days.length,
              itemBuilder: (context, dayIdx) {
                final day = _days[dayIdx];
                final dayMeals = MessRepository.instance.getMenuForDay(day);
                final isFriday = day == 'Friday';

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isFriday ? const Color(0xFF86EFAC) : const Color(0xFFE2E8F0), width: isFriday ? 1.5 : 1.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            day,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isFriday ? const Color(0xFFDCFCE7) : const Color(0xFFF0F9FF),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: isFriday ? const Color(0xFF86EFAC) : const Color(0xFFBAE6FD)),
                            ),
                            child: Text(
                              isFriday ? 'FULL VEG DAY 🌿' : '1 NON-VEG MEAL 🍗',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isFriday ? const Color(0xFF15803D) : const Color(0xFF0284C7)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Column(
                        children: dayMeals.map((meal) {
                          final isNonVeg = meal.foodType == 'NON-VEG';
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 85,
                                  child: Text(
                                    meal.mealType,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isNonVeg ? Colors.red.shade800 : const Color(0xFF15803D),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    meal.items,
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF334155), height: 1.3),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isNonVeg ? Colors.red.shade50 : const Color(0xFFDCFCE7),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: isNonVeg ? Colors.red.shade200 : const Color(0xFF86EFAC)),
                                  ),
                                  child: Text(
                                    isNonVeg ? 'NON-VEG 🍗' : 'VEG 🌿',
                                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isNonVeg ? Colors.red.shade700 : const Color(0xFF15803D)),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
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
