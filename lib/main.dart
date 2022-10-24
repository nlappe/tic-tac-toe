import 'dart:math';

import 'package:flutter/material.dart';
import 'package:t3/dialogues/draw.dart';
import 'package:t3/dialogues/win.dart';

import 'models/game_states.dart';
import 'models/player_config.dart';

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

class _GamePageState extends State<GamePage> {
  _GamePageState() {
    playerSettings = [
      PlayerConfig(char: 'X', color: Colors.blue),
      PlayerConfig(char: 'O', color: Colors.red),
      PlayerConfig(char: '🤣', color: Colors.green),
      PlayerConfig(char: '🙃', color: Colors.purple),
    ];
    initGridSizes();
    int verticalSize = (gridItemCount / crossAxisItemCount).round();

    initVertical(verticalSize);
    initHorizontal(verticalSize);
  }

  late List<PlayerConfig> playerSettings;
  late int crossAxisItemCount;
  late int gridItemCount;

  int streakToWin = 3;

  GameStates gameState = GameStates.RUNNING;

  PlayerConfig? winner;
  Map<int, PlayerConfig> gameMap = {};

  List<List<int>> horizontalIndices = [];
  List<List<int>> verticalIndices = [];
  List<List<int>> diagonalIndices = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade800,
      body: Column(
        children: [
          Center(
              child: ElevatedButton(
                  onPressed: reset,
                  child: const Text('Reset',
                      style: TextStyle(color: Colors.white, fontSize: 64)))),
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

    setState(() => {
          gameMap[index] =
              playerSettings[gameMap.length % playerSettings.length]
        });

    checkForWin();
  }

  void reset() {
    setState(() => {
          gameMap = {},
          gameState = GameStates.RUNNING,
        });
  }

  void checkForWin() {
    PlayerConfig? horizontalWinningPlayer = processIndicesForWinner([
      ...horizontalIndices,
      ...verticalIndices,
      ...diagonalIndices,
    ]);
    if (horizontalWinningPlayer != null) {
      setState(() => {
            winner = horizontalWinningPlayer,
            gameState = GameStates.WON,
          });
    }

    if (gameMap.length >= gridItemCount) {
      setState(() => {gameState = GameStates.DRAW});
    }
  }

  Widget chooseGameAreaFiller() {
    switch (gameState) {
      case GameStates.RUNNING:
        return getGridView();
      case GameStates.DRAW:
        return Draw();
      case GameStates.WON:
        return Win(winner!);
    }
  }

  Widget getGridView() {
    return GridView.builder(
        itemCount: gridItemCount,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisItemCount),
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () => tapped(index),
            child: Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
              child: Center(
                child: Text(
                  (gameMap[index]?.char ?? ''),
                  style: TextStyle(
                      color: gameMap[index]?.color ?? Colors.white,
                      fontSize: 64),
                ),
              ),
            ),
          );
        });
  }

  PlayerConfig? processIndicesForWinner(List<List<int>> indices) {
    for (List<int> line in indices) {
      String string =
          line.map((lineIndex) => gameMap[lineIndex]?.char).join('');
      if (string.length < streakToWin) {
        continue;
      }

      for (PlayerConfig playerConfig in playerSettings) {
        String playerChar = playerConfig.char;
        if (string.contains(playerChar * streakToWin)) {
          return playerConfig;
        }
      }
    }
    return null;
  }

  void generateDiagonalIndices(int horizontalReferenceColIndex,
      int loopIndexAddition, int crossAxisComparator) {
    bool leftInBoundary = true;
    List<int> leftDiagonalRow = [];

    int leftTargetIndex = horizontalReferenceColIndex;

    leftDiagonalRow.add(leftTargetIndex);

    while (leftInBoundary) {
      leftTargetIndex = leftTargetIndex + loopIndexAddition;
      if (leftTargetIndex < 0 ||
          leftTargetIndex % crossAxisItemCount == crossAxisComparator) {
        leftInBoundary = false;
        break;
      }
      leftDiagonalRow.add(leftTargetIndex);
    }

    if (leftDiagonalRow.length >= streakToWin) {
      diagonalIndices.add(leftDiagonalRow);
    }
  }

  void initHorizontal(int verticalSize) {
    for (int horizontal = 0; horizontal < crossAxisItemCount; horizontal++) {
      List<int> row = [];
      for (int vertical = 0; vertical < verticalSize; vertical++) {
        row.add((vertical * (verticalSize)) + horizontal);
      }
      verticalIndices.add(row);

      // diagonal - top left to bot left
      generateDiagonalIndices(
        horizontal,
        crossAxisItemCount - 1,
        crossAxisItemCount - 1,
      );

      // horizontal - top left to bot right
      generateDiagonalIndices(
        horizontal,
        crossAxisItemCount + 1,
        0,
      );
    }
  }

  void initVertical(int verticalSize) {
    for (int vertical = 0; vertical < verticalSize; vertical++) {
      List<int> col = [];
      for (int horizontal = 0; horizontal < crossAxisItemCount; horizontal++) {
        col.add((vertical * crossAxisItemCount) + horizontal);
      }
      horizontalIndices.add(col);

      // vertical - top left to bot right
      generateDiagonalIndices(
        vertical * crossAxisItemCount,
        crossAxisItemCount + 1,
        0,
      );

      //vertical - top right to bot left
      generateDiagonalIndices(
        (1 + vertical) * crossAxisItemCount - 1,
        crossAxisItemCount - 1,
        crossAxisItemCount - 1,
      );
    }
  }

  void initGridSizes() {
    crossAxisItemCount = streakToWin * (playerSettings.length - 1);
    gridItemCount = pow(crossAxisItemCount, 2).toInt();
  }
}
