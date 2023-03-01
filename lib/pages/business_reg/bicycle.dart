///Page to add bicycle listing

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../extras/colors.dart';
import '../../extras/data.dart';
import '../../extras/variables.dart';
import '../home.dart';
import 'dart:io';



class Bicycle extends StatefulWidget {
  final String group, bizID;
  const Bicycle({Key? key, required this.bizID, required this.group}) : super(key: key);

  @override
  State<Bicycle> createState() => _BicycleState();
}

class _BicycleState extends State<Bicycle> {

  ///Variables
  late String name, description, price, monthlyPrice, addressPickUp, addressDropOff, extraPrice, pickUpCharge, dropOffCharge, deposit, productPic = logoURL, beds, sizes;
  List<dynamic> productPictures = [];
  List<MyLocation> pickUps = [];
  List<MyLocation> dropOffs = [];

  ///Form controls
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descrController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController monthlyPriceController = TextEditingController();
  final TextEditingController extraPriceController = TextEditingController();
  final TextEditingController depositController = TextEditingController();
  final TextEditingController addressPickUpController = TextEditingController();
  final TextEditingController chargePickUpController = TextEditingController();
  final TextEditingController addressDropOffController = TextEditingController();
  final TextEditingController chargeDropOffController = TextEditingController();
  final FocusNode focusNodeUserName= FocusNode();
  final FocusNode focusNodeUserDescr = FocusNode();
  final FocusNode focusNodeUserPrice = FocusNode();
  final FocusNode focusNodeUserMonthlyPrice = FocusNode();
  final FocusNode focusNodeUserExtraPrice = FocusNode();
  final FocusNode focusNodeUserDeposit = FocusNode();
  final FocusNode focusNodeAddressPickUp = FocusNode();
  final FocusNode focusNodePickUpCharge = FocusNode();
  final FocusNode focusNodeAddressDropOff = FocusNode();
  final FocusNode focusNodeDropOffCharge = FocusNode();

