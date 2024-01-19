import 'package:flutter/material.dart';

class MessageWidget extends StatelessWidget {
  final String sender;
  final String text;
  final bool isMe;

  MessageWidget({required this.sender, required this.text, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.grey,
            ),
          ),
          Material(
            borderRadius: BorderRadius.circular(10.0),
            elevation: 5.0,
            color: isMe ? Colors.blue : Colors.white,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15.0,
                  color: isMe ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
