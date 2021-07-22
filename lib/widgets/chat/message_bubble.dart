import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    Key? key,
    required this.message,
    required this.userImage,
    required this.isMe,
    required this.username,
    required this.isMessageByNewUser,
  }) : super(key: key);

  final String message;
  final String userImage;
  final bool isMe;
  final String username;
  final bool isMessageByNewUser;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: isMe
                    ? Colors.grey
                    : Theme.of(context).accentColor.withOpacity(0.7),
                borderRadius: BorderRadius.circular(15).copyWith(
                    // bottomLeft: isMe ? const Radius.circular(15) : Radius.zero,
                    // bottomRight: isMe ? Radius.zero : const Radius.circular(15),
                    ),
              ),
              //width: 150,
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              margin: EdgeInsets.symmetric(
                      vertical: isMessageByNewUser ? 15 : 1, horizontal: 8)
                  .copyWith(
                bottom: 1,
              ),
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (isMessageByNewUser)
                    Text(
                      username,
                      style: TextStyle(
                        color: isMe ? Colors.black : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: isMe ? TextAlign.right : TextAlign.left,
                    ),
                  if (isMessageByNewUser)
                    const SizedBox(
                      height: 8,
                    ),
                  Text(
                    message,
                    style: TextStyle(
                      color: isMe ? Colors.black : Colors.white,
                    ),
                    textAlign: isMe ? TextAlign.right : TextAlign.left,
                  ),
                ],
              ),
            ),
            if (isMessageByNewUser)
              Positioned(
                right: isMe ? null : -2,
                left: isMe ? -2 : null,
                top: 0,
                child: CircleAvatar(
                  backgroundImage: NetworkImage(userImage),
                ),
              ),
          ],
          clipBehavior: Clip.none,
        ),
      ],
    );
  }
}
