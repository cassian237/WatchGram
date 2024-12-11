package clapps.be.watchgram.chat

import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import clapps.be.watchgram.R

private const val TAG = "ChatAdapter"

class ChatAdapter : RecyclerView.Adapter<ChatAdapter.MessageViewHolder>() {

    private var messages = listOf<Map<String, Any>>()

    fun updateMessages(newMessages: List<Map<String, Any>>) {
        Log.d(TAG, "Updating messages: ${newMessages.size}")
        messages = newMessages.map { it.toMutableMap() }.onEach { message ->
            // Ensure we have a text field
            if (!message.containsKey("text")) {
                message["text"] = ""
            }
        }
        notifyDataSetChanged()
        Log.d(TAG, "Messages updated and notified")
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): MessageViewHolder {
        Log.d(TAG, "Creating new view holder")
        val view = LayoutInflater.from(parent.context)
            .inflate(R.layout.chat_message_item, parent, false)
        return MessageViewHolder(view)
    }

    override fun onBindViewHolder(holder: MessageViewHolder, position: Int) {
        val message = messages[position]
        Log.d(TAG, "Binding message at position $position: $message")
        
        holder.messageText.text = message["text"] as? String ?: ""
        
        // Adjust the message container based on whether it's sent or received
        val isOutgoing = message["isOutgoing"] as? Boolean ?: true
        holder.messageText.apply {
            if (isOutgoing) {
                setBackgroundResource(R.drawable.chat_message_background)
                layoutParams = (layoutParams as ViewGroup.MarginLayoutParams).apply {
                    marginStart = context.resources.getDimensionPixelSize(R.dimen.message_margin_large)
                    marginEnd = context.resources.getDimensionPixelSize(R.dimen.message_margin_small)
                }
            } else {
                setBackgroundResource(R.drawable.chat_message_background_received)
                layoutParams = (layoutParams as ViewGroup.MarginLayoutParams).apply {
                    marginStart = context.resources.getDimensionPixelSize(R.dimen.message_margin_small)
                    marginEnd = context.resources.getDimensionPixelSize(R.dimen.message_margin_large)
                }
            }
        }
    }

    override fun getItemCount() = messages.size

    class MessageViewHolder(view: View) : RecyclerView.ViewHolder(view) {
        val messageText: TextView = view.findViewById(R.id.messageText)
    }
}
