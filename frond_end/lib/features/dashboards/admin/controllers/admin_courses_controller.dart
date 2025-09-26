// lib/features/admin/controllers/admin_courses_controller.dart
import 'package:flutter/material.dart';
import '../data/admin_courses_repository.dart';

class AdminCoursesController extends ChangeNotifier {
  final AdminCoursesRepository _repo;
  AdminCoursesController(this._repo);

  bool loading = false;
  String? error;
  List<AdminCourse> items = [];
  int total = 0;
  int page = 1;
  int pageSize = 20;
  String search = '';

  Future<void> load({int? toPage}) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      if (toPage != null) page = toPage;
      final paged = await _repo.list(
        search: search,
        page: page,
        pageSize: pageSize,
      );
      items = paged.results;
      total = paged.count;
    } catch (e) {
      error = '$e';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> create(AdminCourse draft) async {
    try {
      final created = await _repo.create(draft);
      items.insert(0, created); // optimistic
      total += 1;
      notifyListeners();
      return true;
    } catch (e) {
      error = '$e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> update(AdminCourse draft) async {
    try {
      final u = await _repo.update(draft.id, draft);
      final idx = items.indexWhere((x) => x.id == u.id);
      if (idx >= 0) items[idx] = u;
      notifyListeners();
      return true;
    } catch (e) {
      error = '$e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> delete(int id) async {
    try {
      await _repo.remove(id);
      items.removeWhere((x) => x.id == id);
      total = total > 0 ? total - 1 : 0;
      notifyListeners();
      return true;
    } catch (e) {
      error = '$e';
      notifyListeners();
      return false;
    }
  }
}
