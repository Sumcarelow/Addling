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
import 'dart:io';
import '../../extras/colors.dart';
import '../../extras/data.dart';
import '../../extras/functions.dart';
import '../../extras/variables.dart';
import '../home.dart';

class Shuttle extends StatefulWidget {
  final String group, bizID;
  const Shuttle({Key? key, required this.bizID, required this.group}) : super(key: key);

  @override
  State<Shuttle> createState() => _ShuttleState();
}

class _ShuttleState extends State<Shuttle> {

  ///Variables
  late String name, description, price, transmission = 'Manual', from, to, pickUpSpot, addressPickUp, addressDropOff, dropOff, pickUpCharge, dropOffCharge, deposit, productPic = logoURL, beds, sizes;
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
  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();
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
  final FocusNode focusNodeFrom = FocusNode();
  final FocusNode focusNodeTo = FocusNode();

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
      loadingScreenMsg = "Uploading shuttle pictures...";
    });

    ///Shared Preferences Instance
    prefs = await SharedPreferences.getInstance();

    ///File Name on Firebase storage
    String fileName = name + 'pr-shuttle' + DateFormat('ddMMMMyyyyhhmmss').format(DateTime.now()).toString();

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
        Fluttertoast.showToast(msg: "Picture Uploaded Successfully.");
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
      'puckUp': pickUpSpot,
      'droppOff': dropOff,
      'businessID': widget.bizID,
      'dateRegistered': DateFormat('dd MMMM yyyy').format(DateTime.now()).toString() + " " + DateFormat('hh:mm:ss').format(DateTime.now()).toString(),
    }).then((value) async {

      ///upload pick up points info
      // pickUps.forEach((element) async{
      //   DocumentReference temp =  FirebaseFirestore.instance.collection('listings').doc(docRef.id).collection("pickups").doc();
      //   await temp.set({
      //     "id": temp.id,
      //     "type": element.name,
      //     "address": element.address,
      //     "charge": element.charge
      //   });
      // });
      ///Drop down Button for transmissions
      Widget transMissionDropDown(String value){
        return DropdownButton(

          // Initial Value
          value: value,

          // Down Arrow Icon
          icon: const Icon(Icons.keyboard_arrow_down),

          // Array list of items
          items: transmissions.map((String items) {
            return DropdownMenuItem(
              value: items,
              child: Text(items),
            );
          }).toList(),
          // After selecting the desired option,it will
          // change button value to selected value
          onChanged: (String? newValue) {
            setState(() {
              value = newValue!;
            });
          },
        );
      }
      ///Upload Product Pictures
      productPictures.forEach((element) async{
        await uploadProfilePicture(File(element.path), docRef.id, name);
      });
      setState(() {
        isLoading = false;
      });


      ///Show success message
      Fluttertoast.showToast(msg: "Listing created Successfully");

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
              title: Text("Add Shuttle Service Listing",
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
                            hintText: 'Name/Type',
                            contentPadding: EdgeInsets.all(5.0),
                            hintStyle: TextStyle(color: Colors.grey),

                          ),
                          controller: nameController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Cannot be empty';
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
                              return 'Cannot be empty';
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

                    ///From
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
                            hintText: 'From',
                            contentPadding: EdgeInsets.all(5.0),
                            hintStyle: TextStyle(color: Colors.grey),

                          ),
                          controller: fromController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Cannot be empty';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            from = value;
                          },
                          focusNode: focusNodeFrom,
                        ),
                      ),
                    ),

                    ///From
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
                            hintText: 'To',
                            contentPadding: EdgeInsets.all(5.0),
                            hintStyle: TextStyle(color: Colors.grey),

                          ),
                          controller: toController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Cannot be empty';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            to = value;
                          },
                          focusNode: focusNodeTo,
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
                            hintText: 'Price',
                            contentPadding: EdgeInsets.all(5.0),
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          controller: priceController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Cannot be empty';
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
                          // keyboardType: TextInputType.number,
                          // inputFormatters: <TextInputFormatter>[
                          //   FilteringTextInputFormatter.digitsOnly
                          // ],
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
                            hintText: 'Pick Up Location',
                            contentPadding: EdgeInsets.all(5.0),
                            hintStyle: TextStyle(color: Colors.grey),

                          ),
                          controller: monthlyPriceController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Cannot be empty';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            pickUpSpot = value;
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
                            hintText: 'Drop Off Location',
                            contentPadding: EdgeInsets.all(5.0),
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          controller: extraPriceController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Cannot be empty';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            dropOff = value;
                          },
                          focusNode: focusNodeUserExtraPrice,
                        ),
                      ),
                    ),

                    Wrap(
                      children: [
                        Text(
                          "Shuttle Hours:",
                          style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: getColor('black', 0.5), fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                        /// Monday
                        Padding(
                          padding: EdgeInsets.only(left:8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
                                  "Monday"
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    selectTime(context, "Monday", "arrival",mondayOpenController);
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
                                      onSaved: (String? val) {
                                        mondayOpen = val!;
                                      },
                                      enabled: false,
                                      keyboardType: TextInputType.text,
                                      controller: mondayOpenController,
                                      decoration: InputDecoration(
                                          disabledBorder:
                                          UnderlineInputBorder(borderSide: BorderSide.none),
                                          labelText: 'Arrival Time',
                                          contentPadding: EdgeInsets.all(5)),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    selectTime(context, "Monday", "departure", mondayCloseController);
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
                                          labelText: 'Departure Time',
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
                              Text(
                                  "Tuesday"
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    selectTime(context, "Tuesday", "arrival", tuesdayOpenController);
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
                                          labelText: 'Arrival Time',
                                          contentPadding: EdgeInsets.all(5)),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    selectTime(context, "Tuesday", "departure", tuesdayCloseController);
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(top: 10),
                                    width: MediaQuery.of(context).size.width * 0.2,
                                    height: MediaQuery.of(context).size.width * 0.09,
                                    alignment: Alignment.center,
                                    //decoration: BoxDecoration(color: Colors.grey[200]),
                                    child: TextFormField(
                                      style: TextStyle(fontSize: 15),
                                      textAlign: TextAlign.center,
                                      onSaved: (String? val) {
                                        tuesdayClose = val!;
                                      },
                                      enabled: false,
                                      keyboardType: TextInputType.text,
                                      controller: tuesdayCloseController,
                                      decoration: InputDecoration(
                                          disabledBorder:
                                          UnderlineInputBorder(borderSide: BorderSide.none),
                                          labelText: 'Departure Time',
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
                              Text(
                                  "Wednesday"
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    selectTime(context, "Wednesday", "arrival", wedOpenController);
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(top: 10),
                                    width: MediaQuery.of(context).size.width * 0.2,
                                    height: MediaQuery.of(context).size.width * 0.09,
                                    alignment: Alignment.center,
                                    //decoration: BoxDecoration(color: Colors.grey[200]),
                                    child: TextFormField(
                                      style: TextStyle(fontSize: 15),
                                      textAlign: TextAlign.center,
                                      onSaved: (String? val) {
                                        wedOpen = val!;
                                      },
                                      enabled: false,
                                      keyboardType: TextInputType.text,
                                      controller: wedOpenController,
                                      decoration: InputDecoration(
                                          disabledBorder:
                                          UnderlineInputBorder(borderSide: BorderSide.none),
                                          labelText: 'Arrival Time',
                                          contentPadding: EdgeInsets.all(5)),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    selectTime(context, "Wednesday", "departure", wedCloseController);
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(top: 10),
                                    width: MediaQuery.of(context).size.width * 0.2,
                                    height: MediaQuery.of(context).size.width * 0.09,
                                    alignment: Alignment.center,
                                    //decoration: BoxDecoration(color: Colors.grey[200]),
                                    child: TextFormField(
                                      style: TextStyle(fontSize: 15),
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
                                          labelText: 'Departure Time',
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
                              Text(
                                  "Thursday"
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    selectTime(context, "Thursday", "arrival", thursdayOpenController);
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(top: 10),
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
                                          labelText: 'Arrival Time',
                                          contentPadding: EdgeInsets.all(5)),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    selectTime(context, "Thursday", "departure", thursdayCloseController);
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
                                          labelText: 'Departure Time',
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
                              Text(
                                  "Friday"
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    selectTime(context, "Friday", "arrival", fridayOpenController);
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(top: 10),
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
                                          labelText: 'Arrival Time',
                                          contentPadding: EdgeInsets.all(5)),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    selectTime(context, "Friday", "departure", fridayCloseController);
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(top: 10),
                                    width: MediaQuery.of(context).size.width * 0.2,
                                    height: MediaQuery.of(context).size.width * 0.09,
                                    alignment: Alignment.center,
                                    //decoration: BoxDecoration(color: Colors.grey[200]),
                                    child: TextFormField(
                                      style: TextStyle(fontSize: 15),
                                      textAlign: TextAlign.center,
                                      onSaved: (String? val) {
                                        friClose = val!;
                                      },
                                      enabled: false,
                                      keyboardType: TextInputType.text,
                                      controller: fridayCloseController,
                                      decoration: InputDecoration(
                                          disabledBorder:
                                          UnderlineInputBorder(borderSide: BorderSide.none),
                                          labelText: 'Departure Time',
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
                              Text(
                                  "Saturday"
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    selectTime(context, "Saturday", "arrival", saturdayOpenController);
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(top: 10),
                                    width: MediaQuery.of(context).size.width * 0.2,
                                    height: MediaQuery.of(context).size.width * 0.09,
                                    alignment: Alignment.center,
                                    //decoration: BoxDecoration(color: Colors.grey[200]),
                                    child: TextFormField(
                                      style: TextStyle(fontSize: 15),
                                      textAlign: TextAlign.center,
                                      onSaved: (String? val) {
                                        satOpen = val!;
                                      },
                                      enabled: false,
                                      keyboardType: TextInputType.text,
                                      controller: saturdayOpenController,
                                      decoration: InputDecoration(
                                          disabledBorder:
                                          UnderlineInputBorder(borderSide: BorderSide.none),
                                          labelText: 'Arrival Time',
                                          contentPadding: EdgeInsets.all(5)),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    selectTime(context, "Saturday", "arrival", saturdayCloseController);
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
                                          labelText: 'Departure Time',
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
                              Text(
                                  "Sunday"
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    selectTime(context, "Sunday", "arrival", sundayOpenController);
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
                                          labelText: 'Arrival Time',
                                          contentPadding: EdgeInsets.all(5)),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    selectTime(context, "Sunday", "departure", sundayCloseController);
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(top: 10),
                                    width: MediaQuery.of(context).size.width * 0.2,
                                    height: MediaQuery.of(context).size.width * 0.09,
                                    alignment: Alignment.center,
                                    //decoration: BoxDecoration(color: Colors.grey[200]),
                                    child: TextFormField(
                                      style: TextStyle(fontSize: 15),
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
                                          labelText: 'Departure Time',
                                          contentPadding: EdgeInsets.all(5)),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      ],
                    ),
                    //
                    // pickUps.isNotEmpty
                    //     ?  Wrap(
                    //   children:
                    //   pickUps.map((index) {
                    //     return Row(
                    //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    //       children: [
                    //         Text("${index.address}",
                    //             style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: getColor('black', 1.0), fontSize: 12, ))
                    //         ),
                    //         Text("${index.charge}",
                    //             style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: getColor('black', 1.0), fontSize: 12, ))
                    //         ),
                    //         IconButton(
                    //             onPressed: (){
                    //               setState(() {
                    //                 pickUps.remove(index);
                    //
                    //               });
                    //             },
                    //             icon: Icon(Icons.remove, color: getColor('red', 1.0),)),
                    //       ],
                    //     );
                    //   }).toList()
                    //   ,
                    // )
                    //
                    //     : Container(),
                    // Flexible(
                    //   child: Row(
                    //     children: [
                    //       ///Address
                    //       Expanded(
                    //         child: Container(
                    //           margin: const EdgeInsets.only(left: 30.0, right: 30.0),
                    //           child: Theme(
                    //             data: Theme.of(context).copyWith(primaryColor: Colors.grey),
                    //             child: TextFormField(
                    //               style: const TextStyle(
                    //                   color: Colors.grey
                    //               ),
                    //               decoration: const InputDecoration(
                    //                 hintText: 'Location',
                    //                 contentPadding: EdgeInsets.all(5.0),
                    //                 hintStyle: TextStyle(color: Colors.grey),
                    //
                    //               ),
                    //               controller: addressPickUpController,
                    //               onChanged: (value) {
                    //                 addressPickUp = value;
                    //               },
                    //               focusNode: focusNodeAddressPickUp,
                    //             ),
                    //           ),
                    //         ),
                    //       ),
                    //       ///Charge
                    //       Expanded(
                    //         child: Container(
                    //           margin: const EdgeInsets.only(left: 30.0, right: 30.0),
                    //           child: Theme(
                    //             data: Theme.of(context).copyWith(primaryColor: Colors.grey),
                    //             child: TextFormField(
                    //               style: const TextStyle(
                    //                   color: Colors.grey
                    //               ),
                    //               decoration: const InputDecoration(
                    //                 hintText: 'Charge',
                    //                 contentPadding: EdgeInsets.all(5.0),
                    //                 hintStyle: TextStyle(color: Colors.grey),
                    //
                    //               ),
                    //               controller: chargePickUpController,
                    //               onChanged: (value) {
                    //                 pickUpCharge = value;
                    //               },
                    //               focusNode: focusNodePickUpCharge,
                    //             ),
                    //           ),
                    //         ),
                    //       ),
                    //
                    //       ///Add button
                    //       IconButton(
                    //           onPressed: (){
                    //             setState(() {
                    //               pickUps.add(
                    //                   MyLocation(
                    //                       name: 'pickup',
                    //                       address: addressPickUp,
                    //                       charge: pickUpCharge
                    //                   )
                    //               );
                    //             });
                    //             chargePickUpController.clear();
                    //             addressPickUpController.clear();
                    //           },
                    //           icon: Icon(Icons.add, color: getColor('green', 1.0),))
                    //     ],
                    //   ),
                    // ),

                    ///Submit Button
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: ElevatedButton(
                        onPressed: (){
                          formKey.currentState!.validate() && pickUps.isNotEmpty && dropOffs.isNotEmpty && productPictures.isNotEmpty
                              ? postData()
                              : Fluttertoast.showToast(msg: "Please ensure all information is provided before adding listing.");
                        },
                        style: ButtonStyle(
                          backgroundColor:  MaterialStatePropertyAll<Color>(getColor('green', 1.0),),
                        ),
                        child: const Text("Add Shuttle Listing"),
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