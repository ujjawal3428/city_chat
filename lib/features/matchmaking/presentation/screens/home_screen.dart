import 'package:city_chat/core/constants/services/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/chat_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final socketService = Get.find<SocketService>();

    final controller = Get.put(ChatController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("City Chat"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          if (!socketService.isMatched.value) {
            return Center(
              child: ElevatedButton(
                onPressed: () {
                  socketService.joinQueue();
                },
                child: const Text("Find Stranger"),
              ),
            );
          }

          return Column(
            children: [
              Text(
                "Connected with: ${socketService.matchedUser.value}",
              ),

              const SizedBox(height: 20),

              Expanded(
                child: Obx(
                  () => ListView.builder(
                    itemCount: controller.messages.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(controller.messages[index]),
                      );
                    },
                  ),
                ),
              ),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.messageController,
                      decoration: const InputDecoration(
                        hintText: "Type message...",
                      ),
                    ),
                  ),

                  IconButton(
                    onPressed: controller.sendMessage,
                    icon: const Icon(Icons.send),
                  )
                ],
              )
            ],
          );
        }),
      ),
    );
  }
}