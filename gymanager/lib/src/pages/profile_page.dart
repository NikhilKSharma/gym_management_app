import 'package:flutter/material.dart';
import 'package:gymanager/src/config/app_colors.dart';
import 'package:gymanager/src/models/user_model.dart';
import 'package:gymanager/src/services/api_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<User> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = ApiService.getUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.secondaryText,
      ),
      body: FutureBuilder<User>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.accent));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Could not load profile.'));
          }

          final user = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildProfileCard('Name', user.name, Icons.person_outline),
              _buildProfileCard('Email', user.email, Icons.email_outlined),
              _buildProfileCard('Phone', user.phone, Icons.phone_outlined),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileCard(String title, String subtitle, IconData icon) {
    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, color: AppColors.accent, size: 30),
        title: Text(title,
            style: TextStyle(color: AppColors.secondaryText.withOpacity(0.7))),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
              color: AppColors.secondaryText,
              fontSize: 18,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
