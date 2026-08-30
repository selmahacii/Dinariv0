// MAIN.DART
// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:dinari/src/core/utils/constants/app_colors.dart';
import 'package:dinari/src/presentation/screens/WELIT/contacts_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// CHAT LIST SCREEN
class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(),
      body:
          currentUser == null
              ? const Center(child: Text('Please login to view chats'))
              : StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('chats')
                        .where('participants', arrayContains: currentUser?.uid)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  var chatDocs = snapshot.data?.docs ?? [];
                  // chatDocs.removeWhere(
                  // );

                  if (chatDocs.isEmpty) {
                    return const Center(child: Text('No chats yet'));
                  }

                  return SafeArea(
                    child: Column(
                      children: [
                        // Row(
                        //   mainAxisSize: MainAxisSize.max,
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: [
                        //     Expanded(child: SearchWidget()),
                        //     IconButton(
                        //       onPressed: () {},
                        //       icon: Icon(
                        //         Icons.add_circle_outline,
                        //         color: AppColors.instance.primaryColor,
                        //         size: 40.r,
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: chatDocs.length,
                            itemBuilder: (context, index) {
                              final chatData =
                                  chatDocs[index].data()
                                      as Map<String, dynamic>;
                              final chatId = chatDocs[index].id;
                              final participants = List<String>.from(
                                chatData['participants'] ?? [],
                              );

                              // Remove current user to get the other participant
                              participants.remove(currentUser?.uid);
                              final otherUserId =
                                  participants.isNotEmpty
                                      ? participants.first
                                      : 'Unknown';

                              // Get last message details
                              final lastMessage =
                                  chatData['lastMessage'] as String? ??
                                  'No messages';
                              final lastMessageTime =
                                  chatData['lastMessageTime'] as Timestamp? ??
                                  Timestamp.now();
                              final formattedTime = _formatTime(
                                lastMessageTime.toDate(),
                              );
                              final seen = chatData['seen'] as bool? ?? true;

                              return FutureBuilder<DocumentSnapshot>(
                                future:
                                    FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(otherUserId)
                                        .get(),
                                builder: (context, userSnapshot) {
                                  String username = 'Loading...';

                                  if (userSnapshot.connectionState ==
                                          ConnectionState.done &&
                                      userSnapshot.data != null) {
                                    final userData =
                                        userSnapshot.data!.data()
                                            as Map<String, dynamic>?;
                                    username =
                                        userData?['fullName'] as String? ??
                                        'Unknown User';
                                  }

                                  return ListTile(
                                    leading: CircleAvatar(
                                      child: Text(
                                        username.isNotEmpty
                                            ? username[0].toUpperCase()
                                            : '?',
                                      ),
                                    ),
                                    title: Text(username),
                                    subtitle: Text(
                                      lastMessage,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    trailing: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          formattedTime,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        if (!seen)
                                          Container(
                                            margin: const EdgeInsets.only(
                                              top: 4,
                                            ),
                                            width: 10,
                                            height: 10,
                                            decoration: const BoxDecoration(
                                              color: Colors.blue,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                      ],
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => ChatScreen(
                                                chatId: chatId,
                                                otherUserId: otherUserId,
                                                otherUserName: username,
                                              ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    if (now.year == time.year &&
        now.month == time.month &&
        now.day == time.day) {
      // Today
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (now.difference(time).inDays < 7) {
      // This week
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[time.weekday - 1];
    } else {
      // Older
      return '${time.day}/${time.month}/${time.year}';
    }
  }
}

class SearchWidget extends StatefulWidget {
  const SearchWidget({super.key});

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final currentUser = FirebaseAuth.instance.currentUser;
  final TextEditingController _searchController = TextEditingController();
  List<UserSearchResult> _searchResults = [];
  bool _isSearching = false;

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      // Search by name
      final QuerySnapshot nameResults =
          await FirebaseFirestore.instance
              .collection('chats')
              .where('participants', arrayContains: currentUser?.uid)
              .where('fullName', isGreaterThanOrEqualTo: query)
              .where('fullName', isLessThanOrEqualTo: query + '\uf8ff')
              .limit(5)
              .get();

      // Search by phone
      final QuerySnapshot phoneResults =
          await FirebaseFirestore.instance
              .collection('users')
              .where('phoneNumber', isGreaterThanOrEqualTo: query)
              .where('phoneNumber', isLessThanOrEqualTo: query + '\uf8ff')
              .limit(5)
              .get();

      // Search by email
      final QuerySnapshot emailResults =
          await FirebaseFirestore.instance
              .collection('users')
              .where('email', isGreaterThanOrEqualTo: query)
              .where('email', isLessThanOrEqualTo: query + '\uf8ff')
              .limit(5)
              .get();

      // Combine results and remove duplicates
      final Map<String, UserSearchResult> combinedResults = {};

      // Skip current user
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;

      for (var doc in [
        ...nameResults.docs,
        ...phoneResults.docs,
        ...emailResults.docs,
      ]) {
        if (doc.id != currentUserId && !combinedResults.containsKey(doc.id)) {
          combinedResults[doc.id] = UserSearchResult.fromFirestore(doc);
        }
      }

      setState(() {
        _searchResults = combinedResults.values.toList();
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      print('Error searching users: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Rechercher un utilisateur',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
              suffixIcon:
                  _searchController.text.isNotEmpty
                      ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchResults = [];
                          });
                        },
                      )
                      : null,
              hintText: 'Rechercher par nom, téléphone ou email',
            ),
            onChanged: (value) {
              _searchUsers(value);
            },
          ),
        ),
        // Display search results if there are any
        if (_searchResults.isNotEmpty)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Résultats de recherche',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children:
                        _searchResults
                            .map(
                              (user) => ListTile(
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.instance.primaryColor,
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                                title: Text(user.name),
                                subtitle: Text(user.phone),
                                trailing: IconButton(
                                  icon: Icon(Icons.add_circle_outline),
                                  onPressed: () {},
                                  // onPressed:  () => _addToContacts(user),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ),
              ],
            ),
          ),

        if (_isSearching)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          ),

        // if (_searchQuery.isEmpty ||
        //     (_searchResults.isEmpty && !_isSearching))
      ],
    );
  }
}

// NEW CHAT SCREEN
class NewChatScreen extends StatelessWidget {
  const NewChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('New Chat')),
      body:
          currentUser == null
              ? const Center(child: Text('Please login to create new chats'))
              : StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final userDocs = snapshot.data?.docs ?? [];

                  return ListView.builder(
                    itemCount: userDocs.length,
                    itemBuilder: (context, index) {
                      final userData =
                          userDocs[index].data() as Map<String, dynamic>;
                      final userId = userDocs[index].id;

                      // Skip current user
                      if (userId == currentUser.uid) {
                        return const SizedBox();
                      }

                      final fullName =
                          userData['fullName'] as String? ?? 'Unknown User';
                      final email = userData['email'] as String? ?? 'No email';

                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            fullName.isNotEmpty
                                ? fullName[0].toUpperCase()
                                : '?',
                          ),
                        ),
                        title: Text(fullName),
                        subtitle: Text(email),
                        onTap: () async {
                          // Check if chat already exists
                          final querySnapshot =
                              await FirebaseFirestore.instance
                                  .collection('chats')
                                  .where(
                                    'participants',
                                    arrayContains: currentUser.uid,
                                  )
                                  .get();

                          String? existingChatId;

                          for (final doc in querySnapshot.docs) {
                            final participants = List<String>.from(
                              doc['participants'] as List<dynamic>,
                            );
                            if (participants.contains(userId)) {
                              existingChatId = doc.id;
                              break;
                            }
                          }

                          // Navigate to existing chat or create new one
                          if (existingChatId != null) {
                            if (!context.mounted) return;
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ChatScreen(
                                      chatId: existingChatId!,
                                      otherUserId: userId,
                                      otherUserName: fullName,
                                    ),
                              ),
                            );
                          } else {
                            // Create new chat
                            final chatRef = await FirebaseFirestore.instance
                                .collection('chats')
                                .add({
                                  'participants': [currentUser.uid, userId],
                                  'lastMessage': '',
                                  'lastMessageTime':
                                      FieldValue.serverTimestamp(),
                                  'lastMessageSenderId': '',
                                  'seen': true,
                                });

                            if (!context.mounted) return;
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ChatScreen(
                                      chatId: chatRef.id,
                                      otherUserId: userId,
                                      otherUserName: fullName,
                                    ),
                              ),
                            );
                          }
                        },
                      );
                    },
                  );
                },
              ),
    );
  }
}

