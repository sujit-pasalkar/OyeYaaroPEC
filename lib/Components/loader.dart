import 'package:flutter/material.dart';

class Loader extends StatelessWidget {
 final bool loading;
 Loader({@optionalTypeArgs this.loading});
 @override
 Widget build(BuildContext context) {
   return loading != null && loading
       ? Container(
           color: Colors.black.withOpacity(0.5),
           child: Center(
             child: CircularProgressIndicator(),
           ),
         )
       : SizedBox();
 }
}