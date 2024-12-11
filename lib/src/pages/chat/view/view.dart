import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watchgram/src/components/list/scaling_list_view.dart';
import 'package:watchgram/src/components/overlays/notice/notice.dart';
import 'package:watchgram/src/pages/chat/bloc/bloc.dart';
import 'package:watchgram/src/pages/chat/bloc/data.dart';
import 'package:watchgram/src/common/tdlib/misc/service_chat_type.dart';
import 'package:watchgram/src/pages/chat/view/widgets/message_focusable.dart';
import 'package:handy_tdlib/api.dart' as td;

class ChatView extends StatefulWidget {
  const ChatView({
    super.key,
    required this.chatId,
  });

  final int chatId;

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  late ChatBloc bloc;
  StreamSubscription<ChatBlocStreamedData>? _msgSubcription;
  List<ChatBlocContainer> _containers = [];
  bool _initFinished = false;
  final _errors = StreamController<String>.broadcast();

  String _formatMessage(td.Message message) {
    final sender = switch (message.senderId) {
      td.MessageSenderChat(chatId: final chatId) => 'Chat $chatId',
      td.MessageSenderUser(userId: final userId) => 'User $userId',
    };
    
    final time = DateTime.fromMillisecondsSinceEpoch(message.date * 1000)
        .toLocal()
        .toString()
        .substring(11, 16);

    final content = switch (message.content) {
      td.MessageText(text: td.FormattedText(text: final text)) => text,
      td.MessagePhoto(caption: td.FormattedText(text: final text)) => text,
      td.MessageVoiceNote(caption: td.FormattedText(text: final text)) => text,
      td.MessageAnimation(caption: td.FormattedText(text: final text)) => text,
      td.MessageAnimatedEmoji(emoji: final emoji) => emoji,
      _ => 'Unsupported message type',
    };

    return '$sender [$time]\n$content';
  }

  @override
  void initState() {
    super.initState();
    debugPrint('ChatView: Initializing with chatId ${widget.chatId}');
    bloc = ChatBloc();
    _msgSubcription = bloc.dataStream.listen(
      _onBlocUpdate,
      onError: (error) => debugPrint('ChatView: Error from stream: $error'),
      onDone: () => debugPrint('ChatView: Stream closed'),
    );
    bloc.add(ChatBlocStartPreloadingEvent(chatId: widget.chatId));
    
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        debugPrint('ChatView: Sending ready to show event');
        bloc.add(const ChatBlocReadyToShowEvent());
      }
    });
  }

  @override
  void dispose() {
    debugPrint('ChatView: Disposing');
    _msgSubcription?.cancel();
    _errors.close();
    bloc.close();
    super.dispose();
  }

  void _onBlocUpdate(ChatBlocStreamedData update) {
    debugPrint('ChatView: Received update ${update.runtimeType}');
    if (!mounted) return;

    switch (update) {
      case ChatBlocMessagesListData(
        containers: final containers,
        whatsChanged: final change
      ):
        debugPrint('ChatView: Received ${containers.length} containers');
        debugPrint('ChatView: Container types: ${containers.map((c) => '${c.runtimeType}').join(', ')}');
        if (change != null) {
          debugPrint('ChatView: Change - refBefore: ${change.refIndexBefore}, refAfter: ${change.refIndexAfter}, delta: ${change.delta}');
        }

        // Vérifier les conteneurs LoadMore
        final loadMoreContainers = containers.whereType<ChatBlocLoadMore>().toList();
        debugPrint('ChatView: Found ${loadMoreContainers.length} LoadMore containers:');
        for (final container in loadMoreContainers) {
          debugPrint('ChatView: - fromMessageId: ${container.fromMessageId}, older: ${container.older}');
        }

        // Vérifier les conteneurs de messages
        final messageContainers = containers.whereType<ChatBlocMessageId>().toList();
        debugPrint('ChatView: Found ${messageContainers.length} message containers:');
        debugPrint('ChatView: Message IDs: ${messageContainers.map((c) => (c as ChatBlocMessageId).id).join(", ")}');

        setState(() {
          _containers = List<ChatBlocContainer>.from(containers);
          _initFinished = true;
        });

      case ChatBlocError(error: final error):
        debugPrint('ChatView: Received error: $error');
        _errors.add(error);

      case ChatBlocMessageContentUpdated():
        debugPrint('ChatView: Message content updated');
        setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatBlocState>(
      bloc: bloc,
      builder: (context, state) {
        debugPrint('ChatView: Building with state ${state.runtimeType}');
        
        if (state is ChatBlocLoadingState) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ChatBlocReady) {
          debugPrint('ChatView: Building chat view');
          final messages = bloc.messagesData.keys.toList()
            ..sort((a, b) => a.compareTo(b));  // Trier du plus ancien au plus récent

          debugPrint('ChatView: Found ${messages.length} messages');
          debugPrint('ChatView: Message IDs: ${messages.join(", ")}');
          
          final formattedMessages = messages.map((id) {
            final message = bloc.messagesData[id];
            if (message == null) {
              debugPrint('ChatView: Message $id not found in messagesData');
              return null;
            }
            return {
              'id': id.toString(),
              'text': _formatMessage(message),
              'isOutgoing': message.isOutgoing,
              'timestamp': message.date,
            };
          }).whereType<Map<String, dynamic>>().toList();

          debugPrint('ChatView: Formatted ${formattedMessages.length} messages');
          debugPrint('ChatView: First message: ${formattedMessages.firstOrNull}');
          debugPrint('ChatView: Last message: ${formattedMessages.lastOrNull}');
          debugPrint('ChatView: Current containers: ${_containers.length}');
          debugPrint('ChatView: Container types: ${_containers.map((c) => '${c.runtimeType}').join(', ')}');

          // Vérifier si nous avons un container LoadMore pour les messages plus récents
          bool hasMore = _containers.any((container) => 
            container is ChatBlocLoadMore && !container.older
          );
          debugPrint('ChatView: Has more recent messages: $hasMore');

          // Vérifier que les conteneurs correspondent aux messages
          final messageContainers = _containers.whereType<ChatBlocMessageId>().toList();
          debugPrint('ChatView: Message containers: ${messageContainers.length}');
          debugPrint('ChatView: Message container IDs: ${messageContainers.map((c) => (c as ChatBlocMessageId).id).join(", ")}');

          return ScalingListView(
            messages: formattedMessages,
            hasMore: hasMore,
            onLoadMore: () async {
              debugPrint('ChatView: Load more triggered');
              if (_containers.isEmpty) {
                debugPrint('ChatView: No containers available');
                return;
              }

              // Chercher uniquement les conteneurs LoadMore pour les messages plus récents
              final loadMoreContainers = _containers.whereType<ChatBlocLoadMore>()
                .where((container) => !container.older)
                .toList();
              
              if (loadMoreContainers.isEmpty) {
                debugPrint('ChatView: No LoadMore containers for recent messages');
                return;
              }

              final loadMoreContainer = loadMoreContainers.first;
              debugPrint('ChatView: Found ChatBlocLoadMore: fromMessageId=${loadMoreContainer.fromMessageId}, older=${loadMoreContainer.older}');
              bloc.add(ChatBlocLoadMoreEvent(loadMoreContainer));
            },
          );
        }

        return const Center(child: Text('Error loading chat'));
      },
    );
  }
}
