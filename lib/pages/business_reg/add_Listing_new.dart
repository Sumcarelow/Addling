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
import '../main_tabs/home.dart';

class AddListingNew extends StatefulWidget {
  const AddListingNew({Key? key}) : super(key: key);

  @override
  State<AddListingNew> createState() => _AddListingNewState();
}

class _AddListingNewState extends State<AddListingNew> {

  ///Variables
  late String name, bizID, description, ageRestr, price = prices[0], mobile = optionsYN[0];
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


  ///Drop down Button for BedSizes
  Widget restTypesDropDown(){
    return DropdownButton(

      /// Initial Value
      value: mobile,

      /// Down Arrow Icon
      icon: const Icon(Icons.keyboard_arrow_down),

      /// Array list of items
      items: optionsYN.map((String items) {
        return DropdownMenuItem(
          value: items,
          child: Text(items),
        );
      }).toList(),
      // After selecting the desired option,it will
      // change button value to selected value
      onChanged: (String? newValue) {
        setState(() {
          mobile = newValue!;
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
      'price': price,
      'businessID': bizID,
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
  ///load Local Storage Info
  void loadData() async{
    prefs = await SharedPreferences.getInstance();
    setState(() {
      bizID = prefs.getString('id') ?? '';
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: getColor('white', 1.0),
        ///AppBar Title
        centerTitle: true,
        title: Text("Add Self Love Listing",
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


            ///product price
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Price: "),
                priceTypeDropDown(),
              ],
            ),

            ///Restaurant type Selection
            /*Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                      "Mobile Service?",
                      style: GoogleFonts.getFont('Roboto', textStyle: const TextStyle(color: Color.fromRGBO(0, 0, 0, 1.0), fontSize: 16, fontWeight: FontWeight.bold))
                  ),
                  restTypesDropDown(),
                ],
              ),
            ),*/

            ///Amenities section
/*
            amenities.isEmpty
                ? Container()
                :
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
*/


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
                  child: const Text("Add Self Love Listing"),
                ),
              ),
            )

          ],

        ),

      ),
    );
  }
}
