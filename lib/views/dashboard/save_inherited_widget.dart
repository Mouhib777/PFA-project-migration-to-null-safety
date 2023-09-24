

import 'package:flutter/cupertino.dart';

class SaveInheritedWidget extends InheritedWidget {
  final bool isSaved;

  SaveInheritedWidget({@required bool? isSaved, @required Widget? child})
      : this.isSaved = isSaved!,
        super(child: child!);

  @override
  bool updateShouldNotify(SaveInheritedWidget oldWidget) {
    return this.isSaved != oldWidget.isSaved;
  }
}
