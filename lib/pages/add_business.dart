import 'dart:async';
import 'dart:convert';
import 'package:adlinc/extras/data.dart';
import 'package:adlinc/pages/business_reg/add_bait.dart';
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
import 'address_search/address_searching.dart';
import 'address_search/places.dart';
import 'main_tabs/home.dart';
import 'package:uuid/uuid.dart';

class AddBusiness extends StatefulWidget {
  const AddBusiness({Key? key}) : super(key: key);

  @override
  State<AddBusiness> createState() => _AddBusinessState();
}

class _AddBusinessState extends State<AddBusiness> {

///Form Variables
  late String id, docID = '', name, description, businessEmail, phone, website, coverImageUrl = logoURL, policyType = policyTypes[0],
      logo = logoURL, address, group = '', policy = '',
      category = 'Please select your business Type for Bookings',
      subCategory = 'Please select your business sub-category';

  List<String> categoriesList = ['Please select your business Type for Bookings'];
  List<Category> mainCategoryList = [];
  List<String> subCategoriesList = [];
  List<DocumentSnapshot> categories = [];
  List<DocumentSnapshot> subCategories = [];
  List<dynamic> businessPictures = [];
  List<businessDay> businessHours = [];
  List<SocialMedia> businessSocials = [];


///Text Field Controllers
  final GlobalKey<FormState> registerFormKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController policyController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();
  final TextEditingController facebookController = TextEditingController();
  final TextEditingController youtubeController = TextEditingController();
  final TextEditingController linkedInController = TextEditingController();
  final TextEditingController tiktokController = TextEditingController();
  final TextEditingController twitterController = TextEditingController();
  final TextEditingController instagramController = TextEditingController();


///Text Field Focus Nodes
  final FocusNode focusNodeUserEmail = FocusNode();
  final FocusNode focusNodeUserName = FocusNode();
  final FocusNode focusNodeDescription = FocusNode();
  final FocusNode focusNodeUserLastName = FocusNode();
  final FocusNode focusNodePhone= FocusNode();
  final FocusNode focusNodeAddress = FocusNode();
  final FocusNode focusNodeDropDown = FocusNode();
  final FocusNode focusNodePolicy = FocusNode();
  final FocusNode focusNodeWebsite = FocusNode();
  final FocusNode focusNodeFacebook = FocusNode();
  final FocusNode focusNodeInstagram = FocusNode();
  final FocusNode focusNodeYoutube = FocusNode();
  final FocusNode focusNodeLinkedIn = FocusNode();
  final FocusNode focusNodeTwitter = FocusNode();
  final FocusNode focusNodeTikTok = FocusNode();


