import 'package:flutter/material.dart';
import '../theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final Widget? leadingIcon;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.showBackButton = true,
    this.actions,
    this.leadingIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      backgroundColor:
          isDarkMode ? AppTheme.darkPrimaryColor : AppTheme.primaryColor,
      elevation: 0,
      centerTitle: true,
      leading:
          showBackButton
              ? IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              )
              : leadingIcon,
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
