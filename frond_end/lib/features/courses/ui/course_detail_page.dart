// features/courses/ui/course_detail_page.dart
import 'package:flutter/material.dart';
import 'package:frond_end/features/courses/data/course_tree_repository.dart';
import 'package:frond_end/features/courses/models/course_tree_models.dart';
import 'package:go_router/go_router.dart';
import '../../players/pdf_viewer_page.dart';
import '../../players/video_player_page.dart';

class CourseDetailsPage extends StatefulWidget {
  final int id;
  const CourseDetailsPage({super.key, required this.id});

  @override
  State<CourseDetailsPage> createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends State<CourseDetailsPage> {
  late Future<CourseTree> _treeFuture;
  final _treeRepo = CourseTreeRepository();

  @override
  void initState() {
    super.initState();
    _treeFuture = _treeRepo.fetchTree(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Course Details")),
      body: FutureBuilder(
        future: _treeFuture,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            if (snap.error is AuthRequiredException) {
              return Center(
                child: FilledButton(
                  onPressed: () => context.go('/signin'),
                  child: const Text("Sign in required"),
                ),
              );
            }
            return Text('Error: ${snap.error}');
          }
          final tree = snap.data as CourseTree;
          return ListView(
            children: [
              Text(
                tree.title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              // modules / lessons / assets ထပ် loop ပြပါ
            ],
          );
        },
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
