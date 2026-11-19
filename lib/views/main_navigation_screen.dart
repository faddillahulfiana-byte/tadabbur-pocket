import 'package:flutter/material.dart';
import 'home/home_screen.dart';
import 'murajaah/murajaah_screen.dart';
import 'profile/profile_screen.dart';
import 'quotes/quotes_screen.dart';
import 'tadabbur/surah_list_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(onNavigateTab: _onTabTapped),
      const SurahListScreen(),
      const MurajaahScreen(),
      const QuotesScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded),
            label: 'Juz 30',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_task_outlined),
            selectedIcon: Icon(Icons.add_task_rounded),
            label: 'Murajaah',
          ),
          NavigationDestination(
            icon: Icon(Icons.format_quote_outlined),
            selectedIcon: Icon(Icons.format_quote_rounded),
            label: 'Quote',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
