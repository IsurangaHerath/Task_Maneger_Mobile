import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';

class AddEditTaskScreen extends ConsumerStatefulWidget {
  final TaskModel? task;

  const AddEditTaskScreen({super.key, this.task});

  @override
  ConsumerState<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends ConsumerState<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _subjectController;

  int _priority = 1;
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  bool _reminderEnabled = false;
  int _reminderMinutes = 30;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descController = TextEditingController(text: widget.task?.description ?? '');
    _subjectController = TextEditingController(text: widget.task?.subject ?? '');
    _priority = widget.task?.priority ?? 1;
    _dueDate = widget.task?.dueDate;
    if (widget.task?.dueTime != null && widget.task!.dueTime!.isNotEmpty) {
      final parts = widget.task!.dueTime!.split(':');
      if (parts.length == 2) {
        _dueTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
    }
    _reminderEnabled = widget.task?.reminderEnabled ?? false;
    _reminderMinutes = widget.task?.reminderMinutes ?? 30;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _dueTime = picked;
      });
    }
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      String? timeStr;
      if (_dueTime != null) {
        timeStr = '${_dueTime!.hour.toString().padLeft(2, '0')}:${_dueTime!.minute.toString().padLeft(2, '0')}';
      }

      if (widget.task == null) {
        final newTask = TaskNotifier.createNew(
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          subject: _subjectController.text.trim(),
          priority: _priority,
          dueDate: _dueDate,
          dueTime: timeStr,
          reminderEnabled: _reminderEnabled,
          reminderMinutes: _reminderMinutes,
        );
        ref.read(taskProvider.notifier).addTask(newTask);
      } else {
        final updatedTask = widget.task!.copyWith(
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          subject: _subjectController.text.trim(),
          priority: _priority,
          dueDate: _dueDate,
          dueTime: timeStr,
          reminderEnabled: _reminderEnabled,
          reminderMinutes: _reminderMinutes,
        );
        ref.read(taskProvider.notifier).updateTask(updatedTask);
      }

      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Task' : 'New Task'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () {
                ref.read(taskProvider.notifier).deleteTask(widget.task!.id);
                context.pop();
              },
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Task Title',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Title is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _subjectController,
              decoration: const InputDecoration(
                labelText: 'Subject / Category',
                prefixIcon: Icon(Icons.category_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description_outlined),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            const Text('Priority', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('Low')),
                ButtonSegment(value: 1, label: Text('Medium')),
                ButtonSegment(value: 2, label: Text('High')),
              ],
              selected: {_priority},
              onSelectionChanged: (set) {
                setState(() {
                  _priority = set.first;
                });
              },
            ),
            const SizedBox(height: 24),
            const Text('Due Date & Time', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _selectDate,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(_dueDate == null ? 'Set Date' : DateFormat.yMMMd().format(_dueDate!)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _selectTime,
                    icon: const Icon(Icons.access_time),
                    label: Text(_dueTime == null ? 'Set Time' : _dueTime!.format(context)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              title: const Text('Reminder'),
              subtitle: const Text('Notify me before due time'),
              value: _reminderEnabled,
              onChanged: (val) {
                setState(() => _reminderEnabled = val);
              },
              secondary: const Icon(Icons.notifications_active_outlined),
            ),
            if (_reminderEnabled)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButtonFormField<int>(
                  value: _reminderMinutes,
                  decoration: const InputDecoration(labelText: 'Remind me'),
                  items: const [
                    DropdownMenuItem(value: 5, child: Text('5 minutes before')),
                    DropdownMenuItem(value: 30, child: Text('30 minutes before')),
                    DropdownMenuItem(value: 60, child: Text('1 hour before')),
                    DropdownMenuItem(value: 1440, child: Text('1 day before')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _reminderMinutes = val);
                    }
                  },
                ),
              ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveTask,
              child: Text(isEditing ? 'Update Task' : 'Save Task'),
            )
          ],
        ),
      ),
    );
  }
}
