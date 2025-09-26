// lib/features/dashboards/admin/ui/pages/admin_dashboard_page.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 1200;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ShellRoute အပေါ်ဆုံးမှာ topbar/search ရှိပြီးသား হলে ဒီ title ကိုပဲထား
            Text('Dashboard', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const _KpisRow(),
                    const SizedBox(height: 16),
                    const _ChartsRow(),
                    const SizedBox(height: 16),
                    _TablesRow(isWide: isWide),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- KPIs ----------------

class _KpisRow extends StatelessWidget {
  const _KpisRow();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, c) {
        final isNarrow = c.maxWidth < 900;
        final grid = SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isNarrow ? 2 : 4,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 3.6,
        );
        return GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: grid,
          children: const [
            _KpiCard(
              icon: Icons.school_outlined,
              label: 'Total Students',
              valueText: '15,800+',
            ),
            _KpiCard(
              icon: Icons.menu_book_outlined,
              label: 'Total Courses',
              valueText: '350+',
            ),
            _KpiCard(
              icon: Icons.people_outline,
              label: 'Active Enrollments',
              valueText: '12,100+',
            ),
            _KpiCard(
              icon: Icons.attach_money,
              label: 'Monthly Revenue',
              valueText: '\$45,000+',
            ),
          ],
        );
      },
    );
  }
}

class _KpiCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String valueText;
  const _KpiCard({
    required this.icon,
    required this.label,
    required this.valueText,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: cs.primaryContainer,
              child: Icon(icon, color: cs.onPrimaryContainer),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 4),
                Text(
                  valueText,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --------------- Charts ----------------

class _ChartsRow extends StatelessWidget {
  const _ChartsRow();

  @override
  Widget build(BuildContext context) {
    final line = [12, 24, 20, 32, 48, 40, 60, 55, 70, 90, 120, 180];
    final bars = [
      ('Advanced Python', 5200),
      ('ML Basics', 4800),
      ('Web Dev Bootcamp', 3100),
      ('Data Science w/ R', 2500),
      ('Digital Marketing', 1900),
    ];

    return LayoutBuilder(
      builder: (_, c) {
        final narrow = c.maxWidth < 1100;
        return Flex(
          direction: narrow ? Axis.vertical : Axis.horizontal,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'New Enrollments (Last 30 Days)',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 180,
                        child: _TinyLineChart(values: line),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16, height: 16),
            Expanded(
              child: Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Popular Courses',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      _TinyBars(data: bars),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// --------------- Tables ----------------

class _TablesRow extends StatelessWidget {
  final bool isWide;
  const _TablesRow({required this.isWide});

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: isWide ? Axis.horizontal : Axis.vertical,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: const [
        Expanded(
          child: Card(
            elevation: 0,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: _RecentEnrollmentsTable(),
            ),
          ),
        ),
        SizedBox(width: 16, height: 16),
        Expanded(
          child: Card(
            elevation: 0,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: _RecentActivities(),
            ),
          ),
        ),
      ],
    );
  }
}

class _RecentEnrollmentsTable extends StatelessWidget {
  const _RecentEnrollmentsTable();

  @override
  Widget build(BuildContext context) {
    final rows = [
      ['Aung Aung', 'Web Dev Bootcamp', '2025-09-20', 'Paid'],
      ['Su Su', 'ML Basics', '2025-09-19', 'Paid'],
      ['Hla Hla', 'Advanced Python', '2025-09-17', 'Paid'],
      ['Kyaw Kayu', 'Data Science w/ R', '2025-09-16', 'Paid'],
      ['Myat Mon', 'Digital Marketing Pro', '2025-09-15', 'Paid'],
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Enrollments',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Student Name')),
              DataColumn(label: Text('Course')),
              DataColumn(label: Text('Date')),
              DataColumn(label: Text('Status')),
            ],
            rows: rows
                .map(
                  (r) => DataRow(
                    cells: [
                      DataCell(Text(r[0])),
                      DataCell(Text(r[1])),
                      DataCell(Text(r[2])),
                      const DataCell(
                        Text('Paid', style: TextStyle(color: Colors.green)),
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _RecentActivities extends StatelessWidget {
  const _RecentActivities();

  @override
  Widget build(BuildContext context) {
    final items = [
      'Instructor John Doe added a new session to “Advanced Python”.',
      'New student “Aung Aung” just registered.',
      'Payment of \$59 updated by Admin.',
      'Instructor Mary Smith added a quiz to “Marketing Pro”.',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activities',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ...items.map(
          (t) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.fiber_manual_record, size: 8),
                const SizedBox(width: 8),
                Expanded(child: Text(t)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// -------- Tiny charts (no external packages) --------

class _TinyLineChart extends StatelessWidget {
  final List<num> values;
  const _TinyLineChart({required this.values});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LinePainter(
        values.map((e) => e.toDouble()).toList(),
        Theme.of(context).colorScheme.primary,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _LinePainter extends CustomPainter {
  final List<double> values;
  final Color color;
  _LinePainter(this.values, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final maxV = values.reduce(math.max);
    final minV = values.reduce(math.min);
    final span = (maxV - minV).clamp(1, double.infinity);

    final path = Path();
    for (int i = 0; i < values.length; i++) {
      final x = i / (values.length - 1) * size.width;
      final y = size.height - ((values[i] - minV) / span) * size.height;
      if (i == 0)
        path.moveTo(x, y);
      else
        path.lineTo(x, y);
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke,
    );

    final fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      fill,
      Paint()
        ..color = color.withOpacity(0.10)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _LinePainter old) =>
      old.values != values || old.color != color;
}

class _TinyBars extends StatelessWidget {
  final List<(String, num)> data;
  const _TinyBars({required this.data});

  @override
  Widget build(BuildContext context) {
    final max = data.isEmpty
        ? 1.0
        : data.map((e) => e.$2).reduce(math.max).toDouble();
    return Column(
      children: data.map((e) {
        final pct = (e.$2.toDouble() / max).clamp(0.0, 1.0);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Expanded(child: Text(e.$1, overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 12),
              SizedBox(
                width: 200,
                height: 10,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black12.withOpacity(.06),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: pct, // ✅ FIX: 12 → pct
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text('${e.$2.toInt()}'),
            ],
          ),
        );
      }).toList(),
    );
  }
}
