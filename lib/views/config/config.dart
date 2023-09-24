import 'package:docu_diary/views/config/add_class_view.dart';
import 'package:docu_diary/views/config/add_control_view.dart';
import 'package:docu_diary/views/config/add_topic_view.dart';
import 'package:docu_diary/views/config/config_done_view.dart';
import 'package:docu_diary/views/config/config_start_view.dart';
import 'package:docu_diary/views/config/sort_topic_view.dart';
import 'package:flutter/material.dart';

 class ConfigView extends StatefulWidget {
  final int? initialPage;
  ConfigView({Key? key, this.initialPage = 0}) : super(key: key);
  
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }
  
  
  // _ConfigViewState createState() => _ConfigViewState(initialPage);
}

class _ConfigViewState extends State<ConfigView> {
  // _ConfigViewState(int? initialPage,PageController _controller ,initialPagee);

  late int initialPagee;
  // _ConfigViewState(this.initialPage);
 late PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: initialPagee);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  moveToPage(int pageIndex) {
    _controller.animateToPage(
      pageIndex,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _controller,
      children: [
        ConfigStartView(moveToPage),
        AddClassWidget(moveToPage),
        AddTopicWidget(moveToPage),
        SortTopicWidget(moveToPage),
        AddControlWidget(moveToPage),
        ConfigDoneView(moveToPage),
      ],
    );
  }
}
