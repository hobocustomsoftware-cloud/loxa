// features/courses/ui/course_detail_page.dart
import 'package:flutter/material.dart';
import '../../courses/data/course_repository.dart';
import '../../players/pdf_viewer_page.dart';
import '../../players/video_player_page.dart';
import '../models/course_meta_model.dart';
import '../models/course_tree_models.dart';

class CourseDetailPage extends StatefulWidget {
  final int id;
  const CourseDetailPage({super.key, required this.id, required int courseId});

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  final _repo = CourseRepository();
  CourseMeta? _meta;
  CourseTree? _tree;
  String? _err;
  bool _authNeeded = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _err = null;
      _authNeeded = false;
    });
    try {
      final meta = await _repo.fetchMeta(widget.id);
      final tree = await _repo.fetchTree(widget.id);
      setState(() {
        _meta = meta as CourseMeta?;
        _tree = tree as CourseTree?;
        _loading = false;
      });
    } on AuthRequiredException catch (e) {
      setState(() {
        _authNeeded = true;
        _err = e.toString();
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
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_authNeeded) {
      return Scaffold(
        appBar: AppBar(title: const Text('Sign in required')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_err ?? 'Authentication required'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () {
                  // TODO: navigate to your sign-in flow
                },
                child: const Text('Sign in'),
              ),
            ],
          ),
        ),
      );
    }
    if (_err != null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Text(_err!, style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    final meta = _meta!;
    final tree = _tree!;

    return Scaffold(
      appBar: AppBar(title: Text(meta.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (meta.description.isNotEmpty) Text(meta.description),
          const SizedBox(height: 8),
          if ((meta.programLabel ?? '').isNotEmpty)
            Text(
              meta.programLabel!,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          const SizedBox(height: 16),
          ...tree.modules.map((m) => _ModuleTile(m)).toList(),
        ],
      ),
    );
  }
}

class _ModuleTile extends StatelessWidget {
  final ModuleItem m;
  const _ModuleTile(this.m);

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(m.title),
      children: m.lessons.map((l) => _LessonTile(l)).toList(),
    );
  }
}

class _LessonTile extends StatelessWidget {
  final LessonItem l;
  const _LessonTile(this.l);

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(l.title),
      children: l.assets.map((a) {
        final locked = !a
            .isPreview; // preview မဟုတ်ရင် lock (enrollment လှမ်းပြီးပြင်ချင်ရင် အဲ့ဒီ logic ပြောင်း)
        final url = a.playableUrl;

        IconData icon;
        if (a.type == 'VIDEO' || a.type == 'RECORDING') {
          icon = Icons.play_circle;
        } else if (a.type == 'PDF') {
          icon = Icons.picture_as_pdf;
        } else {
          icon = Icons.insert_drive_file;
        }

        return ListTile(
          leading: Icon(icon),
          title: Text('${a.type} #${a.id}'),
          trailing: locked
              ? const Icon(Icons.lock)
              : const Icon(Icons.lock_open),
          onTap: (locked || url == null || url.isEmpty)
              ? null
              : () {
                  if (a.type == 'PDF') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PdfViewerPage(url: url),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VideoPlayerPage(url: url),
                      ),
                    );
                  }
                },
        );
      }).toList(),
    );
  }
}
