///Page to add healthcare listing

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../../extras/colors.dart';
import '../../extras/data.dart';
import '../../extras/variables.dart';
import '../home.dart';
class Healthcare extends StatefulWidget {
  final String group, bizID;
  const Healthcare({Key? key, required this.group, required this.bizID}) : super(key: key);

  @override
  State<Healthcare> createState() => _HealthcareState();
}

class _HealthcareState extends State<Healthcare> {
  ///Variables
  late String name, description, ageRestr, consultationFee, payment = payments[0];
  List<DocumentSnapshot> amenities = [];
  List<DocumentSnapshot> myAmenities = [];
  List<dynamic> productPictures = [];


  final FocusNode focusNodeUserName= FocusNode();
  final FocusNode focusNodeUserDescr = FocusNode();
  final FocusNode focusNodeUserPrice = FocusNode();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();


  final TextEditingController nameController = TextEditingController();
  final TextEditingController descrController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  ///Shared Preferences instance
  late SharedPreferences prefs;

  ///Load image from phone storage
  Future getImage() async {
    var images = (
        await FilePicker.platform.pickFiles(
            allowMultiple: true,
            type: FileType.image,
            dialogTitle: "Please select room pictures."
        ))?.files;

    if(images != null && images.length != 0){
      setState(() {
        productPictures = images;
      });
    }
  }


  ///Drop down Button for BedSizes
  Widget restTypesDropDown(){
    return DropdownButton(

      /// Initial Value
      value: payment,

      /// Down Arrow Icon
      icon: const Icon(Icons.keyboard_arrow_down),

      /// Array list of items
      items: payments.map((String items) {
        return DropdownMenuItem(
          value: items,
          child: Text(items),
        );
      }).toList(),
      // After selecting the desired option,it will
      // change button value to selected value
      onChanged: (String? newValue) {
        setState(() {
          payment = newValue!;
        });
      },
    );
  }

  ///Post data to Firebase
  void postData() async{
    ///Add new user to Firebase
    DocumentReference docRef = FirebaseFirestore.instance.collection('listings').doc();
    docRef.set({
      'id': docRef.id,
      'name': name,
      'description': description,
      'consultationFee': consultationFee,
      'businessID': widget.bizID,
      'dateRegistered': DateFormat('dd MMMM yyyy').format(DateTime.now()).toString() + " " + DateFormat('hh:mm:ss').format(DateTime.now()).toString(),
    }).then((value) async {

      ///Upload Product Pictures
      productPictures.forEach((element) {
        uploadProfilePicture(File(element.path), docRef.id, name);
      });

      Fluttertoast.showToast(msg: "Listing created Successfully");



      ///Navigate to Home Page
      Navigator.push(context, MaterialPageRoute(builder: (context) => const Home()));

    });
  }


  ///Upload Profile Image to firebase storage
  Future uploadProfilePicture(File image, String docID, String name) async {
    ///Set OnLoading Screen
    setState(() {
      isLoading = true;
      loadingScreenMsg = "Uploading room pictures...";
    });

    ///Shared Preferences Instance
    prefs = await SharedPreferences.getInstance();

    ///File Name on Firebase storage
    String fileName = name + 'pr-home' + DateFormat('ddMMMMyyyyhhmmss').format(DateTime.now()).toString();

    ///Create storage reference and upload image
    Reference reference = FirebaseStorage.instance.ref().child(fileName);
    UploadTask uploadTask = reference.putFile(image);
    TaskSnapshot storageTaskSnapshot;
    uploadTask.then((value){
      ///If Upload was successful
      storageTaskSnapshot = value;

      ///Get Url
      storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl)async{

        FirebaseFirestore.instance.collection("listings").doc(docID).collection('pictures').doc()
            .set({
          "location": downloadUrl
        });
        setState(() {
          //profilePic = downloadUrl;
          isLoading = false;
        });

        //await prefs.setString('profilePic', profilePic);
        Fluttertoast.showToast(msg: "Pictures Uploaded Successfully.");
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: getColor('white', 1.0),
        ///AppBar Title
        centerTitle: true,
        title: Text("Add Healthcare Listing",
            textAlign: TextAlign.center,
            style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: getColor('black', 1.0), fontSize: 18, ))
        ),
        leading: IconButton(
          onPressed: ()=>{
            Navigator.pop(context)
          },
          icon: Icon(Icons.close), color: getColor('red', 1.0),),
      ),

      ///Page Body
      body: Container(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
              ),
              ///Product Images
              productPictures.isEmpty
                  ? GestureDetector(
                onTap: getImage,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.camera_alt,
                    ),
                    const Text('Upload Images')
                  ],
                ),
              )
                  : Wrap(
                spacing: MediaQuery.of(context).size.width * 0.05,
                children: productPictures.map((picture) {
                  return Container(
                    height: MediaQuery.of(context).size.height * 0.08,
                    width: MediaQuery.of(context).size.width * 0.15,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: FileImage(File(picture.path)),
                          fit: BoxFit.fill
                      ),
                    ),
                    child: const Text(""),
                  );
                }).toList(),
              ),


              ///Product Name
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
                      hintText: 'Name',
                      contentPadding: EdgeInsets.all(5.0),
                      hintStyle: TextStyle(color: Colors.grey),

                    ),
                    controller: nameController,
                    validator: (value) {
                      if (value == null) {
                        return 'Please enter your Product Name';
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

              ///Product Description
              Container(
                margin: const EdgeInsets.only(left: 30.0, right: 30.0, bottom: 20.0),
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
                      hintText: 'Description',
                      contentPadding: EdgeInsets.all(5.0),
                      hintStyle: TextStyle(color: Colors.grey),

                    ),
                    controller: descrController,
                    validator: (value) {
                      if (value == null) {
                        return 'Please enter your listing description';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      description = value;
                    },
                    focusNode: focusNodeUserDescr,
                  ),
                ),
              ),

              Center(
                child: Container(
                  margin: const EdgeInsets.only(left: 30.0, right: 30.0),
                  child: Theme(
                    data: Theme.of(context).copyWith(primaryColor: Colors.grey),
                    child: TextFormField(keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
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
                        hintText: 'Consultation Fee',
                        contentPadding: EdgeInsets.all(5.0),
                        hintStyle: TextStyle(color: Colors.grey),

                      ),
                      controller: priceController,
                      validator: (value) {
                        if (value == null) {
                          return 'Please enter your Listing Price';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        consultationFee = value;
                      },
                      focusNode: focusNodeUserPrice,
                    ),
                  ),
                ),
              ),

              ///Restaurant type Selection
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                        "Payment Method: ",
                        style: GoogleFonts.getFont('Roboto', textStyle: const TextStyle(color: Color.fromRGBO(0, 0, 0, 1.0), fontSize: 16, fontWeight: FontWeight.bold))
                    ),
                    restTypesDropDown(),
                  ],
                ),
              ),

              ///Submit Button
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Center(
                  child: ElevatedButton(
                    onPressed: (){
                      formKey.currentState!.validate() && productPictures.isNotEmpty
                          ? postData()
                          : null;
                    },
                    style: ButtonStyle(
                      backgroundColor:  MaterialStatePropertyAll<Color>(getColor('green', 1.0),),
                    ),
                    child: const Text("Add Listing"),
                  ),
                ),
              )

            ],

          ),

        ),
      ),
    );
  }
}