  late GlobalKey dropdownKey;
  late Widget nextPage = Home();
  var policyDoc, coverImage;
  late Coordinates coords;


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

///Upload Business Pictures
  Future uploadBusinessPictures(File image, String docID, String name) async {
    //print("Here I go.............................");
    ///Set OnLoading Screen
    setState(() {
      isLoading = true;
      loadingScreenMsg = "Uploading room pictures...";
    });

    ///Shared Preferences Instance
    prefs = await SharedPreferences.getInstance();

    ///File Name on Firebase storage
    String fileName = name + 'business' + DateFormat('ddMMMMyyyyhhmmss').format(DateTime.now()).toString();

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

///Select Business Cover Image
  Future getCoverImage() async {
    var images = (
        await FilePicker.platform.pickFiles(
            type: FileType.image,
            dialogTitle: "Please select a cover image."
        ))?.files;

    if(images != null && images.length != 0){
      setState(() {
        coverImage = File((images.first.path).toString());
      });
      uploadCoverImage();
    }
  }

///load Local Storage Info
  void loadData() async{
    prefs = await SharedPreferences.getInstance();
    setState(() {
      id = prefs.getString('id') ?? '';
    });
  }

///Shared Preferences instance
  late SharedPreferences prefs;

///Toggle show password
  bool showPassword = false;
  bool showAcceptTC = false;
  var profileImage;

///Select Category Icon
  IconData getIcon(String cat) {
    IconData icon = Icons.add;
    switch (cat){
      case 'TECH' :
        icon = Icons.computer_rounded;
            break;
       case 'BEAUTY':
         icon = Icons.clean_hands_rounded;
         break;
      case 'TRAVEL':
        icon = Icons.mode_of_travel_rounded;
        break;
      case 'STATIONARY':
        icon = Icons.menu_book_rounded;
        break;
      case 'FOOD':
        icon = Icons.fastfood_rounded;
        break;
      case 'FASHION':
        icon = Icons.shopping_bag_rounded;
        break;
      case 'JEWELLERY':
        icon = Icons.diamond_rounded;
        break;
    }
    return icon;
  }

///Fetch Categories from Firebase using level as key
  void getCategories(String level) async{
    ///Get Firebase Docs
    final QuerySnapshot result =
        await FirebaseFirestore.instance.collection('categories').where('level', isEqualTo: level).get();
    final List<DocumentSnapshot> documents = result.docs;

    ///Check if documents were loaeded successfully
    if(documents.length != 0){
      ///Load to the relevant list
      if(level == 'main'){
        //Load to main categories list
        documents.forEach((categ) {

          ///Add main categories with icons add
          this.setState(() {
            this.setState(() {
              mainCategoryList.add(Category(name: categ['name'], iconData: getIcon(categ['name'])));
            });
          });

          this.setState(() {
            categoriesList.add(categ['name']);
            categories = documents;
          });
          //print(categ['name']);
        });
      } else if(level == 'sub'){
        documents.forEach((categ) {
          this.setState(() {
            subCategories = documents;
          });
        });
      }

    } else {
      Fluttertoast.showToast(msg: "There was an error loading requested information");
    }
  }

///When Add Business Button is pressed
  void onRegisterBusinessPress() async{
    //Navigator.push(context, MaterialPageRoute(builder: (context) => AddListing(bizID: "documents[0].id", group: 'B&B',)));
    ///Unfocus all nodes
    focusNodeUserEmail.unfocus();
    focusNodeUserName.unfocus();
    focusNodeDescription.unfocus();
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
      if(showAcceptTC && category != 'Please select your business Type for Bookings'){
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
      'bio': description,
      'category': category,
      'website': website,
      'logo': logo,
      'status': 'pending',
      'type': 'booking',
      'favourites': 0,
      'comments': 0,
      'rating': 0,
      'ownerID': id,
      'time': DateFormat('hh:mm:ss').format(DateTime.now()).toString(),
      'dateRegistered': DateFormat('dd MMMM yyyy').format(DateTime.now()).toString(),
      'operationTimes': {
        'Monday': '${mondayOpenController.text} - ${mondayCloseController.text}',
        'Tuesday': '${tuesdayOpenController.text} - ${tuesdayCloseController.text}',
        'Wednesday': '${wedOpenController.text} - ${wedCloseController.text}',
        'Thursday': '${thursdayOpenController.text} - ${thursdayCloseController.text}',
        'Friday': '${fridayOpenController.text} - ${fridayCloseController.text}',
        'Saturday': '${saturdayOpenController.text} - ${saturdayCloseController.text}',
        'Sunday': '${sundayOpenController.text} - ${sundayCloseController.text}'
      },
      'coordinates': {
        'lat': coords.lat,
        'long': coords.long,
      },
      'socials': jsonEncode(businessSocials)

    }).then((value) async {

      ///Upload Business Pictures
      businessPictures.forEach((element) {
        uploadBusinessPictures(File(element.path), docRef.id, name);
      });

      ///Save Business Firebase Data to local Storage
      await prefs.setString('bizID', docRef.id);
      await prefs.setString('bizName', name);
      await prefs.setString('bizAddress', address);
      await prefs.setString('bizSubCategory', subCategory);

    });
    setState(() {
      docID = docRef.id;
    });

    Navigator.push(context, MaterialPageRoute(builder: (context) => AddBait(bizID: docRef.id, bizAddress: address, bizName: name, bizLogo: logo, bizCategory: category,)));

  }

///Set Group variable according to the subCategory
  void setGroup(String category){
    switch (category){
      case 'B&B' 'HOTEL' 'VACATION DESTINATION' :
        {
          setState(() {
            group = 'ACCOMMODATION';
          });
        }
        break;
      case 'RESTAURANT':
        {
          setState(() {
            group = 'restaurant';
          });
        }
        break;
      case 'FUN & GAMES':
        {
          setState(() {
            group = 'games';
          });
        }
        break;
      case 'SELF LOVE' 'MAKE-UP ARTIST' 'HAIRDRESSING' 'MANI AND PEDI' 'TATTOO PARLOUR' 'BODY PIERCING' 'NAIL TECHNICIAN' 'MASSAGE SALON/THERAPIST' 'FACIAL SPA' 'FOOT MASSAGE' 'SKIN CARE CONSULTING':
        {
          setState(() {
            group = 'self';
          });
        }
        break;
      case 'BICYCLE RENTAL':
        {
          setState(() {
            group = 'bicycle';
          });
        }
        break;
      case 'CAR RENTAL':
        {
          setState(() {
            group = 'carRental';
          });
        }
        break;
      case 'HEALTHCARE' 'DENTIST' 'PHYSICIAN' 'GENERAL PRACTISIONER' 'THERAPIST' 'DERMATOLOGIST' 'COUNSELLOR':
        {
          setState(() {
            group = 'healthcare';
          });
        }
        break;
      case 'HOME CARE' 'LAWN-MOWER' 'CLEANING' 'PLUMBING' 'CARPET CLEANING' 'MOVERS' 'ELECTRICIAN' 'MECHANIC' 'ROOF REPAIR' 'FLOORING' 'GUTTER CLEAN' 'HANDYMAN' 'PAINTER' 'LANDSCAPER':
        {
          setState(() {
            group = 'homeCare';
          });
        }
        break;
      case 'MOTORCYCLE':
        {
          setState(() {
            group = 'motorcycle';
          });
        }
        break;
      case 'SHUTTLE':
        {
          this.setState(() {
            group = 'shuttle';
          });
        }
    }
  }


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
    String fileName = id + 'Business-Logo' + DateFormat('ddMMMMyyyyhhmmss').format(DateTime.now()).toString();

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

///Upload PDF Document
  Future uploadPolicyDoc() async {

    ///Set OnLoading Screen
    setState(() {
      isLoading = true;
      loadingScreenMsg = "Uploading policy document...";
    });

    ///Shared Preferences Instance
    prefs = await SharedPreferences.getInstance();

    ///File Name on Firebase storage
    String fileName = id + 'Business-Policy' + DateFormat('ddMMMMyyyyhhmmss').format(DateTime.now()).toString();

    ///Create storage reference and upload image
    Reference reference = FirebaseStorage.instance.ref().child(fileName);
    UploadTask uploadTask = reference.putFile(policyDoc);
    TaskSnapshot storageTaskSnapshot;
    uploadTask.then((value){

      ///If Upload was successful
      storageTaskSnapshot = value;

      ///Get Url
      storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl)async{
        setState(() {
          policy = downloadUrl;
          isLoading = false;
        });

        //await prefs.setString('profilePic', profilePic);
        Fluttertoast.showToast(msg: "Business Policy Uploaded Successfully.");
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

///Upload PDF Document
  Future uploadCoverImage() async {

    ///Set OnLoading Screen
    setState(() {
      isLoading = true;
      loadingScreenMsg = "Uploading cover image";
    });

    ///Shared Preferences Instance
    prefs = await SharedPreferences.getInstance();

    ///File Name on Firebase storage
    String fileName = id + 'Cover-Image' + DateFormat('ddMMMMyyyyhhmmss').format(DateTime.now()).toString();

    ///Create storage reference and upload image
    Reference reference = FirebaseStorage.instance.ref().child(fileName);
    UploadTask uploadTask = reference.putFile(coverImage);
    TaskSnapshot storageTaskSnapshot;
    uploadTask.then((value){

      ///If Upload was successful
      storageTaskSnapshot = value;

      ///Get Url
      storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl)async{
        setState(() {
          coverImageUrl = downloadUrl;
          isLoading = false;
        });

        //await prefs.setString('profilePic', profilePic);
        Fluttertoast.showToast(msg: "Business Policy Uploaded Successfully.");
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

///Load image from phone storage
  Future getImages() async {
    var images = (
        await FilePicker.platform.pickFiles(
            allowMultiple: true,
            type: FileType.image,
            dialogTitle: "Please select business pictures."
        ))?.files;

    if(images != null && images.length != 0){
      setState(() {
        businessPictures = images;
      });
    }
  }

///Filter Sub Categories
  void filterSubCategories(String value){
    setState(() {
      //subCategory = 'Please select your business sub-category';
      subCategoriesList = [];
    });
    if(value == 'Please select your business Type for Bookings'){
      setState(() {
        subCategoriesList = [];
      });
    } else {
      subCategories.forEach((element) {
        if(element['name'] == null){

          //print(element.id);
        }

        if(element['from'] == value){
          subCategoriesList.add(element['name'] == null ?'Test' :element['name']);
        }
      });
    }


  }

///On Main Category Drop Down Select
  void mainCategorySelect(String? value){
    //Set category variable
    this.setState(() {
      category = value!;
    });

    //fetch sub categories
    filterSubCategories(value!);
  }

///Dropdown Widgets
  Widget categoryDropDown(){
    return DropdownButton<String>(
        focusNode: focusNodeDropDown,
        key: dropdownKey,
        value: category,
        items: categoriesList.map<DropdownMenuItem<String>>((String element) {
          String sub = '';
          bool showSubDropDownButton = false;
          if(subCategory == 'Please select your business sub-category'){
            showSubDropDownButton = true;
            sub = '';
          }
          else {
            //print("Here I am: $subCategory");
            showSubDropDownButton = false;
            sub = subCategory;
          }
      return DropdownMenuItem<String>(
      value: element,
        child:
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            element == 'Please select your business Type for Bookings'
            ? Container()
            : Icon(getIcon(element)),
            Text('$element \n$sub'),
           /* element == 'Please select your business Type for Bookings'
                ? Container()
                :
            subMenuCategoryDropDown(element),*/
          ],
        ),
      );
    }).toList(),
        onChanged: (String? newValue){
          mainCategorySelect(newValue);
        });
  }

  Widget subMenuCategoryDropDown(String cate){
    filterSubCategories(cate);
    List<PopupMenuEntry<dynamic>> myList = [];
    subCategoriesList.forEach((element) {
      myList.add(
          PopupMenuItem(
              child: Text(element),
          onTap: (){
            mainCategorySelect(cate);
          setState(() {
              subCategory = element;
            });

          setGroup(element);
            Navigator.pop(dropdownKey.currentContext!);
            setState(() {
              focusNodeDropDown.unfocus();
            });
          //print("I do get here with $nextPage");
          },
          )
      );
    });

    return PopupMenuButton<dynamic>(
      icon: Icon(Icons.arrow_drop_down, color: getColor("black", 1.0),),
        itemBuilder: (context) =>
        myList,
      onSelected: (value){
          setGroup(value!);

      },
    );
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
          onChanged: (value) {
            policy = value;
          },
          focusNode: focusNodePolicy,
        ),
      ),
    );
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

  void getAmenities() async{
   // print("STarted pilling");
    final QuerySnapshot result =
    await FirebaseFirestore.instance.collection('newAmenities').get();
   // print("Done pulling");
    final List<DocumentSnapshot> documents = result.docs;
  }

///Show Add Socials Dialog
  Future<bool> onSocialsAddPress() {
    openSocialsAddDialog();
    return Future.value(false);
  }

///Add Socials Dialog
  Future<Null> openSocialsAddDialog() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding:
            EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
            children: <Widget>[
              Container(
                color: Colors.blueAccent,
                margin: EdgeInsets.all(0.0),
                padding: EdgeInsets.only(bottom: 10.0, top: 10.0),
                height: 120.0,
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.info_outline_rounded,
                        size: 30.0,
                        color: Colors.white,
                      ),
                      margin: EdgeInsets.only(bottom: 10.0),
                    ),
                    Text(
                      'Add Social Media Links',
                      style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    Text(
                      'Please enter all business social media links.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: Colors.white, fontSize: 16,)),
                    ),
                  ],
                ),
              ),
              ///Form
              Form(
                child: Column(
                  children: [
                    ///Facebook
                    Container(
                      child: Theme(
                        data: Theme.of(context).copyWith(primaryColor: Colors.blueAccent, splashColor:Colors.blueAccent),
                        child: TextFormField(
                          autocorrect: false,
                          cursorColor: Colors.blueAccent,
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 17,
                              fontWeight: FontWeight.bold
                          ),
                          decoration: InputDecoration(

                            disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(5))
                            ),
                            focusColor: Colors.blueAccent,
                            fillColor: Colors.blueAccent,
                            labelStyle: TextStyle(color: Colors.blueAccent),
                            hintText: 'Facebook',
                            contentPadding: EdgeInsets.all(5.0),
                            hintStyle: TextStyle(color: Colors.grey,
                                fontSize: 17,
                                fontWeight: FontWeight.bold
                            ),

                          ),
                          controller: facebookController,

                          onChanged: (value) {
                            setState(() {
                              businessSocials.add(SocialMedia(name: "Facebook", icon: 'assets/icons/fb.svg', link: value));
                            });
                          },
                          focusNode: focusNodeFacebook,
                        ),
                      ),
                      margin: EdgeInsets.only(left: 30.0, right: 30.0),
                    ),

