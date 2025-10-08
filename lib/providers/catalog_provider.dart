import 'package:flutter/foundation.dart';

class CatalogProvider with ChangeNotifier {
  String? _selectedBrandId;
  List<String>? _selectedBodyParts;
  String? _selectedMachineType;
  String? _selectedMachineId;

  String? get selectedBrandId => _selectedBrandId;
  List<String>? get selectedBodyParts => _selectedBodyParts;
  String? get selectedMachineType => _selectedMachineType;
  String? get selectedMachineId => _selectedMachineId;

  void selectBrand(String? brandId) {
    if (_selectedBrandId == brandId) {
      if (_selectedMachineId != null) {
        _selectedMachineId = null;
        notifyListeners();
      }
      return;
    }

    _selectedBrandId = brandId;
    _selectedMachineId = null;
    notifyListeners();
  }

  void selectBodyParts(List<String>? bodyParts) {
    if (listEquals(_selectedBodyParts, bodyParts)) {
      return;
    }

    _selectedBodyParts = bodyParts == null ? null : List.from(bodyParts);
    notifyListeners();
  }

  void selectMachineType(String? machineType) {
    if (_selectedMachineType == machineType) {
      return;
    }

    _selectedMachineType = machineType;
    notifyListeners();
  }

  void selectMachine(String? machineId) {
    if (_selectedMachineId == machineId) {
      return;
    }

    _selectedMachineId = machineId;
    notifyListeners();
  }

  void reset() {
    _selectedBrandId = null;
    _selectedBodyParts = null;
    _selectedMachineType = null;
    _selectedMachineId = null;
    notifyListeners();
  }
}
