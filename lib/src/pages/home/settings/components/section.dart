import 'package:flutter/material.dart';
import 'package:watchgram/src/common/cubits/text.dart';
import 'package:watchgram/src/components/list/listview.dart';
import 'package:watchgram/src/components/scaled_sizes.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection(
    this.name, {
    super.key,
    this.color,
  });

  final String name;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return HandyListViewNoWrap(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Paddings.tilesHorizontalPadding,
        ),
        child: Text(
          name,
          style: TextStyles.active.labelLarge?.copyWith(color: color),
          textAlign: TextAlign.left,
        ),
      ),
    );
  }
}