                    ///Instagram
                    Container(
                      child: Theme(
                        data: Theme.of(context).copyWith(primaryColor: Colors.blueAccent, splashColor:Colors.blueAccent),
                        child: TextFormField(
                          autocorrect: false,
                          cursorColor: Colors.blueAccent,
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 17,
                              fontWeight: FontWeight.bold
                          ),
                          decoration: InputDecoration(

                            disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(5))
                            ),
                            focusColor: Colors.blueAccent,
                            fillColor: Colors.blueAccent,
                            labelStyle: TextStyle(color: Colors.blueAccent),
                            hintText: 'Instagram link',
                            contentPadding: EdgeInsets.all(5.0),
                            hintStyle: TextStyle(color: Colors.grey,
                                fontSize: 17,
                                fontWeight: FontWeight.bold
                            ),

                          ),
                          controller: instagramController,

                          onChanged: (value) {
                            businessSocials.add(SocialMedia(name: "Instagram", icon: 'assets/icons/insta.svg', link: value));
                          },
                          focusNode: focusNodeInstagram,
                        ),
                      ),
                      margin: EdgeInsets.only(left: 30.0, right: 30.0),
                    ),

                    ///Twitter
                    Container(
                      child: Theme(
                        data: Theme.of(context).copyWith(primaryColor: Colors.blueAccent, splashColor:Colors.blueAccent),
                        child: TextFormField(
                          autocorrect: false,
                          cursorColor: Colors.blueAccent,
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 17,
                              fontWeight: FontWeight.bold
                          ),
                          decoration: InputDecoration(

                            disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(5))
                            ),
                            focusColor: Colors.blueAccent,
                            fillColor: Colors.blueAccent,
                            labelStyle: TextStyle(color: Colors.blueAccent),
                            hintText: 'Twitter link',
                            contentPadding: EdgeInsets.all(5.0),
                            hintStyle: TextStyle(color: Colors.grey,
                                fontSize: 17,
                                fontWeight: FontWeight.bold
                            ),

                          ),
                          controller: twitterController,

                          onChanged: (value) {
                            businessSocials.add(SocialMedia(name: "Twitter", icon: 'assets/icons/twitter.svg', link: value));
                          },
                          focusNode: focusNodeTwitter,
                        ),
                      ),
                      margin: EdgeInsets.only(left: 30.0, right: 30.0),
                    ),

                    ///TIKTOK
                    Container(
                      child: Theme(
                        data: Theme.of(context).copyWith(primaryColor: Colors.blueAccent, splashColor:Colors.blueAccent),
                        child: TextFormField(
                          autocorrect: false,
                          cursorColor: Colors.blueAccent,
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 17,
                              fontWeight: FontWeight.bold
                          ),
                          decoration: InputDecoration(

                            disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(5))
                            ),
                            focusColor: Colors.blueAccent,
                            fillColor: Colors.blueAccent,
                            labelStyle: TextStyle(color: Colors.blueAccent),
                            hintText: 'TikTok link',
                            contentPadding: EdgeInsets.all(5.0),
                            hintStyle: TextStyle(color: Colors.grey,
                                fontSize: 17,
                                fontWeight: FontWeight.bold
                            ),

                          ),
                          controller: tiktokController,

                          onChanged: (value) {
                            businessSocials.add(SocialMedia(name: "TikTok", icon: 'assets/icons/tiktok.svg', link: value));
                          },
                          focusNode: focusNodeTikTok,
                        ),
                      ),
                      margin: EdgeInsets.only(left: 30.0, right: 30.0),
                    ),

                    ///YOUTUBE
                    Container(
                      child: Theme(
                        data: Theme.of(context).copyWith(primaryColor: Colors.blueAccent, splashColor:Colors.blueAccent),
                        child: TextFormField(
                          autocorrect: false,
                          cursorColor: Colors.blueAccent,
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 17,
                              fontWeight: FontWeight.bold
                          ),
                          decoration: InputDecoration(

                            disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(5))
                            ),
                            focusColor: Colors.blueAccent,
                            fillColor: Colors.blueAccent,
                            labelStyle: TextStyle(color: Colors.blueAccent),
                            hintText: 'Youtube link',
                            contentPadding: EdgeInsets.all(5.0),
                            hintStyle: TextStyle(color: Colors.grey,
                                fontSize: 17,
                                fontWeight: FontWeight.bold
                            ),

                          ),
                          controller: youtubeController,

                          onChanged: (value) {
                            businessSocials.add(SocialMedia(name: "Youtube", icon: 'assets/icons/youtube.svg', link: value));
                          },
                          focusNode: focusNodeYoutube,
                        ),
                      ),
                      margin: EdgeInsets.only(left: 30.0, right: 30.0),
                    ),

                    ///LINKEDIN
                    Container(
                      child: Theme(
                        data: Theme.of(context).copyWith(primaryColor: Colors.blueAccent, splashColor:Colors.blueAccent),
                        child: TextFormField(
                          autocorrect: false,
                          cursorColor: Colors.blueAccent,
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 17,
                              fontWeight: FontWeight.bold
                          ),
                          decoration: InputDecoration(

                            disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(5))
                            ),
                            focusColor: Colors.blueAccent,
                            fillColor: Colors.blueAccent,
                            labelStyle: TextStyle(color: Colors.blueAccent),
                            hintText: 'LinkedIn link',
                            contentPadding: EdgeInsets.all(5.0),
                            hintStyle: TextStyle(color: Colors.grey,
                                fontSize: 17,
                                fontWeight: FontWeight.bold
                            ),

                          ),
                          controller: linkedInController,

                          onChanged: (value) {
                            businessSocials.add(SocialMedia(name: "LinkedIn", icon: 'assets/icons/linkedin.svg', link: value));
                          },
                          focusNode: focusNodeLinkedIn,
                        ),
                      ),
                      margin: EdgeInsets.only(left: 30.0, right: 30.0),
                    ),

                    ///Submit Button
                    ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:  MaterialStatePropertyAll<Color>(Colors.lightBlue),
                        ),
                        //color: colors[2],
                        onPressed: (){
                          //Navigator.push(context, MaterialPageRoute(builder: (context) => const Home()));
                          //loginFormKey.currentState!.validate()
                          Fluttertoast.showToast(msg: "Information saved.");
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.07,
                              right: MediaQuery.of(context).size.width * 0.07),
                          child: Text("Submit",
                              style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))
                          ),
                        )
                    ),
                  ],
                ),
              )
            ],
          );
        });
  }

