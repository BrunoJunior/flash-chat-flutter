import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/constants.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  static const String id = '/chat';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _store = Firestore.instance;
  final msgTxtCtrl = TextEditingController();
  FirebaseUser loggedInUser;
  String messageToAdd;

  @override
  void initState() {
    super.initState();
    _auth
        .currentUser()
        .then((user) => user != null ? loggedInUser = user : null)
        .catchError((err) => print(err));
    messages;
  }

  Stream<List<Widget>> get messages {
    return _store
        .collection('messages')
        .snapshots()
        .where((snapshot) => snapshot.documents.length > 0)
        .map((snapshot) => snapshot.documents.reversed
            .where((document) => document.data["sender"].toString().length > 0)
            .map((document) => MessageBubble(
                  sender: document.data["sender"],
                  message: document.data["text"],
                  isMe: document.data["sender"] == loggedInUser.email,
                ))
            .toList());
  }

  logOut(BuildContext context) async {
    await _auth.signOut();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () => logOut(context),
          ),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<List<Widget>>(
              stream: messages,
              builder: (context, snapshot) => snapshot.hasData
                  ? Expanded(
                      child: ListView(
                        children: snapshot.data,
                        reverse: true,
                      ),
                    )
                  : Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.white70,
                      ),
                    ),
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: msgTxtCtrl,
                      onChanged: (value) => messageToAdd = value,
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () async {
                      await _store.collection('messages').add(
                          {"text": messageToAdd, "sender": loggedInUser.email});
                      msgTxtCtrl.clear();
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String sender, message;
  final bool isMe;
  final radius = Radius.circular(20.0);
  MessageBubble(
      {@required this.sender, @required this.message, this.isMe = false});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: <Widget>[
          Text(
            isMe ? "Me" : sender,
            style: TextStyle(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),
          Material(
            color: isMe ? Colors.white : Colors.lightBlue,
            borderRadius: BorderRadius.only(
              topLeft: (isMe ? Radius.zero : radius),
              topRight: (isMe ? radius : Radius.zero),
              bottomLeft: radius,
              bottomRight: radius,
            ),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                message,
                style: TextStyle(
                  color: isMe ? Colors.black54 : Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
