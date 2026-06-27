import 'package:flutter/material.dart';
import 'beranda_screen.dart';
import '../products/my_products_screen.dart';
import '../profile/profile_screen.dart';
import '../forum/forum_screen.dart';
import '../colab/colab_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _idx = 0;

  // Keys to refresh screens when switching tabs
  final List<GlobalKey<RefreshableState>> _tabKeys = List.generate(
    5,
    (_) => GlobalKey<RefreshableState>(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _idx,
        children: [
          BerandaScreen(key: _tabKeys[0]),
          MyProductsScreen(key: _tabKeys[1]),
          const ColabScreen(),
          const ForumScreen(),
          ProfileScreen(
            key: _tabKeys[4],
            onNavigateToTab: (tabIndex) {
              setState(() => _idx = tabIndex);
            },
          ),
        ],
      ),
      floatingActionButton: null,
      floatingActionButtonLocation: null,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, -4),
            spreadRadius: -8,
          ),
        ],
      ),
      child: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        color: Colors.white,
        elevation: 0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(
                      index: 0,
                      icon: Icons.home_outlined,
                      activeIcon: Icons.home_rounded,
                      label: 'Home',
                    ),
                    _buildNavItem(
                      index: 1,
                      icon: Icons.inventory_2_outlined,
                      activeIcon: Icons.inventory_2_rounded,
                      label: 'Produk',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 48),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(
                      index: 2,
                      icon: Icons.hub_outlined,
                      activeIcon: Icons.hub_rounded,
                      label: 'Colab',
                    ),
                    _buildNavItem(
                      index: 3,
                      icon: Icons.forum_outlined,
                      activeIcon: Icons.forum_rounded,
                      label: 'Forum',
                    ),
                    _buildNavItem(
                      index: 4,
                      icon: Icons.person_outline_rounded,
                      activeIcon: Icons.person_rounded,
                      label: 'Profil',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isActive = _idx == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() => _idx = index);
          // Refresh data when switching to tabs
          if (index <= 1) {
            _tabKeys[index].currentState?.refreshData();
          }
        },
        borderRadius: BorderRadius.circular(12),
        splashColor: const Color(0xFF27AE60).withValues(alpha: 0.08),
        child: SizedBox(
          height: 56,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF27AE60).withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isActive ? activeIcon : icon,
                  color: isActive ? const Color(0xFF27AE60) : Colors.grey[400],
                  size: 22,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: isActive ? const Color(0xFF27AE60) : Colors.grey[400],
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Mixin for screens that can be refreshed
abstract class RefreshableState<T extends StatefulWidget> extends State<T> {
  void refreshData();
}