  ///Load image from phone storage
  Future getImage() async {
    var images = (
        await FilePicker.platform.pickFiles(
          allowMultiple: true,
            type: FileType.image,
            dialogTitle: "Please select bicycle pictures."
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
      loadingScreenMsg = "Uploading bicycle pictures...";
    });

    ///Shared Preferences Instance
    prefs = await SharedPreferences.getInstance();

    ///File Name on Firebase storage
    String fileName = name + 'pr-cycle' + DateFormat('ddMMMMyyyyhhmmss').format(DateTime.now()).toString();

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


  ///Post data to Firebase
  void postData() async{
    setState(() {
      isLoading = true;
      loadingScreenMsg = "Posting Data ...";
    });
    ///Add new user to Firebase
    DocumentReference docRef = FirebaseFirestore.instance.collection('listings').doc();
    docRef.set({
      'id': docRef.id,
      'name': name,
      'description': description,
      'price': price,
      'businessID': widget.bizID,
      //'pic': productPic,
      'dateRegistered': DateFormat('dd MMMM yyyy').format(DateTime.now()).toString() + " " + DateFormat('hh:mm:ss').format(DateTime.now()).toString(),
    }).then((value) async {

      Fluttertoast.showToast(msg: "Listing created Successfully");

      ///Upload Product Pictures
       productPictures.forEach((element) {
        uploadProfilePicture(File(element.path), docRef.id, name);
      });

      ///Navigate to Home Page
      Navigator.push(context, MaterialPageRoute(builder: (context) => const Home()));

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
              title: Text("Add Bicycle Listing",
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
            body: SingleChildScrollView(
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
                            hintText: 'Bicycle Name/Type',
                            contentPadding: EdgeInsets.all(5.0),
                            hintStyle: TextStyle(color: Colors.grey),

                          ),
                          controller: nameController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter a valid Name';
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
                            hintText: 'Description',
                            contentPadding: EdgeInsets.all(5.0),
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          controller: descrController,
                          validator: (value) {
                            if (value!.isEmpty) {
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

                    ///prices
                    Container(
                      margin: const EdgeInsets.only(left: 30.0, right: 30.0),
                      child: Theme(
                        data: Theme.of(context).copyWith(primaryColor: Colors.grey),
                        child: TextFormField(
                          keyboardType: TextInputType.number,
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
                            hintText: 'Daily Rate',
                            contentPadding: EdgeInsets.all(5.0),
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          controller: priceController,
                          validator: (value) {
                            if (value!.isEmpty) {
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
                    Container(
                      margin: const EdgeInsets.only(left: 30.0, right: 30.0),
                      child: Theme(
                        data: Theme.of(context).copyWith(primaryColor: Colors.grey),
                        child: TextFormField(
                          keyboardType: TextInputType.number,
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
                            hintText: 'Monthly Rate',
                            contentPadding: EdgeInsets.all(5.0),
                            hintStyle: TextStyle(color: Colors.grey),

                          ),
                          controller: monthlyPriceController,
                          validator: (value) {
                            if (value == null) {
                              return 'Please enter your Listing Price';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            monthlyPrice = value;
                          },
                          focusNode: focusNodeUserMonthlyPrice,
                        ),
                      ),
                    ),

                    Container(
                      margin: const EdgeInsets.only(left: 30.0, right: 30.0),
                      child: Theme(
                        data: Theme.of(context).copyWith(primaryColor: Colors.grey),
                        child: TextFormField(
                          keyboardType: TextInputType.number,
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
                            hintText: 'Extra Daily Rate',
                            contentPadding: EdgeInsets.all(5.0),
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          controller: extraPriceController,
                          validator: (value) {
                            if (value == null) {
                              return 'Please enter your Listing Price';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            extraPrice = value;
                          },
                          focusNode: focusNodeUserExtraPrice,
                        ),
                      ),
                    ),

                    ///Deposit
                    Container(
                      margin: const EdgeInsets.only(left: 30.0, right: 30.0),
                      child: Theme(
                        data: Theme.of(context).copyWith(primaryColor: Colors.grey),
                        child: TextFormField(
                          keyboardType: TextInputType.number,
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
                            hintText: 'Refundable Deposit',
                            contentPadding: EdgeInsets.all(5.0),
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          controller: depositController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter the deposit price';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            deposit = value;
                          },
                          focusNode: focusNodeUserDeposit,
                        ),
                      ),
                    ),

                    ///Pick Up points
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top:18.0),
                        child: Text(
                          "Pick Up Points",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: getColor('black', 1.0), fontSize: 18, ))
                        ),
                      ),
                    ),
                    pickUps.length != 0
                    ?  Wrap(
                      children:
                        pickUps.map((index) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text("${index.address}",
                                  style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: getColor('black', 1.0), fontSize: 12, ))
                              ),
                              Text("${index.charge}",
                                  style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: getColor('black', 1.0), fontSize: 12, ))
                              ),
                              IconButton(
                                  onPressed: (){
                                    setState(() {
                                      pickUps.remove(index);

                                    });
                                  },
                                  icon: Icon(Icons.remove, color: getColor('red', 1.0),)),
                            ],
                          );
                        }).toList()
                      ,
                    )

