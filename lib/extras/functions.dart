///Functions used frequently on App
///
///
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Select date and Time Functions
///
///Variables
double height = 20;
double width = 10;

late String setTime, setDate;

late String hour, minute, time;

late String dateTime;

TimeOfDay selectedTime = const TimeOfDay(hour: 00, minute: 00);

late String mondayOpen, mondayClose;
TextEditingController mondayOpenController = TextEditingController();
TextEditingController mondayCloseController = TextEditingController();
FocusNode focusNodeMondayOpen = FocusNode();
FocusNode focusNodeMondayClose = FocusNode();
TimeOfDay selectedTimeMonOpen = const TimeOfDay(hour: 00, minute: 00);
TimeOfDay selectedTimeMonClose = const TimeOfDay(hour: 00, minute: 00);

late String tuesdayOpen, tuesdayClose;
TextEditingController tuesdayOpenController = TextEditingController();
TextEditingController tuesdayCloseController = TextEditingController();
TimeOfDay selectedTimeTuesOpen = const TimeOfDay(hour: 00, minute: 00);
TimeOfDay selectedTimeTuesClose = const TimeOfDay(hour: 00, minute: 00);

late String wedOpen, wedClose;
TextEditingController wedOpenController = TextEditingController();
TextEditingController wedCloseController = TextEditingController();
TimeOfDay selectedTimeWedOpen = const TimeOfDay(hour: 00, minute: 00);
TimeOfDay selectedTimeWedClose = const TimeOfDay(hour: 00, minute: 00);

late String thursOpen, thursClose;
TextEditingController thursdayOpenController = TextEditingController();
TextEditingController thursdayCloseController = TextEditingController();
TimeOfDay selectedTimeThurOpen = const TimeOfDay(hour: 00, minute: 00);
TimeOfDay selectedTimeThurClose = const TimeOfDay(hour: 00, minute: 00);

late String friOpen, friClose;
TextEditingController fridayOpenController = TextEditingController();
TextEditingController fridayCloseController = TextEditingController();
TimeOfDay selectedTimeFriOpen = const TimeOfDay(hour: 00, minute: 00);
TimeOfDay selectedTimeFriClose = const TimeOfDay(hour: 00, minute: 00);

late String satOpen, satClose;
TextEditingController saturdayOpenController = TextEditingController();
TextEditingController saturdayCloseController = TextEditingController();
TimeOfDay selectedTimeSatOpen = const TimeOfDay(hour: 00, minute: 00);
TimeOfDay selectedTimeSatClose = const TimeOfDay(hour: 00, minute: 00);

late String sundayOpen, sundayClose;
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