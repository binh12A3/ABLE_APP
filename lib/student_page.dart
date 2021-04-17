import 'package:ABLE_APP/utils.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:ABLE_APP/animation/FadeAnimation.dart';

String _thisPage = "=====>[student_page.dart]: "; //used to beautify log
ScreenInfo _screenInfo = new ScreenInfo();


// ignore: must_be_immutable
class StudentPage extends StatefulWidget {
  bool isRegister;
  final String deviceToken;
  final String id;
  final String name;
  final String dob;
  final String studentclass;
  final String mScores;
  final String eScores;
  final String notification;
  final String lastUpdateDT;

  StudentPage(
      {Key key,
      this.isRegister,
      this.deviceToken,
      this.id,
      this.name,
      this.dob,
      this.studentclass,
      this.mScores,
      this.eScores,
      this.notification,
      this.lastUpdateDT})
      : super(key: key);

  @override
  StudentPageState createState() => StudentPageState();
}

class StudentPageState extends State<StudentPage> {
  @override
  Widget build(BuildContext context) {
    double ratioWidth = (MediaQuery.of(context).size.width * _screenInfo.offsetWidth ) / _screenInfo.dividedRatio;
    double ratioHeight= (MediaQuery.of(context).size.height * _screenInfo.offsetHeight ) / _screenInfo.dividedRatio;


    print(_thisPage + "CALLING build()... with widget.deviceToken = " + widget.deviceToken);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,

      //-------------------------------------------------------------------------------------------------------------------> Appbar
      appBar: AppBar(
        elevation: 0,
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        //-------------------------------------------------------------------------------------------------------------------> Back button
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: Color(0xff0E2F56),
          ),
        ),
        //-------------------------------------------------------------------------------------------------------------------> Notification button
        actions: <Widget>[
          IconButton(
            icon: Icon(
              (widget.isRegister == true)
                  ? Icons.notifications_active
                  : Icons.add_alert,
              color: (widget.isRegister == true)
                  ? Colors.yellow[900]
                  : Colors.grey,
            ),
            onPressed: () {
              print(_thisPage + 'widget.deviceToken =' + widget.deviceToken);
              print(_thisPage + 'widget.id          =' + widget.id);

              //check if this student id has any registered token
              FirebaseDatabase.instance
                  .reference()
                  .child('students/' + widget.id)
                  .once()
                  .then((DataSnapshot snapshot) {
                String token = snapshot.value['token'].toString();
                print(_thisPage + 'token           =' + token);

                //Register this devide token to student id
                if (token == null || token == 'null') {
                  print(_thisPage + 'token is NULL --> Register new');
                  final dbRef = FirebaseDatabase.instance.reference();
                  dbRef.child("students/" + widget.id).update({
                    "token": [null, widget.deviceToken]
                  });

                  showDialog(
                      context: context,
                      builder: (_) =>  new AlertDialog(
                        title: new Text("ABLE"),
                        content: new Text("Đăng Kí Thành Công"),
                      ));

                  setState(() {
                    widget.isRegister = true;
                  });
                } else {
                  print(_thisPage + 'token is NOT NULL');

                  //Add toList() to resolve ERROR: Unhandled Exception: Unsupported operation: Cannot add to a fixed-length list
                  List<dynamic> strTokenArr = snapshot.value['token'].toList();

                  if (strTokenArr.contains(widget.deviceToken)) {
                    print(_thisPage + 'This device id was already registered to this student');
                    showDialog(
                        context: context,
                        builder: (_) =>  new AlertDialog(
                          title: new Text("ABLE"),
                          content: new Text("Đã Đăng Kí"),
                          actions: <Widget>[
                            TextButton(
                              child: Text('Hủy Đăng Kí'),
                              onPressed: () {
                                Navigator.of(context, rootNavigator: true).pop();

                                strTokenArr.remove(widget.deviceToken);
                                final dbRef = FirebaseDatabase.instance.reference();
                                dbRef.child("students/" + widget.id).update({"token": strTokenArr});

                                showDialog(
                                    context: context,
                                    builder: (_) =>  new AlertDialog(
                                      title: new Text("ABLE"),
                                      content: new Text("Hủy Đăng Kí Thành Công"),
                                    ));

                                setState(() {
                                  widget.isRegister = false;
                                });
                              },
                            )
                          ],
                        ));
                  } else {
                    print(_thisPage + 'strTokenArr doesnt contain this device id --> Add it to token list');
                    strTokenArr.add(widget.deviceToken);
                    final dbRef = FirebaseDatabase.instance.reference();
                    dbRef.child("students/" + widget.id).update({"token": strTokenArr});

                    showDialog(
                        context: context,
                        builder: (_) => new AlertDialog(
                          title: new Text("ABLE"),
                          content: new Text("Đăng Kí Thành Công"),
                        ));

                    setState(() {
                      widget.isRegister = true;
                    });
                  }
                }
              });
            },
          )
        ],
      ),

      //-------------------------------------------------------------------------------------------------------------------> Body
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      FadeAnimation(
                          1,
                          Wrap(
                            children: [
                              Text(
                                "Hello ",
                                style: TextStyle(
                                    fontSize: ratioWidth * 30, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                widget.name + " 😃 ",
                                style: TextStyle(
                                    fontSize: ratioWidth * 30,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.tealAccent[400]),
                              ),
                            ],
                          )),

                      //dummy space
                      SizedBox(
                        height: ratioHeight * 20,
                      ),

                      FadeAnimation(
                          1.2,
                          Text(
                            "~ Have a nice day ~",
                            style: TextStyle(
                                fontSize: ratioWidth * 15, color: Colors.grey[700]),
                          )),

                      FadeAnimation(
                          1.3,
                          makeInput(context,
                              Icon(
                                Icons.fingerprint,
                                color: Colors.teal,
                              ),
                              'Mã học viên : ' + widget.id,
                              Colors.white)),

                      FadeAnimation(
                          1.4,
                          makeInput(context,
                              Icon(
                                Icons.face,
                                color: Colors.teal,
                              ),
                              'Tên học viên : ' + widget.name,
                              Colors.white)),

                      FadeAnimation(
                          1.5,
                          makeInput(context,
                              Icon(
                                Icons.cake,
                                color: Colors.teal,
                              ),
                              'Ngày sinh : ' + widget.dob,
                              Colors.white)),

                      FadeAnimation(
                          1.6,
                          makeInput(context,
                              Icon(
                                Icons.local_library,
                                color: Colors.teal,
                              ),
                              'Lớp học : ' + widget.studentclass,
                              Colors.white)),
                      FadeAnimation(
                          1.7,
                          makeInput(context,
                              Icon(
                                Icons.school,
                                color: Colors.teal,
                              ),
                              'Điểm giữa kì : ' + widget.mScores,
                              Colors.white)),
                      FadeAnimation(
                          1.8,
                          makeInput(context,
                              Icon(
                                Icons.school,
                                color: Colors.teal,
                              ),
                              'Điểm cuối kì : ' + widget.eScores,
                              Colors.white)),
                      FadeAnimation(
                          1.9,
                          makeInput(context,
                              Icon(
                                Icons.notifications_active,
                                color: Colors.teal,
                              ),
                              'Ghi chú : ' + widget.notification,
                              Colors.cyan[50])),
                      FadeAnimation(
                          1.10,
                          makeInput(context,
                              Icon(
                                Icons.date_range,
                                color: Colors.teal,
                              ),
                              'Ngày cập nhật : ' + widget.lastUpdateDT,
                              Colors.white)),

                      //---------------------------------------------------------------> Image background

                      FadeAnimation(
                        2.0,
                        Container(
                          margin: new EdgeInsets.symmetric(vertical: ratioHeight * 20),
                          height: MediaQuery.of(context).size.height / 4,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage('assets/background.png'),
                                  fit: BoxFit.fill)),
                        ),
                      ),
                    ],
                  ),
                  //--End
                ],
              ),

              //--End
            ],
          ),
        ),
      ),
    );
  }//end build()



/*
 *------------------------------------------------------------------------------------------------
 *------------------------------------ Re-used widgets, functions --------------------------------
 *------------------------------------------------------------------------------------------------
*/
  Widget makeInput(BuildContext context, Icon iconinput, String textData, Color colorinput) {
    double ratioWidth = (MediaQuery.of(context).size.width * _screenInfo.offsetWidth ) / _screenInfo.dividedRatio;
    double ratioHeight= (MediaQuery.of(context).size.height * _screenInfo.offsetHeight ) / _screenInfo.dividedRatio;

    return Card(
      color: colorinput,
      margin: EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
      child: ListTile(
          leading: iconinput,
          title: Text(
            textData,
            style: TextStyle(
              fontSize: ratioWidth * 17,
              fontFamily: 'Source Sans Pro',
              color: Colors.teal.shade900,
            ),
          )),
    );
  }//end makeInput()

} //end class StudentPageState
