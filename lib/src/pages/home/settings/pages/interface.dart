import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:watchgram/generated/l10n.dart';
import 'package:watchgram/src/common/cubits/colors.dart';
import 'package:watchgram/src/common/cubits/scaling.dart';
import 'package:watchgram/src/common/cubits/text.dart';
import 'package:watchgram/src/common/settings/entries.dart';
import 'package:watchgram/src/common/settings/manager.dart';
import 'package:watchgram/src/components/controls/tile_button.dart';
import 'package:watchgram/src/components/list/listview.dart';
import 'package:watchgram/src/components/scaled_sizes.dart';
import 'package:watchgram/src/components/text/header.dart';
import 'package:watchgram/src/pages/home/settings/components/int_picker.dart';
import 'package:watchgram/src/pages/home/settings/components/section.dart';

class SettingsInterfaceView extends StatefulWidget {
  const SettingsInterfaceView({super.key});

  @override
  State<SettingsInterfaceView> createState() => _SettingsInterfaceViewState();
}

class _SettingsInterfaceViewState extends State<SettingsInterfaceView> {
  void _selectColor(int id) {
    ColorStyles.instance.accentColor = id;
    Settings().put(SettingsEntries.colorSchemeId, id);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final itemSize = size.shortestSide * 0.27 * Scaling.userFactor;

    return Scaffold(
      body: HandyListView(
        children: [
          PageHeader(title: AppLocalizations.current.interface),
          HandyListViewNoWrap(
            child: SettingsSection(AppLocalizations.current.colorScheme),
          ),
          SizedBox(height: Paddings.betweenSimilarElements),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final color in ColorStyles.accentColors) ...[
                  InkWell(
                    onTap: () => _selectColor(
                      ColorStyles.accentColors.indexOf(color),
                    ),
                    splashColor: Theme.of(context).splashColor,
                    borderRadius: BorderRadius.circular(999),
                    child: Ink(
                      width: itemSize,
                      height: itemSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.primary,
                      ),
                      child: (ColorStyles.active == color)
                          ? Center(
                              child: Icon(
                                Icons.done,
                                size: itemSize / 2,
                                color: color.onPrimary,
                              ),
                            )
                          : null,
                    ),
                  ),
                  if (ColorStyles.accentColors.indexOf(color) !=
                      ColorStyles.accentColors.length - 1)
                    SizedBox(width: 5 * Scaling.factor)
                ]
              ],
            ),
          ),
          SizedBox(height: Paddings.beforeSmallButton),
          HandyListViewNoWrap(
            child: SettingsSection(AppLocalizations.current.watchShape),
          ),
          SizedBox(height: Paddings.betweenSimilarElements),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Paddings.tilesHorizontalPadding,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(999),
                  splashColor: Theme.of(context).splashColor,
                  onTap: () => setState(() {
                    Settings().put(SettingsEntries.isRoundScreen, true);
                  }),
                  child: Ink(
                    width: itemSize,
                    height: itemSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Settings().get(SettingsEntries.isRoundScreen)!
                          ? ColorStyles.active.primary
                          : ColorStyles.active.surface,
                    ),
                    child: Settings().get(SettingsEntries.isRoundScreen)!
                        ? Center(
                            child: Icon(
                              Icons.done,
                              size: itemSize / 2,
                              color: ColorStyles.active.onPrimary,
                            ),
                          )
                        : null,
                  ),
                ),
                SizedBox(width: 10 * Scaling.factor),
                InkWell(
                  borderRadius: BorderRadius.circular(999),
                  splashColor: Theme.of(context).splashColor,
                  onTap: () => setState(() {
                    Settings().put(SettingsEntries.isRoundScreen, false);
                  }),
                  child: Ink(
                    width: itemSize,
                    height: itemSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(17),
                      color: !Settings().get(SettingsEntries.isRoundScreen)!
                          ? ColorStyles.active.primary
                          : ColorStyles.active.surface,
                    ),
                    child: !Settings().get(SettingsEntries.isRoundScreen)!
                        ? Center(
                            child: Icon(
                              Icons.done,
                              size: itemSize / 2,
                              color: ColorStyles.active.onPrimary,
                            ),
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: Paddings.beforeSmallButton),
          SettingsIntPicker(
            SettingsEntries.textScale,
            title: AppLocalizations.current.uiScale,
            step: 0.1,
            maxValue: 1.2,
            minValue: 0.8,
            onChanged: (scale) => TextStyles.instance.scale = scale,
          ),
          SizedBox(height: Paddings.beforeSmallButton),
          TileButton(
            text: AppLocalizations.current.doneButton,
            big: false,
            onTap: () => GoRouter.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