// CHAT SCREEN
class ChatScreen extends StatefulWidget {
  final String chatId;
  final String otherUserId;
  final String otherUserName;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _markAsSeen();
    });
  }

  Future<void> _markAsSeen() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .get()
        .then((doc) {
          final data = doc.data();
          if (data != null && data['lastMessageSenderId'] != currentUser.uid) {
            FirebaseFirestore.instance
                .collection('chats')
                .doc(widget.chatId)
                .update({'seen': true});
          }
        });
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Add message to subcollection
      final messageRef = FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages');

      await messageRef.add({
        'message': message,
        'senderId': currentUser.uid,
        'messageTime': FieldValue.serverTimestamp(),
      });

      // Update chat document with last message info
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .update({
            'lastMessage': message,
            'lastMessageTime': FieldValue.serverTimestamp(),
            'lastMessageSenderId': currentUser.uid,
            'seen': false,
          });

      _messageController.clear();

      // Scroll to bottom after sending message
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error sending message: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUserName),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          UserDetailsScreen(userId: widget.otherUserId),
                ),
              );
            },
          ),
        ],
      ),
      body:
          currentUser == null
              ? const Center(child: Text('Please login to view messages'))
              : Column(
                children: [
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream:
                          FirebaseFirestore.instance
                              .collection('chats')
                              .doc(widget.chatId)
                              .collection('messages')
                              .orderBy('messageTime', descending: false)
                              .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                                ConnectionState.waiting &&
                            !snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        }

                        final messageDocs = snapshot.data?.docs ?? [];

                        if (messageDocs.isEmpty) {
                          return const Center(
                            child: Text('No messages yet. Say hello!'),
                          );
                        }

                        // Scroll to bottom when data is initially loaded
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (_scrollController.hasClients) {
                            _scrollController.jumpTo(
                              _scrollController.position.maxScrollExtent,
                            );
                          }
                        });

                        return ListView.builder(
                          controller: _scrollController,
                          itemCount: messageDocs.length,
                          itemBuilder: (context, index) {
                            final messageData =
                                messageDocs[index].data()
                                    as Map<String, dynamic>;
                            final senderId =
                                messageData['senderId'] as String? ?? '';
                            final text =
                                messageData['message'] as String? ?? '';
                            final timestamp =
                                messageData['messageTime'] as Timestamp? ??
                                Timestamp.now();
                            final isMe = senderId == currentUser.uid;

                            return Align(
                              alignment:
                                  isMe
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 4,
                                  horizontal: 8,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: isMe ? Colors.blue : Colors.grey[700],
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.7,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      text,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatTime(timestamp.toDate()),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.white.withOpacity(0.7),
                                      ),
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: const InputDecoration(
                              hintText: 'Type a message',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(24),
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FloatingActionButton(
                          onPressed: _isLoading ? null : _sendMessage,
                          mini: true,
                          child:
                              _isLoading
                                  ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Icon(Icons.send),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

// USER DETAILS SCREEN
class UserDetailsScreen extends StatelessWidget {
  final String userId;

  const UserDetailsScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Details')),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('users').doc(userId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('User not found'));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final fullName = userData['fullName'] as String? ?? 'Unknown';
          final email = userData['email'] as String? ?? 'No email';
          final phoneNumber = userData['phoneNumber'] as String? ?? 'No phone';
          final createdAt =
              userData['createdAt'] as Timestamp? ?? Timestamp.now();
          final updatedAt =
              userData['updatedAt'] as Timestamp? ?? Timestamp.now();
          // final sold = userData['sold'] as int? ?? 0;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    child: Text(
                      fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 36),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildInfoItem('Full Name', fullName),
                _buildInfoItem('Email', email),
                _buildInfoItem('Phone', phoneNumber),
                _buildInfoItem('Created', _formatDateTime(createdAt.toDate())),
                _buildInfoItem('Updated', _formatDateTime(updatedAt.toDate())),
                // _buildInfoItem('Items Sold', sold.toString()),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18)),
          const Divider(),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
