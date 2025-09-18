// import 'package:flutter/material.dart';

// import '../models/course_model.dart';

// class CoursesHomePage extends StatefulWidget {
//   const CoursesHomePage({super.key});

//   @override
//   State<CoursesHomePage> createState() => _CoursesHomePageState();
// }

// class _CoursesHomePageState extends State<CoursesHomePage> {
//   CourseCategory _tab = CourseCategory.university;
//   AcademicYear? _year; // only for University
//   String _search = '';

//   // Responsive columns
//   int _cols(double w) {
//     if (w >= 1280) return 4;
//     if (w >= 980) return 3;
//     if (w >= 640) return 2;
//     return 1;
//   }

//   List<Course> _filteredAll() {
//     var list = demoCourses.where((c) {
//       if (_tab != c.category) return false;
//       if (_tab == CourseCategory.university &&
//           _year != null &&
//           c.year != _year) {
//         return false;
//       }
//       if (_search.isNotEmpty &&
//           !c.title.toLowerCase().contains(_search.toLowerCase())) {
//         return false;
//       }
//       return true;
//     }).toList();
//     return list;
//   }

//   List<Course> _liveNow() {
//     // show only “Live” inside current tab
//     final list = _filteredAll().where((c) => c.live).take(3).toList();
//     return list;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final w = MediaQuery.of(context).size.width;
//     final col = _cols(w);
//     final lives = _liveNow();
//     final all = _filteredAll();

//     return Scaffold(
//       appBar: AppBar(
//         titleSpacing: 16,
//         title: Row(
//           children: [
//             const Icon(Icons.menu_book_rounded, size: 28),
//             const SizedBox(width: 8),
//             const Text("Loxa"),
//           ],
//         ),
//         actions: [
//           TextButton(onPressed: () {}, child: const Text('Sign In')),
//           const SizedBox(width: 8),
//           FilledButton.tonal(onPressed: () {}, child: const Text('Register')),
//           const SizedBox(width: 12),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Search
//             TextField(
//               decoration: InputDecoration(
//                 hintText: 'Search courses',
//                 prefixIcon: const Icon(Icons.search),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               onChanged: (v) => setState(() => _search = v),
//             ),
//             const SizedBox(height: 16),

//             // Top category tabs
//             Wrap(
//               spacing: 10,
//               runSpacing: 10,
//               children: [
//                 _catChip('University', CourseCategory.university),
//                 _catChip('Basic Education', CourseCategory.basicEducation),
//                 _catChip('Certification', CourseCategory.certification),
//               ],
//             ),

//             // Sub-filter when University
//             if (_tab == CourseCategory.university) ...[
//               const SizedBox(height: 12),
//               Wrap(
//                 spacing: 8,
//                 children: [
//                   _yearChip('First Year', AcademicYear.first),
//                   _yearChip('Second Year', AcademicYear.second),
//                   _yearChip('Third Year', AcademicYear.third),
//                   _yearChip('Fourth Year', AcademicYear.fourth),
//                   ChoiceChip(
//                     label: const Text('All Years'),
//                     selected: _year == null,
//                     onSelected: (_) => setState(() => _year = null),
//                   ),
//                 ],
//               ),
//             ],

//             const SizedBox(height: 20),

//             // Live Now
//             if (lives.isNotEmpty) ...[
//               Text(
//                 'Live Now',
//                 style: Theme.of(
//                   context,
//                 ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
//               ),
//               const SizedBox(height: 12),
//               SizedBox(
//                 height: 170,
//                 child: ListView.separated(
//                   scrollDirection: Axis.horizontal,
//                   itemCount: lives.length,
//                   separatorBuilder: (_, __) => const SizedBox(width: 16),
//                   itemBuilder: (_, i) => SizedBox(
//                     width: 340,
//                     child: CourseCard(course: lives[i], dark: true),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 24),
//             ],

//             // All Courses
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'All Courses',
//                   style: Theme.of(
//                     context,
//                   ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
//                 ),
//                 TextButton(onPressed: () {}, child: const Text('View All')),
//               ],
//             ),
//             const SizedBox(height: 12),

//             if (all.isEmpty)
//               const _Empty()
//             else
//               GridView.builder(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 itemCount: all.length,
//                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: col,
//                   crossAxisSpacing: 16,
//                   mainAxisSpacing: 16,
//                   childAspectRatio: 4 / 3,
//                 ),
//                 itemBuilder: (_, i) => CourseCard(course: all[i]),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _catChip(String label, CourseCategory c) {
//     return ChoiceChip(
//       label: Text(label),
//       selected: _tab == c,
//       onSelected: (_) => setState(() {
//         _tab = c;
//         // reset sub-filter when leaving University
//         if (_tab != CourseCategory.university) _year = null;
//       }),
//     );
//   }

//   Widget _yearChip(String label, AcademicYear year) {
//     return ChoiceChip(
//       label: Text(label),
//       selected: _year == year,
//       onSelected: (_) => setState(() => _year = year),
//     );
//   }
// }

// class _Empty extends StatelessWidget {
//   const _Empty();

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 140,
//       alignment: Alignment.center,
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.black12),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: const Text('No courses to show'),
//     );
//   }
// }
