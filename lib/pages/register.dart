import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../extras/data.dart';
import '../extras/ui_elements.dart';
import '../extras/variables.dart';
import 'address_search/address_searching.dart';
import 'address_search/places.dart';
import 'main_tabs/home.dart';
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
  TextEditingController dateInput = TextEditingController();


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

  Coordinates coords = Coordinates(122, 122);

  ///Toggle show password
  bool showPassword = false;
  bool showAcceptTC = false;
  var profileImage;

  void onRegisterPress() async{
    ///Set Loading Screen
    setState(() {
      isLoading = true;
    });
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
       // print("Here it is ......................... ${coords.lat coords.long}");
        postData();
      } else {
        ///Set Loading Screen
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: "Please accept the terms and conditions to proceed.");
      }

    }

  }

  ///Post data to Firebase
 void postData() async{
   ///Set Loading Screen
   setState(() {
     isLoading = true;
   });
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
     'dateOfBirth': dateInput.text,
     'profilePic': profilePic,
     'wallet': '0',
     'coins': '0',
     'coordinates': {
       'lat': coords.lat,
       'long': coords.long,
     },
     'dateRegistered': DateFormat('dd MMMM yyyy').format(DateTime.now()).toString() + " " + DateFormat('hh:mm:ss').format(DateTime.now()).toString(),

   }).then((value) async {
     await prefs.setString('id', docRef.id);
     await prefs.setString('name', firstName);
     await prefs.setString('lastName', lastName);
     await prefs.setString('email', userEmail);

     Fluttertoast.showToast(msg: "Registration successful");

     postNotification(docRef.id);

     ///Set Loading Screen
     setState(() {
       isLoading = false;
       globalUserID = docRef.id;
     });
     ///Navigate to Home Page
     Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));

   });
 }

 void postNotification(String userID) async{
   DocumentReference docRef = FirebaseFirestore.instance.collection('users').doc(userID).collection('notifications').doc();
   docRef.set({
     'title': "Welcome Note",
     'mesage': "Welcome to the Adlinc community."
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
  void initState() {
    // TODO: implement initState
    super.initState();

    dateInput.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: getColor('white', 1.0),
            appBar: AppBar(
              elevation: 0,
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


                    ///Registration Form
                    Form(
                        key: registerFormKey,
                        child: Column(
                          children: [
                            ///Page Heading
                            Text("Create New Account",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: getColor('black', 1.0),
                                  fontSize: 25,
                                ))
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

                            ///Full Name
                            Padding(
                              padding: EdgeInsets.only(bottom: 16.0),
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(width: 0.4, color: Colors.grey),
                                    borderRadius: BorderRadius.circular(30)
                                ),
                                child: Theme(
                                  data: Theme.of(context).copyWith(primaryColor: Colors.grey),
                                  child: TextFormField(
                                    autocorrect: false,
                                    cursorColor: Colors.grey,
                                    style: TextStyle(
                                        color: Colors.grey,
                                    ),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      disabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(5))
                                      ),
                                      focusColor: Colors.grey,
                                      fillColor: Colors.grey,
                                      labelStyle: TextStyle(color: Colors.grey),
                                      hintText: 'First Name',
                                      contentPadding: EdgeInsets.all(15.0),
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
                            ),

                            ///Last Name
                            Padding(
                              padding: EdgeInsets.only(bottom: 16.0),
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(width: 0.4, color: Colors.grey),
                                    borderRadius: BorderRadius.circular(30)
                                ),
                                child: Theme(
                                  data: Theme.of(context).copyWith(primaryColor: Colors.grey),
                                  child: TextFormField(
                                    autocorrect: false,
                                    cursorColor: Colors.grey,
                                    style: TextStyle(
                                        color: Colors.grey
                                    ),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      disabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(5))
                                      ),
                                      focusColor: Colors.grey,
                                      fillColor: Colors.grey,
                                      labelStyle: TextStyle(color: Colors.grey),
                                      hintText: 'Last Name',
                                      contentPadding: EdgeInsets.all(15.0),
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
                            ),

                            ///Date of Birth
                            Padding(
                              padding: EdgeInsets.only(bottom: 16.0),
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(width: 0.4, color: Colors.grey),
                                    borderRadius: BorderRadius.circular(30)
                                ),
                                child: Theme(
                                  data: Theme.of(context).copyWith(primaryColor: Colors.grey),
                                  child:
                                  TextField(
                                    controller: dateInput,
                                    //editing controller of this TextField
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                        contentPadding: EdgeInsets.all(15.0),
                                        //icon: Icon(Icons.calendar_today), //icon of text field
                                        labelText: "Date of Birth" //label text of field
                                    ),
                                    readOnly: true,
                                    //set it true, so that user will not able to edit text
                                    onTap: () async {
                                      DateTime? pickedDate = await showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime(1950),
                                          //DateTime.now() - not to allow to choose before today.
                                          lastDate: DateTime(2100));

                                      if (pickedDate != null) {
                                        print(
                                            pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                                        String formattedDate =
                                        DateFormat('yyyy-MM-dd').format(pickedDate);
                                        print(
                                            formattedDate); //formatted date output using intl package =>  2021-03-16
                                        setState(() {
                                          dateInput.text =
                                              formattedDate; //set output date to TextField value.
                                        });
                                      } else {}
                                    },
                                  ),
                                ),
                                margin: EdgeInsets.only(left: 30.0, right: 30.0),
                              ),
                            ),

                            ///Email Address
                            Padding(
                              padding: EdgeInsets.only(bottom: 16.0),
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(width: 0.4, color: Colors.grey),
                                    borderRadius: BorderRadius.circular(30)
                                ),
                                child: Theme(
                                  data: Theme.of(context).copyWith(primaryColor: getColor('green', 1.0), splashColor: getColor('green', 1.0)),
                                  child: TextFormField(
                                    autocorrect: false,
                                    cursorColor: Colors.grey,
                                    style: TextStyle(
                                        color: Colors.grey
                                    ),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      disabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(5))
                                      ),
                                      focusColor: getColor('green', 1.0),
                                      fillColor: getColor('green', 1.0),
                                      labelStyle: TextStyle(color: getColor('green', 1.0),),
                                      hintText: 'Email',
                                      contentPadding: EdgeInsets.all(15.0),
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
                            ),

                            ///Phone Number
                            Padding(
                              padding: EdgeInsets.only(bottom: 16.0),
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(width: 0.4, color: Colors.grey),
                                    borderRadius: BorderRadius.circular(30)
                                ),
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
                                      border: InputBorder.none,
                                      hintText: 'Phone',
                                      contentPadding: EdgeInsets.all(15.0),
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
                            ),

                            ///Address
                            Padding(
                              padding: EdgeInsets.only(bottom: 16.0),
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(width: 0.4, color: Colors.grey),
                                    borderRadius: BorderRadius.circular(30)
                                ),
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
                                        var temp =  await displayPrediction(result.placeId);
                                        setState(() {
                                          coords = temp;
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
                                      border: InputBorder.none,
                                      hintText: 'Home Address',
                                      contentPadding: EdgeInsets.all(15.0),
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
                            ),

                            ///Password
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(width: 0.4, color: Colors.grey),
                                    borderRadius: BorderRadius.circular(30)
                                ),
                                child: Theme(
                                  data: Theme.of(context).copyWith(primaryColor: Colors.grey),
                                  child: TextFormField(
                                    autocorrect: false,
                                    cursorColor: getColor('green', 1.0),
                                    style: TextStyle(
                                        color:Colors.grey
                                    ),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      disabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(5))
                                      ),
                                      focusColor: getColor('green', 1.0),
                                      fillColor: getColor('green', 1.0),
                                      labelStyle: TextStyle(color: getColor('green', 1.0),),
                                      hintText: 'Password',
                                      contentPadding: EdgeInsets.all(15.0),
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
                            ),

                            ///Password Verify
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(width: 0.4, color: Colors.grey),
                                  borderRadius: BorderRadius.circular(30)
                              ),
                              child: Theme(
                                data: Theme.of(context).copyWith(primaryColor: Colors.grey),
                                child: TextFormField(
                                  autocorrect: false,
                                  cursorColor: getColor('green', 1.0),
                                  style: TextStyle(
                                      color: Colors.grey
                                  ),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    disabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(5))
                                    ),
                                    focusColor: getColor('green', 1.0),
                                    fillColor: getColor('green', 1.0),
                                    labelStyle: TextStyle(color: getColor('green', 1.0),),
                                    hintText: 'Confirm Password',
                                    contentPadding: EdgeInsets.all(15.0),
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



                            ///Bottom Section
                            ///Submit Button
                           /* ElevatedButton(
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
                            ),*/

                            Padding(
                              padding: EdgeInsets.only(bottom: 8.0),
                              child: GestureDetector(
                                onTap: (){
                                  registerFormKey.currentState!.validate()
                                      ? onRegisterPress()
                                      : Fluttertoast.showToast(msg: "Please fill in the missing or incorrect information.");
                                },
                                child: Container(
                                  padding: EdgeInsets.all(15),
                                  width: MediaQuery.of(context).size.width * 0.7,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(28),
                                      color: getColor('blue', 1.0)
                                  ),
                                  child: Center(
                                    child: Text("Sign Up",
                                        style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: getColor("white", 1.0), fontSize: 18, fontWeight: FontWeight.bold))
                                    ),
                                  ),
                                ),
                              ),
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
          ),

          ///Loading Screen
          Positioned(child: loadingScreen())
        ],
      ),
    );
  }
}
