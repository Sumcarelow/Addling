///Page to add Home Care based services listing

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
class HomeCare extends StatefulWidget {
  final String group, bizID;
  const HomeCare({Key? key, required this.bizID, required this.group}) : super(key: key);

  @override
  State<HomeCare> createState() => _HomeCareState();
}

class _HomeCareState extends State<HomeCare> {
  ///Variables
  late String name, description, ageRestr, price = prices[0], rate = rates[0], speciality = specialities[0];
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
            dialogTitle: "Please select pictures."
        ))?.files;

    if(images != null && images.length != 0){
      setState(() {
        productPictures = images;
      });
    }
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
    String fileName = name + 'pr-comm' + DateFormat('ddMMMMyyyyhhmmss').format(DateTime.now()).toString();

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

  ///Drop down Button for BedSizes
  Widget restTypesDropDown(){
    return DropdownButton(

      /// Initial Value
      value: speciality,

      /// Down Arrow Icon
      icon: const Icon(Icons.keyboard_arrow_down),

      /// Array list of items
      items: specialities.map((String items) {
        return DropdownMenuItem(
          value: items,
          child: Text(items),
        );
      }).toList(),
      // After selecting the desired option,it will
      // change button value to selected value
      onChanged: (String? newValue) {
        setState(() {
          speciality = newValue!;
        });
      },
    );
  }
  ///Drop down Button for BedSizes
  Widget ratesDropDown(){
    return DropdownButton(

      /// Initial Value
      value: rate,

      /// Down Arrow Icon
      icon: const Icon(Icons.keyboard_arrow_down),

      /// Array list of items
      items: rates.map((String items) {
        return DropdownMenuItem(
          value: items,
          child: Text(items),
        );
      }).toList(),
      // After selecting the desired option,it will
      // change button value to selected value
      onChanged: (String? newValue) {
        setState(() {
          rate = newValue!;
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
      'price': '$price',
      //'speciality': speciality,
      'businessID': widget.bizID,
      'favourites': 0,
      'comments': 0,
      'rating': 0,
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

  ///Price Dropdown
  Widget priceTypeDropDown() {
    return DropdownButton<String>(
      value: price,
      icon: const Icon(Icons.arrow_drop_down),
      elevation: 16,
      style: const TextStyle(color: Colors.black),
      underline: Container(
        height: 2,
        //color: Colors.deepPurpleAccent,
      ),
      onChanged: (String? value) {
        // This is called when the user selects an item.
        setState(() {
          price = value!;
        });
      },
      items: prices.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text('R$value'),
        );
      }).toList(),
    );
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: getColor('white', 1.0),
        ///AppBar Title
        centerTitle: true,
        title: Text("Add Community Product Listing",
            textAlign: TextAlign.center,
            style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: getColor('black', 1.0), fontSize: 18, ))
        ),
        leading: IconButton(
          onPressed: ()=>{
            Navigator.pop(context)
          },
          icon: const Icon(Icons.close), color: getColor('red', 1.0),),
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

              ///Price Section
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Price: "),
                  priceTypeDropDown(),
                ],
              ),

             /* Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ///product price
                    Expanded(
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
                              hintText: 'Price',
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
                              price = value;
                            },
                            focusNode: focusNodeUserPrice,
                          ),
                        ),
                      ),
                    ),
                    //ratesDropDown(),
                  ],
                ),
              ),*/

              ///Restaurant type Selection
              /*Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                        "Specialty: ",
                        style: GoogleFonts.getFont('Roboto', textStyle: const TextStyle(color: Color.fromRGBO(0, 0, 0, 1.0), fontSize: 16, fontWeight: FontWeight.bold))
                    ),
                    restTypesDropDown(),
                  ],
                ),
              ),*/

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
                    child: const Text("Add Home Care Listing"),
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