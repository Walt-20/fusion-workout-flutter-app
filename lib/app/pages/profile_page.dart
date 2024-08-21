import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fusion_workouts/app/pages/profile_page_edit.dart';
import 'package:fusion_workouts/app/utils/StorageService.dart';
import 'package:fusion_workouts/features/user_auth/firebase_auth_implementation/firebase_auth_services.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  final StorageService storage = StorageService();
  Uint8List? pickedImage;
  Map<String, dynamic>? profileInfo;
  String? displayName;
  String? email;

  @override
  void initState() {
    super.initState();
    getProfileInformation();
    getProfilePicture();
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

  Future<void> removeAccount() async {
    try {
      try {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .delete();
      } catch (e) {
        debugPrint("whats the deal $e");
      }
      await FirebaseAuth.instance.currentUser!.delete();
      _auth.signOut(context);
    } on FirebaseAuthException catch (e) {
      debugPrint(e.toString());

      if (e.code == "requires-recent-login") {
        await _reauthenticateAndDelete();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _reauthenticateAndDelete() async {
    try {
      final providerData =
          FirebaseAuth.instance.currentUser?.providerData.first;

      if (AppleAuthProvider().providerId == providerData!.providerId) {
        await FirebaseAuth.instance.currentUser!
            .reauthenticateWithProvider(AppleAuthProvider());
      } else if (GoogleAuthProvider().providerId == providerData.providerId) {
        await FirebaseAuth.instance.currentUser!
            .reauthenticateWithProvider(GoogleAuthProvider());
      }

      await FirebaseAuth.instance.currentUser?.delete();
    } catch (e) {
      // Handle exceptions
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
              CircleAvatar(
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
              Text(
                displayName ?? 'No name!',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 24.0,
              ),
              Text(
                email ?? 'No email!',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(237, 255, 134, 21),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfilePageEdit(),
                          ),
                        );
                      },
                      child: const Text(
                        "Edit Profile",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title:
                                    const Text("We are sad to see you go :("),
                                content: const Text(
                                    "Are you sure you want to delete your account?"),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text(
                                      "Cancel",
                                      style: TextStyle(
                                        color:
                                            Color.fromARGB(237, 255, 134, 21),
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                        backgroundColor: Colors.red),
                                    onPressed: () {
                                      removeAccount();
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text(
                                      "Delete",
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                ],
                              );
                            });
                      },
                      child: const Text(
                        "Remove my account",
                        style: TextStyle(
                          color: Colors.white,
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
