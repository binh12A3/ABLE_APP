import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import "utils.dart"; //include re-used functions
import 'package:diacritic/diacritic.dart';

String _thisPage = "=====>[search_page.dart]: "; //used to beautify log
TextEditingController _searchController = new TextEditingController();
bool _isActiveSelected = false;
List<Student> _studentList = <Student>[];
ScreenInfo _screenInfo = new ScreenInfo();


class SearchPage extends StatefulWidget {
  final String deviceToken;

  SearchPage({
    Key key,
    this.deviceToken,
  }) : super(key: key);

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    double ratioWidth = (MediaQuery.of(context).size.width * _screenInfo.offsetWidth ) / _screenInfo.dividedRatio;
    double ratioHeight= (MediaQuery.of(context).size.height * _screenInfo.offsetHeight ) / _screenInfo.dividedRatio;

    //-----------------------------------------------------------------FutureBuilder will wait until an Future-async function getStudentList() return value then call "builder" to rebuild
    print(_thisPage + "CALLING build()... with widget.deviceToken = " + widget.deviceToken);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Color(0xffECECDA),
          //-------------------------------------------------------------------------------------------------------------------> Appbar
          appBar: AppBar(
            elevation: 0,
            brightness: Brightness.light,
            backgroundColor: Color(0xffECECDA),
            centerTitle: true,
            title: Text(
              "Danh Sách Học Sinh",
              style: TextStyle(
                  fontSize: ratioWidth * 25,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff0E2F56)),
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(
                  _isActiveSelected
                      ? Icons.notifications_active
                      : Icons.notifications,
                  color: _isActiveSelected ? Colors.yellow[900] : Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _isActiveSelected = !_isActiveSelected;
                  });
                },
              )
            ],
          ),

          //-------------------------------------------------------------------------------------------------------------------> Body
          body: Container(
              padding: EdgeInsets.all(20.0),
              child: Column(
                children: <Widget>[
                  Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (text) {
                          setState(() {
                            buildBody(context);
                          });
                        },
                        decoration: InputDecoration(
                            labelText: "Tìm Kiếm",
                            hintText: "Nhập Tên Học Sinh",
                            prefixIcon: Icon(Icons.person_search, color: Color(0xffFF304F),),
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(ratioWidth * 25)))),
                      )),
                  Text(
                    "🌎 🌍 🌏",
                    style: TextStyle(
                      fontSize: ratioWidth * 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  //-------------------------------------------------------------------------------------------------------------------> Main Body
                  Flexible(
                    child: buildBody(context),
                  ),
                ],
              ))),
    );
  } //end build()







