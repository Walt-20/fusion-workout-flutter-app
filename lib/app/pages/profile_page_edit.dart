import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:fusion_workouts/app/models/entry.dart';
import 'package:fusion_workouts/app/pages/profile_page.dart';
import 'package:fusion_workouts/app/utils/StorageService.dart';
import 'package:fusion_workouts/app/widgets/form_container_widget.dart';
import 'package:fusion_workouts/features/user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePageEdit extends StatefulWidget {
  const ProfilePageEdit({super.key});

  @override
  State<ProfilePageEdit> createState() => _ProfilePageEditState();
}

class _ProfilePageEditState extends State<ProfilePageEdit> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  final StorageService storage = StorageService();
  Uint8List? pickedImage;
  Map<String, dynamic>? profileInfo;
  String displayName = '';
  String email = '';
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getProfileInformation();
    getProfilePicture();
  }

  Future<void> uploadProfilePicture() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    await storage.uploadFile('profile_picture.jpg', image);
    final imageBytes = await image.readAsBytes();
    setState(() {
      pickedImage = imageBytes;
    });
  }

  Future<void> getProfilePicture() async {
    try {
      final imageBytes = await storage.getFile('profile_picture.jpg');
      if (imageBytes != null) {
        setState(() {
          pickedImage = imageBytes;
        });
      } else {
        print('No profile picture found.');
      }
    } catch (e) {
      print('Error fetching profile picture: $e');
    }
  }

  Future<void> getProfileInformation() async {
    profileInfo = await _auth.fetchProfileInformation();

    if (profileInfo != null) {
      displayName = profileInfo?['name'];
      email = profileInfo?['email'];
    }

    setState(() {});
  }

  Future<void> savePorfile() async {
    String newName = _displayNameController.text.isEmpty
        ? displayName
        : _displayNameController.text;

    String newEmail =
        _emailController.text.isEmpty ? email : _emailController.text;

    await _auth.saveProfile(newName, newEmail);
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
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
              SizedBox(
                height: 16.0,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Name',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FormContainerWidget(
                      controller: _displayNameController,
                      key: Key('name'),
                      hintText: displayName,
                      isPasswordField: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 24.0,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Email',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FormContainerWidget(
                      controller: _emailController,
                      key: Key('email'),
                      hintText: email,
                      isPasswordField: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 24.0,
              ),
              const Spacer(),
              Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        savePorfile();
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        "Save Profile",
                        style: TextStyle(
                          color: Color.fromARGB(237, 255, 134, 21),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
