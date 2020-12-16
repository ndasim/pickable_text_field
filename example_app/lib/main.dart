import 'package:exampleapp/widgets/pickable_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'data/turkey_cities.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context){
    return Scaffold(
        body: SafeArea(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Center(
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text("Benim Formum", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
                  PickableTextField(
                    controller: TextEditingController(),
                    decoration: InputDecoration(
                      labelText: "Adınız",
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Container(height: 10,),
                  PickableTextField(
                    controller: TextEditingController(),
                    pickerMethod: PickerInputMethod.cupertinoPicker,
                    cupertinoPickerOptions: CupertinoPickerOptions(),
                    items: CITY_LIST,
                    itemToString: (i) => i.title,
                    itemBuilder: (c, i){
                      return Container(
                          height: 15,
                          child: Center(
                            child: Text(
                                i.title,
                                style: TextStyle(fontSize: 15, color: Theme.of(context).accentColor)
                            ),
                          )
                      );
                    },
                    decoration: InputDecoration(
                      labelText: "Yaşadığınız Şehir",
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Container(height: 10,),
                  PickableTextField(
                    controller: TextEditingController(),
                    decoration: InputDecoration(
                      labelText: "Hobileriniz",
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
    );
  }
}
