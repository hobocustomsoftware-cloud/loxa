import 'package:flutter/material.dart';

const gap4 = SizedBox(height: 4);
const gap8 = SizedBox(height: 8);
const gap12 = SizedBox(height: 12);
const gap16 = SizedBox(height: 16);
const gap24 = SizedBox(height: 24);
const gap32 = SizedBox(height: 32);

Widget sectionTitle(BuildContext context, String text) => Text(
  text,
  style: Theme.of(
    context,
  ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
);
