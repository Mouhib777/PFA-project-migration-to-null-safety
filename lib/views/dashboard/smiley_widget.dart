import 'package:docu_diary/blocs/dashboard/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final _smileys = <String>['pain', 'sad', 'happy', 'amazing'];

class SmileyWidget extends StatefulWidget {
  final String classId;
  final String observationId;
  final String studentId;
  final int rating;
  final bool isShowAllSmileys;

  const SmileyWidget(
      {Key key,
      @required this.classId,
      @required this.observationId,
      @required this.studentId,
      @required this.rating,
      @required this.isShowAllSmileys})
      : super(key: key);

  @override
  SmileyWidgetState createState() => SmileyWidgetState(
      classId: this.classId,
      observationId: this.observationId,
      studentId: this.studentId,
      rating: this.rating,
      isShowAllSmileys: this.isShowAllSmileys);
}

class SmileyWidgetState extends State<SmileyWidget> {
  String classId;
  String observationId;
  String studentId;
  int rating;
  bool isShowAllSmileys;
  SmileyWidgetState(
      {this.classId,
      this.observationId,
      this.studentId,
      this.rating,
      this.isShowAllSmileys});

  @override
  didUpdateWidget(SmileyWidget oldWidget) {
    setState(() {
      classId = widget.classId;
      observationId = widget.observationId;
      studentId = widget.studentId;
      rating = widget.rating;
      isShowAllSmileys = widget.isShowAllSmileys;
    });
  }

  @override
  Widget build(BuildContext context) {
    int iconIdx = rating > 0 ? rating - 1 : 0;

    if (isShowAllSmileys && iconIdx < 0) {
      return Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4.0),
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            width: 40,
            height: 40,
          )
        ],
      );
    }

    if (isShowAllSmileys) {
      return Smiley(
          classId: classId,
          observationId: observationId,
          studentId: studentId,
          rating: rating);
    }

    return Container(
      padding: const EdgeInsets.all(4.0),
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Image.asset(
        "assets/images/${_smileys[iconIdx] + (rating != iconIdx + 1 ? "_desabled" : "")}.png",
        width: 36,
        height: 36,
        fit: BoxFit.contain,
      ),
    );
  }
}

class Smiley extends StatefulWidget {
  final String classId;
  final String observationId;
  final String studentId;
  final int rating;

  Smiley(
      {Key key,
      @required this.classId,
      @required this.observationId,
      @required this.studentId,
      @required this.rating})
      : super(key: key);

  @override
  _SmileyState createState() => _SmileyState(
      this.classId, this.observationId, this.studentId, this.rating);
}

class _SmileyState extends State<Smiley> {
  String classId;
  String observationId;
  String studentId;
  int rating;
  _SmileyState(this.classId, this.observationId, this.studentId, this.rating);

  @override
  didUpdateWidget(Smiley oldWidget) {
    setState(() {
      classId = widget.classId;
      observationId = widget.observationId;
      studentId = widget.studentId;
      rating = widget.rating;
    });
  }

  Widget _smileyWidget(String type, int rtVal, int index) {
    return InkWell(
      onTap: () {
        setState(() {
          if (rating > -1 && rating == index + 1) {
            rating = 0;
          } else {
            rating = index + 1;
          }
        });
        context.bloc<DashboardBloc>()
          ..add(UpdateRating(
              classId: classId,
              observationId: observationId,
              studentId: studentId,
              rating: rating));
      },
      child: Container(
        padding: const EdgeInsets.all(2.0),
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Image.asset(
          "assets/images/${type + (rating != index + 1 ? "_desabled" : "")}.png",
          width: 27,
          height: 27,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => DashboardBloc(),
      child: Row(children: [
        ..._smileys
            .map<Widget>((d) => _smileyWidget(d, rating, _smileys.indexOf(d)))
            .toList()
      ]),
    );
  }
}