/*
 *------------------------------------------------------------------------------------------------
 *------------------------------------ Re-used widgets, functions --------------------------------
 *------------------------------------------------------------------------------------------------
*/
  Widget buildBody(BuildContext context) {
    double ratioWidth = (MediaQuery.of(context).size.width * _screenInfo.offsetWidth ) / _screenInfo.dividedRatio;
    double ratioHeight= (MediaQuery.of(context).size.height * _screenInfo.offsetHeight ) / _screenInfo.dividedRatio;
    
    print(_thisPage + "CALLING buildBody()...");
    print(_thisPage + "widget.deviceID=" + widget.deviceToken);

    final dbRef = FirebaseDatabase.instance.reference();

    return StreamBuilder(
      //--------------------------------------------------------------------------------> OPEN A STREAM
      //--------------------------------------------------------------------------------> LISTEN CHANGES (SNAPSHOTS) ON REALTIME_DATABASE
      stream: dbRef.child("students").onValue,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error ${snapshot.error}');
        }
        if (snapshot.hasData) {
          print(_thisPage +
              "---------DETECTING NEW CHANGES(SNAPSHOTS) ON REALTIME_DATABASE---------");
          print(_thisPage +
              "snapshot.value=" +
              snapshot.data.snapshot.value.toString());
          return FutureBuilder(
              future: getStudentList(),
              builder: (context, snapshot) {
                if (snapshot.hasData ||
                    snapshot.connectionState == ConnectionState.done) {
                  if (_studentList.length == 0) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: Text("Không tìm thấy"),
                    );
                  } else {
                    return ListView.builder(
                        itemCount: _studentList.length,
                        itemBuilder: (BuildContext ctxt, int index) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: ratioHeight * 8),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.lightBlue),
                                borderRadius: BorderRadius.circular((ratioWidth * 20)),
                                color: Colors.teal[100],//màu card
                              ),
                              child: ListTile(
                                  leading: Icon(Icons.fingerprint),
                                  title:
                                      Text(_studentList[index].id.toString()),
                                  subtitle: Text(_studentList[index].name +
                                      '\n' +
                                      _studentList[index].dob),
                                  onTap: () async {
                                    print(_thisPage + 'student.id        =' + _studentList[index].id);
                                    print(_thisPage + 'widget.deviceToken=' + widget.deviceToken);
                                    print(_thisPage + "CALLING readDatabase()...");
                                    bool tmp = await readDatabase(
                                        context,
                                        _studentList[index].id,
                                        widget.deviceToken);
                                  },
                                  trailing: IconButton(
                                    icon: (_studentList[index]
                                            .allInfo
                                            .contains(widget.deviceToken))
                                        ? Icon(
                                            Icons.notifications_active,
                                            color: Colors.yellow[900],
                                          )
                                        : Icon(Icons.add_alert), onPressed: () {  },
                                  ),
                                ),
                              
                            ),
                          );
                        });
                  }
                } else if (snapshot.hasError) {
                  return Text('Delivery error: ${snapshot.error.toString()}');
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              });
        }
        return CircularProgressIndicator();
      },
    );
  } //end buildBody()

  getStudentList() async {
    print(_thisPage + "CALLING getStudentList()...");
    await FirebaseDatabase.instance
        .reference()
        .child("students")
        .once()
        .then((DataSnapshot snapshot) {
      print(_thisPage + 'Returned data : ${snapshot.value}');
      Map<dynamic, dynamic> values = snapshot.value;

      //clear the list everytime this func is call i.e : user searches data
      _studentList.clear();
      print(_thisPage + "_studentList.length=" + _studentList.length.toString());

      //input info
      print(_thisPage + "deviceToken               =" + widget.deviceToken);
      print(_thisPage + "_searchController.text    =" + _searchController.text);
      print(_thisPage + "Removed accented letters  =" + removeDiacritics(_searchController.text));

      //loop all returned data
      print( _thisPage + "Loop all returned data to extract values...");   
      values.forEach((k, v) {
        print(_thisPage + "-------------------------------------------");
        print(_thisPage + "Student id                =" + k);
        print(_thisPage + "Student info              =" + v.toString());
        print(_thisPage + "Student info -> name      =" + v["name"]);
        print(_thisPage + "Student info -> dob       =" + v["dob"]);
        print(_thisPage + "Removed accented letters  =" + removeDiacritics(v["name"]));
        print(_thisPage + "-------------------------------------------");
        
        //Cover accented letters by removeDiacritics(), and cover UPPER. lower case by toUpperCase()
        if (removeDiacritics(v["name"]).toUpperCase().contains(removeDiacritics(_searchController.text).toUpperCase()) || _searchController.text == "") {
          print(_thisPage + 'Found Data');

          if (_isActiveSelected == false) {
            print(_thisPage + '_isActiveSelected = FALSE, Adding data...');
            Student _student = new Student(k, v["name"], v["dob"], v.toString());
            _studentList.add(_student);
          } else {
            if (v.toString().contains(widget.deviceToken)) {
              print(_thisPage + '_isActiveSelected = TRUE, Adding data...');
              Student _student = new Student(k, v["name"], v["dob"], v.toString());
              _studentList.add(_student);
            }
          }
        }

        print(_thisPage + "Final _studentList.length=" + _studentList.length.toString());
      });
    });
  } //end getStudentList()
} //end class SearchPageState
