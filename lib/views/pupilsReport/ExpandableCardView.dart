import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Color getTopicColor(String topicColor) {
  if (topicColor != null && topicColor != '')
    return Color(int.parse('$topicColor'));
  return Colors.black;
}

class ExpandableCardView extends StatelessWidget {
  final String? title;
  final int? reportNumber;
  final String? sid;
  final List? topicList;
  final int? counter;

  const ExpandableCardView({
    Key? key,
    this.title,
    this.topicList,
    this.reportNumber,
    this.sid,
    this.counter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        return new ExpandableListView(
          title: topicList![index].name,
          topicList: topicList!,
          counter: index,
        );
      },
      itemCount: topicList!.length,
    );
  }
}

class ExpandableListView extends StatefulWidget {
  final String? title;
  final int? reportNumber;
  final String? sid;
  final List? topicList;
  final int? counter;

  const ExpandableListView({
    Key? key,
    this.title,
    this.topicList,
    this.reportNumber,
    this.sid,
    this.counter,
  }) : super(key: key);

  @override
  _ExpandableListViewState createState() => new _ExpandableListViewState();
}

String iconRate = 'assets/images/pain.png';
Widget _getRating(rate) {
  switch (rate) {
    case 1:
      return Image.asset('assets/images/pain.png', width: 31, height: 31);
      break;
    case 2:
      return Image.asset('assets/images/sad.png', width: 31, height: 31);
      break;

    case 3:
      return Image.asset('assets/images/happy.png', width: 31, height: 31);
      break;
    case 4:
      return Image.asset('assets/images/amazing.png', width: 31, height: 31);
      break;
    default:
      return Container(width: 31, height: 31);
      break;
  }
}

