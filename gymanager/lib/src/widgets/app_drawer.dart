import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gymanager/src/config/app_colors.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: AppColors.accent,
            ),
            child: Text(
              'Gymanager Menu',
              style: TextStyle(
                color: AppColors.surface,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline,
                color: AppColors.secondaryText),
            title: const Text('My Profile',
                style: TextStyle(color: AppColors.secondaryText)),
            onTap: () {
              context.push('/profile'); // Navigate to Profile Page
            },
          ),

          // In app_drawer.dart
          ListTile(
            leading: const Icon(Icons.bar_chart_outlined,
                color: AppColors.secondaryText),
            title: const Text('Analytics',
                style: TextStyle(color: AppColors.secondaryText)),
            onTap: () {
              context.push('/analytics'); // Navigate to Analytics Page
            },
          ),
          const Divider(color: AppColors.background),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.secondaryText),
            title: const Text('Sign Out',
                style: TextStyle(color: AppColors.secondaryText)),
            onTap: () async {
              const storage = FlutterSecureStorage();
              await storage.deleteAll(); // Clear all saved data
              if (context.mounted) {
                context.go('/login'); // Navigate back to login
              }
            },
          ),
        ],
      ),
    );
  }
}
