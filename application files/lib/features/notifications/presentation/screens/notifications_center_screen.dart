import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/notifications_provider.dart';

class NotificationsCenterScreen extends ConsumerStatefulWidget {
  const NotificationsCenterScreen({super.key});

  @override
  ConsumerState<NotificationsCenterScreen> createState() => _NotificationsCenterScreenState();
}

class _NotificationsCenterScreenState extends ConsumerState<NotificationsCenterScreen> {
  String _selectedFilter = 'ALL';

  @override
  Widget build(BuildContext context) {
    final notifState = ref.watch(notificationsNotifierProvider);

    final filteredList = notifState.notifications.where((n) {
      if (_selectedFilter == 'ALL') return true;
      return n.type == _selectedFilter;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Notifications & Reminders',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          if (notifState.unreadCount > 0)
            TextButton.icon(
              onPressed: () {
                ref.read(notificationsNotifierProvider.notifier).markAllAsRead();
              },
              icon: const Icon(Icons.done_all_rounded, size: 18, color: Color(0xFF4F46E5)),
              label: const Text(
                'Mark Read',
                style: TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF4F46E5),
        icon: const Icon(Icons.add_alarm_rounded, color: Colors.white),
        label: const Text('Add Reminder', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () => _showAddReminderBottomSheet(context),
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: notifState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredList.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () =>
                            ref.read(notificationsNotifierProvider.notifier).loadNotifications(),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) {
                            final item = filteredList[index];
                            return _buildNotificationCard(item);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      {'label': 'All', 'value': 'ALL'},
      {'label': 'Expiries', 'value': 'EXPIRY_WARNING'},
      {'label': 'Dues', 'value': 'DUE_PAYMENT'},
      {'label': 'Smart Sync', 'value': 'SMART_SYNC'},
      {'label': 'Custom', 'value': 'CUSTOM'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: filters.map((f) {
          final isSelected = _selectedFilter == f['value'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(f['label']!),
              selected: isSelected,
              selectedColor: const Color(0xFF4F46E5),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: Colors.white,
              onSelected: (_) {
                setState(() {
                  _selectedFilter = f['value']!;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNotificationCard(dynamic item) {
    final IconData iconData;
    final Color iconColor;

    switch (item.type) {
      case 'EXPIRY_WARNING':
        iconData = Icons.warning_amber_rounded;
        iconColor = Colors.orange;
        break;
      case 'DUE_PAYMENT':
        iconData = Icons.payment_rounded;
        iconColor = Colors.redAccent;
        break;
      case 'SMART_SYNC':
        iconData = Icons.sync_rounded;
        iconColor = Colors.blueAccent;
        break;
      default:
        iconData = Icons.notifications_active_rounded;
        iconColor = const Color(0xFF4F46E5);
    }

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        ref.read(notificationsNotifierProvider.notifier).dismiss(item.id);
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: item.isRead ? Colors.transparent : const Color(0xFF818CF8).withOpacity(0.4),
            width: item.isRead ? 0 : 1.5,
          ),
        ),
        color: item.isRead ? Colors.white : const Color(0xFFEEF2FF),
        child: ListTile(
          onTap: () {
            if (!item.isRead) {
              ref.read(notificationsNotifierProvider.notifier).markAsRead(item.id);
            }
          },
          leading: CircleAvatar(
            backgroundColor: iconColor.withOpacity(0.12),
            child: Icon(iconData, color: iconColor, size: 22),
          ),
          title: Text(
            item.title,
            style: TextStyle(
              fontWeight: item.isRead ? FontWeight.w600 : FontWeight.bold,
              fontSize: 15,
              color: const Color(0xFF0F172A),
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                item.body,
                style: TextStyle(color: Colors.black.withOpacity(0.7), fontSize: 13),
              ),
              const SizedBox(height: 6),
              Text(
                DateFormat('MMM dd, yyyy • hh:mm a').format(item.createdAt),
                style: TextStyle(color: Colors.black.withOpacity(0.45), fontSize: 11),
              ),
            ],
          ),
          trailing: !item.isRead
              ? Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4F46E5),
                    shape: BoxShape.circle,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.notifications_none_rounded, size: 64, color: Colors.black26),
          SizedBox(height: 16),
          Text(
            'All caught up!',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
          ),
          SizedBox(height: 6),
          Text(
            'No notifications or active alerts found.',
            style: TextStyle(color: Colors.black54, fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _showAddReminderBottomSheet(BuildContext context) {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    DateTime? selectedDate;
    String selectedType = 'DUE_PAYMENT';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Add Custom Reminder',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Reminder Title',
                      hintText: 'e.g. City Bank Loan Installment',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: bodyController,
                    decoration: InputDecoration(
                      labelText: 'Details / Amount',
                      hintText: 'e.g. Tk 5,000 due by 25th of month',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'DUE_PAYMENT', child: Text('Due Payment / Installment')),
                      DropdownMenuItem(value: 'EXPIRY_WARNING', child: Text('Document / Pass Expiry')),
                      DropdownMenuItem(value: 'CUSTOM', child: Text('Custom Note')),
                    ],
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedType = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade400),
                    ),
                    leading: const Icon(Icons.calendar_today_rounded, color: Color(0xFF4F46E5)),
                    title: Text(
                      selectedDate == null
                          ? 'Select Due Date (Optional)'
                          : 'Due: ${DateFormat('MMM dd, yyyy').format(selectedDate!)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 1)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setModalState(() => selectedDate = picked);
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        if (titleController.text.trim().isEmpty) return;
                        await ref
                            .read(notificationsNotifierProvider.notifier)
                            .createCustomReminder(
                              title: titleController.text.trim(),
                              body: bodyController.text.trim(),
                              type: selectedType,
                              scheduledFor: selectedDate,
                            );
                        if (mounted) Navigator.pop(context);
                      },
                      child: const Text(
                        'Save Reminder',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
