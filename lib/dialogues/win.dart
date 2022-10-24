import 'package:flutter/material.dart';

import '../models/player_config.dart';

class Win extends StatelessWidget {
  const Win(this.player, {super.key});

  final PlayerConfig player;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '${player.char} WON!',
        style: TextStyle(fontSize: 128, color: player.color),
      ),
    );
  }
}
