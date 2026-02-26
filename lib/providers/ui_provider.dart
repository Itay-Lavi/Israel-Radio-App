import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
import 'package:radio_timer_app/services/preference_service.dart';

enum ViewType {
  grid,
  list,
}

String viewTypeString = 'viewType';

class UiProvider with ChangeNotifier {
  ViewType _viewType = ViewType.list;

  ViewType get viewType => _viewType;

  void initViewType() async {
    final int vtype =
        await PreferencesService.getIntPreference(viewTypeString) ?? 1;
    if (vtype == 0) {
      _viewType = ViewType.grid;
    } else {
      _viewType = ViewType.list;
    }
  }

  void switchViewType() async {
    _viewType = viewType == ViewType.list ? ViewType.grid : ViewType.list;
    notifyListeners();

    await PreferencesService.setIntPreference(viewTypeString, viewType.index);
  }

  void showErrorToast([String text = 'שגיאת אינטרנט']) {
    // Fluttertoast.showToast(
    //     msg: text,
    //     toastLength: Toast.LENGTH_SHORT,
    //     gravity: ToastGravity.SNACKBAR,
    //     timeInSecForIosWeb: 3,
    //     backgroundColor: Colors.red,
    //     textColor: Colors.white,
    //     fontSize: 16.0);
  }
}