///Show Add Business Hours Dialog
  Future<bool> onBusinessHoursAddPress() {
    openBusinessHoursAddDialog();
    return Future.value(false);
  }

///Add Business Hours Dialog
  Future<Null> openBusinessHoursAddDialog() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding:
            EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
            children: <Widget>[
              Container(
                color: Colors.blueAccent,
                margin: EdgeInsets.all(0.0),
                padding: EdgeInsets.only(bottom: 10.0, top: 10.0),
                height: 100.0,
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.timer,
                        size: 30.0,
                        color: Colors.white,
                      ),
                      margin: EdgeInsets.only(bottom: 10.0),
                    ),
                    Text(
                      'Add Business Hours',
                      style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    Text(
                      'Please enter all business hours.',
                      style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: Colors.white, fontSize: 16,)),
                    ),
                  ],
                ),
              ),
              ///Form
              Form(
                child: Column(
                  children: [

                    ///Monday
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

                    ///Submit Button
                    ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:  MaterialStatePropertyAll<Color>(Colors.lightBlue),
                        ),
                        //color: colors[2],
                        onPressed: (){
                          //Navigator.push(context, MaterialPageRoute(builder: (context) => const Home()));
                          //loginFormKey.currentState!.validate()
                          Fluttertoast.showToast(msg: "Please fill in the missing or incorrect information.");
                        },
                        child: Padding(
                          padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.07,
                              right: MediaQuery.of(context).size.width * 0.07),
                          child: Text("Submit",
                              style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))
                          ),
                        )
                    ),
                  ],
                ),
              )
            ],
          );
        });
  }



