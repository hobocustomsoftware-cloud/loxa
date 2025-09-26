import 'package:flutter/material.dart';
import '../data/course_admin_repository.dart';
import '../data/course_admin_models.dart';

class CourseAdminController extends ChangeNotifier {
  final repo = CourseAdminRepository();
  List<AdminCourse> items = [];
  bool loading = false;
  String? error;
  String search = '';

  Future<void> reload() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      items = await repo.list(search: search);
    } catch (e) {
      error = '$e';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> createOrUpdate(AdminCourse? existing, AdminCourse data) async {
    loading = true;
    notifyListeners();
    try {
      if (existing == null) {
        await repo.create(data);
      } else {
        await repo.update(existing.id, data);
      }
      await reload();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> remove(int id) async {
    loading = true;
    notifyListeners();
    try {
      await repo.delete(id);
      items.removeWhere((e) => e.id == id);
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
