import 'package:city_chat/core/constants/services/socket_service.dart';
import 'package:city_chat/features/matchmaking/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  Get.put(SocketService()).connect();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'City Chat',
      theme: ThemeData.dark(),
      home: const HomeScreen(),
    );
  }
}