import 'package:ABLE_APP/login_page.dart';
import 'package:ABLE_APP/search_page.dart';
import 'package:ABLE_APP/utils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'able_page.dart';



String _thisPage = "=====>[main.dart]: "; //used to beautify log
String _deviceToken = ""; //token of the current device
String _savedID = "";



void main() async {
  //Add this line to resolve "ERROR: ServicesBinding.defaultBinaryMessenger was accessed before the binding was initialized.
  WidgetsFlutterBinding.ensureInitialized();

  //-------------------------------------------------------------------------------------------------------------------> Waiting for UserPreferences() initialize then load it into _savedID
  _savedID = "";
  await UserPreferences().init(); //defined in "utils.dart"
  _savedID = UserPreferences().data;
  print(_thisPage + "_savedID=" + _savedID);

  //-------------------------------------------------------------------------------------------------------------------> Get token of the current user's device
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  _deviceToken = "";
  await _firebaseMessaging.getToken().then((String token) {
    assert(token != null);
    print(_thisPage + "_deviceToken=" + token);
    _deviceToken = token;
  });

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MainPage(),
  ));
} //end main()

/*
 *------------------------------------------------------------------------------------------------
 *------------------------------------------------------------------------------------------------
 *--------------------------------------- Main Class --------------------------------------------
 *------------------------------------------------------------------------------------------------
 *------------------------------------------------------------------------------------------------
*/

class MainPage extends StatefulWidget {
  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
/*
 *------------------------------------------------------------------------------------------------
 *------------------------------------  Bottom bar configuations --------------------------------
 *------------------------------------------------------------------------------------------------
*/
  int _selectedIndexBottomBar = 0;

  List<Widget> _childrenPage() => [
        LoginPage(
          deviceToken: _deviceToken,
          savedID: _savedID,
        ),
        SearchPage(
          deviceToken: _deviceToken,
        ),
        AbleApp(),
      ];

  void _onItemTapped(int index) {
    setState(() {
      print(_thisPage + "index=" + index.toString());
      _selectedIndexBottomBar = index;
    });
  }


  @override
  Widget build(BuildContext context) {
    final List<Widget> children = _childrenPage();
    return Scaffold(
      //-------------------------------------------------------------------------------------------------------------------> BottomBar
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xffECECDA),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.face),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Able',
          ),
        ],
        currentIndex: _selectedIndexBottomBar,
        unselectedItemColor: Color(0xff0E2F56),
        selectedItemColor: Color(0xffFF304F),
        onTap: _onItemTapped,
      ),

      //-------------------------------------------------------------------------------------------------------------------> Body
      body: children[_selectedIndexBottomBar],
    );
  } //end build()

} //end class MainPage
