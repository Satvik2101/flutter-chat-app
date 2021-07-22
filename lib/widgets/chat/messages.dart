import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import './message_bubble.dart';

class Messages extends StatelessWidget {
  const Messages({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (ctx,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> chatSnapshot) {
        if (chatSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final chatsData = chatSnapshot.data?.docs;
        final user = FirebaseAuth.instance.currentUser!;
        return ListView.builder(
          reverse: true,
          itemCount: chatsData?.length,
          itemBuilder: (ctx, index) {
            return MessageBubble(
              key: ValueKey(chatsData?[index].id),
              message: chatsData?[index].data()['text'],
              userImage: chatsData?[index].data()['userImage'],
              isMe: chatsData?[index].data()['userId'] == user.uid,
              username: chatsData?[index].data()['username'],
              isMessageByNewUser: index == chatsData!.length - 1
                  ? true
                  : chatsData[index + 1].data()['userId'] !=
                      chatsData[index].data()['userId'],
            );
          },
        );
      },
    );
  }
}
