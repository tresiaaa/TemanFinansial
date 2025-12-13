import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Get current user data
  String get userId => _auth.currentUser?.uid ?? 'N/A';
  String get userName => _auth.currentUser?.displayName ?? 'User';
  String get userEmail => _auth.currentUser?.email ?? 'No email';
  String userGender = 'Not set';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildProfileHeader(context),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Email
                  _buildProfileItem(context, 'Email', userEmail, showArrow: false),
                  const Divider(),

                  // Name
                  _buildProfileItem(
                    context,
                    'Name',
                    userName,
                    onTap: () {
                      _navigateToEditName(context, userName);
                    },
                  ),
                  const Divider(),

                  // Gender
                  _buildProfileItem(
                    context,
                    'Gender',
                    userGender,
                    onTap: () {
                      _showGenderDialog(context);
                    },
                  ),
                  const Divider(),

                  const Spacer(),
                  
                  // Tombol Logout
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _handleLogout(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF192A56),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Tombol Delete Account
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _showDeleteAccountDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text(
                        'Delete account',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.30,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1976D2), Color(0xFF1565C0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Expanded(
                  child: Text(
                    'Profile',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white,
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976D2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(
    BuildContext context,
    String title,
    String value, {
    VoidCallback? onTap,
    bool showArrow = true,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            Row(
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (showArrow)
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.black54,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Handle Logout with Firebase
  Future<void> _handleLogout(BuildContext context) async {
    // Show confirmation dialog
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: const Text(
            'Logout',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(fontFamily: 'Poppins'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.black54,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(fontFamily: 'Poppins'),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        // Sign out from Firebase
        await _auth.signOut();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Logout berhasil'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );

          // Navigate back to login - AuthWrapper will handle this automatically
          // But we can force navigate to root
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    }
  }

  void _showGenderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Material(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(20),
              width: 250,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Gender',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildGenderButton('Male', () {
                    setState(() => userGender = 'Male');
                    Navigator.pop(context);
                  }),
                  const SizedBox(height: 10),
                  _buildGenderButton('Female', () {
                    setState(() => userGender = 'Female');
                    Navigator.pop(context);
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGenderButton(String text, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.grey),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Poppins',
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: const Text(
            'Delete Account',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Colors.red,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          content: const Text(
            'Are you sure you want to delete this account? This action cannot be undone.',
            style: TextStyle(fontFamily: 'Poppins'),
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.black54,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  // Delete user account from Firebase
                  await _auth.currentUser?.delete();
                  
                  if (context.mounted) {
                    Navigator.pop(context); // Close dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Account deleted successfully'),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                    // Navigate to login
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                } on FirebaseAuthException catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context);
                    String errorMsg = 'Failed to delete account';
                    if (e.code == 'requires-recent-login') {
                      errorMsg = 'Please login again before deleting your account';
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(errorMsg),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text(
                'Delete',
                style: TextStyle(fontFamily: 'Poppins'),
              ),
            ),
          ],
        );
      },
    );
  }

  void _navigateToEditName(BuildContext context, String currentName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditNameScreen(currentName: currentName),
      ),
    );
  }
}

// Edit Name Screen
class EditNameScreen extends StatefulWidget {
  final String currentName;
  const EditNameScreen({required this.currentName, super.key});

  @override
  State<EditNameScreen> createState() => _EditNameScreenState();
}

class _EditNameScreenState extends State<EditNameScreen> {
  late TextEditingController _nameController;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name cannot be empty')),
      );
      return;
    }

    try {
      // Update display name in Firebase
      await _auth.currentUser?.updateDisplayName(_nameController.text.trim());
      await _auth.currentUser?.reload();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Name updated successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'Name',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  heroTag: 'cancelBtn',
                  onPressed: () => Navigator.pop(context),
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.close, color: Colors.white),
                ),
                const SizedBox(width: 30),
                FloatingActionButton(
                  heroTag: 'confirmBtn',
                  onPressed: _saveName,
                  backgroundColor: const Color(0xFF1976D2),
                  child: const Icon(Icons.check, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}