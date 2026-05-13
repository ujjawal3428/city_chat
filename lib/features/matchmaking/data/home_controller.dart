import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {

  /// ── Observables ──────────────────────────────────────────────
  final RxString selectedCountry  = 'India'.obs;
  final RxString selectedCity     = 'Indore'.obs;
  final RxString selectedGender   = 'Female'.obs;
  final RxBool   isOnline         = true.obs;
  final RxBool   isMatching       = false.obs;

  /// ── Camera ───────────────────────────────────────────────────
  CameraController? cameraController;
  final RxBool isCameraReady = false.obs;
  final RxBool isCameraOn    = true.obs;   // user can mute camera

  /// ── Data ─────────────────────────────────────────────────────
  final Map<String, List<String>> countryCityMap = {
    'India':        ['Indore', 'Mumbai', 'Delhi', 'Bangalore', 'Chennai', 'Hyderabad', 'Kolkata', 'Pune'],
    'USA':          ['New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix', 'San Francisco'],
    'UK':           ['London', 'Manchester', 'Birmingham', 'Leeds', 'Glasgow', 'Liverpool'],
    'Canada':       ['Toronto', 'Vancouver', 'Montreal', 'Calgary', 'Ottawa', 'Edmonton'],
    'Australia':    ['Sydney', 'Melbourne', 'Brisbane', 'Perth', 'Adelaide'],
    'Germany':      ['Berlin', 'Munich', 'Hamburg', 'Frankfurt', 'Cologne'],
    'France':       ['Paris', 'Lyon', 'Marseille', 'Toulouse', 'Nice'],
    'Japan':        ['Tokyo', 'Osaka', 'Kyoto', 'Nagoya', 'Sapporo'],
    'Brazil':       ['São Paulo', 'Rio de Janeiro', 'Brasília', 'Salvador', 'Fortaleza'],
    'South Africa': ['Johannesburg', 'Cape Town', 'Durban', 'Pretoria'],
  };

  final List<String> genderOptions = ['Any', 'Male', 'Female'];

  /// Cities derived from selected country
  List<String> get cities => countryCityMap[selectedCountry.value] ?? [];

  // ── Lifecycle ─────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _initCamera();
  }

  @override
  void onClose() {
    cameraController?.dispose();
    super.onClose();
  }

  // ── Camera helpers ────────────────────────────────────────────

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      // Prefer front camera
      final front = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      cameraController = CameraController(
        front,
        ResolutionPreset.high,
        enableAudio: true,          // keep audio for the call
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await cameraController!.initialize();
      isCameraReady.value = true;
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  /// Toggle camera on / off without re-initialising the controller
  Future<void> toggleCamera() async {
    if (cameraController == null || !cameraController!.value.isInitialized) return;
    isCameraOn.value = !isCameraOn.value;
  }

  // ── Country / City / Gender ───────────────────────────────────

  void onCountryChanged(String? value) {
    if (value == null) return;
    selectedCountry.value = value;
    selectedCity.value    = countryCityMap[value]?.first ?? '';
  }

  void onCityChanged(String? value) {
    if (value == null) return;
    selectedCity.value = value;
  }

  void onGenderChanged(String? value) {
    if (value == null) return;
    selectedGender.value = value;
  }

  // ── Matching ──────────────────────────────────────────────────

  void startMatching() => isMatching.value = true;
  void stopMatching()  => isMatching.value = false;

  // ── Reusable Widgets ──────────────────────────────────────────

  Widget buildDropdown({
    required String title,
    required IconData icon,
    required RxString selected,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Obx(() => Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xff23262F),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selected.value,
                dropdownColor: const Color(0xff23262F),
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                selectedItemBuilder: (context) => items.map((item) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  );
                }).toList(),
                items: items
                    .map((item) => DropdownMenuItem(
                          value: item,
                          child: Text(
                            item,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ))
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    ));
  }

  Widget buildStartMatchingButton() {
    return Obx(() => GestureDetector(
      onTap: isMatching.value ? stopMatching : startMatching,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 68,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isMatching.value
                ? [const Color(0xffFF4B4B), const Color(0xffFF8C00)]
                : [const Color(0xffFF4B91), const Color(0xff9D44FF)],
          ),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Center(
          child: isMatching.value
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Stop',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
              : const Text(
                  'Start Matching',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    ));
  }
}