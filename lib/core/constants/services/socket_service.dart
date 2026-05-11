import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket socket;

  void connect() {
    socket = IO.io(
      'http://http://10.223.186.197:3000',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket.connect();

    socket.onConnect((_) {
      print("Connected to server");
    });

    socket.onDisconnect((_) {
      print("Disconnected from server");
    });

    socket.on("matched", (data) {
      print("Matched with: $data");
    });
  }

  void joinQueue() {
    socket.emit("joinQueue");
  }
}