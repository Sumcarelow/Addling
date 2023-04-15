///Page to add business under business community section
import 'package:adlinc/extras/data.dart';
import 'package:adlinc/pages/business_reg/bicycle.dart';
import 'package:adlinc/pages/business_reg/car_rental.dart';
import 'package:adlinc/pages/business_reg/fun_and_games.dart';
import 'package:adlinc/pages/business_reg/healthcare.dart';
import 'package:adlinc/pages/business_reg/home_care.dart';
import 'package:adlinc/pages/business_reg/motocycle.dart';
import 'package:adlinc/pages/business_reg/restaurants.dart';
import 'package:adlinc/pages/business_reg/self_love.dart';
import 'package:adlinc/pages/business_reg/shuttle.dart';
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
import 'package:shared_preferences/shared_preferences.dart';
import '../extras/functions.dart';
import '../extras/variables.dart';
import 'dart:io';
import '../extras/colors.dart';
import 'business_reg/accomodation.dart';
import 'home.dart';

class AddBusinessComminity extends StatefulWidget {
  const AddBusinessComminity({Key? key}) : super(key: key);

  @override
  State<AddBusinessComminity> createState() => _AddBusinessComminityState();
}

class _AddBusinessComminityState extends State<AddBusinessComminity> {

  ///Variables
  late String logo = '', category = businessCategories[0], name, docID, address, businessEmail, phone, policy, policyType = policyTypes[0];
  List<String> categoriesList = ['Please select your business Type'];

  bool showAcceptTC = false;
  ///Form variables
  final GlobalKey<FormState> registerFormKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController policyController = TextEditingController();


  final FocusNode focusNodeUserEmail = FocusNode();
  final FocusNode focusNodeUserName = FocusNode();
  final FocusNode focusNodePhone= FocusNode();
  final FocusNode focusNodeAddress = FocusNode();
  final FocusNode focusNodeDropDown = FocusNode();
  final FocusNode focusNodePolicy = FocusNode();