///Initial State
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dropdownKey = GlobalKey();
    getCategories('main');
    getCategories('sub');
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
        title: Text("Business\nInformation",
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
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),

            ///Upload Pic Section
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

            ///Registration Form
            Form(
                key: registerFormKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    ///Business Name
                    Padding(
                      padding: EdgeInsets.only(bottom: 14.0),
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(width: 0.4, color: Colors.grey),
                            borderRadius: BorderRadius.circular(30)
                        ),
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
                              border: InputBorder.none,
                              disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(5))
                              ),
                              focusColor: Colors.grey,
                              fillColor: Colors.grey,
                              labelStyle: TextStyle(color: Colors.grey),
                              hintText: 'Business Name',
                              contentPadding: EdgeInsets.all(15.0),
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
                    ),

                    ///Business Bio
                    Padding(
                      padding: EdgeInsets.only(bottom: 14.0),
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(width: 0.4, color: Colors.grey),
                            borderRadius: BorderRadius.circular(30)
                        ),
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
                              border: InputBorder.none,
                              disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(5))
                              ),
                              focusColor: Colors.grey,
                              fillColor: Colors.grey,
                              labelStyle: TextStyle(color: Colors.grey),
                              hintText: 'Business Bio',
                              contentPadding: EdgeInsets.all(5.0),
                              hintStyle: TextStyle(color: Colors.grey),

                            ),
                            controller: descriptionController,
                            validator: (value) {
                              if (value == null) {
                                return 'Please enter your Business Bio';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              description = value;
                            },
                            focusNode: focusNodeDescription,
                          ),
                        ),
                      ),
                    ),

                    ///Business Email Address
                    Padding(
                      padding: EdgeInsets.only(bottom: 14.0),
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(width: 0.4, color: Colors.grey),
                            borderRadius: BorderRadius.circular(30)
                        ),
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
                              border: InputBorder.none,
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
                    ),

                    ///Phone Number
                    Padding(
                      padding: EdgeInsets.only(bottom: 14.0),
                      child: Container(decoration: BoxDecoration(
                          border: Border.all(width: 0.4, color: Colors.grey),
                          borderRadius: BorderRadius.circular(30)
                      ),
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
                              border: InputBorder.none,
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
                    ),

                    ///Address
                    Padding(
                      padding: EdgeInsets.only(bottom: 14.0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(width: 0.4, color: Colors.grey),
                          borderRadius: BorderRadius.circular(30)
                      ),
                        margin: const EdgeInsets.only(left: 30.0, right: 30.0),
                        child: Theme(
                          data: Theme.of(context).copyWith(primaryColor: Colors.grey),
                          child: TextFormField(
                            style: const TextStyle(
                                color: Colors.grey
                            ),

                            readOnly: true,
                            onTap: () async {
                              final sessionToken = Uuid().v4();
                              final Suggestion? result = await showSearch(
                                context: context,
                                delegate: AddressSearch(),
                              );
                              if (result != null) {
                                final placeDetails = await PlaceApiProvider(sessionToken)
                                    .getPlaceDetailFromId(result.placeId);

                                var temp = await displayPrediction(result.placeId);
                                setState(() {
                                  coords = temp;
                                  addressController.text = result.description;
                                  address = result.description;
                                });
                              }
                              // placeholder for our places search later
                            },
                            decoration: const InputDecoration(
                              border: InputBorder.none,
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
                    ),

                    ///Website
                    Padding(
                      padding: EdgeInsets.only(bottom: 14.0),
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(width: 0.4, color: Colors.grey),
                            borderRadius: BorderRadius.circular(30)
                        ),
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
                              border: InputBorder.none,
                              disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(5))
                              ),
                              focusColor: Colors.grey,
                              fillColor: Colors.grey,
                              labelStyle: TextStyle(color: Colors.grey),
                              hintText: 'Business Website',
                              contentPadding: EdgeInsets.all(5.0),
                              hintStyle: TextStyle(color: Colors.grey),

                            ),
                            controller: websiteController,
                            onChanged: (value) {
                              website = value;
                            },
                            focusNode: focusNodeWebsite,
                          ),
                        ),
                      ),
                    ),

                    ///Category selection
                    Flexible(
                        child: categoryDropDown()),

                    SizedBox(
                      height: 10,
                    ),

                    ///Socials
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: onSocialsAddPress,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.face,
                              size: 25,
                              color:  getColor('black', 0.7),
                            ),
                            Text('Add Socials',
                              style:  GoogleFonts.getFont('Roboto',
                                  textStyle: TextStyle(
                                    color:  getColor('black', 0.7),
                                    fontSize: 14,
                                    //fontWeight: FontWeight.bold
                                  )),
                            )
                          ],
                        ),
                      ),
                    ),

                    ///Business Hours
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: onBusinessHoursAddPress,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.timer,
                              size: 25,
                              color:  getColor('black', 0.7),
                            ),
                            Text('Add Business Hours',
                              style:  GoogleFonts.getFont('Roboto',
                                  textStyle: TextStyle(
                                    color:  getColor('black', 0.7),
                                    fontSize: 14,
                                    //fontWeight: FontWeight.bold
                                  )),
                            )
                          ],
                        ),
                      ),
                    ),

                    ///Product Images
                    businessPictures.isEmpty
                        ? GestureDetector(
                      onTap: getImages,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                             Icon(
                              Icons.camera_alt,
                              size: 25,
                              color:  getColor('black', 0.7),
                            ),
                             Text('Upload Business Images',
                            style:  GoogleFonts.getFont('Roboto',
                                textStyle: TextStyle(
                                    color:  getColor('black', 0.7),
                                    fontSize: 16,
                                    //fontWeight: FontWeight.bold
                                )),
                            )
                          ],
                        ),
                      ),
                    )
                        : Wrap(
                      spacing: MediaQuery.of(context).size.width * 0.05,
                      children: businessPictures.map((picture) {
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

                    SizedBox(
                      height: 10,
                    ),

                /*    ///Business Policy Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Business Policy: ",
                        style:  GoogleFonts.getFont('Roboto',
                            textStyle: TextStyle(
                                color:getColor('black', 1.0),
                                fontSize: 16,
                                fontWeight: FontWeight.bold
                            )),
                        ),
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
                        : Container(),*/

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

                    ///Bottom Section
                    ///Continue Button
                    ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:  MaterialStatePropertyAll<Color>(getColor('green', 1.0),),
                        ),
                        //color: colors[2],
                        onPressed: (){
                          // ///Set Nav
                          // Navigator.push(context, MaterialPageRoute(builder: (context) => nextPage));
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
                ))
          ],
        ),
      ),
    );
  }
}
