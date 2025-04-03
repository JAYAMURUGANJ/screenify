import 'package:window_manager/window_manager.dart';

import 'window_service.dart';

class MyWindowListener extends WindowListener {
  @override
  void onWindowClose() {
    // Show taskbar before closing
    WindowService().showTaskbar();
    windowManager.destroy();
  }
}
