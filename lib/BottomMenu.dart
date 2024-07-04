import 'package:flutter/material.dart';

class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  AppBottomNavigation({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home, color: Colors.black),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search, color: Colors.black),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.book, color: Colors.black),
          label: 'Diary',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings, color: Colors.black),
          label: 'Settings',
        ),
      ],
      currentIndex: currentIndex,
      selectedItemColor: Colors.blue,
      onTap: onTap,
    );
  }
}