import 'package:camera/camera.dart';
import 'package:city_chat/features/matchmaking/data/chat_controller.dart';
import 'package:city_chat/features/matchmaking/data/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController home = Get.put(HomeController());
    final ChatController chat = Get.put(ChatController());
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xff0F1115),
      body: SafeArea(
        child: Column(
          children: [
            // ── TOP BAR ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xffFF4B91), Color(0xff9D44FF)],
                          ),
                        ),
                        child: const Icon(Icons.favorite, color: Colors.white),
                      ),
                      const SizedBox(width: 14),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'City Chat',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Find your perfect stranger',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Online/Offline pill
                  Obx(
                    () => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xff1A1D24),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.circle,
                            color: home.isOnline.value
                                ? Colors.green
                                : Colors.red,
                            size: 12,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            home.isOnline.value ? 'Online' : 'Offline',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── VIDEO + CHAT ──────────────────────────────────────
            SizedBox(
              height: screenHeight * 0.50,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // LEFT — Your camera (60 %)
                    Expanded(
                      flex: 6,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // ── Camera preview (or fallback) ──────
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(28),
                              bottomLeft: Radius.circular(28),
                            ),
                            child: Obx(() {
                              final ready = home.isCameraReady.value;
                              final on = home.isCameraOn.value;

                              if (!ready) {
                                // Still initialising
                                return Container(
                                  color: const Color(0xff1A1D24),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: Color(0xffFF4B91),
                                      strokeWidth: 2,
                                    ),
                                  ),
                                );
                              }

                              if (!on) {
                                // Camera muted by user
                                return Container(
                                  color: const Color(0xff1A1D24),
                                  child: const Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.videocam_off,
                                          color: Colors.white24,
                                          size: 52,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Camera off',
                                          style: TextStyle(
                                            color: Colors.white24,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }

                              // Live preview — mirror it so it feels natural
                              return Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.rotationY(
                                  3.14159,
                                ), // horizontal flip
                                child: CameraPreview(home.cameraController!),
                              );
                            }),
                          ),

                          // "You" label — top left
                          Positioned(
                            top: 14,
                            left: 14,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black45,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    color: Colors.green,
                                    size: 8,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'You',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Camera toggle button — top right
                          Positioned(
                            top: 14,
                            right: 14,
                            child: Obx(
                              () => GestureDetector(
                                onTap: home.toggleCamera,
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: home.isCameraOn.value
                                        ? Colors.black45
                                        : const Color(
                                            0xffFF4B4B,
                                          ).withOpacity(0.85),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    home.isCameraOn.value
                                        ? Icons.videocam
                                        : Icons.videocam_off,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Stranger PiP — bottom right
                          Positioned(
                            right: 14,
                            bottom: 14,
                            child: Container(
                              width: 110,
                              height: 140,
                              decoration: BoxDecoration(
                                color: const Color(0xff23262F),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.white24,
                                  width: 1.5,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  const Center(
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.white24,
                                      size: 40,
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    left: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black45,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Row(
                                        children: [
                                          Icon(
                                            Icons.circle,
                                            color: Colors.green,
                                            size: 6,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            'Stranger',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // RIGHT — Chat panel (40 %)
                    Expanded(
                      flex: 4,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xff15171C),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(28),
                            bottomRight: Radius.circular(28),
                          ),
                        ),
                        child: Column(
                          children: [
                            // Chat header
                            Container(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                14,
                                16,
                                12,
                              ),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Color(0xff23262F),
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    color: Colors.green,
                                    size: 9,
                                  ),
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

                            // Messages
                            Expanded(
                              child: ListView(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                children: [
                                  _chatLine(
                                    sender: 'Stranger',
                                    message: 'heyy! 👋',
                                    isMe: false,
                                  ),
                                  _chatLine(
                                    sender: 'You',
                                    message: 'Hi there! ❤️',
                                    isMe: true,
                                  ),
                                  _chatLine(
                                    sender: 'Stranger',
                                    message: 'Where are you from?',
                                    isMe: false,
                                  ),
                                  _chatLine(
                                    sender: 'You',
                                    message: 'I\'m from Indore! 🌆',
                                    isMe: true,
                                  ),
                                  _chatLine(
                                    sender: 'Stranger',
                                    message: 'Oh nice! What\'s it like there?',
                                    isMe: false,
                                  ),
                                ],
                              ),
                            ),

                            // Input bar
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: Color(0xff23262F),
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 40,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xff1E2128),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const TextField(
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                        ),
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: 'Type a message...',
                                          hintStyle: TextStyle(
                                            color: Colors.white38,
                                            fontSize: 13,
                                          ),
                                          isDense: true,
                                          contentPadding: EdgeInsets.symmetric(
                                            vertical: 10,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xffFF4B91),
                                          Color(0xff9D44FF),
                                        ],
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.send,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── FILTERS ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xff1A1D24),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: home.buildDropdown(
                            title: 'Country',
                            icon: Icons.public,
                            selected: home.selectedCountry,
                            items: home.countryCityMap.keys.toList(),
                            onChanged: home.onCountryChanged,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Obx(
                            () => home.buildDropdown(
                              title: 'City',
                              icon: Icons.location_city,
                              selected: home.selectedCity,
                              items: home.cities,
                              onChanged: home.onCityChanged,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: home.buildDropdown(
                            title: 'Gender',
                            icon: Icons.favorite_border,
                            selected: home.selectedGender,
                            items: home.genderOptions,
                            onChanged: home.onGenderChanged,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: home.buildStartMatchingButton()),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _chatLine({
    required String sender,
    required String message,
    required bool isMe,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$sender: ',
              style: TextStyle(
                color: isMe ? const Color(0xffFF4B91) : const Color(0xff9D44FF),
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: message,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
