import 'package:flutter/material.dart';

class ProfileCard extends StatefulWidget {
  const ProfileCard({super.key});

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}



class _ProfileCardState extends State<ProfileCard> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Name text field
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: TextField(
                decoration: const InputDecoration(
                  hintText: 'habib hamouti',
                  border: UnderlineInputBorder(),
                  contentPadding: EdgeInsets.zero,
                ),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              contentPadding: EdgeInsets.zero,
            ),

            const SizedBox(height: 8),

            // Email text field
            ListTile(
              leading: const Icon(Icons.email, color: Colors.blue),
              title: TextField(
                decoration: const InputDecoration(
                  hintText: 'habib@gmail.com',
                  border: UnderlineInputBorder(),
                  contentPadding: EdgeInsets.zero,
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              contentPadding: EdgeInsets.zero,
            ),

            // Phone number text field
            ListTile(
              leading: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage('https://flagcdn.com/w20/dz.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, color: Colors.black54),
                ],
              ),
              title: TextField(
                decoration: const InputDecoration(
                  hintText: '+(213) 777-95-13-64',
                  border: UnderlineInputBorder(),
                  contentPadding: EdgeInsets.zero,
                ),
                keyboardType: TextInputType.phone,
              ),
              contentPadding: EdgeInsets.zero,
            ),

            // Password text field
            ListTile(
              leading: const Icon(Icons.lock, color: Colors.blue),
              title: TextField(
                decoration: InputDecoration(
                  hintText: '*******',
                  border: const UnderlineInputBorder(),
                  contentPadding: EdgeInsets.zero,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.black26,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscurePassword,
              ),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}
