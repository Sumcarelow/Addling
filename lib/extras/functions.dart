///Functions used frequently on App
///
///
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:math';

/// Select date and Time Functions
///
///Variables
double height = 20;
double width = 10;

late String setTime, setDate;

late String hour, minute, time;

late String dateTime;

TimeOfDay selectedTime = const TimeOfDay(hour: 00, minute: 00);

String mondayOpen = '', mondayClose = '';
TextEditingController mondayOpenController = TextEditingController();
TextEditingController mondayCloseController = TextEditingController();
FocusNode focusNodeMondayOpen = FocusNode();
FocusNode focusNodeMondayClose = FocusNode();
TimeOfDay selectedTimeMonOpen = const TimeOfDay(hour: 00, minute: 00);
TimeOfDay selectedTimeMonClose = const TimeOfDay(hour: 00, minute: 00);

 String tuesdayOpen = '', tuesdayClose = '';
TextEditingController tuesdayOpenController = TextEditingController();
TextEditingController tuesdayCloseController = TextEditingController();
TimeOfDay selectedTimeTuesOpen = const TimeOfDay(hour: 00, minute: 00);
TimeOfDay selectedTimeTuesClose = const TimeOfDay(hour: 00, minute: 00);

 String wedOpen = '', wedClose = '';
TextEditingController wedOpenController = TextEditingController();
TextEditingController wedCloseController = TextEditingController();
TimeOfDay selectedTimeWedOpen = const TimeOfDay(hour: 00, minute: 00);
TimeOfDay selectedTimeWedClose = const TimeOfDay(hour: 00, minute: 00);

 String thursOpen = '', thursClose = '';
TextEditingController thursdayOpenController = TextEditingController();
TextEditingController thursdayCloseController = TextEditingController();
TimeOfDay selectedTimeThurOpen = const TimeOfDay(hour: 00, minute: 00);
TimeOfDay selectedTimeThurClose = const TimeOfDay(hour: 00, minute: 00);

 String friOpen = '', friClose = '';
TextEditingController fridayOpenController = TextEditingController();
TextEditingController fridayCloseController = TextEditingController();
TimeOfDay selectedTimeFriOpen = const TimeOfDay(hour: 00, minute: 00);
TimeOfDay selectedTimeFriClose = const TimeOfDay(hour: 00, minute: 00);


 String satOpen = '', satClose = '';
TextEditingController saturdayOpenController = TextEditingController();
TextEditingController saturdayCloseController = TextEditingController();
TimeOfDay selectedTimeSatOpen = const TimeOfDay(hour: 00, minute: 00);
TimeOfDay selectedTimeSatClose = const TimeOfDay(hour: 00, minute: 00);


 String sundayOpen = '', sundayClose = '';
TextEditingController sundayOpenController = TextEditingController();
TextEditingController sundayCloseController = TextEditingController();
TimeOfDay selectedTimeSunOpen = const TimeOfDay(hour: 00, minute: 00);
TimeOfDay selectedTimeSunClose = const TimeOfDay(hour: 00, minute: 00);


DateTime selectedDate = DateTime.now();

TextEditingController dateController = TextEditingController();
TextEditingController timeController = TextEditingController();

///Select Date
Future<Null> selectDate(BuildContext context) async {
  final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      initialDatePickerMode: DatePickerMode.day,
      firstDate: DateTime(2015),
      lastDate: DateTime(2101));
  if (picked != null) {
    selectedDate = picked;
    dateController.text = DateFormat.yMd().format(selectedDate);
  }
}

///Select time variable
TimeOfDay chooseVariable(String day, String kind){
  TimeOfDay theSelectedTime = const TimeOfDay(hour: 00, minute: 00);
  switch(day){
    case 'Monday':
      {
        kind == 'open'
            ? theSelectedTime = selectedTimeMonOpen
            : theSelectedTime = selectedTimeMonClose;
      }
      break;
    case 'Tuesday':
      {
        kind == 'open'
            ? theSelectedTime = selectedTimeTuesOpen
            : theSelectedTime = selectedTimeTuesClose;
      }
      break;
    case 'Wednesday':
      {
        kind == 'open'
            ? theSelectedTime = selectedTimeWedOpen
            : theSelectedTime = selectedTimeWedClose;
      }
      break;
    case 'Thursday':
      {
        kind == 'open'
            ? theSelectedTime = selectedTimeThurOpen
            : theSelectedTime = selectedTimeThurClose;
      }
      break;
    case 'Friday':
      {
        kind == 'open'
            ? theSelectedTime = selectedTimeFriOpen
            : theSelectedTime = selectedTimeFriClose;
      }
      break;
    case 'Saturday':
      {
        kind == 'open'
            ? theSelectedTime = selectedTimeSatOpen
            : theSelectedTime = selectedTimeSatClose;
      }
      break;
    case 'Sunday':
      {
        kind == 'open'
            ? theSelectedTime = selectedTimeSunOpen
            : theSelectedTime = selectedTimeSunClose;
      }
      break;
    default:
      {

      }

  }
  return theSelectedTime;
}

///Select Time
Future<String> selectTime(BuildContext context, String day, String kind, TextEditingController Tcontrol) async {
  TimeOfDay mySelectedTime = const TimeOfDay(hour: 00, minute: 00);

  ///Chose Time variable

  ///Time Selector
  final TimeOfDay? picked = await showTimePicker(
    context: context,
    initialTime: chooseVariable(day, kind),
  );
  if (picked != null) {
    mySelectedTime = picked;
    hour = mySelectedTime.hour.toString();
    minute = mySelectedTime.minute.toString();
    time = hour + ' : ' + minute;
    Tcontrol.text = time;
    Tcontrol.text = formatDate(
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day, mySelectedTime.hour, mySelectedTime.minute),
        [hh, ':', nn, " ", am]).toString();
  }
  return Tcontrol.text;

}

///Distance between two coordinates
double calculateDistance(lat1, lon1, lat2, lon2){
  var p = 0.017453292519943295;
  var a = 0.5 - cos((lat2 - lat1) * p)/2 +
      cos(lat1 * p) * cos(lat2 * p) *
          (1 - cos((lon2 - lon1) * p))/2;
  return 12742 * asin(sqrt(a));
}

///Calculate number of coins for wallet amount
double coinsCalculator(double amount){
  double total;
  ///Conversion
  total = (amount * 50)/600;
  return total;
}

///Calculate wallet cost from coins
double walletCalculator(double amount){
  double total;
  ///Conversion
  total = (amount )/0.05;
  return total;
}


class CardMonthInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var newText = newValue.text;
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }
    var buffer = StringBuffer();
    for (int i = 0; i < newText.length; i++) {
      buffer.write(newText[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 2 == 0 && nonZeroIndex != newText.length) {
        buffer.write('/');
      }
    }
    var string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: TextSelection.collapsed(offset: string.length));
  }
}


class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write('  '); // Add double spaces.
      }
    }
    var string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: TextSelection.collapsed(offset: string.length));
  }
}

///Find Number of Days between two dates
int daysBetween(DateTime from, DateTime to) {
  from = DateTime(from.year, from.month, from.day);
  to = DateTime(to.year, to.month, to.day);
  return (to.difference(from).inHours / 24).round();
}


