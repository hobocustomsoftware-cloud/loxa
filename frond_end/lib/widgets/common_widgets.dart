// lib/widgets/common_widgets.dart
import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  const Loading({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class ErrorText extends StatelessWidget {
  final String message;
  const ErrorText(this.message, {super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(color: Colors.red),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  const EmptyState({super.key, required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(subtitle, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
