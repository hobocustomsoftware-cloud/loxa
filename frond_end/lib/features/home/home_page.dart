import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/api/dio_client.dart';
import '../courses/data/course_repository.dart';
import '../courses/models/course_summary_model.dart';
import '../../widgets/course_card.dart';

enum Category { university, basic, certification }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final repo = CourseRepository();
  late final TabController _tabs;
  final _searchCtl = TextEditingController();
  Timer? _debounce;

  List<CourseSummary> _items = [];
  bool _loading = true;
  String? _err;

  @override
  void initState() {
    super.initState();
    DioClient.instance.setupInterceptors();
    _tabs = TabController(length: 3, vsync: this);
    _tabs.addListener(_reload);
    _searchCtl.addListener(_onSearchChanged);
    _reload();
  }

  @override
  void dispose() {
    _tabs.dispose();
    _searchCtl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _reload);
  }

  int? _levelIdFor(Category c) {
    // Future mapping - right now null means fetch all
    return null;
  }

  Future<void> _reload() async {
    setState(() {
      _loading = true;
      _err = null;
    });

    try {
      final cat = Category.values[_tabs.index];
      final levelId = _levelIdFor(cat);
      final search = _searchCtl.text.trim();

      // Repo က Future<List<CourseSummary>> return ပေးရမယ်
      final courses = await repo.fetchCourses(levelId: levelId, search: search);

      // Client-side filter
      List<CourseSummary> filtered;
      switch (cat) {
        case Category.university:
          filtered = courses
              .where(
                (c) =>
                    (c.programLabel ?? '').toLowerCase().contains('university'),
              )
              .toList();
          break;
        case Category.basic:
          filtered = courses.where((c) {
            final p = (c.programLabel ?? '').toLowerCase();
            final l = (c.levelLabel ?? '').toLowerCase();
            return p.contains('basic') ||
                l.contains('grade') ||
                l.contains('kg');
          }).toList();
          break;
        case Category.certification:
          filtered = courses.where((c) {
            final t = (c.programLabel ?? '').toLowerCase();
            return t.contains('cert') ||
                t.contains('certificate') ||
                t.contains('certification');
          }).toList();
          break;
      }

      setState(() {
        _items = filtered;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _err = '$e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final cross = w >= 1280
        ? 4
        : w >= 960
        ? 3
        : w >= 640
        ? 2
        : 1;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.menu_book_outlined),
            SizedBox(width: 8),
            Text('Loxa'),
          ],
        ),
        actions: [
          TextButton(onPressed: () {}, child: const Text('Sign In')),
          const SizedBox(width: 12),
          FilledButton(onPressed: () {}, child: const Text('Register')),
          const SizedBox(width: 12),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(104),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchCtl,
                  decoration: InputDecoration(
                    hintText: 'Search courses',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: TabBar(
                  controller: _tabs,
                  isScrollable: true,
                  tabs: const [
                    Tab(text: 'University'),
                    Tab(text: 'Basic Education'),
                    Tab(text: 'Certification'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _err != null
          ? Center(
              child: Text(_err!, style: const TextStyle(color: Colors.red)),
            )
          : _items.isEmpty
          ? const Center(child: Text('No courses'))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cross,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 4 / 3,
                ),
                itemCount: _items.length,
                itemBuilder: (_, i) {
                  final c = _items[i];
                  return CourseCard(
                    course: c,
                    onTap: () => context.go('/courses/${c.id}'),
                  );
                },
              ),
            ),
    );
  }
}
