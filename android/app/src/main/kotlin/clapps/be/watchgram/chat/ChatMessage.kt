package clapps.be.watchgram.chat

data class ChatMessage(
    val id: String,
    val text: String,
    val senderName: String,
    val isOutgoing: Boolean,
    val timestamp: Long
)
