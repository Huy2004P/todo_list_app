import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todoapp/presentation/pages/home_page.dart';
import 'package:todoapp/presentation/pages/focus_page.dart';
import 'package:todoapp/presentation/pages/analytics_page.dart';
import 'package:todoapp/presentation/pages/trash_page.dart';
import 'package:todoapp/application/bloc/language_bloc.dart';
import 'package:todoapp/application/bloc/language_state.dart';
import 'package:todoapp/core/localization/app_translation.dart';
import 'package:todoapp/core/responsive/responsive_layout.dart';

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
    
    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, langState) {
        return ResponsiveLayout(
          mobile: Scaffold(
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
                selectedItemColor: const Color(0xFF0066CC),
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
                items: [
                  BottomNavigationBarItem(
                    icon: const Icon(CupertinoIcons.checkmark_circle),
                    activeIcon: const Icon(CupertinoIcons.checkmark_circle_fill),
                    label: 'tasks'.tr,
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(CupertinoIcons.timer),
                    activeIcon: const Icon(CupertinoIcons.timer_fill),
                    label: 'focus'.tr,
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(CupertinoIcons.chart_bar),
                    activeIcon: const Icon(CupertinoIcons.chart_bar_fill),
                    label: 'analytics'.tr,
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(CupertinoIcons.trash),
                    activeIcon: const Icon(CupertinoIcons.trash_fill),
                    label: 'trash'.tr,
                  ),
                ],
              ),
            ),
          ),
          tablet: Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                  selectedIconTheme: const IconThemeData(color: Color(0xFF0066CC)),
                  unselectedIconTheme: IconThemeData(
                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                  ),
                  selectedLabelTextStyle: const TextStyle(
                    fontFamily: 'SF Pro Text',
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: Color(0xFF0066CC),
                  ),
                  unselectedLabelTextStyle: TextStyle(
                    fontFamily: 'SF Pro Text',
                    fontWeight: FontWeight.normal,
                    fontSize: 12,
                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                  ),
                  labelType: NavigationRailLabelType.all,
                  destinations: [
                    NavigationRailDestination(
                      icon: const Icon(CupertinoIcons.checkmark_circle),
                      selectedIcon: const Icon(CupertinoIcons.checkmark_circle_fill),
                      label: Text('tasks'.tr),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(CupertinoIcons.timer),
                      selectedIcon: const Icon(CupertinoIcons.timer_fill),
                      label: Text('focus'.tr),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(CupertinoIcons.chart_bar),
                      selectedIcon: const Icon(CupertinoIcons.chart_bar_fill),
                      label: Text('analytics'.tr),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(CupertinoIcons.trash),
                      selectedIcon: const Icon(CupertinoIcons.trash_fill),
                      label: Text('trash'.tr),
                    ),
                  ],
                ),
                VerticalDivider(
                  width: 1,
                  thickness: 0.5,
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
                Expanded(
                  child: IndexedStack(
                    index: _currentIndex,
                    children: _pages,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
