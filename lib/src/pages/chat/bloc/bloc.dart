/*
 * Copyright (C) Roman Rikhter <teledurak@gmail.com>, 2024
 * This program comes with ABSOLUTELY NO WARRANTY;
 * This is free software, and you are welcome to redistribute it under certain conditions;
 *
 * See /LICENSE for more details.
 */

import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:handy_tdlib/handy_tdlib.dart';
import 'package:watchgram/src/common/cubits/current_account.dart';
import 'package:watchgram/src/common/exceptions/tdlib_core_exception.dart';
import 'package:watchgram/src/common/exceptions/ui_exception.dart';
import 'package:watchgram/src/common/log/log.dart';
import 'package:watchgram/src/common/misc/localizations.dart';
import 'package:watchgram/src/common/settings/entries.dart';
import 'package:watchgram/src/common/settings/manager.dart';
import 'package:watchgram/src/common/tdlib/providers/messages/messages.dart';
import 'package:watchgram/src/common/tdlib/misc/service_chat_type.dart';
import 'package:watchgram/src/pages/chat/bloc/data.dart';
import 'package:handy_tdlib/api.dart' as td;
import 'package:mutex/mutex.dart';

enum _ContainerInsertStatus {
  /// Inserted new container
  insertedNew,

  /// Exactly same container already did exist
  alreadyExists,

  /// Similar container was updated
  updated,
}

class ChatBloc extends Bloc<ChatBlocEvent, ChatBlocState> {
  static const String tag = "ChatBloc";
  static bool debugCleanupDisabled = false;

  final Map<int, td.Message> _messagesData = {};
  final List<ChatBlocContainer> _containers = [];
  Completer<void>? _uiReady = Completer<void>();
  final _streamController = StreamController<ChatBlocStreamedData>();
  final Mutex _lock = Mutex();
  StreamSubscription? _chatInfoUpdateSub, _messageUpdatesSub;

  late td.Chat _chat;

  Map<int, td.Message> get messagesData => _messagesData;
  td.Chat get chat => _chat;
  Stream<ChatBlocStreamedData> get dataStream => _streamController.stream;

  @override
  void onError(Object error, StackTrace stackTrace) {
    l.e(tag, "$error");
    l.e(tag, "$stackTrace");
    super.onError(error, stackTrace);
  }

  ChatBloc() : super(const ChatBlocLoadingState()) {
    on<ChatBlocStartPreloadingEvent>(_preload);
    on<ChatBlocReadyToShowEvent>(_setUiReady);
    on<ChatBlocLoadChunkEvent>(_loadChunk);
    on<ChatBlocLoadMoreEvent>(_loadMore);
    on<ChatBlocLoadLatestMessagesEvent>(_loadLatest);
    on<ChatBlocCurrentlyFocusedMessagesEvent>(_cleanup);
    on<ChatBlocNewFocusedMessageEvent>(_viewMessage);
  }

  void dispose() async {
    await _chatInfoUpdateSub?.cancel();
    await _messageUpdatesSub?.cancel();
    await _streamController.close();
    await CurrentAccount.providers.chats.closeChat(_chat.id);
  }

