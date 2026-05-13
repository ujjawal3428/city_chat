import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatMessage {
  final String sender;
  final String message;
  final bool isMe;
  final DateTime time;

  ChatMessage({
    required this.sender,
    required this.message,
    required this.isMe,
    required this.time,
  });
}

class ChatController extends GetxController {

  final RxList<ChatMessage> messages = <ChatMessage>[
    ChatMessage(
      sender: 'Stranger',
      message: 'heyy! 👋',
      isMe: false,
      time: DateTime.now().subtract(const Duration(minutes: 3)),
    ),
    ChatMessage(
      sender: 'You',
      message: 'Hi there! ❤️',
      isMe: true,
      time: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
    ChatMessage(
      sender: 'Stranger',
      message: 'Where are you from?',
      isMe: false,
      time: DateTime.now().subtract(const Duration(minutes: 1)),
    ),
  ].obs;

  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController    = ScrollController();
  final RxBool isTyping                      = false.obs;

  @override
  void onInit() {
    super.onInit();
    textController.addListener(() {
      isTyping.value = textController.text.trim().isNotEmpty;
    });
  }

  @override
  void onClose() {
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void sendMessage() {
    final text = textController.text.trim();
    if (text.isEmpty) return;

    messages.add(ChatMessage(
      sender: 'You',
      message: text,
      isMe: true,
      time: DateTime.now(),
    ));

    textController.clear();
    isTyping.value = false;
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String formatTime(DateTime time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// ── Chat Panel Widget ────────────────────────────────────────
  Widget buildChatPanel() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xff15171C),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [

          /// Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xff23262F), width: 1),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.circle, color: Colors.green, size: 9),
                SizedBox(width: 8),
                Text(
                  'Live Chat',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          /// Messages list
          Expanded(
            child: Obx(() => ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return _buildChatLine(msg);
              },
            )),
          ),

          /// Input bar
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildChatLine(ChatMessage msg) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${msg.sender}: ',
                  style: TextStyle(
                    color: msg.isMe
                        ? const Color(0xffFF4B91)
                        : const Color(0xff9D44FF),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: msg.message,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Text(
            formatTime(msg.time),
            style: const TextStyle(
              color: Colors.white24,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xff23262F), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xff1E2128),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: textController,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                onSubmitted: (_) => sendMessage(),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Obx(() => GestureDetector(
            onTap: sendMessage,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: isTyping.value
                      ? [const Color(0xffFF4B91), const Color(0xff9D44FF)]
                      : [const Color(0xff2A2D37), const Color(0xff2A2D37)],
                ),
              ),
              child: Icon(
                Icons.send,
                color: isTyping.value ? Colors.white : Colors.white24,
                size: 18,
              ),
            ),
          )),
        ],
      ),
    );
  }
}