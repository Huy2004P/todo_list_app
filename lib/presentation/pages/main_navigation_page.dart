import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todoapp/presentation/pages/home_page.dart';
import 'package:todoapp/presentation/pages/focus_page.dart';
import 'package:todoapp/presentation/pages/analytics_page.dart';
import 'package:todoapp/presentation/pages/trash_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    FocusPage(),
    AnalyticsPage(),
    TrashPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              width: 0.5,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
          selectedItemColor: const Color(0xFF0066CC), // Action Blue phong cách Apple
          unselectedItemColor: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
          selectedLabelStyle: const TextStyle(
            fontFamily: 'SF Pro Text',
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'SF Pro Text',
            fontWeight: FontWeight.normal,
            fontSize: 11,
          ),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.checkmark_circle),
              activeIcon: Icon(CupertinoIcons.checkmark_circle_fill),
              label: 'Công việc',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.timer),
              activeIcon: Icon(CupertinoIcons.timer_fill),
              label: 'Tập trung',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.chart_bar),
              activeIcon: Icon(CupertinoIcons.chart_bar_fill),
              label: 'Thống kê',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.trash),
              activeIcon: Icon(CupertinoIcons.trash_fill),
              label: 'Thùng rác',
            ),
          ],
        ),
      ),
    );
  }
}