class _ExpandableListViewState extends State<ExpandableListView> {
  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new Column(
        children: <Widget>[
          new Container(
            margin: EdgeInsets.only(top: 15),
            padding: new EdgeInsets.symmetric(horizontal: 15.0),
            child: Theme(
              data: Theme.of(context).copyWith(
                  // accentColor: Colors.black,
                  dividerColor: Colors.transparent,
                  unselectedWidgetColor: Colors.black.withOpacity(0.8)),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.grey[200]!,
                    ),
                    bottom: BorderSide(
                      color: Colors.transparent,
                    ),
                  ),
                ),
                child: ExpansionTile(
                  initiallyExpanded: true,
                  title: Text(
                    widget.title! +
                        ' ( ' +
                        widget.topicList![widget.counter!].observation
                            .toString() +
                        ' )',
                    style: new TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 20.0,
                      color: getTopicColor(
                          widget.topicList![widget.counter!].topicColor),
                    ),
                  ),
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      width: MediaQuery.of(context).size.width * 0.50,
                      child: ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount:
                              widget.topicList![widget.counter!].controls.length,
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                                child: Theme(
                              data: Theme.of(context).copyWith(
                                  dividerColor: Colors.transparent,
                                  unselectedWidgetColor:
                                      Colors.black.withOpacity(0.8)),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      color: Colors.grey[200]!,
                                    ),
                                    bottom: BorderSide(
                                      color: Colors.transparent,
                                    ),
                                  ),
                                ),
                                child: ExpansionTile(
                                    initiallyExpanded: false,
                                    title: Text(
                                      widget.topicList![widget.counter!]
                                          .controls[index].name,
                                      style: new TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 18.0,
                                        color: getTopicColor(widget
                                            .topicList![widget.counter!]
                                            .topicColor),
                                      ),
                                    ),
                                    children: <Widget>[
                                      ListView.builder(
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: widget
                                              .topicList![widget.counter!]
                                              .controls[index]
                                              .observations
                                              .length,
                                          shrinkWrap: true,
                                          itemBuilder:
                                              (BuildContext context, int i) {
                                            return Container(
                                                child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 30.0, bottom: 30.0),
                                              child:
                                                  widget
                                                              .topicList![widget
                                                                  .counter!]
                                                              .controls[index]
                                                              .observations[i]
                                                              .type ==
                                                          'SPONTANEOUS'
                                                      ? new Container(
                                                          child: new ListTile(
                                                            title: Row(
                                                              children: [
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      right:
                                                                          15.0),
                                                                  child: _getRating(widget
                                                                      .topicList![
                                                                          widget
                                                                              .counter!]
                                                                      .controls[
                                                                          index]
                                                                      .observations[
                                                                          i]
                                                                      .rating),
                                                                ),
                                                                Flexible(
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        bottom:
                                                                            10.0),
                                                                    child:
                                                                        new Text(
                                                                      widget
                                                                          .topicList![widget
                                                                              .counter!]
                                                                          .controls[
                                                                              index]
                                                                          .observations[
                                                                              i]
                                                                          .title,
                                                                      style: new TextStyle(
                                                                          color: Colors
                                                                              .black,
                                                                          fontSize:
                                                                              15.0,
                                                                          fontWeight:
                                                                              FontWeight.w400),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            subtitle: widget
                                                                        .topicList![widget
                                                                            .counter!]
                                                                        .controls[
                                                                            index]
                                                                        .observations[
                                                                            i]
                                                                        .dateOfUpdate ==
                                                                    null
                                                                ? Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .bottomRight,
                                                                    child:
                                                                        new Text(
                                                                      widget
                                                                          .topicList![widget
                                                                              .counter!]
                                                                          .controls[
                                                                              index]
                                                                          .observations[
                                                                              i]
                                                                          .date,
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              17.0,
                                                                          color: Colors.grey[
                                                                              500],
                                                                          fontWeight:
                                                                              FontWeight.w500),
                                                                    ),
                                                                  )
                                                                : Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .bottomRight,
                                                                    child:
                                                                        new Text(
                                                                      widget
                                                                          .topicList![widget
                                                                              .counter!]
                                                                          .controls[
                                                                              index]
                                                                          .observations[
                                                                              i]
                                                                          .dateOfUpdate,
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              17.0,
                                                                          color: Colors.grey[
                                                                              500],
                                                                          fontWeight:
                                                                              FontWeight.w500),
                                                                    ),
                                                                  ),
                                                          ),
                                                        )
                                                      : Container(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 15.0),
                                                          child: Row(
                                                            children: [
                                                              widget
                                                                          .topicList![widget
                                                                              .counter!]
                                                                          .controls[
                                                                              index]
                                                                          .observations[
                                                                              i]
                                                                          .rating ==
                                                                      1
                                                                  ? _getRating(widget
                                                                      .topicList![
                                                                          widget
                                                                              .counter!]
                                                                      .controls[
                                                                          index]
                                                                      .observations[
                                                                          i]
                                                                      .rating)
                                                                  : Image.asset(
                                                                      'assets/images/-e-pain.png',
                                                                      width: 31,
                                                                      height:
                                                                          31),
                                                              SizedBox(
                                                                width: 5,
                                                              ),
                                                              widget
                                                                          .topicList![widget
                                                                              .counter!]
                                                                          .controls[
                                                                              index]
                                                                          .observations[
                                                                              i]
                                                                          .rating ==
                                                                      2
                                                                  ? _getRating(widget
                                                                      .topicList![
                                                                          widget
                                                                              .counter!]
                                                                      .controls[
                                                                          index]
                                                                      .observations[
                                                                          i]
                                                                      .rating)
                                                                  : Image.asset(
                                                                      'assets/images/-e-sad.png',
                                                                      width: 31,
                                                                      height:
                                                                          31),
                                                              SizedBox(
                                                                width: 5,
                                                              ),
                                                              widget
                                                                          .topicList![widget
                                                                              .counter!]
                                                                          .controls[
                                                                              index]
                                                                          .observations[
                                                                              i]
                                                                          .rating ==
                                                                      3
                                                                  ? _getRating(widget
                                                                      .topicList![
                                                                          widget
                                                                              .counter!]
                                                                      .controls[
                                                                          index]
                                                                      .observations[
                                                                          i]
                                                                      .rating)
                                                                  : Image.asset(
                                                                      'assets/images/-e-happy.png',
                                                                      width: 31,
                                                                      height:
                                                                          31),
                                                              SizedBox(
                                                                width: 5,
                                                              ),
                                                              widget
                                                                          .topicList![widget
                                                                              .counter!]
                                                                          .controls[
                                                                              index]
                                                                          .observations[
                                                                              i]
                                                                          .rating ==
                                                                      4
                                                                  ? _getRating(widget
                                                                      .topicList![
                                                                          widget
                                                                              .counter!]
                                                                      .controls[
                                                                          index]
                                                                      .observations[
                                                                          i]
                                                                      .rating)
                                                                  : Image.asset(
                                                                      'assets/images/-e-amazing.png',
                                                                      width: 31,
                                                                      height:
                                                                          31),
                                                              SizedBox(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.05,
                                                              ),
                                                              Expanded(
                                                                child: Column(
                                                                  children: [
                                                                    Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .centerLeft,
                                                                      child:
                                                                          Text(
                                                                        widget
                                                                            .topicList![widget.counter!]
                                                                            .controls[index]
                                                                            .observations[i]
                                                                            .title,
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                17.0,
                                                                            color:
                                                                                Color(0xFF333951),
                                                                            fontWeight: FontWeight.bold),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      height: MediaQuery.of(context)
                                                                              .size
                                                                              .height *
                                                                          0.01,
                                                                    ),
                                                                    Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .centerLeft,
                                                                      child:
                                                                          Text(
                                                                        widget
                                                                            .topicList![widget.counter!]
                                                                            .controls[index]
                                                                            .observations[i]
                                                                            .date,
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                17.0,
                                                                            color:
                                                                                Colors.grey[500],
                                                                            fontWeight: FontWeight.w500),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      height: MediaQuery.of(context)
                                                                              .size
                                                                              .height *
                                                                          0.005,
                                                                    ),
                                                                    Row(
                                                                      children: [
                                                                        Flexible(
                                                                          child:
                                                                              Text(
                                                                            widget.topicList![widget.counter!].controls[index].observations[i].topicName +
                                                                                ' - ' +
                                                                                widget.topicList![widget.counter!].controls[index].observations[i].controlName,
                                                                            style: TextStyle(
                                                                                fontSize: 17.0,
                                                                                color: getTopicColor(widget.topicList![widget.counter!].topicColor),
                                                                                fontWeight: FontWeight.bold),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          )),
                                            ));
                                          }),
                                    ]),
                              ),
                            ));
                          }),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ExpandableContainer extends StatelessWidget {
  final bool expanded;
  final double collapsedHeight;
  final double expandedHeight;
  final Widget? child;

  ExpandableContainer({
    @required this.child,
    this.collapsedHeight = 0.0,
    this.expandedHeight = 300.0,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return new AnimatedContainer(
      duration: new Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      width: screenWidth,
      height: expanded ? expandedHeight : collapsedHeight,
      child: new Container(
        child: child,
        decoration: new BoxDecoration(
            border: new Border.all(width: 0.6, color: Colors.grey[200]!)),
      ),
    );
  }
}
