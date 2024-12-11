import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ScalingListView extends StatefulWidget {
  const ScalingListView({
    super.key,
    required this.messages,
    required this.hasMore,
    this.onLoadMore,
  });

  final List<Map<String, dynamic>> messages;
  final bool hasMore;
  final Future<void> Function()? onLoadMore;

  @override
  State<ScalingListView> createState() => _ScalingListViewState();
}

class _ScalingListViewState extends State<ScalingListView> {
  MethodChannel? _viewChannel;
  bool _initialized = false;

  Future<void> _updateNativeView() async {
    try {
      if (!_initialized || _viewChannel == null) {
        debugPrint('ScalingListView: View not initialized yet, skipping update');
        return;
      }

      debugPrint('ScalingListView: Updating native view with ${widget.messages.length} messages, hasMore: ${widget.hasMore}');
      debugPrint('ScalingListView: First message: ${widget.messages.firstOrNull}');
      debugPrint('ScalingListView: Last message: ${widget.messages.lastOrNull}');
      
      await _viewChannel!.invokeMethod('updateMessages', {
        'messages': widget.messages,
        'hasMore': widget.hasMore,
      });
      debugPrint('ScalingListView: Native view updated successfully');
    } catch (e, stackTrace) {
      debugPrint('ScalingListView: Error updating native view: $e');
      debugPrint('ScalingListView: Stack trace: $stackTrace');
    }
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onLoadMore':
        debugPrint('ScalingListView: Load more requested from native side');
        if (widget.onLoadMore != null) {
          try {
            await widget.onLoadMore!();
            debugPrint('ScalingListView: Load more completed successfully');
          } catch (e) {
            debugPrint('ScalingListView: Error in load more: $e');
          }
        } else {
          debugPrint('ScalingListView: No onLoadMore callback provided');
        }
        break;
    }
  }

  @override
  void didUpdateWidget(ScalingListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.messages != widget.messages || oldWidget.hasMore != widget.hasMore) {
      debugPrint('ScalingListView: Messages or hasMore changed, updating native view');
      _updateNativeView();
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('ScalingListView: Building view');
    
    return SizedBox.expand(
      child: AndroidView(
        viewType: 'chat_list_view',
        onPlatformViewCreated: (id) {
          debugPrint('ScalingListView: Platform view created with id $id');
          _viewChannel = MethodChannel('chat_list_view_$id');
          _viewChannel!.setMethodCallHandler(_handleMethodCall);
          _initialized = true;
          _updateNativeView();
        },
        creationParams: <String, dynamic>{
          'messages': widget.messages,
          'hasMore': widget.hasMore,
        },
        creationParamsCodec: const StandardMessageCodec(),
      ),
    );
  }
}
