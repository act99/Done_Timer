import 'package:flutter/cupertino.dart';

class FontSizeProvider with ChangeNotifier {
  double _fontSize;
  get fontSize => _fontSize;
  FontSizeProvider(this._fontSize);

  void size1() {
    _fontSize = 0.096;
    notifyListeners();
  }

  void size2() {
    _fontSize = 0.128;
    notifyListeners();
  }

  void size3() {
    _fontSize = 0.164;
    notifyListeners();
  }

  void size4() {
    _fontSize = 0.2;
    notifyListeners();
  }

  void size5() {
    _fontSize = 0.23;
    notifyListeners();
  }
}
