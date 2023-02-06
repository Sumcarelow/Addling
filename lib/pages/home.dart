import 'package:adlinc/pages/add_business.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import '../extras/colors.dart';


class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.white,
          title: Text("Home Page",
              style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: Color.fromRGBO(12, 106, 187, 1.0), fontSize: 13, fontWeight: FontWeight.bold))
          ),
        ),
        body: Center(
          child:  ElevatedButton(
              style: ButtonStyle(
                backgroundColor:  MaterialStatePropertyAll<Color>(getColor('green', 1.0),),
              ),
              //color: colors[2],
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => AddBusiness()));
              },
              child: Padding(
                padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.07,
                    right: MediaQuery.of(context).size.width * 0.07),
                child: Text("Register A New Business",
                    style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: getColor('white', 1.0), fontSize: 16, fontWeight: FontWeight.bold))
                ),
              )
          ),
        ),
      ),
    );
  }
}
