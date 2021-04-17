import 'package:ABLE_APP/animation/FadeAnimation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import "utils.dart"; //include re-used functions

String _thisPage = "=====>[login_page.dart]: "; //used to beautify log
TextEditingController _idController = new TextEditingController();
String _idErr = "Mã Học Viên không tồn tại";
bool _idInvalid = false;
bool _newComingMessage = false;
ScreenInfo _screenInfo = new ScreenInfo();

// ignore: must_be_immutable
class LoginPage extends StatefulWidget {
  String deviceToken;
  String savedID;

  LoginPage({
    Key key,
    this.deviceToken,
    this.savedID,
  }) : super(key: key);

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();

    //-------------------------------------------------------------------------------------------------------------------> Initialize Cloud Messaging
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
    final List<Message> messages = [];
    _firebaseMessaging.configure(

      onMessage: (Map<String, dynamic> message) async {
        print(_thisPage + "onMessage: $message");
        _newComingMessage = true;
        final notification = message['notification'];
        setState(() {
          messages.add(Message(
              title: notification['title'], body: notification['body']));
        });

        showDialog(
            context: context,
            builder: (_) => new AlertDialog(
                  title: new Text(notification['title']),
                  content: new Text(notification['body']),
                ));
      }, //end onMessage()
      

      onLaunch: (Map<String, dynamic> message) async {
        print(_thisPage + "onLaunch: $message");
        _newComingMessage = true;

        final notification = message['notification'];
        setState(() {
          messages.add(Message(
              title: 'OnLaunch: ${notification['title']}',
              body: 'OnLaunch: ${notification['body']}'));
        });


      }, //end onLaunch()

      onResume: (Map<String, dynamic> message) async {
        print(_thisPage + "onResume: $message");
        _newComingMessage = true;
        setState(() {   
        });
      }, //end onResume()
      
    );

    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));

    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print(_thisPage + "Settings registered: $settings");
    });
  } //end initState()

  @override
  Widget build(BuildContext context) {
    double ratioWidth =
        (MediaQuery.of(context).size.width * _screenInfo.offsetWidth) /
            _screenInfo.dividedRatio;
    double ratioHeight =
        (MediaQuery.of(context).size.height * _screenInfo.offsetHeight) /
            _screenInfo.dividedRatio;

    print(_thisPage +
        "ratioWidth = " + ratioWidth.toString());


    print(_thisPage +
        "CALLING build()... with widget.deviceToken = " +
        widget.deviceToken);
    print(_thisPage + "and widget.savedID = " + widget.savedID);
    _idController.text = widget.savedID;

    return Scaffold(
      resizeToAvoidBottomInset: true, // prevent keyboard hide textfield
      backgroundColor: Color(
          0xffECECDA), //0xff + https://html-color-codes.info/colors-from-image/

      //-------------------------------------------------------------------------------------------------------------------> Appbar
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xffECECDA),
        /*
        //-------------------------------------------------------------------------------------------------------------------> Filter button
        actions: <Widget>[
          IconButton(
            icon: Icon(
              (_newComingMessage == true)
                  ? Icons.notifications_active
                  : Icons.notifications,
              color: (_newComingMessage == true)
                  ? Colors.yellow[900]
                  : Colors.grey,
            ),
            onPressed: () {
              _newComingMessage = false;
              setState(() {});
            },
          )
        ],
        */
      ),
      //-------------------------------------------------------------------------------------------------------------------> Body
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: ratioWidth * 40),
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Column(
                children: <Widget>[
                  FadeAnimation(
                      1,
                      Text(
                        "Welcome to ABLE Academy",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: ratioWidth * 25, //fontSize: 25,
                            color: Color(0xff0E2F56)),
                      )),
                  SizedBox(
                    height: ratioHeight * 10, //height: 10,
                  ),
                  FadeAnimation(
                      1.2,
                      Text(
                        "We Enter to Learn, Leave to Achieve",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: ratioWidth * 15), //fontSize: 15
                      )),


                  SizedBox(
                    height: ratioHeight * 10, //height: 10,
                  ),
                ],
              ),
              FadeAnimation(
                  1.3,
                  Container(
                    height: MediaQuery.of(context).size.height / 2.0,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('assets/able_logo.png'))),
                  )),
              Column(
                children: <Widget>[
                  FadeAnimation(
                      1.4, makeInput(context: context, label: "Mã Học Viên")),

                  //-------------------------------------------------------------------------------------------------------------------> "Đăng Nhập" button
                  FadeAnimation(
                      1.5,
                      Container(
                        padding: EdgeInsets.only(top: 3, left: 3),
                        decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(ratioWidth * 50), //50
                            border: Border(
                              bottom: BorderSide(color: Colors.black),
                              top: BorderSide(color: Colors.black),
                              left: BorderSide(color: Colors.black),
                              right: BorderSide(color: Colors.black),
                            )),
                        child: MaterialButton(
                          minWidth: double.infinity,
                          height: ratioHeight * 60, //height: 60,
                          onPressed: () async {
                            _newComingMessage = false;
                            print(_thisPage +
                                "_idInvalid=" +
                                (_idInvalid == true ? "TRUE" : "FALSE") +
                                " (BEFORE)");
                            print(_thisPage + "CALLING readDatabase()...");
                            _idInvalid = await readDatabase(context,
                                _idController.text, widget.deviceToken);
                            print(_thisPage +
                                "_idInvalid=" +
                                (_idInvalid == true ? "TRUE" : "FALSE") +
                                " (AFTER)");
                            setState(() {
                              _idInvalid = _idInvalid;
                            });
                          },
                          color: Color(0xffFF304F),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(ratioWidth * 50)), //50
                          child: Text(
                            "Đăng Nhập",
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: ratioWidth * 18, //fontSize: 18,
                                color: Color(0xff0E2F56)),
                          ),
                        ),
                      )),

                  SizedBox(
                    height: ratioHeight * 20, //height: 10,
                  ),


                ],
              )
            ],
          ),
        ),
      ),
    );
  } //end build()

/*
 *------------------------------------------------------------------------------------------------
 *------------------------------------ Re-used widgets, functions --------------------------------
 *------------------------------------------------------------------------------------------------
*/
  Widget makeInput({context, label, obscureText = false}) {
    double ratioWidth =
        (MediaQuery.of(context).size.width * _screenInfo.offsetWidth) /
            _screenInfo.dividedRatio;
    double ratioHeight =
        (MediaQuery.of(context).size.height * _screenInfo.offsetHeight) /
            _screenInfo.dividedRatio;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
              fontSize: ratioWidth * 15,
              fontWeight: FontWeight.w400,
              color: Colors.black87),
        ),
        SizedBox(
          height: ratioHeight * 5,
        ),
        Stack(
          alignment: AlignmentDirectional.centerEnd,
          children: <Widget>[
            TextField(
              controller: _idController,
              inputFormatters: [
                UpperCaseTextFormatter(),
              ], //Auto format to UPPER CASE
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.fingerprint),
                errorText: _idInvalid ? _idErr : null,
                contentPadding: EdgeInsets.symmetric(
                    vertical: 0, horizontal: ratioWidth * 10),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[400])),
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[400])),
              ),
            ),
          ],
        ),
        SizedBox(
          height: ratioHeight * 30,
        ),
      ],
    );
  } //end makeInput()
} //end class LoginPageState
