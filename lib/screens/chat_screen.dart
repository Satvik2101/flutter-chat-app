import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({Key? key}) : super(key: key);
  static const routeName = '/chat-screen';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chats/5JWofFNT06J2UNl36VJI/messages')
            .snapshots(),
        builder: (ctx,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> streamSnapshot) {
          if (streamSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final documentsData = streamSnapshot.data?.docs;
          return ListView.builder(
            itemCount: documentsData?.length,
            itemBuilder: (ctx, index) => Container(
              padding: const EdgeInsets.all(8),
              child: Text(documentsData?[index]['text']),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          FirebaseFirestore.instance
              .collection('chats/5JWofFNT06J2UNl36VJI/messages')
              .add(
            {'text': 'This was added by floating action button'},
          );
        },
      ),
    );
  }
}
