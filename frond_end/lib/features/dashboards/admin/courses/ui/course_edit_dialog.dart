import 'package:flutter/material.dart';
import '../data/course_admin_models.dart';

class CourseEditDialog extends StatefulWidget {
  final AdminCourse? initial;
  const CourseEditDialog({super.key, this.initial});

  @override
  State<CourseEditDialog> createState() => _CourseEditDialogState();
}

class _CourseEditDialogState extends State<CourseEditDialog> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _code = TextEditingController();
  final _desc = TextEditingController();

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    if (i != null) {
      _title.text = i.title;
      _code.text = i.code ?? '';
      _desc.text = i.description ?? '';
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _code.dispose();
    _desc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? 'Create Course' : 'Edit Course'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _code,
                decoration: const InputDecoration(labelText: 'Code'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _desc,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (!_form.currentState!.validate()) return;
            final data = AdminCourse(
              id: widget.initial?.id ?? 0,
              title: _title.text.trim(),
              code: _code.text.trim().isEmpty ? null : _code.text.trim(),
              description: _desc.text.trim().isEmpty ? null : _desc.text.trim(),
              levelLabel: null,
              programLabel: null,
            );
            Navigator.pop(context, data);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