  Future<void> _exceptionsGuard(
    Emitter<ChatBlocState> emit,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } catch (error) {
      emit(ChatBlocError(
          AppLocalizations.current.chatBlocLoadingError(switch (error) {
        TdlibCoreException(module: final module, message: final message) =>
          "TDLib[$module] $message",
        _ => "[Unknown] $error",
      })));
    }
  }

  /// 1. Loads chat info, subscribes to its updates
  /// 2. Parses +5/-5 messages from lastReadInboxMessageId into ChatBlocContainer
  /// 3. Sets NoMoreMessages and LoadMore appropriately
  /// 4. Waits for UI loading and then sends ChatBlocReady state
  Future<void> _preload(
    ChatBlocStartPreloadingEvent event,
    Emitter<ChatBlocState> emit,
  ) async {
    l.d(tag, "Starting preload for chat ${event.chatId}");
    await _exceptionsGuard(
      emit,
      () async {
        _chat = await CurrentAccount.providers.chats.getChat(event.chatId);
        l.d(tag, "Chat loaded: ${_chat.id}");

        _chatInfoUpdateSub = CurrentAccount.providers.chats
            .filter(_chat.id, tdUpdateTypes: [
              td.UpdateChatReadInbox,
              td.UpdateChatReadOutbox,
              td.UpdateChatLastMessage,
            ]).listen((event) {
          l.d(tag, "Received chat update: ${event.runtimeType}");
          switch (event.update) {
            case td.UpdateChatReadInbox(
                lastReadInboxMessageId: final lastReadInboxMessageId,
                unreadCount: final unreadCount,
              ):
              _chat = _chat.copyWith(
                lastReadInboxMessageId: lastReadInboxMessageId,
                unreadCount: unreadCount,
              );
            case td.UpdateChatReadOutbox(
                lastReadOutboxMessageId: final lastReadOutboxMessageId,
              ):
              _chat = _chat.copyWith(
                lastReadOutboxMessageId: lastReadOutboxMessageId,
              );
            case td.UpdateChatLastMessage(lastMessage: final lastMessage):
              _chat = _chat.copyWith(lastMessage: lastMessage);
            default:
              break;
          }
        });

        await _loadInitialMessages(emit);
        l.d(tag, "Initial messages loaded");

        await _uiReady?.future;
        l.d(tag, "UI is ready");

        final serviceChatType = await getServiceChatType(_chat);
        emit(ChatBlocReady(_streamController.stream, serviceChatType));
        l.d(tag, "Emitted ChatBlocReady state");
        return;
      },
    );
  }

  Future<void> _loadInitialMessages(Emitter<ChatBlocState> emit) async {
    l.d(tag, "Loading initial messages");
    final messages = await CurrentAccount.providers.messages.getHistory(
      _chat.id,
      fromMessageId: _chat.lastReadInboxMessageId,
      limit: 20,
    );
    l.d(tag, "Received ${messages.length} initial messages");

    if (messages.isEmpty) {
      l.d(tag, "No messages found, adding NoMoreMessages container");
      _containers.add(const ChatBlocNoMoreMessages(older: true));
      _notifyContainersChanged();
      return;
    }

    // Ajouter d'abord le LoadMore pour les messages plus anciens si nécessaire
    if (messages.length >= 20) {
      l.d(tag, "Adding LoadMore container for older messages");
      _containers.add(ChatBlocLoadMore(
        fromMessageId: messages.last.id,
        older: true,
      ));
    } else {
      l.d(tag, "No more older messages, adding NoMoreMessages container");
      _containers.add(const ChatBlocNoMoreMessages(older: true));
    }

    // Ajouter les messages du plus ancien au plus récent
    for (final message in messages.reversed) {
      l.d(tag, "Processing message ${message.id}");
      _messagesData[message.id] = message;
      _containers.add(ChatBlocMessageId(message.id));
    }

    // Ajouter le LoadMore pour les messages plus récents si nécessaire
    if (messages.first.id != _chat.lastMessage?.id) {
      l.d(tag, "Adding LoadMore container for newer messages");
      _containers.add(ChatBlocLoadMore(
        fromMessageId: messages.first.id,
        older: false,
      ));
    } else {
      l.d(tag, "No more newer messages, adding NoMoreMessages container");
      _containers.add(const ChatBlocNoMoreMessages(older: false));
    }

    _notifyContainersChanged();
  }

  void _notifyContainersChanged([MessageListChange? change]) {
    l.d(tag, "Notifying containers changed");
    l.d(tag, "Current containers: ${_containers.map((c) => c.runtimeType).join(', ')}");
    if (!_streamController.isClosed) {
      _streamController.add(ChatBlocMessagesListData(
        _containers,
        whatsChanged: change,
      ));
    }
  }

  Future<void> _setUiReady(
    ChatBlocReadyToShowEvent event,
    Emitter<ChatBlocState> emit,
  ) async {
    _uiReady?.complete();
    _uiReady = null;
  }

  /// Automatically insert container into the most relevant position
  /// Also checks for LoadMore, NoMoreMessages conflicts.
  _ContainerInsertStatus _containerInsert(
      final ChatBlocContainer newContainer) {
    switch (newContainer) {
      case ChatBlocNoMoreMessages(older: final older):
        if (_containers.contains(newContainer)) {
          return _ContainerInsertStatus.alreadyExists;
        }
        if (older) {
          _containers.add(newContainer);
        } else {
          _containers.insert(0, newContainer);
        }
      case ChatBlocLoadMore(
          fromMessageId: final fromMessageId,
          older: final older,
        ):
        final targetMessageIndex = _getMessageIndex(fromMessageId);
        if (targetMessageIndex == -1) {
          throw const HandyUiException(
            tag,
            "fromMessageId must exist in message list, but it doesn't",
          );
        }

        final nextIndex =
            min(_containers.length - 1, targetMessageIndex + (older ? 1 : 0));
        if (_containers[nextIndex] == newContainer) {
          return _ContainerInsertStatus.alreadyExists;
        }

        final next = _containers[nextIndex];
        if (next is ChatBlocLoadMore) {
          // Update?
          if (next.older == older) {
            _containers[nextIndex] = newContainer;
            return _ContainerInsertStatus.updated;
          }
        }

        _containers.insert(
          targetMessageIndex + (older ? 1 : 0),
          newContainer,
        );
      case ChatBlocMessageId(id: final objId):
        // It may be the same or older message
        final closestMessageId = _containers.indexWhere((e) => switch (e) {
              ChatBlocMessageId(id: final id) => id <= objId,
              _ => false,
            });
        if (closestMessageId == -1) {
          // The message is older than every message in this list.
          switch (_containers.last) {
            case ChatBlocMessageId():
              // can be a case if not all messages were loaded yet
              _containers.add(newContainer);
            case ChatBlocNoMoreMessages():
              // invalid
              throw const HandyUiException(
                tag,
                "NMM flag was set, but messages are still appearing!",
              );
            case ChatBlocLoadMore():
              _containers.add(newContainer);
          }
        } else {
          final closestMessage =
              _containers[closestMessageId] as ChatBlocMessageId;
          if (closestMessage.id == objId) {
            return _ContainerInsertStatus.alreadyExists;
          }

          // Correct LoadMore id

          if (closestMessageId > 0) {
            final loadMore = _containers[closestMessageId - 1];
            if (loadMore is ChatBlocLoadMore &&
                loadMore.fromMessageId == closestMessage.id) {
              _containers[closestMessageId - 1] = ChatBlocLoadMore(
                fromMessageId: objId,
                older: loadMore.older,
              );
            }
          } else if (closestMessageId < _containers.length - 1) {
            final loadMore = _containers[closestMessageId + 1];
            if (loadMore is ChatBlocLoadMore &&
                loadMore.fromMessageId == closestMessage.id) {
              _containers[closestMessageId + 1] = ChatBlocLoadMore(
                fromMessageId: objId,
                older: loadMore.older,
              );
            }
          }
          _containers.insert(closestMessageId, newContainer);
        }
    }

    return _ContainerInsertStatus.insertedNew;
  }

  static const int _kChunkSize = 11;
  Future<void> _loadChunk(
    ChatBlocLoadChunkEvent event,
    Emitter<ChatBlocState> emit,
  ) async =>
      _lock.protect(() async {
        debugPrint('ChatBloc: Loading chunk from message ${event.middleMessageId}');
        // Load chunk
        final messages = await CurrentAccount.providers.messages.getHistory(
          _chat.id,
          fromMessageId: event.middleMessageId,
          offset: (_kChunkSize - 1) ~/ -2,
          limit: _kChunkSize,
        );
        debugPrint('ChatBloc: Loaded ${messages.length} messages');

        for (final message in messages) {
          final status = _containerInsert(ChatBlocMessageId(message.id));
          _messagesData[message.id] = message;

          if (status == _ContainerInsertStatus.alreadyExists) {
            _streamController.add(ChatBlocMessageContentUpdated(message));
            continue;
          }

          if (message.id == messages.first.id) {
            _containers.add(ChatBlocLoadMore(
              fromMessageId: message.id,
              older: false,
            ));
          } else if (message.id == messages.last.id) {
            _containers.add(ChatBlocLoadMore(
              fromMessageId: message.id,
              older: true,
            ));
          }
        }

        final indexAfter = _containers.indexWhere((c) => c is ChatBlocMessageId && (c as ChatBlocMessageId).id == event.middleMessageId);
        _streamController.add(ChatBlocMessagesListData(
          List<ChatBlocContainer>.from(_containers),
          whatsChanged: MessageListChange(
            refIndexBefore: 0,
            refIndexAfter: indexAfter,
            delta: messages.length,
          ),
        ));
      });

  static const int _kLoadMoreCount = 10;
  Future<void> _loadMore(
    ChatBlocLoadMoreEvent event,
    Emitter<ChatBlocState> emit,
  ) async {
    l.d(tag, "Loading more messages from ${event.data.fromMessageId}, older: ${event.data.older}");
    
    await _exceptionsGuard(
      emit,
      () async {
        final messages = await CurrentAccount.providers.messages.getHistory(
          _chat.id,
          fromMessageId: event.data.fromMessageId,
          limit: _kLoadMoreCount,
          offset: event.data.older ? 0 : -(_kLoadMoreCount - 1),
        );
        l.d(tag, "Received ${messages.length} more messages");

        if (messages.isEmpty) {
          l.d(tag, "No more messages found");
          return;
        }

        final containerIndex = _containers.indexOf(event.data);
        if (containerIndex == -1) {
          l.d(tag, "LoadMore container not found in list");
          return;
        }

        // Remove the LoadMore container
        _containers.removeAt(containerIndex);

        // Add new messages
        final messagesToAdd = event.data.older ? messages.reversed : messages;
        for (final message in messagesToAdd) {
          l.d(tag, "Adding message ${message.id}");
          _messagesData[message.id] = message;
          _containers.insert(
            containerIndex,
            ChatBlocMessageId(message.id),
          );
        }

        // Add new LoadMore container if needed
        if (messages.length >= _kLoadMoreCount) {
          l.d(tag, "Adding new LoadMore container");
          _containers.insert(
            containerIndex,
            ChatBlocLoadMore(
              fromMessageId: event.data.older ? messages.last.id : messages.first.id,
              older: event.data.older,
            ),
          );
        } else {
          l.d(tag, "No more messages to load in this direction");
          _containers.insert(
            containerIndex,
            ChatBlocNoMoreMessages(older: event.data.older),
          );
        }

        _notifyContainersChanged(MessageListChange(
          refIndexBefore: containerIndex,
          refIndexAfter: containerIndex,
          delta: messages.length,
        ));
        return;
      },
    );
  }

  static const int _kLoadLatestCount = 10;
  Future<void> _loadLatest(
    ChatBlocLoadLatestMessagesEvent event,
    Emitter<ChatBlocState> emit,
  ) async =>
      _lock.protect(() async {
        if (_containers.first is ChatBlocNoMoreMessages) {
          _streamController.add(ChatBlocMessagesListData(
            _containers,
            focusData: ChatBlocFocusData(
              focusOnMessageId: (_containers[1] as ChatBlocMessageId).id,
            ),
          ));
          return;
        }

        late final List<td.Message> messages;

        messages = await CurrentAccount.providers.messages.getHistory(
          _chat.id,
          fromMessageId: _chat.lastMessage?.id ??
              (throw const HandyUiException(
                  tag, "lastMessage wasn't updated!")),
          limit: _kLoadLatestCount,
          offset: 0,
        );

        bool conflict = false;
        int indexAfter = messages.length;

        // Insert messages
        for (final msg in messages) {
          final status = _containerInsert(ChatBlocMessageId(msg.id));
          _messagesData[msg.id] = msg;

          // We've ran into a conflict! Skip updating service containers.
          if (status == _ContainerInsertStatus.alreadyExists) {
            indexAfter--;
            _streamController.add(ChatBlocMessageContentUpdated(msg));
            if (msg == messages.last) {
              conflict = true;
            }
          }
        }

        // Update LoadMore / NoMoreMessages
        if (!conflict) {
          if (_containers.first is ChatBlocLoadMore) {
            _containers.remove(_containers.first);
            indexAfter--;
          }

          if (messages.length != _kLoadMoreCount) {
            _containerInsert(const ChatBlocNoMoreMessages(older: false));
          } else {
            _containerInsert(ChatBlocLoadMore(
              fromMessageId: messages.last.id,
              older: false,
            ));
          }

          indexAfter++;
        }

        _streamController.add(ChatBlocMessagesListData(
          _containers,
          whatsChanged: MessageListChange(
            refIndexBefore: 0,
            refIndexAfter: indexAfter,
            delta: indexAfter,
          ),
        ));
      });

  Future<void> _viewMessage(
    ChatBlocNewFocusedMessageEvent event,
    Emitter<ChatBlocState> emit,
  ) async {
    try {
      await CurrentAccount.providers.messages
          .viewMessage(_chat.id, event.messageId);
      if (event.isContentRead) {
        await CurrentAccount.providers.messages
            .readMessageContent(_chat.id, event.messageId);
      }
    } catch (e, st) {
      // that's not critical exception, log it and do nothing
      l.e(tag, "$e\n$st");
    }
  }

  Future<void> _cleanup(
    ChatBlocCurrentlyFocusedMessagesEvent event,
    Emitter<ChatBlocState> emit,
  ) async =>
      _lock.protect(() async {
        final focused = event.focusedMessagesIds;
        if (focused.isEmpty) return;

        final focusedRange = [
          _getMessageIndex(focused.first),
          _getMessageIndex(focused.last),
        ];
        final distance = [
          focusedRange.first,
          _containers.length - focusedRange.last,
        ];

        if (focusedRange.first == -1 || focusedRange.last == -1) return;

        final cleaningNeeded = distance.first > 15 || distance.last > 15;
        if (debugCleanupDisabled ||
            Settings().get(SettingsEntries.doNotCleanupMessages)) {
          l.i(
              tag,
              "Cleanup disabled! | focused range "
              "${focusedRange.first} -> ${focusedRange.last}, "
              "distance from both ends "
              "${distance.first} -> | ... | <- ${distance.last}. "
              "Cleanup is ${cleaningNeeded ? 'NEEDED' : 'not needed'}.");
          return;
        }

        if (!cleaningNeeded) return;

        int indexBefore, indexAfter, delta;
        if (distance.first > 15) {
          indexBefore = 10;
          indexAfter = 0;
          delta = -10;

          for (int i = 0; i < 10; i++) {
            _messagesData.remove(switch (_containers[i]) {
              ChatBlocMessageId(id: final id) => id,
              _ => null,
            });
            _containers.removeAt(i);
          }

          switch (_containers.first) {
            case ChatBlocMessageId(id: final id):
              _containers.insert(
                0,
                ChatBlocLoadMore(
                  fromMessageId: id,
                  older: false,
                ),
              );
              indexAfter++;
              delta++;
            case ChatBlocLoadMore(
                older: final older,
                fromMessageId: final messageId,
              ):
              if (!older) break;
              _containers.first = ChatBlocLoadMore(
                fromMessageId: messageId,
                older: false,
              );
            case ChatBlocNoMoreMessages():
              throw const HandyUiException(
                tag,
                "NoMoreMessages block should've been removed, but it's not",
              );
          }
        } else if (distance.last > 15) {
          indexBefore = _containers.length - 11;
          indexAfter = _containers.length - 11;
          delta = -10;

          for (int i = _containers.length - 10; i < _containers.length; i++) {
            _messagesData.remove(switch (_containers[i]) {
              ChatBlocMessageId(id: final id) => id,
              _ => null,
            });
            _containers.removeAt(i);
          }

          switch (_containers.last) {
            case ChatBlocMessageId(id: final id):
              _containers.add(
                ChatBlocLoadMore(
                  fromMessageId: id,
                  older: true,
                ),
              );
              delta++;
            case ChatBlocLoadMore(
                older: final older,
                fromMessageId: final messageId,
              ):
              if (older) break;
              _containers.last = ChatBlocLoadMore(
                fromMessageId: messageId,
                older: true,
              );
            case ChatBlocNoMoreMessages():
              throw const HandyUiException(
                tag,
                "NoMoreMessages block should've been removed, but it's not",
              );
          }
        } else {
          throw const HandyUiException(tag, "reached unreachable code");
        }

        _streamController.add(ChatBlocMessagesListData(
          _containers,
          whatsChanged: MessageListChange(
            refIndexBefore: indexBefore,
            refIndexAfter: indexAfter,
            delta: delta,
          ),
        ));
      });

  Future<void> _handleNewMessage(final td.UpdateNewMessage update) =>
      _lock.protect(() async {
        // We're not interested in recent messages if we'd not loaded them
        if (_containers.first is! ChatBlocNoMoreMessages) return;

        final status = _containerInsert(ChatBlocMessageId(update.message.id));
        _messagesData[update.message.id] = update.message;

        if (status == _ContainerInsertStatus.alreadyExists) {
          _streamController.add(ChatBlocMessageContentUpdated(update.message));
        } else {
          _streamController.add(ChatBlocMessagesListData(
            _containers,
            whatsChanged: MessageListChange(
              refIndexBefore: 0,
              refIndexAfter: 1,
              delta: 1,
            ),
          ));
        }
      });

  Future<void> _handleMessageDelete(final td.UpdateDeleteMessages update) =>
      _lock.protect(() async {
        // Remove messages
        int indexBefore = 0;
        final messageIds = update.messageIds;
        for (int i = 0; messageIds.isEmpty || i < _containers.length; i++) {
          final mid = switch (_containers) {
            ChatBlocMessageId(id: final id) => id,
            _ => null,
          };
          if (!messageIds.contains(mid)) return;
          if (indexBefore == 0) indexBefore = i + messageIds.length;
          messageIds.removeAt(i);
        }

        indexBefore -= messageIds.length;
        int delta = messageIds.length - update.messageIds.length;
        int indexAfter =
            indexBefore - messageIds.length + update.messageIds.length;

        for (final id in update.messageIds) {
          _messagesData.remove(id);
        }

        // Update LoadMore containers if needed
        for (int i = 0; i < _containers.length; i++) {
          final lm = _containers[i];
          if (lm is! ChatBlocLoadMore) continue;
          if (!update.messageIds.contains(lm.fromMessageId)) continue;

          // The only conflict may be
          // ChatBlocLoadMore(older: true)
          // ChatBlocLoadMore(older: false)
          // But it is resolved by looking into ChatBlocLoadMore.older value.
          final msg = lm.older ? _containers[i - 1] : _containers[i + 1];
          assert(
            msg is ChatBlocMessageId,
            "Containers sorting algorithm is broken - tdrk is a stupid ass",
          );

          _containers[i] = ChatBlocLoadMore(
            fromMessageId: (msg as ChatBlocMessageId).id,
            older: lm.older,
          );
        }

        _streamController.add(ChatBlocMessagesListData(
          _containers,
          whatsChanged: MessageListChange(
            refIndexBefore: indexBefore,
            refIndexAfter: indexAfter,
            delta: delta,
          ),
        ));
      });

  Future<void> _replaceTemporaryMessage(
    final int oldMessageId,
    final td.Message newMessage,
  ) =>
      _lock.protect(() async {
        _containers.removeWhere((element) => switch (element) {
              ChatBlocMessageId(id: final id) => id == oldMessageId,
              _ => false,
            });
        _messagesData[newMessage.id] = newMessage;
        final status = _containerInsert(ChatBlocMessageId(newMessage.id));
        if (status == _ContainerInsertStatus.alreadyExists) {
          _streamController.add(ChatBlocMessageContentUpdated(newMessage));
        } else {
          _streamController.add(ChatBlocMessagesListData(_containers));
        }
      });

  Future<void> _onMessagesUpdate(final MessageUpdate data) async {
    // If message is new - handle it
    if (data.update is td.UpdateNewMessage) {
      await _handleNewMessage(data.update as td.UpdateNewMessage);
      return;
    }
    // If message(s) is(are) older and not in our cache - skip this update
    if (!data.messageId.any((e) => messagesData.containsKey(e))) return;

    // Not _messageData updates
    switch (data.update) {
      case td.UpdateDeleteMessages():
        await _handleMessageDelete(data.update as td.UpdateDeleteMessages);
      case td.UpdateMessageSendSucceeded(
          message: final message,
          oldMessageId: final oldMessageId
        ):
        await _replaceTemporaryMessage(oldMessageId, message);
      case td.UpdateMessageSendFailed():
        // TODO: do we need this?
        break;
      default:
        break;
    }

    // Only _messageData updates
    late final td.Message message;
    switch (data.update) {
      case td.UpdateMessageContent(
          messageId: final messageId,
          newContent: final content,
        ):
        message = messagesData[messageId]!.copyWith(
          content: content,
        );
        messagesData[messageId] = message;
      case td.UpdateMessageContentOpened(messageId: final messageId):
        final content = messagesData[messageId]!.content;
        message = messagesData[messageId]!.copyWith(
          content: switch (content) {
            MessageVideoNote() => content.copyWith(
                isViewed: true,
              ),
            MessageVoiceNote() => content.copyWith(
                isListened: true,
              ),
            _ => content,
          },
        );
        messagesData[messageId] = message;
      case td.UpdateMessageEdited(
          messageId: final messageId,
          replyMarkup: final replyMarkup,
          editDate: final editDate,
        ):
        message = messagesData[messageId]!.copyWith(
          replyMarkup: replyMarkup,
          editDate: editDate,
        );
        messagesData[messageId] = message;
      case td.UpdateMessageInteractionInfo(
          messageId: final messageId,
          interactionInfo: final interactionInfo,
        ):
        message = messagesData[messageId]!.copyWith(
          interactionInfo: interactionInfo,
        );
        messagesData[messageId] = message;
      default:
        return;
    }
    _streamController.add(ChatBlocMessageContentUpdated(message));
  }

  int _getMessageIndex(int targetId) {
    return _containers.indexWhere((e) => switch (e) {
          ChatBlocMessageId(id: final id) => id == targetId,
          _ => false,
        });
  }
}
