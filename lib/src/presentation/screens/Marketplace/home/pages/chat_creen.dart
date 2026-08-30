import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String userId;
  final String otherUserId;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.userId,
    required this.otherUserId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _updateMessageStatus();
    _setupTypingListener();
  }

  void _setupTypingListener() {
    _firestore.collection('chats').doc(widget.chatId).snapshots().listen((
      snapshot,
    ) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        final typingUsers = data['typingUsers'] as Map<String, dynamic>?;
        if (typingUsers != null &&
            typingUsers.containsKey(widget.otherUserId) &&
            typingUsers[widget.otherUserId] == true) {
          setState(() => _isTyping = true);
        } else {
          setState(() => _isTyping = false);
        }
      }
    });
  }

  void _updateMessageStatus() async {
    await _firestore
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .where('status', isLessThan: 'read')
        .where('senderId', isNotEqualTo: widget.userId)
        .get()
        .then((snapshot) {
          for (var doc in snapshot.docs) {
            doc.reference.update({'status': 'read'});
          }
        });
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final message = {
      'content': _messageController.text.trim(),
      'senderId': widget.userId,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'sent',
      'type': 'text',
    };

    try {
      await _firestore
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .add(message);

      await _firestore.collection('chats').doc(widget.chatId).update({
        'lastMessage': message['content'],
        'lastMessageTime': FieldValue.serverTimestamp(),
        'typingUsers.${widget.userId}': false,
      });
    } catch (e) {
      print('Error sending message: $e');
    } finally {
      _messageController.clear();
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<DocumentSnapshot>(
          stream:
              _firestore
                  .collection('users')
                  .doc(widget.otherUserId)
                  .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return SizedBox();
            final user = snapshot.data!.data() as Map<String, dynamic>;
            return Row(
              children: [
                CircleAvatar(backgroundImage: NetworkImage(user['photoUrl'])),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user['name']),
                    StreamBuilder<DocumentSnapshot>(
                      stream:
                          _firestore
                              .collection('presence')
                              .doc(widget.otherUserId)
                              .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return SizedBox();
                        final presence =
                            snapshot.data!.data() as Map<String, dynamic>? ??
                            {};
                        return Text(
                          presence['status'] ?? 'Offline',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                presence['status'] == 'Online'
                                    ? Colors.green
                                    : Colors.grey,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  _firestore
                      .collection('chats')
                      .doc(widget.chatId)
                      .collection('messages')
                      .orderBy('timestamp')
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();

                final messages =
                    snapshot.data!.docs
                        .map((doc) => doc.data() as Map<String, dynamic>)
                        .toList();

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message['senderId'] == widget.userId;

                    return GestureDetector(
                      onTap: () {
                        setState(() => _expanded = !_expanded);
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              isMe
                                  ? Colors.blueAccent.withOpacity(0.2)
                                  : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              message['content'],
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  DateFormat('HH:mm').format(
                                    (message['timestamp'] as Timestamp)
                                        .toDate(),
                                  ),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(width: 4),
                                message['status'] == 'read'
                                    ? Icon(
                                      Icons.done_all,
                                      color: Colors.blue,
                                      size: 16,
                                    )
                                    : message['status'] == 'delivered'
                                    ? Icon(
                                      Icons.done,
                                      color: Colors.grey,
                                      size: 16,
                                    )
                                    : SizedBox(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (_isTyping)
            Padding(
              padding: EdgeInsets.only(left: 16, bottom: 8),
              child: Text('Typing...', style: TextStyle(color: Colors.grey)),
            ),
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    onChanged: (text) {
                      _firestore.collection('chats').doc(widget.chatId).update({
                        'typingUsers.${widget.userId}': text.isNotEmpty,
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(icon: Icon(Icons.send), onPressed: _sendMessage),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
