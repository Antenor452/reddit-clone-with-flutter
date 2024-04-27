import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_reddit_clone/core/failure.dart';
import 'package:flutter_reddit_clone/core/providers/firebase_providers.dart';
import 'package:flutter_reddit_clone/core/type_defs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:path/path.dart' as p;

final firebaseStorageProvider = Provider((ref) {
  return StorageRepository(
    firebaseStorage: ref.watch(storageProvider),
  );
});

class StorageRepository {
  final FirebaseStorage _firebaseStorage;

  StorageRepository({
    required FirebaseStorage firebaseStorage,
  }) : _firebaseStorage = firebaseStorage;

  FutureEither<String> storeFile(
      {required String path, required String id, required File? file}) async {
    try {
      if (file == null) throw 'No file selected';
      Reference storageRef = _firebaseStorage.ref();
      final extension = p.extension(file.path);
      final ref = storageRef.child(path).child('$id$extension');
      UploadTask uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;

      print('upload state ${snapshot.state}');
      return right(
        await snapshot.ref.getDownloadURL(),
      );
    } on FirebaseException catch (e) {
      throw e.message.toString();
    } catch (e) {
      return left(
        Failure(
          e.toString(),
        ),
      );
    }
  }
}
