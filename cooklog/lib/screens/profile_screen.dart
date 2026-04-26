import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/image_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final ImageService _imageService = ImageService();
  UserModel? _user;
  bool _isLoading = true;
  bool _isSaving = false;
  int _currentIndex = 3;

  File? _imageFile;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _loadUser();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final user = await _authService.getCurrentUserData();
    setState(() {
      _user = user;
      _nameController.text = user?.name ?? '';
      _isLoading = false;
    });
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFFFE0CC),
                  child: Icon(Icons.photo_library, color: Color(0xFFE8733A)),
                ),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final file = await _imageService.pickFromGallery();
                  if (file != null) setState(() => _imageFile = file);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFFFE0CC),
                  child: Icon(Icons.camera_alt, color: Color(0xFFE8733A)),
                ),
                title: const Text('Take a Photo'),
                onTap: () async {
                  Navigator.pop(context);
                  final file = await _imageService.pickFromCamera();
                  if (file != null) setState(() => _imageFile = file);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditNameDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Edit Name', style: GoogleFonts.jost(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: _nameController,
          style: GoogleFonts.jost(),
          decoration: InputDecoration(
            hintText: 'Enter your name',
            hintStyle: GoogleFonts.jost(color: Colors.black26),
            enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black12)),
            focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFE8733A), width: 2)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.jost(color: Colors.black45)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {});
            },
            child: Text('OK',
                style: GoogleFonts.jost(color: const Color(0xFFE8733A))),
          ),
        ],
      ),
    );
  }

  void _saveProfile() async {
    if (_nameController.text.isEmpty) return;
    setState(() => _isSaving = true);

    String? photoUrl = _user?.photoUrl;
    if (_imageFile != null) {
      photoUrl = await _imageService.uploadImage(_imageFile!, 'profiles');
    }

    await _authService.updateProfile(
      name: _nameController.text,
      photoUrl: photoUrl,
    );

    await _loadUser();
    setState(() {
      _isSaving = false;
      _imageFile = null;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated!')),
      );
    }
  }

  void _logout() async {
    await _authService.logout();
    if (mounted) Navigator.pushReplacementNamed(context, 'login');
  }

  void onTabTapped(int index) {
    setState(() => _currentIndex = index);
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, 'home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, 'my_recipe');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, 'favorite');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFFE8733A),
        unselectedItemColor: Colors.black38,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        onTap: onTabTapped,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.book_outlined), label: 'My Recipe'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite_outline), label: 'Favorite'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
      body: _isLoading
          ? const Center(
          child: CircularProgressIndicator(color: Color(0xFFE8733A)))
          : CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xFFE8733A),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFE8733A),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 48),
                    GestureDetector(
                      onTap: _showImageSourceSheet,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundColor:
                            Colors.white.withOpacity(0.3),
                            backgroundImage: _imageFile != null
                                ? FileImage(_imageFile!)
                                : _user?.photoUrl != null
                                ? NetworkImage(_user!.photoUrl!)
                                : null,
                            child: _imageFile == null &&
                                _user?.photoUrl == null
                                ? Text(
                              _user?.name.isNotEmpty == true
                                  ? _user!.name[0].toUpperCase()
                                  : '?',
                              style: GoogleFonts.jost(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt,
                                  color: Color(0xFFE8733A), size: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _nameController.text.isNotEmpty
                          ? _nameController.text
                          : (_user?.name ?? ''),
                      style: GoogleFonts.jost(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      _user?.email ?? '',
                      style: GoogleFonts.jost(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account',
                    style: GoogleFonts.jost(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black45,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildMenuItem(
                    icon: Icons.person_outline,
                    title: 'Name',
                    subtitle: _nameController.text.isNotEmpty
                        ? _nameController.text
                        : (_user?.name ?? '-'),
                    onTap: _showEditNameDialog,
                  ),
                  _buildMenuItem(
                    icon: Icons.email_outlined,
                    title: 'Email',
                    subtitle: _user?.email ?? '-',
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE8733A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: _isSaving
                          ? const CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2)
                          : Text(
                        'Save Changes',
                        style: GoogleFonts.jost(
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Logout',
                    style: GoogleFonts.jost(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black45,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout),
                      label: Text(
                        'Logout',
                        style: GoogleFonts.jost(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE8733A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFE0CC),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFFE8733A), size: 20),
        ),
        title: Text(title,
            style:
            GoogleFonts.jost(fontSize: 14, fontWeight: FontWeight.w500)),
        subtitle: subtitle != null
            ? Text(subtitle,
            style: GoogleFonts.jost(fontSize: 13, color: Colors.black45))
            : null,
        trailing: onTap != null
            ? const Icon(Icons.chevron_right, color: Colors.black38)
            : null,
        onTap: onTap,
      ),
    );
  }
}