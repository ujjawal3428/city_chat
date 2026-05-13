import 'package:city_chat/core/constants/services/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatController extends GetxController {
  final socketService = Get.find<SocketService>();

  final TextEditingController messageController =
      TextEditingController();

  var messages = <String>[].obs;

  @override
  void onInit() {
    super.onInit();

    socketService.socket.on("message", (data) {
      messages.add(data.toString());
    });
  }

  void sendMessage() {
    if (messageController.text.trim().isEmpty) return;

    socketService.sendMessage(messageController.text);

    messages.add("Me: ${messageController.text}");

    messageController.clear();
  }
}