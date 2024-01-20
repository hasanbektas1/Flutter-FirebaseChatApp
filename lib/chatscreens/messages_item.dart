import 'dart:math';

import 'package:flutter/material.dart';

class MessageWidget extends StatelessWidget {
  final String sender;
  final String text;
  final String imageUrl;
  final bool isMe;

  MessageWidget(
      {required this.sender,
      required this.text,
      required this.imageUrl,
      required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) _buildAvatar(imageUrl),
          const SizedBox(width: 4.0),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                _buildMessageContainer(isMe),
              ],
            ),
          ),
          const SizedBox(width: 4.0),
          if (isMe) _buildAvatar(imageUrl),
        ],
      ),
    );
  }

  Widget _buildAvatar(String imageUrl) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: Colors.grey,
      foregroundImage: NetworkImage(imageUrl),
    );
  }

  Widget _buildMessageContainer(bool isMe) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: isMe ? Colors.blue : Colors.blue[100],
        borderRadius: BorderRadius.only(
          topLeft: isMe ? Radius.circular(12.0) : Radius.zero,
          topRight: Radius.circular(12.0),
          bottomLeft: Radius.circular(12.0),
          bottomRight: isMe ? Radius.zero : Radius.circular(12.0),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isMe
                  ? Colors.black
                  : Color.fromARGB(
                      255,
                      Random().nextInt(256),
                      Random().nextInt(256),
                      Random().nextInt(256),
                    ),
            ),
          ),
          SizedBox(height: 4.0),
          Text(
            text,
            style: TextStyle(
              fontSize: 17,
              color: isMe ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
