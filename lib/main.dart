import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: GamePage(),
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({Key? key}) : super(key: key);

  @override
  _GamePageState createState() => _GamePageState();
}

class _PlayerConfig {
  _PlayerConfig({
    required this.char,
    required this.color,
  });

  String char;
  Color color;
}

enum _GameStates {
  RUNNING,
  WON,
  DRAW,
}

class _GamePageState extends State<GamePage> {
  _PlayerConfig? winner;

  Map<int, _PlayerConfig> gameMap = {};

  List<_PlayerConfig> playerSettings = [
    _PlayerConfig(char: 'X', color: Colors.blue),
    _PlayerConfig(char: 'O', color: Colors.red),
    //   _PlayerConfig(char: '🤣', color: Colors.green),
  ];

  int round = 0;

  _GameStates gameState = _GameStates.RUNNING;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      body: Column(
        children: [
          Center(
              child: ElevatedButton(
                  onPressed: reset,
                  child: Text('Reset $round',
                      style:
                          const TextStyle(color: Colors.white, fontSize: 64)))),
          Expanded(
            child: chooseGameAreaFiller(),
          ),
        ],
      ),
    );
  }

  void tapped(int index) {
    if (gameMap[index] != null) {
      return;
    }

    setState(
        () => {gameMap[index] = playerSettings[round % playerSettings.length]});
    round++;

    checkForWin();
  }

  void reset() {
    round = 0;
    setState(() => {
          gameMap = {},
          gameState = _GameStates.RUNNING,
        });
  }

  void checkForWin() {
    if (round < (playerSettings.length * 3) - 1) {
      return;
    }

    List<List<int>> winningCombinations = [
      [1, 2, 3],
      [4, 5, 6],
      [7, 8, 9],
      [1, 4, 7],
      [2, 5, 8],
      [3, 6, 9],
      [1, 5, 9],
      [3, 5, 7],
    ];

    for (List<int> winningRow in winningCombinations) {
      Iterable<_PlayerConfig?> mappedPlayersInRow =
          winningRow.map((index) => gameMap[index - 1]);

      bool isWinner = mappedPlayersInRow.every((element) =>
          element != null && element.char == mappedPlayersInRow.first?.char);

      if (isWinner) {
        setState(() => {
              gameState = _GameStates.WON,
              winner = mappedPlayersInRow.first,
            });
        return;
      }
    }

    if (round >= 9) {
      setState(() => {gameState = _GameStates.DRAW});
    }
  }

  Widget chooseGameAreaFiller() {
    switch (gameState) {
      case _GameStates.RUNNING:
        return getGridView();
      case _GameStates.DRAW:
        return const Center(
          child: Text(
            'IT\'S A DRAW',
            style: TextStyle(fontSize: 128, color: Colors.yellow),
          ),
        );
      case _GameStates.WON:
        return Center(
          child: Text(
            '${winner?.char ?? ''} WON!',
            style:
                TextStyle(fontSize: 128, color: winner?.color ?? Colors.yellow),
          ),
        );
    }
  }

  Widget getGridView() {
    return GridView.builder(
        itemCount: 9,
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () => tapped(index),
            child: Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
              child: Center(
                child: Text(
                  '${(gameMap[index]?.char ?? '')} $index',
                  style: TextStyle(
                      color: gameMap[index]?.color ?? Colors.white,
                      fontSize: 64),
                ),
              ),
            ),
          );
        });
  }
}
