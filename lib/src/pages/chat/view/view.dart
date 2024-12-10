import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watchgram/src/common/cubits/scaling.dart';
import 'package:watchgram/src/common/settings/entries.dart';
import 'package:watchgram/src/common/settings/manager.dart';
import 'package:watchgram/src/common/tdlib/misc/service_chat_type.dart';
import 'package:mutex/mutex.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'package:watchgram/src/common/cubits/colors.dart';
import 'package:watchgram/src/common/cubits/text.dart';
import 'package:watchgram/src/common/exceptions/ui_exception.dart';
import 'package:watchgram/src/common/log/log.dart';
import 'package:watchgram/src/common/misc/localizations.dart';
import 'package:watchgram/src/components/list/positioned_scrollbar.dart';
import 'package:watchgram/src/components/overlays/notice/notice.dart';
import 'package:watchgram/src/components/scaled_sizes.dart';
import 'package:watchgram/src/components/list/scaling_list_view.dart';

import 'package:watchgram/src/pages/chat/bloc/bloc.dart';
import 'package:watchgram/src/pages/chat/bloc/data.dart';
import 'package:watchgram/src/pages/chat/view/widgets/chat_scroll_observer.dart';
import 'package:watchgram/src/pages/chat/view/widgets/focus_data.dart';
import 'package:watchgram/src/pages/chat/view/widgets/loading_more.dart';
import 'package:watchgram/src/pages/chat/view/widgets/message_focusable.dart';
import 'package:watchgram/src/pages/chat/view/widgets/header.dart';

