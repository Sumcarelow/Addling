import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

///All data variables used in Application globally stored here

///Shared Preferences instance
late SharedPreferences prefs;

///User ID
String globalUserID = '';


///Transmission types
List<String> transmissions = [
  "Manual", "Auto"
];

///Bed Sizes
List<String> bedSizes = [
  "Single", "3/4", "Double", "Queen", "King"
];

///Restaurants
List<String> rests = [
  "Fine Dining", "Casual Dining", "Fast Food",
  "Food Truck/Cart/Stand", "Cafe", "Buffet",
  "Pub"
];

///Yes/No Dropdwon
List<String> optionsYN = [
  "Yes", "No"
];

///Specialities
List<String> specialities = [
  "Domestic", "Industrial", "Both"
];

///Rates
List<String> rates = [
  "/hour", "/service"
];
List<String> priceFreqs = [
  "/hour", "/night"
];

///Payment Methods
List<String> payments = [
  "Cash", "Slasch Pay", "Online Payment"
];

///Policy Types
List<String> policyTypes = [
  'Url Link',
  'PDF Doc',
  'Text'
];

///Business Community Categories
List<String> businessCategories = [
  'RESTAURANTS',
  'FOOD TRUCKS',
  'COFFEE SHOPS',
  'BAKED FOODS',
  'HOMEMADE FOODS',
  'PIZZA JOINTS',
  'FAST FOOD JOINTS',
  'ICE CREAM SHOPS',
  'BOOKSTORE',
  'TECH & ELECTRONICS',
  'FASHION & ACCESSORY',
  'FOOTWEAR',
  'TOYS & GAMES',
  'STATIONERY',
  'JEWELERY ACCESSORY'
];

///Load Prices
List<String> loadPrices(){
  List<String> temp = [];
  for(int i = 1; i <= 50000; i++){

    temp.add(i.toString());

  }
  return temp;
}
String yocoHtml = '''
<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1">
<script src="https://js.yoco.com/sdk/v1/yoco-sdk-web.js"></script>
<style>
.yc-field-group--placeholder{

font-size: 16px;
display: inline-block;

}

.submitButton{
background-color: #FEA223; /* Green */
border: none;
color: white;
padding: 15px 32px;
text-align: center;
text-decoration: none;
display: inline-block;
font-size: 16px;
}
body {
    margin: 0;
    height: 100%;
    width: 100%;
}

</style>
</head>

<body>
<h1>Payment Confirmation</h1>
<p>Please fill in the following details to complete your purchase.</p>
<form id="payment-form" method="POST">
<div class="one-liner">
<div id="card-frame">
<!-- Yoco Inline form will be added here -->
</div>
<button id="pay-button" class="submitButton">
PAY ZAR 100
</button>
</div>
<p class="success-payment-message" />
</form>
</body>
<footer>

<script>
// Run our code when your form is submitted
var form = document.getElementById('payment-form');
var submitButton = document.getElementById('pay-button');
form.addEventListener('submit', function (event) {
event.preventDefault()
// Disable the button to prevent multiple clicks while processing
submitButton.disabled = true;
// This is the inline object we created earlier with the sdk
inline.createToken().then(function (result) {
// Re-enable button now that request is complete
// (i.e. on success, on error and when auth is cancelled)
submitButton.disabled = false;
if (result.error) {
const errorMessage = result.error.message;
window.Toaster.postMessage('Failed: ' + errorMessage);
//errorMessage && alert("error occured: " + errorMessage);
} else {
const token = result;
window.Toaster.postMessage(token.id);
//window.close();
//alert("card successfully tokenised: " + token.id);
}

}).catch(function (error) {
// Re-enable button now that request is complete
window.Toaster.postMessage('Failed with error: ' + error);
submitButton.disabled = false;
//alert("error occurred: " + error);
});
});
// Any additional form data you want to submit to your backend should be done here, or in another event listener
</script>
<script>
// Replace the supplied `publicKey` with your own.
// Ensure that in production you use a production public_key.
var sdk = new window.YocoSDK({
publicKey: "pk_test_ed3c54a6gOol69qa7f45"
});

// Create a new form instance
var inline = sdk.inline({
layout: 'Plain',
amountInCents: 100,
currency: 'ZAR'
});
// this ID matches the id of the element we created earlier.
inline.mount('#card-frame');
</script>
</footer>
</html>
''';
///Prices List
List<String> prices = [
  '1','2','3','4','5','6','7','8','9','10',
  '11','12','13','14','15','16','17','18','19','20',
  '21','22','23','24','25','26','27','28','29','30',
  '31','32','33','34','35','36','37','38','39','40',
  '41','42','43','44','45','46','47','48','49','50',
  '51','52','53','54','55','56','57','58','59','60',
  '61','62','63','64','65','66','67','68','69','70',
  '71','72','73','74','75','76','77','78','79','80',
  '81','82','83','84','85','86','87','88','89','90',
  '91','92','93','94','95','96','97','98','99','100',
  '101', '102', '103', '104', '105', '106', '107', '108','109', '110',
  '111', '112', '113', '114', '115', '116', '117', '118', '119', '120',
  '121', '122', '123', '124', '125', '126', '127', '128', '129', '130',
  '131', '132', '133', '134', '135', '136', '137', '138', '139', '140',
  '141', '142', '143', '144', '145', '146', '147', '148', '149', '150'
];

List<String> socials = [
  'LinkedIn', 'Youtube', 'Facebook', 'Instagram', 'Twitter', 'TikTok'
];

///location class
class MyLocation {
  final String name, charge, address;
  MyLocation({ required this.name, required this.address, required this.charge});
}

///Bed Class
class Bed {
  final String size, quantity;
  Bed ({required this.size, required this.quantity});
}

///Price Class
class Price {
  final String amount, frequency;
  Price ({required this.amount, required this.frequency});
}

///Menu Item
class MenuItem {
  final String name, description, price;
  MenuItem ({required this.name, required this.price, required this.description});
}

///Category Class
class Category {
  final String name;
  final IconData iconData;
  Category({
    required this.name,
    required this.iconData
});
}

///Business Hours
class businessDay {
  final String day, openTime, closeTime;
  businessDay({required this.day, required this.openTime, required this.closeTime});
}

///Social Media Link
class SocialMedia {
  final String name, link, icon;
  SocialMedia({required this.name, required this.icon, required this.link});

  Map toJson()=>{
    'name': name,
    'link': link,
    'icon': icon
};

}

///Bait Plant
class BaitPlant {
  final DocumentSnapshot doc;
  final List<DocumentSnapshot> pics, likes, followers;
  final bool like, follow;

  BaitPlant({required this.doc, required this.pics,
    required this.likes, required this.followers,
    required this.follow, required this.like,
    //required this.removed
  });

}


///Business Class
class BusinessClass {
  final DocumentSnapshot doc;
  List<DocumentSnapshot> followers;

  BusinessClass({required this.doc, required this.followers});
}

