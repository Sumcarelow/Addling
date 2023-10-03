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
import '../../extras/ui_elements.dart';
import '../../extras/variables.dart';
import '../main_tabs/home.dart';

class AddBait extends StatefulWidget {
  final String bizID, bizName, bizAddress, bizLogo, bizCategory;
  const AddBait({Key? key, required this.bizID, required this.bizAddress, required this.bizName, required this.bizLogo, required this.bizCategory}) : super(key: key);

  @override
  State<AddBait> createState() => _AddBaitState();
}

class _AddBaitState extends State<AddBait> {

  ///Variables
  late String name, bizID, description, ageRestr, bizAddress, price, mobile = optionsYN[0];
  List<DocumentSnapshot> amenities = [];
  List<DocumentSnapshot> myAmenities = [];
  List<dynamic> productPictures = [];
  List<String> imagesUrls = [];

  final FocusNode focusNodeUserName= FocusNode();
  final FocusNode focusNodeUserDescr = FocusNode();
  final FocusNode focusNodeUserPrice = FocusNode();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descrController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  ///Shared Preferences instance
  late SharedPreferences prefs;

  ///Get amenities list from Firebase
  void getAmenities() async{
    print("STarted pilling");
    final QuerySnapshot result =
    await FirebaseFirestore.instance.collection('newAmenities').get();
    print("Done pulling");
    final List<DocumentSnapshot> documents = result.docs;

    if(documents.length == 0){
      setState(() {
        amenities = [];
      });
    } else{
      setState(() {
        amenities = documents;
      });
    }
  }

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

      ///Upload Pictures
      for(int index = 0; index <= images.length - 1; index++)
      {
        await uploadProfilePicture(File(images[index].path!), index.toString(), 'name');
      }
    }
  }

  ///Upload Profile Image to firebase storage
  Future uploadProfilePicture(File image, String docID, String name) async {
    ///Set OnLoading Screen
    setState(() {
      isLoading = true;
      loadingScreenMsg = "Uploading bait pictures...";
    });

    ///Shared Preferences Instance
    prefs = await SharedPreferences.getInstance();

    ///File Name on Firebase storage
    String fileName = DateFormat('ddMMMMyyyyhhmmss').format(DateTime.now()).toString()+ docID;

    ///Create storage reference and upload image
    Reference reference = FirebaseStorage.instance.ref().child(fileName);
    UploadTask uploadTask = reference.putFile(image);
    TaskSnapshot storageTaskSnapshot;
    uploadTask.then((value){
      ///If Upload was successful
      storageTaskSnapshot = value;

      ///Get Url
      storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl)async{

       /*await FirebaseFirestore.instance.collection("baits").doc(docID).collection('pictures').doc()
            .set({
          "location": downloadUrl
        });*/
        print("Sending image one of one with filename : $fileName");
        setState(() {
          imagesUrls.add(downloadUrl);
          isLoading = false;
        });

        //await prefs.setString('profilePic', profilePic);
        Fluttertoast.showToast(msg: "Pictures Uploaded Successfully.");
        ///Navigate to Home Page
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
    ///Set Loading Screen
    setState(() {
      isLoading = true;
    });

    double coins = (int.parse(price) )*0.05;
    ///Add new user to Firebase
    DocumentReference docRef = FirebaseFirestore.instance.collection('baits').doc();
    docRef.set({
      'id': docRef.id,
      'name': name,
      'price': int.parse(price),
      'businessID': widget.bizID,
      'businessName': widget.bizName,
      'businessAddress': widget.bizAddress,
      'businessLogo': widget.bizLogo,
      'category': widget.bizCategory,
      'favourites': 0,
      'comments': 0,
      'rating': 0,
      'coins': coins.toString(),
      'time': DateFormat('hh:mm:ss').format(DateTime.now()).toString(),
      'dateRegistered': DateFormat('dd MMMM yyyy').format(DateTime.now()).toString(),
      'timestamp': DateTime.now()
    }).then((value) async {

      imagesUrls.forEach((element) async{
        await FirebaseFirestore.instance.collection("baits").doc(docRef.id).collection('pictures').doc()
            .set({
          "location": element
        });
      });

      ///Upload Product Pictures

     //await uploadFiles(productPictures, docRef.id, name);

     /* for(int index = 0; index <= productPictures.length - 1; index++){
        await uploadProfilePicture(File(productPictures[index].path), docRef.id, name)
        .then((value) {
        });

      }*/

      /*productPictures.forEach((element) {
        uploadProfilePicture(File(element.path), docRef.id, name);
      });*/

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

  ///load Local Storage Info
  void loadData() async{
    prefs = await SharedPreferences.getInstance();
    setState(() {
      bizID = prefs.getString('id') ?? '';
      bizAddress = prefs.getString('bizAddress') ?? '';
    });


  }

  ///Initial State
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAmenities();
    loadData();
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
              title: Text("Add Bait Plant",
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
            body: Form(
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
                          hintText: 'Bait Name',
                          contentPadding: EdgeInsets.all(5.0),
                          hintStyle: TextStyle(color: Colors.grey),

                        ),
                        controller: nameController,
                        validator: (value) {
                          if (value == null) {
                            return 'Please enter your Bait Name';
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

                  ///ENTER PRICE
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
                          hintText: 'Bait Price',
                          contentPadding: EdgeInsets.all(5.0),
                          hintStyle: TextStyle(color: Colors.grey),

                        ),
                        controller: priceController,
                        validator: (value) {
                          if (value == null) {
                            return 'Please enter your Bait Name';
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

                 /* ///Product price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Price: "),
                      priceTypeDropDown(),
                    ],
                  ),*/

                  ///Submit Button
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Center(
                      child: ElevatedButton(
                        onPressed: (){
                          formKey.currentState!.validate() && productPictures.isNotEmpty
                              ? postData()
                              : Fluttertoast.showToast(msg: "Please fill in all information and pictures.");
                        },
                        style: ButtonStyle(
                          backgroundColor:  MaterialStatePropertyAll<Color>(getColor('green', 1.0),),
                        ),
                        child: const Text("Add Bait Plant"),
                      ),
                    ),
                  )

                ],
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
