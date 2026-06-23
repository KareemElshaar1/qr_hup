import 'package:barcode_app/screen/history_screen.dart';
import 'package:flutter/material.dart';

/// Quick access screen for starred QR records.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const HistoryScreen(favoritesOnly: true);
  }
}
