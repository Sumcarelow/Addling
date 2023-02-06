import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import '../extras/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'home.dart';


class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  ///Form Variables
  late String userEmail, password;
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FocusNode focusNodeUserEmail= FocusNode();
  final FocusNode focusNodeUserPassword= FocusNode();

  ///Shared Preferences
  late SharedPreferences prefs;

  ///Toggle Show Password
  bool showPassword = false;

  ///Login Function
  Future<void> onLoginPress() async {
    ///Unfocus all nodes
    focusNodeUserPassword.unfocus();
    focusNodeUserEmail.unfocus();

    //Initialize Shared Preferences
    prefs = await SharedPreferences.getInstance();

    ///Get Firebase Docs
    final QuerySnapshot result =
    await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: userEmail).get();
    final List<DocumentSnapshot> documents = result.docs;

    if(documents.length != 0 && documents[0]['password'] == password) {
      await prefs.setString('id', documents[0].id);
      await prefs.setString('name', documents[0]['name']);
      await prefs.setString('lastName', documents[0]['lastName']);
      await prefs.setString('email', documents[0]['email']);

      Fluttertoast.showToast(msg: "Login successful");
      Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
    } else {
      Fluttertoast.showToast(msg: "Login unsuccessful");
    }

  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          ///Application Scaffold
          Positioned(
            child: Container(
              color: getColor('white', 1.0),
              child: Scaffold(
                appBar: AppBar(
                  leading: IconButton(
                      onPressed: ()=>{
                        Navigator.pop(context)
                      },
                      icon:Icon(Icons.close, color: getColor('red', 1.0),)),
                  backgroundColor: Colors.white,
                  centerTitle: true,
                  title: Text("Login",
                      style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: getColor('white', 1.0), fontSize: 18,))
                  ),
                ),

                ///Page Body
                body: SingleChildScrollView(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.19,
                        ),
                        ///Logo
                        Center(
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.2,
                            width: MediaQuery.of(context).size.width * 0.6,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage('assets/images/logo2.png'),
                                    fit: BoxFit.fill
                                )
                            ),
                          ),
                        ),
                        Text("Login",
                            style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: getColor('black', 1.0), fontSize: 28, ))
                        ),
                        ///Registration Box
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            ///Login Form
                            Form(
                              key: loginFormKey,
                              child: Column(
                                children: [
                                  ///Email Address
                                  Container(
                                    child: Theme(
                                      data: Theme.of(context).copyWith(primaryColor: getColor("green", 1.0), splashColor: getColor("green", 1.0)),
                                      child: TextFormField(
                                        autocorrect: false,
                                        cursorColor: getColor("orange", 1.0),
                                        style: TextStyle(
                                            color: Colors.grey
                                        ),
                                        decoration: InputDecoration(

                                          disabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(Radius.circular(5))
                                          ),
                                          focusColor: getColor("green", 1.0),
                                          fillColor: getColor("green", 1.0),
                                          labelStyle: TextStyle(color: getColor("green", 1.0)),
                                          hintText: 'E-mail Address',
                                          contentPadding: EdgeInsets.all(5.0),
                                          hintStyle: TextStyle(color: Colors.grey),

                                        ),
                                        controller: emailController,
                                        validator: (value) {
                                          if (!EmailValidator.validate(value!)) {
                                            return 'Please enter a valid email address';
                                          }
                                          return null;
                                        },
                                        onChanged: (value) {
                                          userEmail = value;
                                        },
                                        focusNode: focusNodeUserEmail,
                                      ),
                                    ),
                                    margin: EdgeInsets.only(left: 30.0, right: 30.0),
                                  ),

                                  ///Password
                                  Container(
                                    child: Theme(
                                      data: Theme.of(context).copyWith(primaryColor: getColor("green", 1.0), splashColor: getColor("green", 1.0)),
                                      child: TextFormField(
                                        autocorrect: false,
                                        cursorColor: getColor("green", 1.0),
                                        style: TextStyle(
                                            color: Colors.grey
                                        ),
                                        decoration: InputDecoration(

                                          disabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(Radius.circular(5))
                                          ),
                                          focusColor: getColor("green", 1.0),
                                          fillColor: getColor("green", 1.0),
                                          labelStyle: TextStyle(color: getColor("green", 1.0)),
                                          hintText: 'Password',
                                          contentPadding: EdgeInsets.all(5.0),
                                          hintStyle: TextStyle(color: Colors.grey),

                                        ),
                                        controller: passwordController,
                                        validator: (value) {
                                          if (value == null) {
                                            return 'Cannot be empty';
                                          }
                                          return null;
                                        },
                                        onChanged: (value) {
                                          password = value;
                                        },
                                        focusNode: focusNodeUserPassword,
                                        obscureText: !showPassword,
                                      ),
                                    ),
                                    margin: EdgeInsets.only(left: 30.0, right: 30.0),
                                  ),

                                  ///Show Password
                                  Row(
                                    children: [
                                      Checkbox(value: showPassword, onChanged: (bool? show){
                                        setState(() {
                                          showPassword = !showPassword;
                                        });
                                      }),
                                      Text( showPassword ? "Hide Passwords" : "Show Passwords")
                                    ],
                                  ),

                                  ///Bottom Section
                                  ///Submit Button
                                  ElevatedButton(
                                      style: ButtonStyle(
                                        backgroundColor:  MaterialStatePropertyAll<Color>(getColor("green", 1.0)),
                                      ),
                                      //color: colors[2],
                                      onPressed: (){
                                        loginFormKey.currentState!.validate()
                                            ? onLoginPress()
                                            : Fluttertoast.showToast(msg: "Please fill in the missing or incorrect information.");
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.07,
                                            right: MediaQuery.of(context).size.width * 0.07),
                                        child: Text("Continue",
                                            style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: getColor("white", 1.0), fontSize: 16, fontWeight: FontWeight.bold))
                                        ),
                                      )
                                  ),

                                  /*Text("OR",
                                      style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: colors[1], fontSize: 16, fontWeight: FontWeight.bold))
                                  ),

                                  ///Login with Google
                                  Padding(
                                    padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.0985,
                                    right: MediaQuery.of(context).size.width * 0.0985,
                                    bottom: 8
                                    ),
                                    child: RaisedButton(
                                        color: colors[2],
                                        onPressed: (){

                                        },
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            FaIcon(FontAwesomeIcons.googlePlusG,
                                            color: colors[3],
                                            ),
                                            Text("Continue with Google",
                                                style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: colors[3], fontSize: 16, fontWeight: FontWeight.bold))
                                            ),
                                          ],
                                        )
                                    ),
                                  ),*/
                                ],
                              ),
                            )

                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          ///Loading Screen
          //Positioned(child: loadingScreen())
        ],
      ),
    );
  }
}
