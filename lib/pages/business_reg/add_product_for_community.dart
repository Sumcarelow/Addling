import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../extras/colors.dart';

class AddProductToCommunity extends StatefulWidget {
  const AddProductToCommunity({Key? key}) : super(key: key);

  @override
  State<AddProductToCommunity> createState() => _AddProductToCommunityState();
}

class _AddProductToCommunityState extends State<AddProductToCommunity> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          ///Main App Body
          Scaffold(
            ///App Bar
            appBar: AppBar(
              backgroundColor: getColor('white', 1.0),
              title:  Text("Add\nProduct",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: getColor('black', 1.0), fontSize: 18, ))
              ),
            ),

            body: Container(),
          ),
        ],
      ),
    );
  }
}
