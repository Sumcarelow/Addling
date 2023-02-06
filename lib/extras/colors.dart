///App Base colors declaration
///
///
import 'package:flutter/material.dart';



/// Color class
class color {
  final String name;
  final List<int> code;
  final double opacity;

  color({required this.name, required this.code, required this.opacity});
}

///Colors List
List<color> colors = [
  ///Base logo colors
  color(
    name: "blue",
    opacity: 1.0,
    code: [12, 116, 187]
  ),
    color(
    name: "orange",
    opacity: 1.0,
    code: [247, 147, 33]
  ),
  color(
    name: "red",
    opacity: 1.0,
    code: [238, 2, 62]
  ),
  color(
    name: "green",
    opacity: 1.0,
    code: [17, 106, 57]
  ),
  color(
    name: "white",
    opacity: 1.0,
    code: [255, 255, 255]
  ),
  color(
    name: "black",
    opacity: 1.0,
    code: [0, 0, 0]
  ),

];

///Get Color Function
Color getColor(String name, double opacity){
  Color finalColor = Color.fromRGBO(0, 0, 0, 1.0);
  colors.forEach((colorElem) {
    if (colorElem.name == name){
      finalColor = Color.fromRGBO(colorElem.code[0], colorElem.code[1], colorElem.code[2], opacity);
    }
  });
  return finalColor;
}

