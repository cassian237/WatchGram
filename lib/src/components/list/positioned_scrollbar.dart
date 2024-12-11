import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:watchgram/src/common/cubits/colors.dart';

class PositionedScrollbar extends StatelessWidget {
  const PositionedScrollbar({
    super.key,
    required this.positionsListener,
    required this.itemCount,
    required this.child,
  });

  final ItemPositionsListener positionsListener;
  final int itemCount;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        ValueListenableBuilder<Iterable<ItemPosition>>(
          valueListenable: positionsListener.itemPositions,
          builder: (context, positions, _) {
            if (positions.isEmpty) return const SizedBox();
            
            final firstItem = positions.reduce((value, element) => 
              value.index < element.index ? value : element);
            final lastItem = positions.reduce((value, element) => 
              value.index > element.index ? value : element);
            
            final scrollProgress = firstItem.index / itemCount;
            
            return Positioned(
              right: 2,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  width: 2,
                  height: 40,
                  decoration: BoxDecoration(
                    color: ColorStyles.active.primary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(1),
                  ),
                  child: FractionallySizedBox(
                    heightFactor: 0.3,
                    alignment: Alignment.lerp(
                      Alignment.topCenter,
                      Alignment.bottomCenter,
                      scrollProgress,
                    ) ?? Alignment.center,
                    child: Container(
                      decoration: BoxDecoration(
                        color: ColorStyles.active.primary,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
