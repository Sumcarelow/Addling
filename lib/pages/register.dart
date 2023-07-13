import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../extras/data.dart';
import '../extras/variables.dart';
import 'address_search/address_searching.dart';
import 'address_search/places.dart';
import 'home.dart';
import 'dart:io';
import '../extras/colors.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  ///Form Variables
  late String firstName, lastName, userEmail, password, passwordVerify, phone, profilePic = logoURL, address;
  final GlobalKey<FormState> registerFormKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordVerifyController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final FocusNode focusNodeUserEmail = FocusNode();
  final FocusNode focusNodeUserName = FocusNode();
  final FocusNode focusNodeUserLastName = FocusNode();
  final FocusNode focusNodeUserPassword= FocusNode();
  final FocusNode focusNodeUserPasswordVerify= FocusNode();
  final FocusNode focusNodePhone= FocusNode();
  final FocusNode focusNodeAddress = FocusNode();

  final _controller = TextEditingController();
  String _streetNumber = '';
  String _street = '';
  String _city = '';
  String _zipCode = '';

  ///Toggle show password
  bool showPassword = false;
  bool showAcceptTC = false;
  var profileImage;

  void onRegisterPress() async{
    ///Unfocus all nodes
    focusNodeUserEmail.unfocus();
    focusNodeUserName.unfocus();
    focusNodeUserPassword.unfocus();
    focusNodeUserPasswordVerify.unfocus();
    focusNodePhone.unfocus();
    focusNodeAddress.unfocus();

    ///Initialize Shared Preferences Instance
    prefs = await SharedPreferences.getInstance();

    ///Get Firebase Docs
    final QuerySnapshot result =
    await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: userEmail)
        .get();
    final List<DocumentSnapshot> documents = result.docs;

    ///Check if user exists on Firebase
    if(documents.length != 0){
      Fluttertoast.showToast(msg: "User already exists, please use login or forgot password.");
    } else {
      ///Check if T&C's are Accepted
      if(showAcceptTC){
        postData();
      } else {
        Fluttertoast.showToast(msg: "Please accept the terms and conditions to proceed.");
      }

    }

  }

  ///Post data to Firebase
 void postData() async{
   ///Add new user to Firebase
   DocumentReference docRef = FirebaseFirestore.instance.collection('users').doc();
   docRef.set({
     'id': docRef.id,
     'name': firstName,
     'lastName': lastName,
     'email': userEmail,
     'password': password,
     'phone': phone,
     'address': address,
     'profilePic': profilePic,
     'dateRegistered': DateFormat('dd MMMM yyyy').format(DateTime.now()).toString() + " " + DateFormat('hh:mm:ss').format(DateTime.now()).toString(),
   }).then((value) async {
     await prefs.setString('id', docRef.id);
     await prefs.setString('name', firstName);
     await prefs.setString('lastName', lastName);
     await prefs.setString('email', userEmail);

     Fluttertoast.showToast(msg: "Registration successful");

     ///Navigate to Home Page
     Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));

   });
 }

  ///Select Profile Image
  ///Upload Profile Image to firebase storage
  Future uploadProfilePicture() async {
    ///Set OnLoading Screen
    setState(() {
      isLoading = true;
      loadingScreenMsg = "Uploading profile picture...";
    });

    ///Shared Preferences Instance
    prefs = await SharedPreferences.getInstance();

    ///File Name on Firebase storage
    String fileName = 'PP' + DateFormat('ddMMMMyyyyhhmmss').format(DateTime.now()).toString();

    ///Create storage reference and upload image
    Reference reference = FirebaseStorage.instance.ref().child(fileName);
    UploadTask uploadTask = reference.putFile(profileImage);
    TaskSnapshot storageTaskSnapshot;
    uploadTask.then((value){
      ///If Upload was successful
      storageTaskSnapshot = value;

      ///Get Url
      storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl)async{
        setState(() {
          profilePic = downloadUrl;
          isLoading = false;
        });

        //await prefs.setString('profilePic', profilePic);
        Fluttertoast.showToast(msg: "Profile Picture Uploaded Successfully.");
      }, onError: (err){
        ///Set Off Loading Screen
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: err.toString());
      });
    }, onError: (err){
      ///Set Off Loading Screen
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: err.toString());
    });
  }

  ///Load image from phone storage
  Future getImage() async {
    var images = (
        await FilePicker.platform.pickFiles(
            type: FileType.image,
            dialogTitle: "Please select a profile picture."
        ))?.files;

    if(images != null && images.length != 0){
      setState(() {
        profileImage = File((images.first.path).toString());
      });
      uploadProfilePicture();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: getColor('white', 1.0),
        leading: IconButton(
          onPressed: ()=>{
            Navigator.pop(context)
          },
          icon: Icon(Icons.close), color: getColor('red', 1.0),),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.07,
              ),
              Center(
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.2,
                  width: MediaQuery.of(context).size.width * 0.4,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/images/logo2.png'),
                          fit: BoxFit.fill
                      )
                  ),
                ),
              ),
              Text("Personal\nInformation",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: getColor('black', 1.0),
                    fontSize: 25,
                  ))
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.08,
              ),

              ///Registration Form
              Form(
                  key: registerFormKey,
                  child: Column(
                    children: [
                      ///Full Name
                      Container(
                        child: Theme(
                          data: Theme.of(context).copyWith(primaryColor: Colors.grey),
                          child: TextFormField(
                            autocorrect: false,
                            cursorColor: Colors.grey,
                            style: TextStyle(
                                color: Colors.grey,
                            ),
                            decoration: InputDecoration(

                              disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(5))
                              ),
                              focusColor: Colors.grey,
                              fillColor: Colors.grey,
                              labelStyle: TextStyle(color: Colors.grey),
                              hintText: 'First Name',
                              contentPadding: EdgeInsets.all(5.0),
                              hintStyle: TextStyle(color: Colors.grey,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold
                              ),

                            ),
                            controller: nameController,
                            validator: (value) {
                              if (value == null) {
                                return 'Please enter your First Name';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              firstName = value;
                            },
                            focusNode: focusNodeUserName,
                          ),
                        ),
                        margin: EdgeInsets.only(left: 30.0, right: 30.0),
                      ),

                      ///Last Name
                      Container(
                        child: Theme(
                          data: Theme.of(context).copyWith(primaryColor: Colors.grey),
                          child: TextFormField(
                            autocorrect: false,
                            cursorColor: Colors.grey,
                            style: TextStyle(
                                color: Colors.grey
                            ),
                            decoration: InputDecoration(

                              disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(5))
                              ),
                              focusColor: Colors.grey,
                              fillColor: Colors.grey,
                              labelStyle: TextStyle(color: Colors.grey),
                              hintText: 'Last Name',
                              contentPadding: EdgeInsets.all(5.0),
                              hintStyle: TextStyle(color: Colors.grey,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold
                              ),

                            ),
                            controller: lastNameController,
                            validator: (value) {
                              if (value == null) {
                                return 'Please enter your Last Name';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              lastName = value;
                            },
                            focusNode: focusNodeUserLastName,
                          ),
                        ),
                        margin: EdgeInsets.only(left: 30.0, right: 30.0),
                      ),

                      ///Email Address
                      Container(
                        child: Theme(
                          data: Theme.of(context).copyWith(primaryColor: getColor('green', 1.0), splashColor: getColor('green', 1.0)),
                          child: TextFormField(
                            autocorrect: false,
                            cursorColor: Colors.grey,
                            style: TextStyle(
                                color: Colors.grey
                            ),
                            decoration: InputDecoration(
                              disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(5))
                              ),
                              focusColor: getColor('green', 1.0),
                              fillColor: getColor('green', 1.0),
                              labelStyle: TextStyle(color: getColor('green', 1.0),),
                              hintText: 'Email',
                              contentPadding: EdgeInsets.all(5.0),
                              hintStyle: TextStyle(color: Colors.grey,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold
                              ),

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

                      ///Phone Number
                      Container(
                        child: Theme(
                          data: Theme.of(context).copyWith(primaryColor: Colors.grey),
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            style: TextStyle(
                                color: Colors.grey
                            ),
                            decoration: InputDecoration(
                              hintText: 'Phone',
                              contentPadding: EdgeInsets.all(5.0),
                              hintStyle: TextStyle(color: Colors.grey,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                            controller: phoneController,
                            validator: (value) {
                              if (value!.length != 10) {
                                return 'Please enter valid phone number';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              phone = value;
                            },
                            focusNode: focusNodePhone,
                          ),
                        ),
                        margin: EdgeInsets.only(left: 30.0, right: 30.0),
                      ),

                      ///Address
                      Container(
                        child: Theme(
                          data: Theme.of(context).copyWith(primaryColor: Colors.grey,),
                          child: TextFormField(
                            style: TextStyle(
                                color: Colors.grey
                            ),
                            readOnly: true,
                            onTap: () async {
                              final sessionToken = Uuid().v4();
                              final Suggestion? result = await showSearch(
                                context: context,
                                delegate: AddressSearch(),
                              );
                              if (result != null) {
                                final placeDetails = await PlaceApiProvider(sessionToken)
                                    .getPlaceDetailFromId(result.placeId);
                                //print("Here I am ........... ${result.placeId}");

                                setState(() {
                                  addressController.text = result.description;
                                  address = result.description;
                                  _streetNumber = placeDetails.streetNumber;
                                  _street = placeDetails.street;
                                  _city = placeDetails.city;
                                  _zipCode = placeDetails.zipCode;
                                });
                              }
                              // placeholder for our places search later
                            },
                            decoration: InputDecoration(
                              hintText: 'Home Address',
                              contentPadding: EdgeInsets.all(5.0),
                              hintStyle: TextStyle(color: Colors.grey,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold
                              ),

                            ),
                            controller: addressController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Cannot be empty';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              address = value;
                            },
                            focusNode: focusNodeAddress,
                          ),
                        ),
                        margin: EdgeInsets.only(left: 30.0, right: 30.0),
                      ),

                      ///Password
                      Container(
                        child: Theme(
                          data: Theme.of(context).copyWith(primaryColor: Colors.grey),
                          child: TextFormField(
                            autocorrect: false,
                            cursorColor: getColor('green', 1.0),
                            style: TextStyle(
                                color:Colors.grey
                            ),
                            decoration: InputDecoration(
                              disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(5))
                              ),
                              focusColor: getColor('green', 1.0),
                              fillColor: getColor('green', 1.0),
                              labelStyle: TextStyle(color: getColor('green', 1.0),),
                              hintText: 'Password',
                              contentPadding: EdgeInsets.all(5.0),
                              hintStyle: TextStyle(color: Colors.grey,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold),

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

                      ///Password Verify
                      Container(
                        child: Theme(
                          data: Theme.of(context).copyWith(primaryColor: Colors.grey),
                          child: TextFormField(
                            autocorrect: false,
                            cursorColor: getColor('green', 1.0),
                            style: TextStyle(
                                color: Colors.grey
                            ),
                            decoration: InputDecoration(
                              disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(5))
                              ),
                              focusColor: getColor('green', 1.0),
                              fillColor: getColor('green', 1.0),
                              labelStyle: TextStyle(color: getColor('green', 1.0),),
                              hintText: 'Confirm Password',
                              contentPadding: EdgeInsets.all(5.0),
                              hintStyle: TextStyle(color: Colors.grey,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold
                              ),

                            ),
                            controller: passwordVerifyController,
                            validator: (value) {
                              if (value == null) {
                                return 'Cannot be empty';
                              } else if (value != password){
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              passwordVerify = value;
                            },
                            focusNode: focusNodeUserPasswordVerify,
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

                      ///Accept terms and conditions
                      Row(
                        children: [
                          Checkbox(
                              value: showAcceptTC,
                              onChanged: (bool? show){
                                setState(() {
                                  showAcceptTC = !showAcceptTC;
                                });

                          }),
                          Text("I accept the terms and conditions")
                        ],
                      ),

                      ///Upload Pic Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ///Profile Picture Section
                          Expanded(
                            child: Container(
                              child: Center(
                                child: Column(
                                  children: <Widget>[
                                    (profileImage == null)
                                        ? (profilePic != ''
                                        ? Material(
                                      child: CachedNetworkImage(
                                        placeholder: (context, url) => Container(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.0,
                                          ),
                                          width: 120.0,
                                          height: 120.0,
                                          padding: EdgeInsets.all(20.0),
                                        ),
                                        imageUrl: profilePic,
                                        width: 120.0,
                                        height: 120.0,
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: BorderRadius.all(Radius.circular(45.0)),
                                      clipBehavior: Clip.hardEdge,
                                    )
                                        : Icon(
                                      Icons.account_circle,
                                      size: 120.0,
                                    ))
                                        : Material(
                                      child: Image.file(
                                        profileImage,
                                        width: 120.0,
                                        height: 120.0,
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: BorderRadius.all(Radius.circular(45.0)),
                                      clipBehavior: Clip.hardEdge,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: GestureDetector(
                                        onTap: getImage,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.camera_alt,
                                            ),
                                            Text('Upload Image')
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              width: double.infinity,
                              margin: EdgeInsets.all(20.0),
                            ),
                          ),
                        ],
                      ),

                      ///Bottom Section
                      ///Submit Button
                      ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:  MaterialStatePropertyAll<Color>(getColor('green', 1.0),),
                          ),
                          //color: colors[2],
                          onPressed: (){
                            registerFormKey.currentState!.validate()
                                ? onRegisterPress()
                                : Fluttertoast.showToast(msg: "Please fill in the missing or incorrect information.");
                          },
                          child: Padding(
                            padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.07,
                                right: MediaQuery.of(context).size.width * 0.07),
                            child: Text("Register",
                                style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: getColor('white', 1.0), fontSize: 16, fontWeight: FontWeight.bold))
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
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
