import 'package:flutter/material.dart';
import 'package:handy_tdlib/api.dart' as td;
import 'package:watchgram/src/components/messages/content.dart';
import 'package:watchgram/src/components/messages/parts/caption/widget.dart';
import 'package:watchgram/src/components/scaled_sizes.dart';

class TextMessageContent extends MessageStatelessWidget<td.MessageText> {
  const TextMessageContent({
    super.key,
    required super.data,
  });

  @override
  Widget build(BuildContext context) {
    return MessageCaptionWidget(
      content.text,
      isOutgoing: isOutgoing,
      attributesWidget: attributesWidget,
      attributesPadding: Paddings.betweenSimilarElements,
    );
  }
}
