import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DashboardNoStudents extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height,
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.only(bottom: 30.0),
              child: Image.asset('assets/images/ellipse_1.png', width: 300),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Text(
                'Es sind noch keine Schüler für diese Klasse angelegt.',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 17.0,
                    fontWeight: FontWeight.w500),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/addPupil',
                  arguments: <String, String>{
                    'CurrentPage': 'currentPage',
                  },
                );
              },
              child: new Text(
                'Klicken Sie hier und fügen Sie jetzt Ihre Schüler hinzu',
                style: TextStyle(
                    color: Color(0xFFf45d27),
                    fontSize: 17.0,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ],
        )));
  }
}
