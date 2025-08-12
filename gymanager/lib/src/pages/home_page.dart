import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gymanager/src/pages/tabs/members_view.dart';
import 'package:gymanager/src/pages/tabs/trainers_view.dart';
import 'package:gymanager/src/widgets/app_drawer.dart';
import '../config/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    MembersView(),
    TrainersView(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'Members' : 'Trainers'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.secondaryText,
      ),
      drawer: const AppDrawer(),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      // In home_page.dart, inside the Scaffold...
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_selectedIndex == 0) {
            // Navigate to Add Member page
            context.push('/add-member');
          } else {
            // Navigate to Add Trainer page
            context.push('/add-trainer');
          }
        },
        // ... rest of FAB code
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            label: 'Members',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center_outlined),
            label: 'Trainers',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.primaryText,
        backgroundColor: AppColors.background,
        onTap: _onItemTapped,
      ),
    );
  }
}
