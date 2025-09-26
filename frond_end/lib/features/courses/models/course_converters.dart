// lib/features/courses/models/course_converters.dart

import 'course_meta_model.dart';
import 'course_summary_model.dart';

/// Safe helper: accepts either CourseMeta or CourseSummary and returns Meta.
CourseMeta? toCourseMeta(Object? x) {
  if (x is CourseMeta) return x;
  if (x is CourseSummary) {
    // ⬇️ Summary → Meta mapping (field names ကို သင့် model နဲ့ကိုက်အောင် စစ်ပါ)
    return CourseMeta(
      id: x.id,
      title: x.title,
      description: x.description,
      programLabel: x.programLabel,
      levelLabel: x.levelLabel,
    );
  }
  return null;
}

/// (optional) convenience extension
extension CourseSummaryMapper on CourseSummary {
  CourseMeta toMeta() => CourseMeta(
    id: id,
    title: title,
    description: description,
    programLabel: programLabel,
    levelLabel: levelLabel,
  );
}