                    : Container(),
                    Flexible(
                      child: Row(
                        children: [
                          ///Address
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(left: 30.0, right: 30.0),
                              child: Theme(
                                data: Theme.of(context).copyWith(primaryColor: Colors.grey),
                                child: TextFormField(
                                  style: const TextStyle(
                                      color: Colors.grey
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'Location',
                                    contentPadding: EdgeInsets.all(5.0),
                                    hintStyle: TextStyle(color: Colors.grey),

                                  ),
                                  controller: addressPickUpController,
                                  onChanged: (value) {
                                    addressPickUp = value;
                                  },
                                  focusNode: focusNodeAddressPickUp,
                                ),
                              ),
                            ),
                          ),

                          ///Charge
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(left: 30.0, right: 30.0),
                              child: Theme(
                                data: Theme.of(context).copyWith(primaryColor: Colors.grey),
                                child: TextFormField(
                                  style: const TextStyle(
                                      color: Colors.grey
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'Charge',
                                    contentPadding: EdgeInsets.all(5.0),
                                    hintStyle: TextStyle(color: Colors.grey),

                                  ),
                                  controller: chargePickUpController,
                                  onChanged: (value) {
                                    pickUpCharge = value;
                                  },
                                  focusNode: focusNodePickUpCharge,
                                ),
                              ),
                            ),
                          ),

                          ///Add button
                          IconButton(
                              onPressed: (){
                                setState(() {
                                  pickUps.add(
                                      MyLocation(
                                          name: 'pickup',
                                          address: addressPickUp,
                                          charge: pickUpCharge
                                      )
                                  );
                                });
                                chargePickUpController.clear();
                                addressPickUpController.clear();
                              },
                              icon: Icon(Icons.add, color: getColor('green', 1.0),))
                        ],
                      ),
                    ),
                    ///Drop Off points
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top:18.0),
                        child: Text(
                          "Drop Off Points",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: getColor('black', 1.0), fontSize: 18, ))
                        ),
                      ),
                    ),
                    dropOffs.length != 0
                    ? Wrap(
                      children:
                      dropOffs.map((index) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text("${index.address}",
                                style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: getColor('black', 1.0), fontSize: 12, ))
                            ),
                            Text("${index.charge}",
                                style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: getColor('black', 1.0), fontSize: 12, ))
                            ),
                            IconButton(
                                onPressed: (){
                                  setState(() {
                                    dropOffs.remove(index);

                                  });
                                },
                                icon: Icon(Icons.remove, color: getColor('red', 1.0),)),
                          ],
                        );
                      }).toList()
                      ,
                    )
                    : Container(),
                    Flexible(
                      child: Row(
                        children: [
                          ///Address
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(left: 30.0, right: 30.0),
                              child: Theme(
                                data: Theme.of(context).copyWith(primaryColor: Colors.grey),
                                child: TextFormField(
                                  style: const TextStyle(
                                      color: Colors.grey
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'Location',
                                    contentPadding: EdgeInsets.all(5.0),
                                    hintStyle: TextStyle(color: Colors.grey),

                                  ),
                                  controller: addressDropOffController,

                                  onChanged: (value) {
                                    addressDropOff = value;
                                  },
                                  focusNode: focusNodeAddressDropOff,
                                ),
                              ),
                            ),
                          ),

                          ///Charge
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(left: 30.0, right: 30.0),
                              child: Theme(
                                data: Theme.of(context).copyWith(primaryColor: Colors.grey),
                                child: TextFormField(
                                  style: const TextStyle(
                                      color: Colors.grey
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'Charge',
                                    contentPadding: EdgeInsets.all(5.0),
                                    hintStyle: TextStyle(color: Colors.grey),

                                  ),
                                  controller: chargeDropOffController,
                                  onChanged: (value) {
                                    dropOffCharge = value;
                                  },
                                  focusNode: focusNodeDropOffCharge,
                                ),
                              ),
                            ),
                          ),

                          ///Add button
                          IconButton(
                              onPressed: (){
                                setState(() {
                                  dropOffs.add(MyLocation(name: 'dropoff', address: addressDropOff, charge: dropOffCharge));

                                });
                                chargeDropOffController.clear();
                                addressDropOffController.clear();
                              },
                              icon: Icon(Icons.add, color: getColor('green', 1.0),))
                        ],
                      ),
                    ),

                    ///Submit Button
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: ElevatedButton(
                        onPressed: (){
                          formKey.currentState!.validate() && pickUps.isNotEmpty && dropOffs.isNotEmpty && productPictures.isNotEmpty
                              ? postData()
                              : null;
                        },
                        style: ButtonStyle(
                          backgroundColor:  MaterialStatePropertyAll<Color>(getColor('green', 1.0),),
                        ),
                        child: const Text("Add Bicycle Listing"),
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