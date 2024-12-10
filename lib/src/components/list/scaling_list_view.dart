import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ScalingListView extends StatefulWidget {
  final ItemScrollController? controller;
  final ItemPositionsListener? positionsListener;
  final bool reverse;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final EdgeInsets? padding;
  final int? itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double minScale;
  final double maxScale;

  const ScalingListView({
    super.key,
    this.controller,
    this.positionsListener,
    this.reverse = false,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.itemCount,
    required this.itemBuilder,
    this.minScale = 0.8,
    this.maxScale = 1.0,
  });

  @override
  State<ScalingListView> createState() => _ScalingListViewState();
}

class _ScalingListViewState extends State<ScalingListView> {
  final ItemScrollController _effectiveController = ItemScrollController();
  final ItemPositionsListener _effectivePositionsListener = ItemPositionsListener.create();

  ItemPositionsListener get _positionsListener => 
      widget.positionsListener ?? _effectivePositionsListener;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ScrollablePositionedList.builder(
          itemScrollController: widget.controller ?? _effectiveController,
          itemPositionsListener: _positionsListener,
          reverse: widget.reverse,
          physics: widget.physics,
          shrinkWrap: widget.shrinkWrap,
          padding: widget.padding,
          itemCount: widget.itemCount ?? 0,
          itemBuilder: (context, index) {
            return ValueListenableBuilder<Iterable<ItemPosition>>(
              valueListenable: _positionsListener.itemPositions,
              builder: (context, positions, child) {
                double scale = widget.maxScale;
                
                if (positions.isNotEmpty) {
                  final viewportHeight = constraints.maxHeight;
                  final viewportMiddle = viewportHeight / 2;
                  
                  final itemPosition = positions.where((pos) => pos.index == index).firstOrNull;
                  if (itemPosition != null) {
                    final itemTop = itemPosition.itemLeadingEdge * viewportHeight;
                    final itemBottom = itemPosition.itemTrailingEdge * viewportHeight;
                    final itemMiddle = (itemTop + itemBottom) / 2;
                    
                    final distanceFromCenter = (itemMiddle - viewportMiddle).abs();
                    final maxDistance = viewportHeight / 3;
                    final distanceRatio = (distanceFromCenter / maxDistance).clamp(0.0, 1.0);
                    
                    scale = widget.maxScale - ((widget.maxScale - widget.minScale) * distanceRatio);
                  }
                }

                return Transform(
                  transform: Matrix4.identity()..scale(scale),
                  alignment: Alignment.center,
                  child: widget.itemBuilder(context, index),
                );
              },
            );
          },
        );
      },
    );
  }
}
