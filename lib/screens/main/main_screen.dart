import 'package:flutter/material.dart';
import 'package:irondex/screens/archive/archive_screen.dart';
import 'package:irondex/screens/planner/planner_screen.dart';
import 'package:irondex/screens/reviews/reviews_screen.dart';
import 'package:irondex/screens/settings/settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _pages = [
    const ReviewsScreen(),
    const PlannerScreen(),
    const ArchiveScreen(),
    const SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _pages.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey[500],
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: ImageIcon(
              const AssetImage('assets/icon/home.png'),
              color: _selectedIndex == 0
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey[500],
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              const AssetImage('assets/icon/planner.png'),
              color: _selectedIndex == 1
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey[500],
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              const AssetImage('assets/icon/archive.png'),
              color: _selectedIndex == 2
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey[500],
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              const AssetImage('assets/icon/more.png'),
              color: _selectedIndex == 3
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey[500],
            ),
            label: '',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
