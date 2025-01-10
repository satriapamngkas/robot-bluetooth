import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    required this.isManual,
    super.key,
  });

  final bool isManual;

  @override
  Widget build(BuildContext context) {
    var dateTime = DateTime.now();
    final DateFormat dateFormat = DateFormat('EEEE, d MMMM yyyy', 'id_ID');
    initializeDateFormatting();

    return Stack(
      children: [
        // Gradient background
        Container(
          height: isManual ? 24 : 50, // Tinggi AppBar
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                Colors.white.withAlpha(0),
              ],
            ),
          ),
        ),
        AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          toolbarHeight: isManual ? 24 : 50,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ZonaSort',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                dateFormat.format(dateTime),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(isManual ? 24 : 50);
}
