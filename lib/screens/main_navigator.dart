import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'rank_screen.dart';
import 'profile_screen.dart';

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    RankScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],

      // === Custom Bottom Navigation (Selaras HomeScreen) ===
      bottomNavigationBar: Container(
        color: const Color(0xFFFFB0B5), // pink pastel
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _navItem('assets/home.png', 'Home', 0),
            _navItem('assets/ranking.png', 'Rank', 1),
            _navItem('assets/profil.png', 'Profile', 2),
          ],
        ),
      ),
    );
  }

  Widget _navItem(String iconPath, String label, int index) {
    final bool isActive = _selectedIndex == index;

    return InkWell(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFFB388FF)
                  : Colors.transparent, // warna ungu jika aktif
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(8),
            child: Image.asset(iconPath, width: 28, height: 28),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive
                  ? const Color(0xFFB388FF)
                  : Colors.white, // teks berubah sesuai aktif/tidak
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
