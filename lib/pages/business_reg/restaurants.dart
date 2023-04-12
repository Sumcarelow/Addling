///Page to add restaurant listing

import 'package:adlinc/pages/business_reg/rest_menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../../extras/colors.dart';
import '../../extras/data.dart';
import '../../extras/variables.dart';
import '../home.dart';


class Restaurant extends StatefulWidget {
  final String group, bizID;
  const Restaurant({Key? key, required this.bizID, required this.group}) : super(key: key);

  @override
  State<Restaurant> createState() => _RestaurantState();
}

class _RestaurantState extends State<Restaurant> {
  ///Variables
  List<DocumentSnapshot> amenities = [];
  List<DocumentSnapshot> myAmenities = [];
  List<dynamic> productPictures = [];

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descrController = TextEditingController();

  final FocusNode focusNodeUserDescr = FocusNode();
  late String name, description, restType = rests[0];
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

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
    String fileName = name + 'pr-rest' + DateFormat('ddMMMMyyyyhhmmss').format(DateTime.now()).toString();

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
      value: restType,

      /// Down Arrow Icon
      icon: const Icon(Icons.keyboard_arrow_down),

      /// Array list of items
      items: rests.map((String items) {
        return DropdownMenuItem(
          value: items,
          child: Text(items),
        );
      }).toList(),
      // After selecting the desired option,it will
      // change button value to selected value
      onChanged: (String? newValue) {
        setState(() {
          restType = newValue!;
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
      'description': description,
      'businessID': widget.bizID,
      'dateRegistered': "${DateFormat('dd MMMM yyyy').format(DateTime.now())} ${DateFormat('hh:mm:ss').format(DateTime.now())}",
    }).then((value) async {

      ///Upload Product Pictures
      productPictures.forEach((element) {
        uploadProfilePicture(File(element.path), docRef.id, name);
      });


      ///Upload Amenities List
     // uploadAmenities(docRef.id);

      Fluttertoast.showToast(msg: "Listing created Successfully");

      ///Navigate to Home Page
      Navigator.push(context, MaterialPageRoute(builder: (context) => MenuAdd(bizID: widget.bizID,)));

    });
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
    return Material(
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              backgroundColor: getColor('white', 1.0),
              ///AppBar Title
              centerTitle: true,
              title: Text("Add Restaurant",
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
                            hintText: 'Room Description',
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

                    ///Restaurant type Selection
                    restTypesDropDown(),

                    ///Amenities section
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
                                if(
                                myAmenities.contains(amenities[index])){
                                  setState(() {
                                    myAmenities.remove(amenities[index]);
                                  });
                                } else {
                                  setState(() {
                                    myAmenities.add(amenities[index]);
                                  });
                                }
                              },
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: myAmenities.contains(amenities[index])? Colors.green : Colors.grey,
                                    borderRadius: BorderRadius.circular(15)),
                                child: Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: Text(amenities[index]["name"],
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.getFont('Roboto', textStyle: const TextStyle(color: Color.fromRGBO(255, 255, 255, 1.0), fontSize: 8,))
                                  ),
                                ),
                              ),
                            );
                          }),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
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
                    )

                  ],

                ),

              ),
            ),
          ),


          ///Loading Screen
          isLoading
              ? Positioned(
            child: Container(
              color: getColor("black", 0.5),
              child: Center(
                child: Text(loadingScreenMsg, style: TextStyle(
                    color: getColor("white", 1.0)
                ),),
              ),
            ),
          )
              : Container()
        ],
      ),
    );
  }
}