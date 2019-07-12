import 'package:oye_yaaro_pec/Theme/flexAppBar.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class Filters extends StatefulWidget {
  final List<Map<String, String>> media;

  Filters({Key key, @required this.media}) : super(key: key);

  @override
  _FiltersState createState() => _FiltersState();
}

class _FiltersState extends State<Filters> {
  DateTime initialDate = DateTime.now();
  DateTime startDate;
  DateTime endDate;

  List<Map<String, String>> filteredMedia = [];
  List<String> allNames = [];
  List<String> searchedNames = [];
  List filterNames = [];
  final TextEditingController _textEditingController =
      new TextEditingController();

  @override
  void initState() {
    print('${widget.media}');

    widget.media.forEach((f) {
      print('name:${f['senderName']}');
      allNames.add(f['senderName']);
    });

    searchedNames = allNames = allNames.toSet().toList();

    super.initState();
  }

  Future<Null> _selectStartDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != startDate)
      setState(() {
        startDate = picked;
      });
  }

  Future<Null> _selectEndDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != endDate)
      setState(() {
        endDate = picked;
      });
  }

  applyFilter() {
    bool dates = false;

    if (startDate != null && endDate != null) {
      widget.media.forEach((f) {
        var temp =
            DateTime.fromMillisecondsSinceEpoch(int.parse(f['timestamp']))
                .toUtc();
        var f1 = DateTime.utc(temp.year, temp.month, temp.day);
        print('f1:$f1');
        if ((f1.isBefore(endDate) && f1.isAfter(startDate)) ||
            (startDate.difference(f1).inDays == 0 ||
                endDate.difference(f1).inDays == 0)) {
          print('yes');
          print(
              'f:${DateTime.fromMillisecondsSinceEpoch(int.parse(f['timestamp'])).toUtc()}');
          filteredMedia.add(f);
        }
      });
      if (filteredMedia.length == 0) {
        dates = true;
      }
    }

    if (filterNames.length != 0 && filteredMedia.length != 0) {
      List<Map<String, String>> filter = [];
      filteredMedia.forEach((f) {
        if (filterNames.contains(f['senderName'])) {
          filter.add(f);
          print('name removed');
        }
      });
      filteredMedia = filter;
    } else if (filterNames.length != 0 && filteredMedia.length == 0) {
      widget.media.forEach((f) {
        if (filterNames.contains(f['senderName'])) {
          filteredMedia.add(f);
          print('name added');
        }
      });
    }

    print('then');
    if (dates) {
      Fluttertoast.showToast(
          msg:
              'No images from ${DateFormat('dd MMM').format(startDate)} to ${DateFormat('dd MMM').format(endDate)}');
    }
    Navigator.pop(context, filteredMedia);
  }

  // Future<bool> onBackPress() async{
  //   print('ooo');
  //   return Future.value(false);
  // }

  @override
  Widget build(BuildContext context) {
    return 
    // WillPopScope(
    //     child:
         Scaffold(
      appBar: AppBar(
        title: Text('Apply Filters'),
        actions: <Widget>[
          (startDate != null && endDate != null) || filterNames.length != 0
              ? FlatButton(
                  child: Text(
                    'Apply',
                    style: TextStyle(fontSize: 18.0, color: Colors.white),
                  ),
                  onPressed: () {
                    applyFilter();
                  },
                )
              : SizedBox()
        ],
        flexibleSpace: FlexAppbar(),
      ),
      body: Column(
          children: <Widget>[
            Card(
              elevation: 15,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                          border:
                              Border(bottom: BorderSide(color: Colors.blue))),
                      child: FlatButton.icon(
                        onPressed: () {
                          _selectStartDate(context);
                        },
                        label: Text(
                          startDate == null
                              ? 'Start Date'
                              : DateFormat('dd MMM')
                                  .format(startDate)
                                  .toString(),
                          style: TextStyle(
                            color: Color(0xffb578de3),
                          ),
                        ),
                        icon: Icon(
                          Icons.calendar_today,
                          color: Color(0xffb4fcce0),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          border:
                              Border(bottom: BorderSide(color: Colors.blue))),
                      child: FlatButton.icon(
                        onPressed: () {
                          _selectEndDate(context);
                        },
                        label: Text(
                          endDate == null
                              ? 'End Date'
                              : DateFormat('dd MMM').format(endDate).toString(),
                          style: TextStyle(
                            color: Color(0xffb578de3),
                          ),
                        ),
                        icon: Icon(
                          Icons.calendar_today,
                          color: Color(0xffb4fcce0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: TextField(
                          style: new TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.normal),
                          decoration: InputDecoration(
                            hintText: 'filter by name..',
                          ),
                          controller: _textEditingController,
                          autofocus: false,
                          onChanged: (String searchText) {
                            searchName(searchText);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: searchedNames.length,
                  itemBuilder: (BuildContext context, int i) {
                    return ListTile(
                      selected: true,
                      dense: true,
                      onTap: () {
                        // filterByName(names[i]);
                        if (filterNames.contains(searchedNames[i])) {
                          filterNames.remove(searchedNames[i]);
                        } else {
                          filterNames.add(searchedNames[i]);
                        }
                        setState(() {});
                      },
                      title: Text(
                        searchedNames[i],
                        style: TextStyle(fontSize: 20),
                      ),
                      trailing: filterNames.contains(searchedNames[i])
                          ? Icon(Icons.check_circle)
                          : SizedBox(),
                    );
                  }),
            ),
          ],
        ),
      // ),
      // onWillPop: onBackPress,
    );
  }

  void searchName(String searchText) {
    print('in searchContactsFunc');
    // List n = names;
    setState(() {
      searchedNames = [];
    });

    for (int i = 0; i < allNames.length; i++) {
      if (allNames[i].toLowerCase().contains(searchText.toLowerCase())) {
        searchedNames.add(allNames[i]);
      }
    }
    setState(() {});
  }
}
