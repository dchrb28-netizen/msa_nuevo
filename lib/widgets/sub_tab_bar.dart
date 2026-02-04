import 'package:flutter/material.dart';

class SubTabBar extends StatelessWidget implements PreferredSizeWidget {
  const SubTabBar({
    super.key,
    required this.tabs,
    this.controller,
    this.isScrollable = false,
    this.indicatorSize,
    this.indicatorWeight = 2.0,
    this.labelPadding,
    this.labelStyle,
    this.unselectedLabelStyle,
    this.onTap,
  });

  final List<Widget> tabs;
  final TabController? controller;
  final bool isScrollable;
  final TabBarIndicatorSize? indicatorSize;
  final double indicatorWeight;
  final EdgeInsetsGeometry? labelPadding;
  final TextStyle? labelStyle;
  final TextStyle? unselectedLabelStyle;
  final ValueChanged<int>? onTap;

  static const double _height = 56.0;

  @override
  Size get preferredSize => const Size.fromHeight(_height);

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final background = primary.withAlpha(
      Theme.of(context).brightness == Brightness.dark ? 77 : 26,
    );
    final defaultLabelStyle = Theme.of(context)
        .textTheme
        .labelSmall
        ?.copyWith(fontWeight: FontWeight.w600);
    final defaultUnselectedStyle = Theme.of(context).textTheme.labelSmall;

    return SizedBox(
      height: _height,
      child: ColoredBox(
        color: background,
        child: TabBar(
          controller: controller,
          tabs: tabs,
          isScrollable: isScrollable,
          indicatorColor: primary,
          indicatorWeight: indicatorWeight,
          indicatorSize: indicatorSize,
          labelColor: onSurface,
          unselectedLabelColor: onSurface.withAlpha((255 * 0.7).round()),
          labelPadding: labelPadding,
          labelStyle: labelStyle ?? defaultLabelStyle,
          unselectedLabelStyle: unselectedLabelStyle ?? defaultUnselectedStyle,
          onTap: onTap,
        ),
      ),
    );
  }
}
