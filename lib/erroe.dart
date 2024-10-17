import 'package:flutter/material.dart';
import 'package:trackmate/homepage.dart';

class ErrorPage extends StatelessWidget {
  final String trackingid;
  const ErrorPage({super.key, required this.trackingid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Not able to search this tracking Id',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              trackingid,
              style: TextStyle(fontSize: 14),
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Homepage(),
                      ));
                },
                child: Text('Try another'))
          ],
        ),
      )),
    );
  }
}
