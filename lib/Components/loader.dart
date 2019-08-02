import 'package:flutter/material.dart';

class Loader extends StatelessWidget {
  final bool loading;
  final String loadingMessage;
  Loader(
      {@optionalTypeArgs this.loading, @optionalTypeArgs this.loadingMessage});
  @override
  Widget build(BuildContext context) {
    return loading != null && loading
        ? Container(
            color: Colors.black.withOpacity(0.5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: CircularProgressIndicator(),
                ),
                loadingMessage != null
                    ? Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          loadingMessage,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      )
                    : SizedBox()
              ],
            ),
          )
        : SizedBox();
  }
}
