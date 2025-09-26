import 'package:flutter/material.dart';
import '../../../core/ui/ui.dart';
import '../../courses/data/course_repository.dart';
import '../../courses/models/course_summary_model.dart';
import 'package:go_router/go_router.dart';

class CourseListPage extends StatefulWidget {
  const CourseListPage({super.key});

  @override
  State<CourseListPage> createState() => _CourseListPageState();
}

class _CourseListPageState extends State<CourseListPage> {
  final _repo = CourseRepository();
  final _searchCtl = TextEditingController();
  List<CourseSummary> _items = [];
  bool _loading = true;
  String? _err;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _err = null;
    });
    try {
      final res = await _repo.fetchCourses(search: _searchCtl.text.trim());
      setState(() {
        _items = res;
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sectionTitle(context, 'Catalog'),
          gap12,
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtl,
                  onSubmitted: (_) => _load(),
                  decoration: const InputDecoration(
                    hintText: 'Search courses',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton(onPressed: _load, child: const Text('Search')),
            ],
          ),
          gap16,
          if (_loading) const LinearProgressIndicator(),
          if (_err != null)
            Text(_err!, style: const TextStyle(color: Colors.red)),
          if (!_loading)
            Expanded(
              child: _items.isEmpty
                  ? const Center(child: Text('No courses'))
                  : GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cross,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 4 / 3,
                      ),
                      itemCount: _items.length,
                      itemBuilder: (_, i) {
                        final c = _items[i];
                        return _CourseCard(
                          title: c.title,
                          subtitle: c.programLabel ?? c.levelLabel ?? '',
                          onTap: () => context.go('/courses/${c.id}'),
                        );
                      },
                    ),
            ),
        ],
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _CourseCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.menu_book_outlined),
              const Spacer(),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
