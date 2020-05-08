import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  final Color color;
  final VoidCallback action;
  final String text;

  RoundedButton(
      {@required this.text,
      @required this.action,
      this.color = Colors.lightBlueAccent});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        elevation: 5.0,
        color: color,
        borderRadius: BorderRadius.circular(30.0),
        child: MaterialButton(
          onPressed: action,
          minWidth: 200.0,
          height: 42.0,
          child: Text(
            text,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
