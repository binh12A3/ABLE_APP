/*
 *------------------------------------------------------------------------------------------------
 *---------------------------- This dart file contains re-used functions -------------------------
 *------------------------------------------------------------------------------------------------
*/

import 'dart:math';

import 'package:ABLE_APP/student_page.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';


String _thisPage = "=====>[utils.dart]: "; //used to beautify log


double roundDouble(double value, int places){ 
   double mod = pow(10.0, places); 
   return ((value * mod).round().toDouble() / mod); 
}


/* PURPOSE : used to flexible size of widget */
/*
    //Finding offset by putting below code in build() which referenced to "fontSize: 25" and "height: 10"
    double offsetWidth = 100 / MediaQuery.of(context).size.width;
    offsetWidth = roundDouble(offsetWidth, 4);
    double offsetHeight = 100 / MediaQuery.of(context).size.height;
    offsetHeight = roundDouble(offsetHeight, 4);
    print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" + _thisPage + "offsetWidth=" + offsetWidth.toString() + " ,offsetHeight=" + offsetHeight.toString());
    //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@=====>[login_page.dart]: offsetWidth=0.2546 ,offsetHeight=0.1248

--> //fontSize: 15
--> MediaQuery.of(context).size.width * offset * (15/25)), 
*/
class ScreenInfo {
  double offsetWidth = 0.2546;
  double offsetHeight = 0.1248;
  double dividedRatio = 100;
}


/* PURPOSE : used in search_page.dart */
class Student {
  String id;
  String name;
  String dob;
  String allInfo;

  Student(this.id, this.name, this.dob, this.allInfo);
}

/* PURPOSE : used in main.dart */
@immutable
class Message {
  final String title;
  final String body;

  const Message({
    @required this.title,
    @required this.body,  
  });
}




/* PURPOSE : update characters to UPPER CASE automatically */
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text?.toUpperCase(),
      selection: newValue.selection,
    );
  }
} //end class UpperCaseTextFormatter



/* PURPOSE : store/save the successful login id in the internal phone storage and use/load it for the next time using */
class UserPreferences {
  static final UserPreferences _instance = UserPreferences._ctor();
  factory UserPreferences() {
    return _instance;
  }

  UserPreferences._ctor();

  SharedPreferences _prefs;

  init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  get data {
    return _prefs.getString('data') ?? '';
  }

  set data(String value) {
    _prefs.setString('data', value);
  }

  Future setJwtToken(String value) {
    return _prefs.setString('jwtToken', value);
  }
} //end class UserPreferences



Future<bool> readDatabase( BuildContext context, String id, String deviceToken) async {
  print(_thisPage + 'CALLING readDatabase()... with id = ' + id);
  bool idInvalid = false;

  ProgressDialog pr = ProgressDialog(context);
  pr.style(
    message: 'Đang đăng nhập...',
  );

  await pr.show();

  //check database
  await FirebaseDatabase.instance
      .reference()
      .child('students/' + id)
      .once()
      .then((DataSnapshot snapshot) {
    print('Data : ${snapshot.value}');

    //check id syntax
    if (id.length < 10 || snapshot.value == null) {
      idInvalid = true;
    } else {
      idInvalid = false;
    }

    print(_thisPage + "idInvalid=" + (idInvalid == true ? "TRUE" : "FALSE"));

    //id exist --> Move to StudentPage
    if (!idInvalid) {
      print(_thisPage + 'Found student');

      String _id = id;
      String _name = snapshot.value['name'].toString();
      String _dob = snapshot.value['dob'].toString();
      String _studentclass = snapshot.value['_class'].toString();
      String _mScores = snapshot.value['mScore'].toString();
      String _eScores = snapshot.value['eScore'].toString();
      String _note = snapshot.value['note'].toString();
      String _token = snapshot.value['token'].toString();
      String _lastUpdateDT = snapshot.value['dtUpdate'].toString();
      bool _isRegister = false;

      print(_thisPage + 'deviceToken     = ' + deviceToken);
      print(_thisPage + '_id             = ' + _id);
      print(_thisPage + '_name           = ' + _name);
      print(_thisPage + '_dob            = ' + _dob);
      print(_thisPage + '_studentclass   = ' + _studentclass);
      print(_thisPage + '_mScores        = ' + _mScores);
      print(_thisPage + '_eScores        = ' + _eScores);
      print(_thisPage + '_note           = ' + _note);
      print(_thisPage + '_token          = ' + _token);
      print(_thisPage + '_lastUpdateDT   = ' + _lastUpdateDT);

      //Register this devide token to student id
      if (_token == null || _token == 'null') {
        print(_thisPage + '_token is NULL --> _isRegister = FALSE');
        _isRegister = false;
      } else {
        print(_thisPage + '_token is NOT NULL, check if exist deviceID');

        List<dynamic> strTokenArr = snapshot.value['token'].toList();
        print(_thisPage + 'strTokenArr=' + strTokenArr.toString());
        print(_thisPage + 'deviceToken=' + deviceToken);

        if (strTokenArr.contains(deviceToken)) {
          print(_thisPage + 'Contains deviceToken --> _isRegister = TRUE');
          _isRegister = true;
        }
      }

      print(_thisPage + '_isRegister     = ' + (_isRegister == true ? "TRUE" : "FALSE"));

      if (pr.isShowing()) {
        print(_thisPage + '(1) pr is Showing()');
        pr.hide();
      } else {
        print(_thisPage + '(1) pr is NOT Showing()');
      }

      //save current id for next login
      UserPreferences().data = id;

      print(_thisPage + 'MaterialPageRoute to StudentPage');
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => StudentPage(
                    isRegister: _isRegister,
                    deviceToken: deviceToken,
                    id: _id,
                    name: _name,
                    dob: _dob,
                    studentclass: _studentclass,
                    mScores: _mScores,
                    eScores: _eScores,
                    notification: _note,
                    lastUpdateDT: _lastUpdateDT,
                  )));
    }
  });

  if (pr.isShowing()) {
    print(_thisPage + '(2) pr is Showing() ');
    pr.hide();
  } else {
    print(_thisPage + '(2) pr is NOT Showing()');
  }

  return idInvalid;
}//end readDatabase()