import 'package:watchgram/src/common/tdlib/extensions/chats/misc.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> with WidgetsBindingObserver {
  static const String tag = "ChatView";

  StreamSubscription? _focusNewMessages,
      _focusMessages,
      _msgSubcription,
      _focusRequested;
  final _scrollController = ItemScrollController();
  final _scrollPositionsListener = ItemPositionsListener.create();
  late final _chatObserver = ChatScrollObserver(_scrollPositionsListener)
    ..fixedPositionOffset = 5
    ..toRebuildScrollViewCallback = () => setState(() {});

  final _focusLock = Mutex();
  bool _initFinished = false;
  final List<ChatBlocContainer> _containers = [];
  late ChatBloc bloc;

  final _errorsQueue = StreamController<String>();

  Stream<BaseNotice?> get _errors async* {
    await for (final error in _errorsQueue.stream) {
      yield StringNotice(error, color: ColorStyles.active.onError);
      await Future.delayed(const Duration(seconds: 5));
      yield null;
    }
  }

  Future<void> _focus(ChatBlocFocusData data) async {
    final id = data.focusOnMessageId;
    l.i(tag, "Focus requested on $id");

    if (!mounted || _scrollController.isAttached == false) {
      l.w(tag, "Scroll controller not ready for focusing");
      if (data.mustFocusInstantly) {
        setState(() {
          _initFinished = true;
        });
      }
      return;
    }

    final index = _containers.indexWhere((e) => switch (e) {
          ChatBlocMessageId(id: final mid) => mid == id,
          _ => false,
        });
    if (index == -1) {
      l.e(tag, "Couldn't find message id $id");
      _errorsQueue.add(
        AppLocalizations.current.chatViewMessageNotFoundError(id),
      );
      if (data.mustFocusInstantly) {
        setState(() {
          _initFinished = true;
        });
      }
      return;
    }

    try {
      await _focusLock.protect(() async {
        if (!mounted) return;
        
        final duration = data.mustFocusInstantly 
            ? const Duration(milliseconds: 10)  // Slightly longer duration for instant scroll
            : const Duration(milliseconds: 300);
            
        await _scrollController.scrollTo(
          index: index + 1,
          duration: duration,
        );
        
        if (data.mustFocusInstantly) {
          setState(() {
            _initFinished = true;
          });
        }
      });
    } catch (e) {
      l.e(tag, "Error during focus scroll: $e");
      if (data.mustFocusInstantly) {
        setState(() {
          _initFinished = true;
        });
      }
    }
  }

  void _onBlocUpdate(final ChatBlocStreamedData update) async {
    if (!mounted) return;

    switch (update) {
      case ChatBlocMessageContentUpdated():
        // Message content updated, no need to handle for scaling list
        break;
        
      case ChatBlocMessagesListData(
        containers: final containers,
        focusData: final focusData,
        whatsChanged: final change,
      ):
        final delta = change?.delta ?? containers.length;

        if (!(change?.preservationUnneeded ?? false)) {
          _chatObserver.standby(
            changeCount: delta.abs(),
            isRemove: delta.isNegative,
            refItemIndex: (change?.refIndexBefore ?? 0) + 1,
            refItemIndexAfterUpdate: (change?.refIndexAfter ?? 0) + 1,
          );
        }

        setState(() {
          _containers.clear();
          _containers.addAll(containers);
        });

        if (focusData != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _focus(focusData);
          });
        }
    }
  }

  void _dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    await _focusNewMessages?.cancel();
    await _focusMessages?.cancel();
    await _focusRequested?.cancel();
    await _msgSubcription?.cancel();
    bloc.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    _chatObserver.observeSwitchShrinkWrap();
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    final focus = MessageFocusData.of(context)!;
    _focusNewMessages ??= focus.newFocusedMessages.listen((id) {
      if (!mounted) return;
      context.read<ChatBloc>().add(ChatBlocNewFocusedMessageEvent(id));
    });
    _focusMessages ??= focus.focusedMessages.listen((ids) {
      if (!mounted) return;
      context.read<ChatBloc>().add(ChatBlocCurrentlyFocusedMessagesEvent(ids));
    });
    _focusRequested ??= focus.focusRequestedMessages.listen((id) {
      if (!mounted) return;
      context.read<ChatBloc>().add(ChatBlocLoadChunkEvent(id));
    });
    bloc = context.read<ChatBloc>();
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<ChatBloc>().add(const ChatBlocReadyToShowEvent()),
    );
  }

  Widget _build(
    BuildContext context,
    Stream<ChatBlocStreamedData> stream,
    ServiceChatType? type,
  ) {
    _msgSubcription ??= stream.listen(_onBlocUpdate);

    final listView = ScalingListView(
      key: const ValueKey<String>("chat-screen-lvw"),
      controller: _scrollController,
      positionsListener: _scrollPositionsListener,
      reverse: true,
      physics: const AlwaysScrollableScrollPhysics(),
      shrinkWrap: _chatObserver.isShrinkWrap,
      itemCount: _containers.length + 1,
      minScale: 0.7,
      maxScale: 1.0,
      padding: EdgeInsets.symmetric(
        horizontal: Paddings.messageBubblesPadding,
      ),
      itemBuilder: (context, i) {
        final bloc = context.read<ChatBloc>();

        if (i == 0) {
          return ChatHeader(
            key: const GlobalObjectKey("chathdr"),
            chat: bloc.chat,
          );
        }

        i -= 1;
        if (i >= _containers.length) {
          return const SizedBox.shrink(); // Safety check
        }
        
        final container = _containers[i];

        return switch (container) {
          ChatBlocMessageId(id: final id) => Padding(
              padding: EdgeInsets.only(
                bottom: Paddings.betweenSimilarElements,
              ),
              key: GlobalObjectKey("msg-$id"),
              child: FocusableMessageBubble(
                chat: bloc.chat,
                type: type,
                message: bloc.messagesData[id] ??
                    (throw HandyUiException(tag, "No such message $id")),
              ),
            ),
          ChatBlocNoMoreMessages(older: final older) => SizedBox(
              key: GlobalObjectKey("nomoremessages-$older"),
            ),
          ChatBlocLoadMore(fromMessageId: final id, older: final older) =>
            LoadMoreWidget(
              data: container,
              key: GlobalObjectKey("loadmore-from-$id-$older"),
            ),
        };
      },
    );

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          PositionedScrollbar(
            positionsListener: _scrollPositionsListener,
            itemCount: _containers.length + 1,
            child: listView,
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Easing.standardDecelerate,
            switchOutCurve: Easing.standardDecelerate,
            child: _initFinished
                ? const SizedBox()
                : Container(
                    color: Colors.black.withOpacity(0.5),
                    child: _spinner,
                  ),
          ),
        ],
      ),
    );
  }

  final _spinner = SizedBox.expand(
      child: Container(
    color: Colors.black,
    child: const Center(
      child: SizedBox(
        height: 50,
        width: 50,
        child: CircularProgressIndicator(
          key: ValueKey<String>(
            "pro_fortnait_babaji_caesgo_cybersport_120fps_4k_ultra_hd_spinner",
          ),
        ),
      ),
    ),
  ));

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatBlocState>(
      builder: (context, state) {
        final bloc = context.watch<ChatBloc>();
        return switch (state) {
          ChatBlocLoadingState() => Scaffold(
              body: _spinner,
            ),
          ChatBlocError(error: final errorData) => Scaffold(
              backgroundColor: ColorStyles.active.error,
              body: Center(
                child: Padding(
                    padding:
                        EdgeInsets.all(Paddings.afterPageEndingWithSmallButton),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error, color: ColorStyles.active.onError),
                        Text(
                          errorData,
                          style: TextStyles.active.titleLarge?.copyWith(
                            color: ColorStyles.active.onError,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )),
              ),
            ),
          ChatBlocReady(dataStream: final stream, chatType: final type) =>
            NoticeOverlay(
              noticeUpdates: _errors,
              child: _build(context, stream, type),
            ),
        };
      },
    );
  }
}
