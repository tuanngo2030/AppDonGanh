import 'package:flutter/material.dart';

class ReponsiveScreen extends StatelessWidget {
  final Widget Mobile;
  final Widget Tablet;
  final Widget Desktop;

  ReponsiveScreen({
    required this.Mobile, 
    required this.Tablet, 
    required this.Desktop
  });

  @override
  Widget build(BuildContext context) {
    return  LayoutBuilder(builder: (context, constraints) {
      if(constraints.maxWidth < 500){
        return Mobile;
      }else if(constraints.maxWidth < 1100){
        return Tablet;
      }else{
        return Desktop;
      }
    },);
  }
}