import 'dart:typed_data';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fusion_workouts/app/utils/StorageService.dart';
import 'package:fusion_workouts/features/user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  final StorageService storage = StorageService();
  Uint8List? pickedImage;
  String? displayName;
  String? email;

  @override
  void initState() {
    super.initState();
    getProfilePicture();
    getProfileInformation();
  }

  Future<void> uploadProfilePicture() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    await storage.uploadFile('user_1.jpg', image);
    final imageBytes = await image.readAsBytes();
    setState(() {
      pickedImage = imageBytes;
    });
  }

  Future<void> getProfilePicture() async {
    final imageRef = storage.getFile('user_1.jpg');

    try {
      final imageBytes = await storage.getFile('user_1.jpg');
      if (imageBytes == null) return;
      setState(() {
        pickedImage = imageBytes;
      });
    } catch (e) {
      print('Profile picture could not be found');
    }
  }

  Future<void> getProfileInformation() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        displayName = user.displayName;
        email = user.email;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(237, 255, 134, 21),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            key: const Key('logoutButton'),
            icon: const Icon(Icons.logout),
            onPressed: () => {
              _auth.signOut(context),
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 20.0,
              ),
              GestureDetector(
                onTap: uploadProfilePicture,
                child: CircleAvatar(
                  backgroundColor: Colors.grey,
                  radius: 50,
                  backgroundImage: pickedImage != null
                      ? Image.memory(
                          pickedImage!,
                          fit: BoxFit.cover,
                        ).image
                      : null,
                  child: pickedImage == null
                      ? const Icon(
                          Icons.person_rounded,
                          color: Colors.black,
                          size: 35,
                        )
                      : null,
                ),
              ),
              Text(
                displayName ?? 'Update display name!',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 24.0,
              ),
              Text(
                email ?? 'Update display email!',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
