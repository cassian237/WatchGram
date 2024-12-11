package clapps.be.watchgram.chat

import android.content.Context
import android.util.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

private const val TAG = "ChatListViewFactory"

class ChatListViewFactory(
    private val messenger: BinaryMessenger
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(
        context: Context,
        viewId: Int,
        args: Any?
    ): PlatformView {
        Log.d(TAG, "Creating ChatListView with id: $viewId")
        val creationParams = args as? Map<String, Any>
        return ChatListView(context, messenger, viewId, creationParams)
    }
}
