import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../pages/login.dart';

void main() async{
WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp();
runApp( MyApp());
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

  }

  @override
  Widget build(BuildContext context) {

    return Login() /*Scaffold(

      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ///Logo section
                Container(
                  height: MediaQuery.of(context).size.height * 0.2,
                  width: MediaQuery.of(context).size.width * 0.4,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/logo2.png'),
                      fit: BoxFit.cover
                    )
                  ),
                ),

                ///Welcome Message
                Text(
                  'Hello and welcome to \n ADLINC Community.',
                    style: GoogleFonts.getFont('Roboto', textStyle: const TextStyle(color: Colors.black, fontSize: 20,))
                ),

                ///Spacer
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.07,
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
                        style: GoogleFonts.getFont('Roboto', textStyle: const TextStyle(color: Colors.white, fontSize: 18,))
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
                        style: GoogleFonts.getFont('Roboto', textStyle: const TextStyle(color: Color.fromRGBO(12, 106, 187, 1.0), fontSize: 18,))
                    ))

                ),

                ///Bottom

              ],
            ),
          ),

          ///Loading Screen
          loadingScreen()
        ],
      ),
       // This trailing comma makes auto-formatting nicer for build methods.
    )*/;
  }
}
