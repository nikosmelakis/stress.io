import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EventProvider extends ChangeNotifier {
  PickedFile? _newFile;

  PickedFile? get newFile => _newFile;
  void setImageFile(PickedFile? file) {
    _newFile = file;
    notifyListeners();
  }
}
