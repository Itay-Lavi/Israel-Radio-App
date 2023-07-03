import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ViewType {
  grid,
  list,
}

class UiProvider with ChangeNotifier {
  ViewType _viewType = ViewType.list;

  ViewType get viewType => _viewType;

  void initViewType() async {
    final prefs = await SharedPreferences.getInstance();
    final int vtype = prefs.getInt('viewType') ?? 1;
    if (vtype == 0) {
      _viewType = ViewType.grid;
    } else {
      _viewType = ViewType.list;
    }
  }

  void switchViewType() async {
    _viewType = viewType == ViewType.list ? ViewType.grid : ViewType.list;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('viewType', viewType.index);
  }

  void showErrorToast([String text = 'שגיאת אינטרנט']) {
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.SNACKBAR,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}
