import 'package:flutter/material.dart';

class SidebarProvider extends ChangeNotifier {
  bool _isCollapsed = false;

  bool get isCollapsed => _isCollapsed;

  void toggleSidebar() {
    _isCollapsed = !_isCollapsed;
    notifyListeners();
  }

  void setSidebarCollapsed(bool collapsed) {
    _isCollapsed = collapsed;
    notifyListeners();
  }
}
