import 'package:flutter/material.dart';

class ScalingListView extends StatefulWidget {
  final ScrollController? controller;
  final bool reverse;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final EdgeInsetsGeometry? padding;
  final int? itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double minScale;
  final double maxScale;

  const ScalingListView({
    super.key,
    this.controller,
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
  late final ScrollController _effectiveController;
  static const double _baseSpacing = 0.0;

  @override
  void initState() {
    super.initState();
    _effectiveController = widget.controller ?? ScrollController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _effectiveController.dispose();
    }
    super.dispose();
  }

  double _calculateScale(double itemPosition, double itemHeight, double viewportHeight) {
    final viewportMiddle = viewportHeight / 2;
    final itemMiddle = itemPosition + (itemHeight / 2);
    final distanceFromCenter = (itemMiddle - viewportMiddle).abs();
    final maxDistance = viewportHeight / 3;
    final distanceRatio = (distanceFromCenter / maxDistance).clamp(0.0, 1.0);
    
    return widget.maxScale - ((widget.maxScale - widget.minScale) * distanceRatio);
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification) {
          setState(() {});
        }
        return false;
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ListView.builder(
            controller: _effectiveController,
            reverse: widget.reverse,
            physics: widget.physics,
            shrinkWrap: widget.shrinkWrap,
            padding: widget.padding,
            itemCount: widget.itemCount,
            itemBuilder: (context, index) {
              return Builder(
                builder: (context) {
                  final box = context.findRenderObject() as RenderBox?;
                  double scale = widget.maxScale;
                  
                  if (box != null && box.hasSize) {
                    final itemPos = box.localToGlobal(Offset.zero).dy;
                    scale = _calculateScale(itemPos, box.size.height, constraints.maxHeight);
                  }

                  final scaleDiff = widget.maxScale - scale;
                  final spacing = _baseSpacing * (1 - scaleDiff);
                  
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: spacing / 2),
                    child: Transform(
                      transform: Matrix4.identity()
                        ..scale(scale)
                        ..translate(
                          0.0,
                          widget.reverse ? 
                            -(box?.size.height ?? 0.0) * (scale - 1.0) / 2.0 :
                            (box?.size.height ?? 0.0) * (scale - 1.0) / 2.0,
                        ),
                      alignment: Alignment.center,
                      child: widget.itemBuilder(context, index),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
