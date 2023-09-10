import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tiktok_clone/features/authentication/repos/authentication_repo.dart';
import 'package:tiktok_clone/features/inbox/models/message.dart';
import 'package:tiktok_clone/features/inbox/repos/messages_repo.dart';

class MessagesViewModel extends FamilyAsyncNotifier<void, String> {
  late final MessagesRepo _repo;

  @override
  FutureOr<void> build(String arg) {
    _repo = ref.read(messagesRepo);
  }

  Future<void> sendMessage(
    String text,
  ) async {
    final user = ref.read(authRepo).user;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final message = MessageModel(
        text: text,
        userId: user!.uid,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );
      await _repo.sendMessage(message: message, chatId: arg);
    });
  }
}

final messagesProvider =
    AsyncNotifierProvider.family<MessagesViewModel, void, String>(
  () => MessagesViewModel(),
);

// if there is only GET logic, simple impl without Model
final chatProvider2 =
    StreamProvider.autoDispose.family<List<MessageModel>, String>((ref, arg) {
  final db = FirebaseFirestore.instance;

  return db
      .collection("chatRooms")
      .doc(arg)
      .collection("texts")
      .orderBy("createdAt")
      .snapshots()
      .map(
        (event) => event.docs
            .map(
              (doc) => MessageModel.fromJson(
                doc.data(),
              ),
            )
            .toList()
            .reversed // TODO: can be removed if orderBy("createdAt", descending: true)
            .toList(),
      );
});

// final chatProvider = StreamProvider.autoDispose<List<MessageModel>>((ref) {
//   final db = FirebaseFirestore.instance;

//   return db
//       .collection("chat_rooms")
//       .doc("aaaa")
//       .collection("texts")
//       .orderBy("createdAt")
//       .snapshots()
//       .map(
//         (event) => event.docs
//             .map(
//               (doc) => MessageModel.fromJson(
//                 doc.data(),
//               ),
//             )
//             .toList()
//             .reversed // TODO: can be removed if orderBy("createdAt", descending: true)
//             .toList(),
//       );
// });