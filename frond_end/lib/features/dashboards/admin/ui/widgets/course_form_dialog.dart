// lib/features/admin/ui/widgets/course_form_dialog.dart
import 'package:flutter/material.dart';
import '../../data/admin_courses_repository.dart';

class CourseFormDialog extends StatefulWidget {
  final AdminCourse? initial;
  const CourseFormDialog({super.key, this.initial});

  @override
  State<CourseFormDialog> createState() => _CourseFormDialogState();
}

class _CourseFormDialogState extends State<CourseFormDialog> {
  final _form = GlobalKey<FormState>();
  late TextEditingController _title;
  late TextEditingController _desc;
  late TextEditingController _code;
  late TextEditingController _paperNo;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.initial?.title ?? '');
    _desc = TextEditingController(text: widget.initial?.description ?? '');
    _code = TextEditingController(text: widget.initial?.code ?? '');
    _paperNo = TextEditingController(text: widget.initial?.paperNo ?? '');
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _code.dispose();
    _paperNo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;
    return AlertDialog(
      title: Text(isEdit ? 'Edit Course' : 'Create Course'),
      content: SizedBox(
        width: 480,
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
              TextFormField(
                controller: _desc,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              TextFormField(
                controller: _code,
                decoration: const InputDecoration(labelText: 'Code'),
              ),
              TextFormField(
                controller: _paperNo,
                decoration: const InputDecoration(labelText: 'Paper No'),
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
            final draft = AdminCourse(
              id: widget.initial?.id ?? 0,
              title: _title.text.trim(),
              description: _desc.text.trim(),
              code: _code.text.trim().isEmpty ? null : _code.text.trim(),
              paperNo: _paperNo.text.trim().isEmpty
                  ? null
                  : _paperNo.text.trim(),
              level: widget.initial?.level,
              org: widget.initial?.org,
              levelLabel: widget.initial?.levelLabel,
              programLabel: widget.initial?.programLabel,
            );
            Navigator.pop(context, draft);
          },
          child: Text(isEdit ? 'Save' : 'Create'),
        ),
      ],
    );
  }
}
