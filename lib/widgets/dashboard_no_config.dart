import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DashboardNoConfig extends StatelessWidget {
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
              child: Image.asset('assets/images/2612356.png', width: 300),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Text(
                'Sie haben noch keine Klasse angelegt.',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 17.0,
                    fontWeight: FontWeight.w500),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).pushNamed('/config');
              },
              child: new Text(
                'Klicken Sie hier und fügen Sie jetzt Ihre Klassen und Fächer hinzu',
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
