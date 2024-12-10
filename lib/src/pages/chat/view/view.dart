import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watchgram/src/common/cubits/scaling.dart';
import 'package:watchgram/src/common/settings/entries.dart';
import 'package:watchgram/src/common/settings/manager.dart';
import 'package:watchgram/src/common/tdlib/misc/service_chat_type.dart';
import 'package:mutex/mutex.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

import 'package:watchgram/src/common/cubits/colors.dart';
import 'package:watchgram/src/common/cubits/text.dart';
import 'package:watchgram/src/common/exceptions/ui_exception.dart';
import 'package:watchgram/src/common/log/log.dart';
import 'package:watchgram/src/common/misc/localizations.dart';
import 'package:watchgram/src/components/list/scrollbar.dart';
import 'package:watchgram/src/components/list/scrollwrapper.dart';
import 'package:watchgram/src/components/overlays/notice/notice.dart';
import 'package:watchgram/src/components/scaled_sizes.dart';
import 'package:watchgram/src/components/list/scaling_list_view.dart';

import 'package:watchgram/src/pages/chat/bloc/bloc.dart';
import 'package:watchgram/src/pages/chat/bloc/data.dart';
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
  final _scrollController = ScrollController();
  late final _scrollObserverController = ListObserverController(
    controller: _scrollController,
  )..cacheJumpIndexOffset = false;
  late final _chatObserver = ChatScrollObserver(_scrollObserverController)
    ..fixedPositionOffset = 5
    ..toRebuildScrollViewCallback = () => setState(() {});

  bool _initFinished = false;

  late ChatBloc bloc;

  List<ChatBlocContainer> _containers = [];
  final _errorsQueue = StreamController<String>();

  final _focusLock = Mutex();

  Stream<BaseNotice?> get _errors async* {
    await for (final error in _errorsQueue.stream) {
      yield StringNotice(error, color: ColorStyles.active.onError);
      await Future.delayed(const Duration(seconds: 5));
      yield null;
    }
  }

  void _focus(ChatBlocFocusData data) async {
    final id = data.focusOnMessageId;
    l.i(tag, "Focus requested on $id");

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

    await _focusLock.protect(() async {
      if (data.mustFocusInstantly) {
        await _scrollObserverController.jumpTo(
          index: index + 1,
        );
        setState(() {
          _initFinished = true;
        });
      } else {
        await _scrollObserverController.animateTo(
          index: index + 1,
          duration: const Duration(milliseconds: 300),
          alignment: 0,
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _onBlocUpdate(final ChatBlocStreamedData update) {
    if (!mounted) {
      return _dispose();
    }

    switch (update) {
      case ChatBlocMessageContentUpdated():
        break;
      case ChatBlocMessagesListData(
          containers: final containers,
          focusData: final focusData,
          whatsChanged: final change,
        ):
        int delta = change?.delta ?? containers.length;

        if (!(change?.preservationUnneeded ?? false)) {
          _chatObserver.standby(
            changeCount: delta.abs(),
            isRemove: delta.isNegative,
            refItemIndex: (change?.refIndexBefore ?? 0) + 1,
            refItemIndexAfterUpdate: (change?.refIndexAfter ?? 0) + 1,
          );
        }

        setState(() {
          _containers = containers;
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
    await _focusMessages?.cancel();
    await _focusNewMessages?.cancel();
    await _msgSubcription?.cancel();
    bloc.dispose();
    _scrollController.dispose();
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
      reverse: true,
      physics: ChatObserverClampingScrollPhysics(
        observer: _chatObserver,
      ),
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
          HandyScrollbar(
            controller: _scrollController,
            child: HandyScrollWrapper(
              controller: _scrollController,
              child: ListViewObserver(
                controller: _scrollObserverController,
                child: listView,
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Easing.standardDecelerate,
            switchOutCurve: Easing.standardDecelerate,
            child: _initFinished
                ? const IgnorePointer(
                    key: ValueKey<String>("chat_ip"),
                  )
                : _spinner,
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
    final bloc = context.watch<ChatBloc>();
    return switch (bloc.state) {
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
  }
}
