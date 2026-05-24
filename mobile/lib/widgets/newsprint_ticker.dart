import 'package:flutter/material.dart';

import '../theme/newsprint_theme.dart';

class NewsprintTicker extends StatelessWidget {
  const NewsprintTicker({super.key, required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: NewsprintColors.ink,
        border: Border.symmetric(
          horizontal: BorderSide(color: NewsprintColors.ink),
        ),
      ),
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemBuilder: (context, index) {
          return Center(
            child: Text(
              items[index].toUpperCase(),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: NewsprintColors.background,
              ),
            ),
          );
        },
        separatorBuilder: (context, index) => const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'LIVE DESK',
              style: TextStyle(
                color: NewsprintColors.accent,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
        itemCount: items.length,
      ),
    );
  }
}
