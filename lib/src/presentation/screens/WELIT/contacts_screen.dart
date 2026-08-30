import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dinari/src/core/utils/constants/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class Contact {
  final String id;
  final String name;
  final Timestamp updatedAt;
  final String phone;

  Contact({
    required this.id,
    required this.name,
    required this.updatedAt,
    required this.phone,
  });

  // Factory constructor to create a Contact from a Firestore document
  factory Contact.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Contact(
      id: doc.id,
      name: data['name'] ?? 'No Name',
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
      phone: data['phone'] ?? 'No Phone',
    );
  }
}

// New class to represent users from search results
class UserSearchResult {
  final String id;
  final String name;
  final String phone;
  final String? email;

  UserSearchResult({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
  });

  factory UserSearchResult.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserSearchResult(
      id: doc.id,
      name: data['fullName'] ?? 'No Name',
      phone: data['phoneNumber'] ?? 'No Phone',
      email: data['email'],
    );
  }
}

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});
  @override
  createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Contact> _contacts = [];
  List<UserSearchResult> _searchResults = [];
  bool _isLoading = true;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future<void> _fetchContacts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('contacts')
              .orderBy('updatedAt', descending: true)
              .get();

      setState(() {
        _contacts =
            snapshot.docs.map((doc) => Contact.fromFirestore(doc)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching contacts: $e');
    }
  }

  // New method to search for users
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
              .collection('users')
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

  // Method to add a user to contacts
  Future<void> _addToContacts(UserSearchResult user) async {
    context.push('/home-welit/money-transfer-welit', extra: user.id);
    // try {
    //   // First check if this user is already in contacts
    //   final contactsRef = FirebaseFirestore.instance
    //       .collection('users')
    //       .doc(FirebaseAuth.instance.currentUser!.uid)
    //       .collection('contacts');

    //   final existingContact = await contactsRef.doc(user.id).get();

    //   if (existingContact.exists) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text('Ce contact existe déjà dans votre liste')),
    //     );
    //     return;
    //   }

    //   // Add to contacts
    //   await contactsRef.doc(user.id).set({
    //     'name': user.name,
    //     'phone': user.phone,
    //     'email': user.email,
    //     'updatedAt': Timestamp.now(),
    //   });

    //   // Clear search and refresh contacts
    //   _searchController.clear();
    //   setState(() {
    //     _searchQuery = '';
    //     _searchResults = [];
    //   });

    //   await _fetchContacts();

    //   ScaffoldMessenger.of(
    //     context,
    //   ).showSnackBar(SnackBar(content: Text('Contact ajouté avec succès')));
    // } catch (e) {
    //   print('Error adding contact: $e');
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Erreur lors de l\'ajout du contact')),
    //   );
    // }
  }

  List<Contact> get filteredContacts {
    return _contacts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text('Envoyer')),
      body: Column(
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
                              _searchQuery = '';
                              _searchResults = [];
                            });
                          },
                        )
                        : null,
                hintText: 'Rechercher par nom, téléphone ou email',
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
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
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
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
                                    onPressed: () => _addToContacts(user),
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

          // Show existing contacts if not searching or no results
          if (_searchQuery.isEmpty || (_searchResults.isEmpty && !_isSearching))
            Expanded(
              child:
                  _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : _contacts.isEmpty
                      ? Center(child: Text('Aucun contact trouvé.'))
                      : _buildContactsList(filteredContacts),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchContacts,
        tooltip: 'Rafraîchir les contacts',
        child: Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildContactsList(List<Contact> contacts) {
    // Create separate lists for recent and all contacts
    final recentContacts = contacts.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 4.0),
          child: Text(
            'Recent',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),

        // Use a fixed height container for the first list
        Container(
          height: 100.h,
          padding: REdgeInsets.symmetric(horizontal: 16),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: recentContacts.length,
            itemBuilder: (context, index) {
              var contact = recentContacts[index];
              return InkWell(
                onTap: () {
                  context.push(
                    '/home-welit/money-transfer-welit',
                    extra: contact.id,
                  );
                },
                child: Padding(
                  padding: REdgeInsets.all(8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 50.r,
                        height: 50.r,
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
                      4.verticalSpace,
                      Text(contact.name.split(' ').first),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 4.0),
          child: Text(
            'Tout',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        // Use Expanded for the main list to fill remaining space
        Expanded(
          child: ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              var contact = contacts[index];
              return _buildContactTile(contact);
            },
          ),
        ),
      ],
    );
  }

  // Extract the tile building logic to avoid duplication
  Widget _buildContactTile(Contact contact) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.instance.primaryColor,
        ),
        child: Icon(Icons.person, color: Colors.white, size: 30),
      ),
      title: Text(contact.name),
      subtitle: Text(contact.phone),
      onTap: () {
        context.push('/home-welit/money-transfer-welit', extra: contact.id);
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
