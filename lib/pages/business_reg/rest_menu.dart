///Page for adding restaurant menu items

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

class MenuAdd extends StatefulWidget {
  final String bizID;
  const MenuAdd({Key? key, required this.bizID}) : super(key: key);

  @override
  State<MenuAdd> createState() => _MenuAddState();
}

class _MenuAddState extends State<MenuAdd> {

  ///Variables
  late String name, description, price = prices[0], menuLink;
  List<dynamic> productPictures = [];
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  List<MenuItem> menuList = [];

  ///Text Field Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descrController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController menuLinkController = TextEditingController();

  ///Focus Nodes
  final FocusNode focusNodeUserName = FocusNode();
  final FocusNode focusNodeUserDescr = FocusNode();
  final FocusNode focusNodeUserPrice = FocusNode();
  final FocusNode focusNodeUserMenu = FocusNode();

  ///Load images from phone storage
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

  ///Add to Menu List
 void addToList(){
    ///Add to List
    this.setState(() {
      menuList.add(
          MenuItem(
              name: name,
              price: price,
              description: description,
          ));
    });

    ///Clear Controllers and Strings
    nameController.clear();
    descrController.clear();
    priceController.clear();

    ///Clear variables
    this.setState(() {
      name = '';
      description = '';
      price = '';
    });
  }

  ///Upload Product Image to firebase storage
  Future uploadProfilePicture(File image, String docID, String name) async {
    ///Set OnLoading Screen
    setState(() {
      isLoading = true;
      loadingScreenMsg = "Uploading room pictures...";
    });

    ///Shared Preferences Instance
    prefs = await SharedPreferences.getInstance();

    ///File Name on Firebase storage
    String fileName = name + 'pr-accom' + DateFormat('ddMMMMyyyyhhmmss').format(DateTime.now()).toString();

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

  void postData(){
    ///Clear Controllers and Strings
    nameController.clear();
    descrController.clear();
    priceController.clear();

    ///Post to Firebase
    menuList.forEach((element) {
      ///Add document
      DocumentReference docRef = FirebaseFirestore.instance.collection('listings').doc('').collection('menu').doc();

      docRef.set({
        'name': element.name,
        'description': element.description,
        'price': element.price,
        'menuLink': menuLink,
      });
      ///Upload Product Pictures
      productPictures.forEach((element) {
        uploadProfilePicture(File(element.path), docRef.id, name);
      });
    } );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
      // TODO: implement initState
      super.initState();
      for(int i = 1; i <= 50000; i++){
        this.setState(() {
          prices.add(i.toString());

        });
      }

  }
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [

          ///Mail App Page
          Scaffold(
            ///AppBar
            appBar: AppBar(
              backgroundColor: getColor('white', 1.0),
              ///AppBar Title
              centerTitle: true,
              title: Text("Add Menu Entry",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: getColor('black', 1.0), fontSize: 18, ))
              ),
              leading: IconButton(
                onPressed: ()=>{
                  Navigator.pop(context)
                },
                icon: const Icon(Icons.close), color: getColor('red', 1.0),),
            ),

            ///App Body
            body: Container(
              child: Form(
                key: formKey,
                child: Column(
                  children: [

                    ///Menu List
                    menuList.isEmpty
                    ? Container()
                    : Wrap(
                      children:
                      menuList.map((index) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(index.name,
                                style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: getColor('black', 1.0), fontSize: 12, ))
                            ),
                            Text(index.description,
                                style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: getColor('black', 1.0), fontSize: 12, ))
                            ),
                            Text(index.price,
                                style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: getColor('black', 1.0), fontSize: 12, ))
                            ),

                          ],
                        );
                      }).toList()
                      ,
                    ),

                    ///Product Name
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
                            hintText: 'Name',
                            contentPadding: EdgeInsets.all(5.0),
                            hintStyle: TextStyle(color: Colors.grey),

                          ),
                          controller: nameController,
                          validator: (value) {
                            if (value == null) {
                              return 'Please enter Name';
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
                              return 'Please enter the description';
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

                    ///Product Price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Price: "),
                        priceTypeDropDown(),
                      ],
                    ),
                   /* Container(
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
                            hintText: 'Price',
                            contentPadding: EdgeInsets.all(5.0),
                            hintStyle: TextStyle(color: Colors.grey),

                          ),
                          controller: priceController,
                          validator: (value) {
                            if (value == null) {
                              return 'Please enter your Product Price';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            price = value;
                          },
                          focusNode: focusNodeUserPrice,
                        ),
                      ),
                    ),*/

                    ///Menu Link
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
                            hintText: 'Menu Link (Optional)',
                            contentPadding: EdgeInsets.all(5.0),
                            hintStyle: TextStyle(color: Colors.grey),

                          ),
                          controller: menuLinkController,
                          onChanged: (value) {
                            menuLink = value;
                          },
                          focusNode: focusNodeUserMenu,
                        ),
                      ),
                    ),

                    ///Product Images
                    productPictures.isEmpty
                        ? GestureDetector(
                      onTap: getImage,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                           Icon(
                            Icons.camera_alt,
                          ),
                           Text('Upload Images')
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

                    ///Add to menu button
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: ElevatedButton(
                        onPressed: (){
                          formKey.currentState!.validate() && name != '' && price != '' && description != '' && productPictures.isNotEmpty
                              ? addToList()
                              : Fluttertoast.showToast(msg: 'Please fill in all required details');
                        },
                        style: ButtonStyle(
                          backgroundColor:  MaterialStatePropertyAll<Color>(getColor('blue', 1.0),),
                        ),
                        child: const Text("Add To Menu"),
                      ),
                    ),


                    ///Add menu to store button
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: ElevatedButton(
                        onPressed: (){
                          formKey.currentState!.validate()
                              ? postData()
                              : Fluttertoast.showToast(msg: 'Please add atleast one product to your menu');
                        },
                        style: ButtonStyle(
                          backgroundColor:  MaterialStatePropertyAll<Color>(getColor('green', 1.0),),
                        ),
                        child: const Text("Upload Menu"),
                      ),
                    ),
                  ],
                ),
              ),
            )
          )
        ],
      ),
    );
  }
}
