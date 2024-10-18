import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watchgram/src/common/cubits/scaling.dart';
import 'package:watchgram/src/pages/chat/bloc/bloc.dart';
import 'package:watchgram/src/pages/chat/bloc/data.dart';
import 'package:visibility_detector/visibility_detector.dart';

class LoadMoreWidget extends StatefulWidget {
  const LoadMoreWidget({
    super.key,
    required this.data,
  });

  final ChatBlocLoadMore data;

  @override
  State<LoadMoreWidget> createState() => _LoadMoreWidgetState();
}

class _LoadMoreWidgetState extends State<LoadMoreWidget> {
  static DateTime cooldownExpiration = DateTime.now();
  bool _loadingRequested = false;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: UniqueKey(),
      onVisibilityChanged: (info) {
        if (_loadingRequested) return;
        if (info.visibleFraction < 0.01) return;
        if (cooldownExpiration.isAfter(DateTime.now())) return;

        _loadingRequested = true;
        context.read<ChatBloc>().add(ChatBlocLoadMoreEvent(
              widget.data,
              setCooldownExpirationDate: (date) => cooldownExpiration = date,
            ));
      },
      child: SizedBox(
        height: Scaling.screenSize.height / 2,
        child: const Center(
          child: SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
