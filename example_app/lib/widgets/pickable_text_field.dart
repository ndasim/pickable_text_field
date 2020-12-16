library pickabletextfield;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

enum PickerInputMethod{
  keyboard,
  cupertinoPicker,
  dropdownButton, // Not supported yet
}

class CupertinoPickerOptions{
  /// https://api.flutter.dev/flutter/cupertino/CupertinoPicker/diameterRatio.html
  final double diameterRatio;

  /// https://api.flutter.dev/flutter/cupertino/CupertinoPicker/itemExtent.html
  final double itemExtent;

  const CupertinoPickerOptions({
    this.diameterRatio = 3,
    this.itemExtent = 40
  });
}


class PickableTextField extends StatefulWidget {
  /// Input controller of TextField
  ///
  /// Can not be null
  final TextEditingController controller;

  /// Input decoration for TextField
  ///
  /// Can be null
  final InputDecoration decoration;

  /// Which type of input we have
  ///
  /// Default is [PickerInputMethod.keyboard]
  final PickerInputMethod pickerMethod;

  /// If [pickerMethod] is
  /// [PickerInputMethod.cupertinoPicker] or [PickerInputMethod.dropdownButton]
  /// the list for selectable items will populated from this list
  ///
  /// Default is empty list
  final List<dynamic> items;

  /// The Widget builder for [items]
  /// return can be null if item is not exists
  final Widget Function(BuildContext context, dynamic item) itemBuilder;

  /// Since widget itself can not produce String representation of selected item,
  /// this callback must be defined if [pickerMethod] is
  /// [PickerInputMethod.cupertinoPicker] or [PickerInputMethod.dropdownButton]
  ///
  /// Null return is accepted
  final String Function(dynamic item) itemToString;

  /// If [pickerMethod] is [PickerInputMethod.cupertinoPicker] this variable is required
  /// Defines CupertinoPicker values
  final CupertinoPickerOptions cupertinoPickerOptions;

  /// To be able to dispatch picker screen without launching keyboard, we need to
  /// disable TextField, since disabled color is different than active color
  /// this field will allow developer to set single border for each scenario
  ///
  /// If null, widget will manage borders itself
  final InputBorder border;

  const PickableTextField({
    Key key,
    this.controller,
    this.decoration,
    this.pickerMethod = PickerInputMethod.keyboard,
    this.items,
    this.itemBuilder,
    this.itemToString,
    this.cupertinoPickerOptions, this.border
  }) :  assert(pickerMethod == PickerInputMethod.keyboard || pickerMethod != PickerInputMethod.keyboard && items != null),
        assert(pickerMethod == PickerInputMethod.keyboard || pickerMethod != PickerInputMethod.keyboard && itemBuilder != null),
        assert(pickerMethod == PickerInputMethod.keyboard || pickerMethod != PickerInputMethod.keyboard && itemToString != null),
        assert(pickerMethod == PickerInputMethod.keyboard || pickerMethod != PickerInputMethod.dropdownButton), // dropdownButton not supported yet
        super(key: key);

  @override
  _PickableTextFieldState createState() => _PickableTextFieldState();
}

class _PickableTextFieldState extends State<PickableTextField> {
  InputDecoration _decoration;
  @override
  void initState() {
    _decoration = buildInputDecoration();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant PickableTextField oldWidget) {
    /// Do not lose decoration if we got rebuild
    _decoration = buildInputDecoration();
    super.didUpdateWidget(oldWidget);
  }

  /// Dispatches modal bottom sheet to place CupertinoPicker and build itemList

  void dispatchCupertinoPicker() async{
    await showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          // Start with selected item if exists
          int initialItemIndex = 0;
          if(widget.controller.text.isNotEmpty){
            initialItemIndex = widget.items.indexWhere((element) => widget.itemToString(element) == widget.controller.text) + 1;
          }

          return Container(
            height: 200,
            child: Padding(
              padding: EdgeInsets.only(top: 20),
              child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(initialItem: initialItemIndex),
                  itemExtent:  widget.cupertinoPickerOptions.itemExtent,
                  diameterRatio: widget.cupertinoPickerOptions.diameterRatio,
                  looping: true,
                  onSelectedItemChanged: (int value) {
                    widget.controller.text = value != 0 ? widget.itemToString(widget.items[value - 1]) : "";
                  },
                  children: [Container()] + widget.items.map((e){
                    return Container(child: widget.itemBuilder(context, e),);
                  }).toList()
              ),
            ),
          );
        }
    );

    FocusScope.of(context).requestFocus(new FocusNode());
  }

  /// To handle enabled-disabled color issue of EditText apply some controls
  /// over the widget and produce same border for both enabled and disabled
  /// TextField states
  InputDecoration buildInputDecoration(){
    if(widget.border == null){
      if(widget.decoration?.enabledBorder ?? false){
        return widget.decoration.copyWith(disabledBorder: widget.decoration.enabledBorder);
      }
      else{
        InputBorder defaultBorder = UnderlineInputBorder(borderSide: BorderSide(color: Colors.black26));
        return widget.decoration.copyWith(enabledBorder: defaultBorder, disabledBorder: defaultBorder);
      }
    }
    else{
      return widget.decoration.copyWith(enabledBorder: widget.border, disabledBorder: widget.border);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child = TextField(
      autofocus: false,
      controller: widget.controller,
      decoration: _decoration,
      enabled: widget.pickerMethod == PickerInputMethod.keyboard,
    );

    if(widget.pickerMethod == PickerInputMethod.cupertinoPicker){
      child = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: dispatchCupertinoPicker,
        child: child,
      );
    }

    return Theme(
        data: Theme.of(context).copyWith(disabledColor: Theme.of(context).hintColor),
        child: child
    );
  }
}