import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService extends GetxService {
  late IO.Socket socket;

  var isConnected = false.obs;
  var isMatched = false.obs;
  var matchedUser = "".obs;

  void connect() {
    socket = IO.io(
      'http://10.223.186.197:3000',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket.connect();

    socket.onConnect((_) {
      isConnected.value = true;
      print("Connected to server");
    });

    socket.onDisconnect((_) {
      isConnected.value = false;
      print("Disconnected from server");
    });

    socket.on("matched", (data) {
      isMatched.value = true;
      matchedUser.value = data.toString();

      print("Matched with: $data");
    });

    socket.on("message", (data) {
      print("New Message: $data");
    });
  }

  void joinQueue() {
    socket.emit("joinQueue");
  }

  void sendMessage(String message) {
    socket.emit("message", message);
  }

  @override
  void onClose() {
    socket.dispose();
    super.onClose();
  }
}