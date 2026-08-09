import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/exam_model.dart';
import '../../providers/exam_provider.dart';

class AddEditExamScreen extends ConsumerStatefulWidget {
  final ExamModel? exam;

  const AddEditExamScreen({super.key, this.exam});

  @override
  ConsumerState<AddEditExamScreen> createState() => _AddEditExamScreenState();
}

class _AddEditExamScreenState extends ConsumerState<AddEditExamScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _subjectController;
  late TextEditingController _venueController;
  late TextEditingController _notesController;

  String _examType = 'Final';
  DateTime? _date;
  TimeOfDay? _time;
  bool _reminderEnabled = false;
  int _reminderMinutes = 1440;

  @override
  void initState() {
    super.initState();
    _subjectController = TextEditingController(text: widget.exam?.subject ?? '');
    _venueController = TextEditingController(text: widget.exam?.venue ?? '');
    _notesController = TextEditingController(text: widget.exam?.notes ?? '');
    
    _examType = widget.exam?.examType ?? 'Final';
    _date = widget.exam?.date;
    if (widget.exam?.time != null && widget.exam!.time!.isNotEmpty) {
      final parts = widget.exam!.time!.split(':');
      if (parts.length == 2) {
        _time = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
    }
    _reminderEnabled = widget.exam?.reminderEnabled ?? false;
    _reminderMinutes = widget.exam?.reminderMinutes ?? 1440;
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _venueController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _time = picked);
    }
  }

  void _save() {
    if (_formKey.currentState!.validate() && _date != null) {
      String? timeStr;
      if (_time != null) {
        timeStr = '${_time!.hour.toString().padLeft(2, '0')}:${_time!.minute.toString().padLeft(2, '0')}';
      }

      if (widget.exam == null) {
        final newExam = ExamNotifier.createNew(
          subject: _subjectController.text.trim(),
          examType: _examType,
          date: _date!,
          time: timeStr,
          venue: _venueController.text.trim(),
          notes: _notesController.text.trim(),
          reminderEnabled: _reminderEnabled,
          reminderMinutes: _reminderMinutes,
        );
        ref.read(examProvider.notifier).addExam(newExam);
      } else {
        final updated = widget.exam!.copyWith(
          subject: _subjectController.text.trim(),
          examType: _examType,
          date: _date,
          time: timeStr,
          venue: _venueController.text.trim(),
          notes: _notesController.text.trim(),
          reminderEnabled: _reminderEnabled,
          reminderMinutes: _reminderMinutes,
        );
        ref.read(examProvider.notifier).updateExam(updated);
      }
      context.pop();
    } else if (_date == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an exam date')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.exam != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Exam' : 'New Exam'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () {
                ref.read(examProvider.notifier).deleteExam(widget.exam!.id);
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
              controller: _subjectController,
              decoration: const InputDecoration(labelText: 'Subject Name', prefixIcon: Icon(Icons.school)),
              validator: (v) => v == null || v.isEmpty ? 'Subject is required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _examType,
              decoration: const InputDecoration(labelText: 'Exam Type', prefixIcon: Icon(Icons.category)),
              items: ExamModel.examTypes.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _examType = val);
              },
            ),
            const SizedBox(height: 24),
            const Text('Date & Time', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _selectDate,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(_date == null ? 'Set Date' : DateFormat.yMMMd().format(_date!)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _selectTime,
                    icon: const Icon(Icons.access_time),
                    label: Text(_time == null ? 'Set Time' : _time!.format(context)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _venueController,
              decoration: const InputDecoration(labelText: 'Venue / Location', prefixIcon: Icon(Icons.location_on)),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Notes / Topics', prefixIcon: Icon(Icons.notes), alignLabelWithHint: true),
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
                    DropdownMenuItem(value: 60, child: Text('1 hour before')),
                    DropdownMenuItem(value: 1440, child: Text('1 day before')),
                    DropdownMenuItem(value: 4320, child: Text('3 days before')),
                    DropdownMenuItem(value: 10080, child: Text('1 week before')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _reminderMinutes = val);
                  },
                ),
              ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _save,
              child: Text(isEditing ? 'Update Exam' : 'Save Exam'),
            )
          ],
        ),
      ),
    );
  }
}
