// lib/features/courses/ui/courses_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/dio_client.dart';
import '../data/course_repository.dart';
import '../models/course_meta_model.dart';

class CoursesPage extends StatefulWidget {
  final String? search;
  const CoursesPage({super.key, this.search});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  final _repo = CourseRepository();
  List<CourseMeta> items = [];
  bool loading = true;
  String? err;
  final _searchCtl = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    DioClient.instance.setupInterceptors();
    _searchCtl.text = widget.search ?? '';
    _searchCtl.addListener(_onSearchChanged);
    _fetch();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtl.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _fetch);
  }

  Future<void> _fetch() async {
    setState(() => loading = true);
    try {
      final list = await _repo.fetchCourses(search: _searchCtl.text.trim());
      setState(() {
        items = list.cast<CourseMeta>();
        err = null;
        loading = false;
      });
    } catch (e) {
      setState(() {
        err = '$e';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (err != null) {
      return Center(
        child: Text(err!, style: const TextStyle(color: Colors.red)),
      );
    }
    if (items.isEmpty) {
      return const Center(child: Text('No courses'));
    }

    final w = MediaQuery.of(context).size.width;
    final grid = w >= 1200
        ? 4
        : w >= 900
        ? 3
        : w >= 600
        ? 2
        : 1;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _searchCtl,
            decoration: const InputDecoration(
              hintText: 'Search courses',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: grid == 1
                ? ListView.separated(
                    itemBuilder: (_, i) => _tile(items[i], context),
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemCount: items.length,
                  )
                : GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: grid,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 4 / 3,
                    ),
                    itemCount: items.length,
                    itemBuilder: (_, i) => _card(items[i], context),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _tile(CourseMeta c, BuildContext ctx) => ListTile(
    title: Text(c.title),
    subtitle: Text(
      [
        if (c.code!.isNotEmpty) 'Code: ${c.code}',
        if ((c.paperNo ?? '').isNotEmpty) 'Paper: ${c.paperNo}',
        if ((c.levelLabel ?? '').isNotEmpty) 'Level: ${c.levelLabel}',
        if ((c.programLabel ?? '').isNotEmpty) 'Program: ${c.programLabel}',
      ].join(' • '),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    ),
    trailing: const Icon(Icons.chevron_right),
    onTap: () => ctx.go('/courses/${c.id}'),
  );

  Widget _card(CourseMeta c, BuildContext ctx) => Card(
    child: InkWell(
      onTap: () => ctx.go('/courses/${c.id}'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(c.title, style: Theme.of(ctx).textTheme.titleMedium),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                [
                  if (c.code!.isNotEmpty) 'Code: ${c.code}',
                  if ((c.paperNo ?? '').isNotEmpty) 'Paper: ${c.paperNo}',
                  if ((c.levelLabel ?? '').isNotEmpty) 'Level: ${c.levelLabel}',
                  if ((c.programLabel ?? '').isNotEmpty)
                    'Program: ${c.programLabel}',
                  if (c.description.isNotEmpty) c.description,
                ].join('\n'),
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: FilledButton.tonal(
                onPressed: () => ctx.go('/courses/${c.id}'),
                child: const Text('Open'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
