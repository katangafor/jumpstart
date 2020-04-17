import 'package:flutter/material.dart';

class BluefruitFinder extends StatelessWidget {
  final Function findBluefruit;
  final Function setBluefruit;
  final Function printBluefruit;

  BluefruitFinder(this.setBluefruit, this.findBluefruit, this.printBluefruit);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        RaisedButton(child: Text('Find bluefruit'), onPressed: findBluefruit),
        RaisedButton(child: Text('print bluefruit'), onPressed: printBluefruit)
      ],
    );
  }
}
