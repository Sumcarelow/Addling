import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

///All data variables used in Application globally stored here

///Shared Preferences instance
late SharedPreferences prefs;

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

///Payment Methods
List<String> payments = [
  "Cash Only", "Medical Aid", "Digital Payment", "All"
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