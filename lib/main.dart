import 'package:adlinc/pages/add_business.dart';
import 'package:adlinc/pages/business_reg/accomodation.dart';
import 'package:adlinc/pages/business_reg/bicycle.dart';
import 'package:adlinc/pages/business_reg/car_rental.dart';
import 'package:adlinc/pages/business_reg/fun_and_games.dart';
import 'package:adlinc/pages/business_reg/healthcare.dart';
import 'package:adlinc/pages/business_reg/home_care.dart';
import 'package:adlinc/pages/business_reg/motocycle.dart';
import 'package:adlinc/pages/business_reg/rest_menu.dart';
import 'package:adlinc/pages/business_reg/restaurants.dart';
import 'package:adlinc/pages/business_reg/self_love.dart';
import 'package:adlinc/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import '../pages/register.dart';
import '../pages/login.dart';
import 'extras/data.dart';

void main() async{
WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp();
runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    for(int i = 1; i <= 50000; i++){
      this.setState(() {
        prices.add(i.toString());

      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ///Logo section
            Container(
              height: MediaQuery.of(context).size.height * 0.2,
              width: MediaQuery.of(context).size.width * 0.6,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/logo.png'),
                  fit: BoxFit.cover
                )
              ),
            ),

            ///Welcome Message
            Text(
              'Hello and welcome to \n ADLINC Community.',
                style: GoogleFonts.getFont('Roboto', textStyle: const TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.bold))
            ),

            ///Create Account Button
            ElevatedButton(
                style: const ButtonStyle(
                  backgroundColor:  MaterialStatePropertyAll<Color>(Color.fromRGBO(17, 106, 57, 1.0)),
                ),
                onPressed: (){

                  Navigator.push(context, MaterialPageRoute(builder: (context) => const Register()));
                },
                child: Text("CREATE ACCOUNT",
                    style: GoogleFonts.getFont('Roboto', textStyle: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold))
                )
            ),

            ///Login Button
            OutlinedButton(
                style: const ButtonStyle(
                  foregroundColor:  MaterialStatePropertyAll<Color>(Color.fromRGBO(12, 106, 187, 1.0)),
                ),
                onPressed: (){

                  Navigator.push(context, MaterialPageRoute(builder: (context) => const Login()));
                },
                child: Padding(
                  padding: EdgeInsets
                   .only(
                      left: MediaQuery.of(context).size.width * 0.09,
                      right: MediaQuery.of(context).size.width * 0.09
                  ),
                    child:Text(
                  "LOGIN",
                    style: GoogleFonts.getFont('Roboto', textStyle: const TextStyle(color: Color.fromRGBO(12, 106, 187, 1.0), fontSize: 13, fontWeight: FontWeight.bold))
                ))

            ),
          ],
        ),
      ),
       // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
