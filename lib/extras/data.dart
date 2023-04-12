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
List<String> priceFreqs = [
  "/hour", "/night"
];

///Payment Methods
List<String> payments = [
  "Cash", "Medical Aid", "Digital Payment"
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
  'COFFEE SHOPS',
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

///Prices List
List<String> prices = [];

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