  var profileImage;
  var policyDoc;
  ///Upload Business Logo to firebase storage
  Future uploadProfilePicture() async {

    ///Set OnLoading Screen
    setState(() {
      isLoading = true;
      loadingScreenMsg = "Uploading profile picture...";
    });

    ///Shared Preferences Instance
    prefs = await SharedPreferences.getInstance();

    ///File Name on Firebase storage
    String fileName = 'Business-Logo' + DateFormat('ddMMMMyyyyhhmmss').format(DateTime.now()).toString();

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
          logo = downloadUrl;
          isLoading = false;
        });

        //await prefs.setString('profilePic', profilePic);
        Fluttertoast.showToast(msg: "Business logo Uploaded Successfully.");
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
            dialogTitle: "Please select a logo as a picture."
        ))?.files;

    if(images != null && images.length != 0){
      setState(() {
        profileImage = File((images.first.path).toString());
      });
      uploadProfilePicture();
    }
  }


  ///Policy document section
  Widget textInput(){
    return Container(
      margin: const EdgeInsets.only(left: 30.0, right: 30.0),
      child: Theme(
        data: Theme.of(context).copyWith(primaryColor: Colors.grey),
        child: TextFormField(
          autocorrect: false,
          cursorColor: Colors.grey,
          style: const TextStyle(
              color: Colors.grey
          ),
          decoration: const InputDecoration(

            disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(5))
            ),
            focusColor: Colors.grey,
            fillColor: Colors.grey,
            labelStyle: TextStyle(color: Colors.grey),
            hintText: 'Policy link/text',
            contentPadding: EdgeInsets.all(5.0),
            hintStyle: TextStyle(color: Colors.grey),

          ),
          controller: policyController,
          validator: (value) {
            if (value == null) {
              return 'Please enter your Product Name';
            }
            return null;
          },
          onChanged: (value) {
            policy = value;
          },
          focusNode: focusNodePolicy,
        ),
      ),
    );
  }

  ///Select PDF Policy doc from device
  Future getDoc() async {
    var images = (
        await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: ['pdf', 'doc'],
            dialogTitle: "Please select a valid document."
        ))?.files;

    if(images != null && images.length != 0){
      setState(() {
        policyDoc = File((images.first.path).toString());
      });
      uploadProfilePicture();
    }
  }


  ///Dropdown for Policy type
  Widget policyTypeDropDown() {
    return DropdownButton<String>(
      value: policyType,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      style: const TextStyle(color: Colors.black),
      underline: Container(
        height: 2,
        //color: Colors.deepPurpleAccent,
      ),
      onChanged: (String? value) {
        // This is called when the user selects an item.
        setState(() {
          policyType = value!;
        });
      },
      items: policyTypes.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  ///Dropdown for Business Categories
  Widget categoryTypeDropDown() {
    return DropdownButton<String>(
      value: category,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      style: const TextStyle(color: Colors.black),
      underline: Container(
        height: 2,
        //color: Colors.deepPurpleAccent,
      ),
      onChanged: (String? value) {
        // This is called when the user selects an item.
        setState(() {
          category = value!;
        });
      },
      items: businessCategories.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  ///When Add Business Button is pressed
  void onRegisterBusinessPress() async{
    //Navigator.push(context, MaterialPageRoute(builder: (context) => AddListing(bizID: "documents[0].id", group: 'B&B',)));
    ///Unfocus all nodes
    focusNodeUserEmail.unfocus();
    focusNodeUserName.unfocus();
    focusNodePhone.unfocus();
    focusNodeAddress.unfocus();

    ///Initialize Shared Preferences Instance
    prefs = await SharedPreferences.getInstance();

    ///Get Firebase Docs
    final QuerySnapshot result =
    await FirebaseFirestore.instance.collection('businesses').where('email', isEqualTo: businessEmail)
        .get();
    final List<DocumentSnapshot> documents = result.docs;

    ///Check if business with email exists on Firebase
    if(documents.length != 0){

      //Navigator.push(context, MaterialPageRoute(builder: (context) => AddListing(bizID: documents[0].id, group: group,)));
      Fluttertoast.showToast(msg: "Business already exists, please use login or forgot password.");
    } else {
      ///Check if T&C's are Accepted
      if(showAcceptTC && category != 'Please select your business Type'){
        postData();
      } else {
        Fluttertoast.showToast(msg: "Please accept the terms and conditions to proceed and select categories for your business.");
      }
    }
  }

  ///Post data to Firebase
  void postData() async{
    ///Add new user to Firebase
    DocumentReference docRef = FirebaseFirestore.instance.collection('businesses').doc();
    docRef.set({
      'id': docRef.id,
      'name': name,
      'email': businessEmail,
      'phone': phone,
      'address': address,
      'category': category,
      'logo': logo,
      'status': 'pending',
      'dateRegistered': DateFormat('dd MMMM yyyy').format(DateTime.now()).toString() + " " + DateFormat('hh:mm:ss').format(DateTime.now()).toString(),
    }).then((value) async {

      Fluttertoast.showToast(msg: "Business Registration Successful");

      ///Save Business Firebase Data to local Storage
      setState(() {
        docID = docRef.id;
        prefs.setString('bizID', docRef.id);
        prefs.setString('bizName', name);
      });

      ///Set Nav
      Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));

    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          ///Main Application level
          Scaffold(

            ///App Bar
            appBar: AppBar(
              backgroundColor: getColor('white', 1.0),
              centerTitle: true,
              title: Text(
                'Join Business Community',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: getColor('black', 1.0), fontSize: 18, ))
              ),
            ),

            ///App Body
            body: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                  ),

                  ///Business Logo Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ///Company Logo Section
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.all(20.0),
                          child: Center(
                            child: Column(
                              children: <Widget>[
                                (profileImage == null)
                                    ? (logo != ''
                                    ? Material(
                                  child: CachedNetworkImage(
                                    placeholder: (context, url) => Container(
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2.0,
                                      ),
                                      width: 120.0,
                                      height: 120.0,
                                      padding: const EdgeInsets.all(20.0),
                                    ),
                                    imageUrl: logo,
                                    width: 150.0,
                                    height: 150.0,
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: const BorderRadius.all(Radius.circular(45.0)),
                                  clipBehavior: Clip.hardEdge,
                                )
                                    : const Icon(
                                  Icons.account_circle,
                                  size: 120.0,
                                ))
                                    : Material(
                                  child: Image.file(
                                    profileImage,
                                    width: 150.0,
                                    height: 150.0,
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: const BorderRadius.all(Radius.circular(45.0)),
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
                                          size: 24,
                                          color: getColor('black', 0.5),
                                        ),
                                        Text('Upload logo',
                                          style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: getColor('black', 0.5), fontSize: 22, fontWeight: FontWeight.bold)),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  ///Form
                  Form(
                    key: registerFormKey,
                      child: Column(
                        children: [
                          ///Business Name
                          Container(
                            margin: const EdgeInsets.only(left: 30.0, right: 30.0),
                            child: Theme(
                              data: Theme.of(context).copyWith(primaryColor: Colors.grey),
                              child: TextFormField(
                                autocorrect: false,
                                cursorColor: Colors.grey,
                                style: const TextStyle(
                                    color: Colors.grey
                                ),
                                decoration: const InputDecoration(

                                  disabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(5))
                                  ),
                                  focusColor: Colors.grey,
                                  fillColor: Colors.grey,
                                  labelStyle: TextStyle(color: Colors.grey),
                                  hintText: 'Business Name',
                                  contentPadding: EdgeInsets.all(5.0),
                                  hintStyle: TextStyle(color: Colors.grey),

                                ),
                                controller: nameController,
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please enter your Business Name';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  name = value;
                                },
                                focusNode: focusNodeUserName,
                              ),
                            ),
                          ),

                          ///Business Email Address
                          Container(
                            margin: const EdgeInsets.only(left: 30.0, right: 30.0),
                            child: Theme(
                              data: Theme.of(context).copyWith(primaryColor: getColor('green', 1.0), splashColor: getColor('green', 1.0)),
                              child: TextFormField(
                                autocorrect: false,
                                cursorColor: Colors.grey,
                                style: const TextStyle(
                                    color: Colors.grey
                                ),
                                decoration: InputDecoration(
                                  disabledBorder: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(5))
                                  ),
                                  focusColor: getColor('green', 1.0),
                                  fillColor: getColor('green', 1.0),
                                  labelStyle: TextStyle(color: getColor('green', 1.0),),
                                  hintText: 'Business Email',
                                  contentPadding: const EdgeInsets.all(5.0),
                                  hintStyle: const TextStyle(color: Colors.grey),

                                ),
                                controller: emailController,
                                validator: (value) {
                                  if (!EmailValidator.validate(value!)) {
                                    return 'Please enter a valid email address';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  businessEmail = value;
                                },
                                focusNode: focusNodeUserEmail,
                              ),
                            ),
                          ),

                          ///Phone Number
                          Container(
                            margin: const EdgeInsets.only(left: 30.0, right: 30.0),
                            child: Theme(
                              data: Theme.of(context).copyWith(primaryColor: Colors.grey),
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                style: const TextStyle(
                                    color: Colors.grey
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'Business Phone',
                                  contentPadding: EdgeInsets.all(5.0),
                                  hintStyle: TextStyle(color: Colors.grey),
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
                          ),


                          ///Address
                          Container(
                            margin: const EdgeInsets.only(left: 30.0, right: 30.0),
                            child: Theme(
                              data: Theme.of(context).copyWith(primaryColor: Colors.grey),
                              child: TextFormField(
                                style: const TextStyle(
                                    color: Colors.grey
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'Business Address',
                                  contentPadding: EdgeInsets.all(5.0),
                                  hintStyle: TextStyle(color: Colors.grey),

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
                          ),

                          ///Dropdown
                          categoryTypeDropDown(),

                          ///Business hours selection
                          ///Section Header
                          Text(
                            "Business Hours:",
                            style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: getColor('black', 0.5), fontSize: 20, fontWeight: FontWeight.bold)),
                          ),
                          /// Monday
                          Padding(
                            padding: const EdgeInsets.only(left:8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                const Text(
                                    "Monday"
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      selectTime(context, "Monday", "open",mondayOpenController);
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(top: 6),
                                      width: MediaQuery.of(context).size.width * 0.2,
                                      height: MediaQuery.of(context).size.width * 0.09,
                                      alignment: Alignment.center,
                                      //decoration: BoxDecoration(color: Colors.grey[200]),
                                      child: TextFormField(
                                        style: const TextStyle(fontSize: 15),
                                        textAlign: TextAlign.center,
                                        onChanged: (val) {
                                          //print("this is where it is at $val");
                                          setState((){
                                            mondayOpen = val;
                                          });
                                        },
                                        enabled: false,
                                        keyboardType: TextInputType.text,
                                        controller: mondayOpenController,
                                        focusNode: focusNodeMondayOpen,
                                        decoration: const InputDecoration(
                                            disabledBorder:
                                            UnderlineInputBorder(borderSide: BorderSide.none),
                                            labelText: 'Opening Time',
                                            contentPadding: EdgeInsets.all(5)),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      selectTime(context, "Monday", "close", mondayCloseController);
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(top: 6),
                                      width: MediaQuery.of(context).size.width * 0.02,
                                      height: MediaQuery.of(context).size.width * 0.09,
                                      alignment: Alignment.center,
                                      //decoration: BoxDecoration(color: Colors.grey[200]),
                                      child: TextFormField(
                                        style: const TextStyle(fontSize: 15),
                                        textAlign: TextAlign.center,
                                        onSaved: (String? val) {
                                          mondayClose = val!;
                                        },
                                        enabled: false,
                                        keyboardType: TextInputType.text,
                                        controller: mondayCloseController,
                                        decoration: const InputDecoration(
                                            disabledBorder:
                                            UnderlineInputBorder(borderSide: BorderSide.none),
                                            labelText: 'Closing Time',
                                            contentPadding: EdgeInsets.all(5)),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ///Tuesday
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                const Text(
                                    "Tuesday"
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      selectTime(context, "Tuesday", "open", tuesdayOpenController);
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(top: 10),
                                      width: MediaQuery.of(context).size.width * 0.2,
                                      height: MediaQuery.of(context).size.width * 0.09,
                                      alignment: Alignment.center,
                                      //decoration: BoxDecoration(color: Colors.grey[200]),
                                      child: TextFormField(
                                        style: const TextStyle(fontSize: 15),
                                        textAlign: TextAlign.center,
                                        onSaved: (String? val) {
                                          tuesdayOpen = val!;
                                        },
                                        enabled: false,
                                        keyboardType: TextInputType.text,
                                        controller: tuesdayOpenController,
                                        decoration: const InputDecoration(
                                            disabledBorder:
                                            UnderlineInputBorder(borderSide: BorderSide.none),
                                            labelText: 'Opening Time',
                                            contentPadding: EdgeInsets.all(5)),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      selectTime(context, "Tuesday", "close", tuesdayCloseController);
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(top: 10),
                                      width: MediaQuery.of(context).size.width * 0.2,
                                      height: MediaQuery.of(context).size.width * 0.09,
                                      alignment: Alignment.center,
                                      //decoration: BoxDecoration(color: Colors.grey[200]),
                                      child: TextFormField(
                                        style: const TextStyle(fontSize: 15),
                                        textAlign: TextAlign.center,
                                        onSaved: (String? val) {
                                          tuesdayClose = val!;
                                        },
                                        enabled: false,
                                        keyboardType: TextInputType.text,
                                        controller: tuesdayCloseController,
                                        decoration: const InputDecoration(
                                            disabledBorder:
                                            UnderlineInputBorder(borderSide: BorderSide.none),
                                            labelText: 'Closing Time',
                                            contentPadding: EdgeInsets.all(5)),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          ///Wednesday
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                const Text(
                                    "Wednesday"
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      selectTime(context, "Wednesday", "open", wedOpenController);
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(top: 10),
                                      width: MediaQuery.of(context).size.width * 0.2,
                                      height: MediaQuery.of(context).size.width * 0.09,
                                      alignment: Alignment.center,
                                      //decoration: BoxDecoration(color: Colors.grey[200]),
                                      child: TextFormField(
                                        style: const TextStyle(fontSize: 15),
                                        textAlign: TextAlign.center,
                                        onSaved: (String? val) {
                                          wedOpen = val!;
                                        },
                                        enabled: false,
                                        keyboardType: TextInputType.text,
                                        controller: wedOpenController,
                                        decoration: const InputDecoration(
                                            disabledBorder:
                                            UnderlineInputBorder(borderSide: BorderSide.none),
                                            labelText: 'Opening Time',
                                            contentPadding: EdgeInsets.all(5)),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      selectTime(context, "Wednesday", "close", wedCloseController);
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(top: 10),
                                      width: MediaQuery.of(context).size.width * 0.2,
                                      height: MediaQuery.of(context).size.width * 0.09,
                                      alignment: Alignment.center,
                                      //decoration: BoxDecoration(color: Colors.grey[200]),
                                      child: TextFormField(
                                        style: const TextStyle(fontSize: 15),
                                        textAlign: TextAlign.center,
                                        onSaved: (String? val) {
                                          wedClose = val!;
                                        },
                                        enabled: false,
                                        keyboardType: TextInputType.text,
                                        controller: wedCloseController,
                                        decoration: const InputDecoration(
                                            disabledBorder:
                                            UnderlineInputBorder(borderSide: BorderSide.none),
                                            labelText: 'Closing Time',
                                            contentPadding: EdgeInsets.all(5)),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          ///Thursday
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                const Text(
                                    "Thursday"
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      selectTime(context, "Thursday", "open", thursdayOpenController);
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(top: 10),
                                      width: MediaQuery.of(context).size.width * 0.2,
                                      height: MediaQuery.of(context).size.width * 0.09,
                                      alignment: Alignment.center,
                                      //decoration: BoxDecoration(color: Colors.grey[200]),
                                      child: TextFormField(
                                        style: const TextStyle(fontSize: 15),
                                        textAlign: TextAlign.center,
                                        onSaved: (String? val) {
                                          thursOpen = val!;
                                        },
                                        enabled: false,
                                        keyboardType: TextInputType.text,
                                        controller: thursdayOpenController,
                                        decoration: const InputDecoration(
                                            disabledBorder:
                                            UnderlineInputBorder(borderSide: BorderSide.none),
                                            labelText: 'Opening Time',
                                            contentPadding: EdgeInsets.all(5)),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      selectTime(context, "Thursday", "close", thursdayCloseController);
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(top: 10),
                                      width: MediaQuery.of(context).size.width * 0.2,
                                      height: MediaQuery.of(context).size.width * 0.09,
                                      alignment: Alignment.center,
                                      //decoration: BoxDecoration(color: Colors.grey[200]),
                                      child: TextFormField(
                                        style: const TextStyle(fontSize: 15),
                                        textAlign: TextAlign.center,
                                        onSaved: (String? val) {
                                          thursClose = val!;
                                        },
                                        enabled: false,
                                        keyboardType: TextInputType.text,
                                        controller: thursdayCloseController,
                                        decoration: const InputDecoration(
                                            disabledBorder:
                                            UnderlineInputBorder(borderSide: BorderSide.none),
                                            labelText: 'Closing Time',
                                            contentPadding: EdgeInsets.all(5)),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          ///Friday
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                const Text(
                                    "Friday"
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      selectTime(context, "Friday", "open", fridayOpenController);
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(top: 10),
                                      width: MediaQuery.of(context).size.width * 0.2,
                                      height: MediaQuery.of(context).size.width * 0.09,
                                      alignment: Alignment.center,
                                      //decoration: BoxDecoration(color: Colors.grey[200]),
                                      child: TextFormField(
                                        style: const TextStyle(fontSize: 15),
                                        textAlign: TextAlign.center,
                                        onSaved: (String? val) {
                                          friOpen = val!;
                                        },
                                        enabled: false,
                                        keyboardType: TextInputType.text,
                                        controller: fridayOpenController,
                                        decoration: const InputDecoration(
                                            disabledBorder:
                                            UnderlineInputBorder(borderSide: BorderSide.none),
                                            labelText: 'Opening Time',
                                            contentPadding: EdgeInsets.all(5)),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      selectTime(context, "Friday", "close", fridayCloseController);
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(top: 10),
                                      width: MediaQuery.of(context).size.width * 0.2,
                                      height: MediaQuery.of(context).size.width * 0.09,
                                      alignment: Alignment.center,
                                      //decoration: BoxDecoration(color: Colors.grey[200]),
                                      child: TextFormField(
                                        style: const TextStyle(fontSize: 15),
                                        textAlign: TextAlign.center,
                                        onSaved: (String? val) {
                                          friClose = val!;
                                        },
                                        enabled: false,
                                        keyboardType: TextInputType.text,
                                        controller: fridayCloseController,
                                        decoration: const InputDecoration(
                                            disabledBorder:
                                            UnderlineInputBorder(borderSide: BorderSide.none),
                                            labelText: 'Closing Time',
                                            contentPadding: EdgeInsets.all(5)),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          ///Saturday
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                const Text(
                                    "Saturday"
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      selectTime(context, "Saturday", "open", saturdayOpenController);
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(top: 10),
                                      width: MediaQuery.of(context).size.width * 0.2,
                                      height: MediaQuery.of(context).size.width * 0.09,
                                      alignment: Alignment.center,
                                      //decoration: BoxDecoration(color: Colors.grey[200]),
                                      child: TextFormField(
                                        style: const TextStyle(fontSize: 15),
                                        textAlign: TextAlign.center,
                                        onSaved: (String? val) {
                                          satOpen = val!;
                                        },
                                        enabled: false,
                                        keyboardType: TextInputType.text,
                                        controller: saturdayOpenController,
                                        decoration: const InputDecoration(
                                            disabledBorder:
                                            UnderlineInputBorder(borderSide: BorderSide.none),
                                            labelText: 'Opening Time',
                                            contentPadding: EdgeInsets.all(5)),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      selectTime(context, "Saturday", "close", saturdayCloseController);
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(top: 10),
                                      width: MediaQuery.of(context).size.width * 0.2,
                                      height: MediaQuery.of(context).size.width * 0.09,
                                      alignment: Alignment.center,
                                      //decoration: BoxDecoration(color: Colors.grey[200]),
                                      child: TextFormField(
                                        style: const TextStyle(fontSize: 15),
                                        textAlign: TextAlign.center,
                                        onSaved: (String? val) {
                                          satClose = val!;
                                        },
                                        enabled: false,
                                        keyboardType: TextInputType.text,
                                        controller: saturdayCloseController,
                                        decoration: const InputDecoration(
                                            disabledBorder:
                                            UnderlineInputBorder(borderSide: BorderSide.none),
                                            labelText: 'Closing Time',
                                            contentPadding: EdgeInsets.all(5)),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          ///Sunday
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                const Text(
                                    "Sunday"
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      selectTime(context, "Sunday", "open", sundayOpenController);
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(top: 10),
                                      width: MediaQuery.of(context).size.width * 0.2,
                                      height: MediaQuery.of(context).size.width * 0.09,
                                      alignment: Alignment.center,
                                      //decoration: BoxDecoration(color: Colors.grey[200]),
                                      child: TextFormField(
                                        style: const TextStyle(fontSize: 15),
                                        textAlign: TextAlign.center,
                                        onSaved: (String? val) {
                                          sundayOpen = val!;
                                        },
                                        enabled: false,
                                        keyboardType: TextInputType.text,
                                        controller: sundayOpenController,
                                        decoration: const InputDecoration(
                                            disabledBorder:
                                            UnderlineInputBorder(borderSide: BorderSide.none),
                                            labelText: 'Opening Time',
                                            contentPadding: EdgeInsets.all(5)),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      selectTime(context, "Sunday", "close", sundayCloseController);
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(top: 10),
                                      width: MediaQuery.of(context).size.width * 0.2,
                                      height: MediaQuery.of(context).size.width * 0.09,
                                      alignment: Alignment.center,
                                      //decoration: BoxDecoration(color: Colors.grey[200]),
                                      child: TextFormField(
                                        style: const TextStyle(fontSize: 15),
                                        textAlign: TextAlign.center,
                                        onSaved: (String? val) {
                                          sundayClose = val!;
                                        },
                                        enabled: false,
                                        keyboardType: TextInputType.text,
                                        controller: sundayCloseController,
                                        decoration: const InputDecoration(
                                            disabledBorder:
                                            UnderlineInputBorder(borderSide: BorderSide.none),
                                            labelText: 'Closing Time',
                                            contentPadding: EdgeInsets.all(5)),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),


                          ///Business Policy Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Business Policy: "),
                              policyTypeDropDown(),
                            ],
                          ),

                          policyType == 'Url Link'
                              ? textInput()
                              : policyType == 'PDF Doc'
                              ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ///Company Policy Section
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.all(20.0),
                                  child: Center(
                                    child: Column(
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: GestureDetector(
                                            onTap: getDoc,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.picture_as_pdf,
                                                  size: 24,
                                                  color: getColor('black', 0.5),
                                                ),
                                                Text('Upload Doc',
                                                  style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: getColor('black', 0.5), fontSize: 22, fontWeight: FontWeight.bold)),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                              : policyType == 'Text'
                              ? textInput()
                              : Container(),

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
                              const Text("I accept the terms and conditions.")
                            ],
                          ),

                          ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:  MaterialStatePropertyAll<Color>(getColor('green', 1.0),),
                              ),
                              //color: colors[2],
                              onPressed: (){
                                registerFormKey.currentState!.validate()
                                    ? onRegisterBusinessPress()
                                    : Fluttertoast.showToast(msg: "Please fill in the missing or incorrect information.");
                              },
                              child: Padding(
                                padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.07,
                                    right: MediaQuery.of(context).size.width * 0.07),
                                child: Text("Register Business",
                                    style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: getColor('white', 1.0), fontSize: 16, fontWeight: FontWeight.bold))
                                ),
                              )
                          ),

                        ],
                      )

                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
