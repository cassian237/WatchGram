package clapps.be.watchgram.chat

import android.content.Context
import android.util.Log
import android.view.View
import androidx.recyclerview.widget.RecyclerView
import androidx.wear.widget.WearableLinearLayoutManager
import androidx.wear.widget.WearableRecyclerView
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

private const val TAG = "ChatListView"
private const val MAX_ICON_PROGRESS = 0.65f

class CustomScrollingLayoutCallback : WearableLinearLayoutManager.LayoutCallback() {
    private var progressToCenter: Float = 0f

    override fun onLayoutFinished(child: View, parent: RecyclerView) {
        Log.d(TAG, "CustomScrollingLayoutCallback: onLayoutFinished called")
        child.apply {
            // Figure out % progress from top to bottom.
            val centerOffset = height.toFloat() / 2.0f / parent.height.toFloat()
            val yRelativeToCenterOffset = y / parent.height + centerOffset

            // Normalize for center.
            progressToCenter = Math.abs(0.5f - yRelativeToCenterOffset)
            // Adjust to the maximum scale.
            progressToCenter = Math.min(progressToCenter, MAX_ICON_PROGRESS)

            scaleX = 1 - progressToCenter
            scaleY = 1 - progressToCenter
            Log.d(TAG, "CustomScrollingLayoutCallback: Applied scale: ${1 - progressToCenter}")
        }
    }
}

class ChatListView(
    context: Context,
    messenger: BinaryMessenger,
    id: Int,
    creationParams: Map<String, Any>?
) : PlatformView, MethodChannel.MethodCallHandler {

    private val recyclerView = WearableRecyclerView(context)
    private val adapter = ChatAdapter()
    private val methodChannel = MethodChannel(messenger, "chat_list_view_$id")
    private val customScrollingLayoutCallback = CustomScrollingLayoutCallback()

    init {
        Log.d(TAG, "Initializing ChatListView with id: $id")
        
        recyclerView.apply {
            val layoutManager = WearableLinearLayoutManager(context, customScrollingLayoutCallback)
            layoutManager.stackFromEnd = true
            this.layoutManager = layoutManager
            
            adapter = this@ChatListView.adapter
            isEdgeItemsCenteringEnabled = true
            isCircularScrollingGestureEnabled = false
            Log.d(TAG, "WearableRecyclerView configured with CustomScrollingLayoutCallback")
        }

        methodChannel.setMethodCallHandler(this)

        creationParams?.let { params ->
            Log.d(TAG, "Creation params received: $params")
            @Suppress("UNCHECKED_CAST")
            (params["messages"] as? List<Map<String, Any>>)?.let { messages ->
                Log.d(TAG, "Initial messages received: ${messages.size}")
                adapter.updateMessages(messages)
                Log.d(TAG, "Messages updated in adapter")
                recyclerView.post {
                    recyclerView.scrollToPosition(messages.size - 1)
                }
            }
        }
        Log.d(TAG, "ChatListView initialization complete")
    }

    override fun getView(): View {
        Log.d(TAG, "getView called")
        return recyclerView
    }

    override fun dispose() {
        Log.d(TAG, "dispose called")
        methodChannel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        Log.d(TAG, "Method call received: ${call.method}")
        if (call.method == "updateMessages") {
            @Suppress("UNCHECKED_CAST")
            (call.arguments as? Map<String, Any>)?.get("messages")?.let { messages ->
                val messagesList = messages as List<Map<String, Any>>
                Log.d(TAG, "Updating messages: ${messagesList.size}")
                adapter.updateMessages(messagesList)
                recyclerView.post {
                    recyclerView.scrollToPosition(messagesList.size - 1)
                }
                Log.d(TAG, "Messages updated successfully")
                result.success(null)
            } ?: result.error("INVALID_ARGUMENTS", "Messages cannot be null", null)
        } else {
            result.notImplemented()
        }
    }
}
