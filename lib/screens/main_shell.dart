import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

// ---------------------------------------------------------------------------
// Placeholder tab screens – will be replaced with real implementations.
// ---------------------------------------------------------------------------

class _TabPlaceholder extends StatelessWidget {
  const _TabPlaceholder(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        label,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// MainShell – persistent bottom tab navigation
// ---------------------------------------------------------------------------

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const _tabs = <_TabDef>[
    _TabDef(icon: Icons.bolt_rounded, label: 'Summarize'),
    _TabDef(icon: Icons.people_rounded, label: 'Experts'),
    _TabDef(icon: Icons.menu_book_rounded, label: 'Library'),
    _TabDef(icon: Icons.person_rounded, label: 'Profile'),
  ];

  // Lazily instantiated so tabs survive index changes (via IndexedStack).
  final List<Widget> _tabScreens = const [
    _TabPlaceholder('Summarize'),
    _TabPlaceholder('Experts'),
    _TabPlaceholder('Library'),
    _TabPlaceholder('Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabScreens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(
            top: BorderSide(color: colors.border, width: 1),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              children: List.generate(_tabs.length, (i) {
                final tab = _tabs[i];
                final selected = i == _currentIndex;
                return Expanded(
                  child: _BottomTabItem(
                    icon: tab.icon,
                    label: tab.label,
                    selected: selected,
                    onTap: () => setState(() => _currentIndex = i),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab definition DTO
// ---------------------------------------------------------------------------

class _TabDef {
  const _TabDef({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

// ---------------------------------------------------------------------------
// Individual bottom tab item
// ---------------------------------------------------------------------------

class _BottomTabItem extends StatelessWidget {
  const _BottomTabItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = selected ? AppPalette.primary : colors.textTertiary;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: selected ? 1.0 : 0.5,
        duration: const Duration(milliseconds: 200),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
