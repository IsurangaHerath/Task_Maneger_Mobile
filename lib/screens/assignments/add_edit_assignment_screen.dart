import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/assignment_model.dart';
import '../../providers/assignment_provider.dart';

class AddEditAssignmentScreen extends ConsumerStatefulWidget {
  final AssignmentModel? assignment;

  const AddEditAssignmentScreen({super.key, this.assignment});

  @override
  ConsumerState<AddEditAssignmentScreen> createState() => _AddEditAssignmentScreenState();
}

class _AddEditAssignmentScreenState extends ConsumerState<AddEditAssignmentScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _courseController;
  late TextEditingController _descController;
  late TextEditingController _marksController;
  late TextEditingController _totalMarksController;

  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  int _priority = 1;
  bool _reminderEnabled = false;
  int _reminderMinutes = 30;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.assignment?.title ?? '');
    _courseController = TextEditingController(text: widget.assignment?.courseName ?? '');
    _descController = TextEditingController(text: widget.assignment?.description ?? '');
    _marksController = TextEditingController(text: widget.assignment?.marksObtained?.toString() ?? '');
    _totalMarksController = TextEditingController(text: widget.assignment?.totalMarks?.toString() ?? '');
    
    _dueDate = widget.assignment?.dueDate;
    if (widget.assignment?.dueTime != null && widget.assignment!.dueTime!.isNotEmpty) {
      final parts = widget.assignment!.dueTime!.split(':');
      if (parts.length == 2) {
        _dueTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
    }
    _priority = widget.assignment?.priority ?? 1;
    _reminderEnabled = widget.assignment?.reminderEnabled ?? false;
    _reminderMinutes = widget.assignment?.reminderMinutes ?? 30;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _courseController.dispose();
    _descController.dispose();
    _marksController.dispose();
    _totalMarksController.dispose();
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
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _dueTime = picked);
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      String? timeStr;
      if (_dueTime != null) {
        timeStr = '${_dueTime!.hour.toString().padLeft(2, '0')}:${_dueTime!.minute.toString().padLeft(2, '0')}';
      }

      double? totalMarks = double.tryParse(_totalMarksController.text);
      double? marksObtained = double.tryParse(_marksController.text);

      if (widget.assignment == null) {
        final newAssignment = AssignmentNotifier.createNew(
          title: _titleController.text.trim(),
          courseName: _courseController.text.trim(),
          description: _descController.text.trim(),
          dueDate: _dueDate,
          dueTime: timeStr,
          priority: _priority,
          totalMarks: totalMarks,
          reminderEnabled: _reminderEnabled,
          reminderMinutes: _reminderMinutes,
        );
        ref.read(assignmentProvider.notifier).addAssignment(newAssignment);
      } else {
        final updated = widget.assignment!.copyWith(
          title: _titleController.text.trim(),
          courseName: _courseController.text.trim(),
          description: _descController.text.trim(),
          dueDate: _dueDate,
          dueTime: timeStr,
          priority: _priority,
          marksObtained: marksObtained,
          totalMarks: totalMarks,
          reminderEnabled: _reminderEnabled,
          reminderMinutes: _reminderMinutes,
        );
        ref.read(assignmentProvider.notifier).updateAssignment(updated);
      }
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.assignment != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Assignment' : 'New Assignment'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () {
                ref.read(assignmentProvider.notifier).deleteAssignment(widget.assignment!.id);
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
              decoration: const InputDecoration(labelText: 'Assignment Title', prefixIcon: Icon(Icons.assignment)),
              validator: (v) => v == null || v.isEmpty ? 'Title is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _courseController,
              decoration: const InputDecoration(labelText: 'Course Name', prefixIcon: Icon(Icons.book)),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Description', prefixIcon: Icon(Icons.description), alignLabelWithHint: true),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _marksController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Marks Obtained'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _totalMarksController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Total Marks'),
                  ),
                ),
              ],
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
              value: _reminderEnabled,
              onChanged: (val) => setState(() => _reminderEnabled = val),
              secondary: const Icon(Icons.notifications_active_outlined),
            ),
            if (_reminderEnabled)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButtonFormField<int>(
                  value: _reminderMinutes,
                  decoration: const InputDecoration(labelText: 'Remind me'),
                  items: const [
                    DropdownMenuItem(value: 30, child: Text('30 minutes before')),
                    DropdownMenuItem(value: 1440, child: Text('1 day before')),
                    DropdownMenuItem(value: 2880, child: Text('2 days before')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _reminderMinutes = val);
                  },
                ),
              ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _save,
              child: Text(isEditing ? 'Update Assignment' : 'Save Assignment'),
            )
          ],
        ),
      ),
    );
  }
}
