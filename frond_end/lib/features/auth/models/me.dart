// lib/features/auth/models/me.dart

class Me {
  final int id;
  final String email;
  final bool isAdmin;
  final bool isModerator;
  final bool isEditor;
  final bool isStaff;
  final bool isSuperuser;
  final List<String> roles;

  Me({
    required this.id,
    required this.email,
    required this.isAdmin,
    required this.isModerator,
    required this.isEditor,
    required this.isStaff,
    required this.isSuperuser,
    required this.roles,
  });

  factory Me.fromJson(Map<String, dynamic> j) {
    // 1. ID Fix (ယခင်က ပြင်ခဲ့သည့်အတိုင်း)
    final int id = (j['id'] as num?)?.toInt() ?? 0;

    // 2. Boolean Fix (JSON ထဲက တန်ဖိုးကို null မဟုတ်ကြောင်း စစ်ဆေးပြီးမှ cast လုပ်ပါ)
    // Backend က တန်ဖိုးကို bool မဟုတ်ဘဲ 0/1 (num) နဲ့ ပို့နိုင်တဲ့အတွက် ပိုမိုလုံခြုံအောင် ညှိရပါမယ်။

    bool safeBool(dynamic value) {
      if (value == true || value == 1) return true;
      return false;
    }

    return Me(
      id: id,
      email: (j['email'] ?? '') as String,

      // 🚨 FIX: Boolean Fields အားလုံးကို safeBool function ဖြင့် စစ်ဆေးခြင်း
      isAdmin: safeBool(j['isAdmin'] ?? j['is_admin']),
      isModerator: safeBool(j['isModerator'] ?? j['is_moderator']),
      isEditor: safeBool(j['isEditor'] ?? j['is_editor']),
      isStaff: safeBool(j['isStaff'] ?? j['is_staff']),
      isSuperuser: safeBool(j['isSuperuser'] ?? j['is_superuser']),

      roles: (j['roles'] as List?)?.cast<String>() ?? const [],
    );
  }

  bool safeBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value > 0; // 1 ကို true အဖြစ် ယူဆ
    return false;
  }

  bool get isStudent => roles.contains('student');
  bool get isTeacher => roles.contains('teacher');
  bool get isParent => roles.contains('parent');
}
