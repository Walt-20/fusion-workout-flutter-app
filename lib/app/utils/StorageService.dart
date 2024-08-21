import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  StorageService() : ref = FirebaseStorage.instance.ref();

  final Reference ref;

  Future<void> uploadFile(String fileName, XFile file) async {
    try {
      final String directoryPath =
          'userFiles/${FirebaseAuth.instance.currentUser?.uid}/$fileName';
      final imageRef = ref.child(directoryPath);
      final imageBytes = await file.readAsBytes();
      await imageRef.putData(imageBytes);
    } catch (e) {
      print('Could not upload file.');
    }
  }

  Future<Uint8List?> getFile(String fileName) async {
    try {
      final imageRef = ref.child(
          'userFiles/${FirebaseAuth.instance.currentUser?.uid}/$fileName');
      return imageRef.getData();
    } catch (e) {
      print('Could not get file.');
    }
  }

  Future<void> deleteFile(String fileName) async {
    final deleteRef = ref
        .child('userFiles/${FirebaseAuth.instance.currentUser?.uid}/$fileName');

    await deleteRef.delete();
  }
}
