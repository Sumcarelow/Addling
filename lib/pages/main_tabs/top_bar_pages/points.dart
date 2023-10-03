
import 'package:flutter/material.dart';


class MyGoldenPoints extends StatefulWidget {
  const MyGoldenPoints({super.key});

  @override
  State<MyGoldenPoints> createState() => _MyGoldenPointsState();
}

class _MyGoldenPointsState extends State<MyGoldenPoints> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      ///AppBAr
      appBar: AppBar(
        title: Text("My Golden Points"),
      ),

      body: Center(
        child: Text("You have the following number of golden points: 0"),
      ),
    );
  }
}
