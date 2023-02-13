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
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../extras/variables.dart';
import 'home.dart';
import 'dart:io';
import '../extras/colors.dart';


class AddListing extends StatefulWidget {
  final String group, bizID;
  const AddListing({Key? key, required this.group, required this.bizID}) : super(key: key);

  @override
  State<AddListing> createState() => _AddListingState();
}

class _AddListingState extends State<AddListing> {
  ///Vartiables
  List<DocumentSnapshot> amenities = [];
  List<DocumentSnapshot> myAmenities = [];
  late String name, description, price, productPic = logoURL;
  var profileImage;
  final GlobalKey<FormState> registerFormKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descrController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final FocusNode focusNodeUserName= FocusNode();
  final FocusNode focusNodeUserDescr = FocusNode();
  final FocusNode focusNodeUserPrice = FocusNode();

  ///Shared Preferences instance
  late SharedPreferences prefs;

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

  Future uploadProfilePicture() async {
    ///Set OnLoading Screen
    setState(() {
      isLoading = true;
      loadigScreenMsg = "Uploading profile picture...";
    });

    ///Shared Preferences Instance
    prefs = await SharedPreferences.getInstance();

    ///File Name on Firebase storage
    String fileName = 'Logo' + DateFormat('ddMMMMyyyyhhmmss').format(DateTime.now()).toString();

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
          productPic = downloadUrl;
          isLoading = false;
        });

        //await prefs.setString('profilePic', profilePic);
        Fluttertoast.showToast(msg: "Product Image Uploaded Successfully.");
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

  ///Post data to Firebase
  void postData() async{
    ///Add new user to Firebase
    DocumentReference docRef = FirebaseFirestore.instance.collection('businesses').doc(widget.bizID).collection('listings').doc();
    docRef.set({
      'id': docRef.id,
      'name': name,
      'description': description,
      'price': price,
      'businessID': widget.bizID,
      'pic': productPic,
      'dateRegistered': DateFormat('dd MMMM yyyy').format(DateTime.now()).toString() + " " + DateFormat('hh:mm:ss').format(DateTime.now()).toString(),
    }).then((value) async {

      Fluttertoast.showToast(msg: "Listing created Successfully");

      ///Navigate to Home Page
      Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));

    });
  }
  ///Get amenities list from Firebase
  void getAmenities() async{
    final QuerySnapshot result =
    await FirebaseFirestore.instance.collection('amenities').doc('9CS2DCN4zN9kycbxYMmv').collection('amenities').get();
    final List<DocumentSnapshot> documents = result.docs;

    if(documents.isEmpty){
      this.setState(() {
        amenities = [];
      });
    } else{

      this.setState(() {
        amenities = documents;
      });
    }
  }

  ///Initial state
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAmenities();
    this.setState(() {

    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Listing"),
      ),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          ///Product Name
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
                  hintText: 'Product Name',
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
            margin: EdgeInsets.only(left: 30.0, right: 30.0),
          ),

          ///Product Description
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
                  hintText: 'Product Description',
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
            margin: EdgeInsets.only(left: 30.0, right: 30.0),
          ),

          ///product price
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
            margin: EdgeInsets.only(left: 30.0, right: 30.0),
          ),

          ///Upload Pic Section
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ///Company Logo Section
              Expanded(
                child: Container(
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        (profileImage == null)
                            ? (productPic != ''
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
                            imageUrl: productPic,
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
                                Text('Upload logo')
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


          Expanded(
            child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 100,
                    childAspectRatio: 4 / 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 20
                ),
                itemCount: amenities.length,
                itemBuilder: (BuildContext ctx, index) {
                  return GestureDetector(
                    onTap: (){
                      if(myAmenities.contains(amenities[index])){
                        myAmenities.remove(index);
                      } else {

                        myAmenities.add(amenities[index]);
                      }
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: myAmenities.contains(amenities[index])? Colors.green : Colors.grey,
                          borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(amenities[index]["name"],
                            textAlign: TextAlign.center,
                            style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: Color.fromRGBO(255, 255, 255, 1.0), fontSize: 10,))
                        ),
                      ),
                    ),
                  );
                }),
          ),

          ElevatedButton(
              style: ButtonStyle(
                backgroundColor:  MaterialStatePropertyAll<Color>(getColor('green', 1.0),),
              ),
              //color: colors[2],
              onPressed: (){
                registerFormKey.currentState!.validate()
                    ? postData()
                    : Fluttertoast.showToast(msg: "Please fill in the missing or incorrect information.");
              },
              child: Padding(
                padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.07,
                    right: MediaQuery.of(context).size.width * 0.07),
                child: Text("Register Listing",
                    style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: getColor('white', 1.0), fontSize: 16, fontWeight: FontWeight.bold))
                ),
              )
          ),
        ],
      ),
    );
  }
}
