import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:trackmate/erroe.dart';

Future<Map<String, dynamic>?> getData(
    context, String trackingId, String courierName) async {
  try {
    final url = Uri.parse(
      'https://api.trackingmore.com/v4/trackings/get?tracking_numbers=$trackingId&courier_code=$courierName&archived_status=tracking',
    );

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Tracking-Api-Key': 'avhiamkg-fspz-ak05-6pfj-essxnu03bpwv',
      },
    );

    var fetchedData = json.decode(response.body);
    if (fetchedData['meta']['code'] == 4102) {
      print('Tracking number not found, creating tracking...');
      final creationResponse = await createTracking(courierName, trackingId);

      // If tracking number doesn't exist, response contains meta code 4102
      if (creationResponse == true) {
        print('Tracking created. Retrying getData...');
        return await getData(context, trackingId,
            courierName); // Retry getData after creating tracking
      } else {
        print('Failed to create tracking.');
      }
    }

    if (response.statusCode == 200) {
      return fetchedData; // Return fetched data if tracking exists
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ErrorPage(
              trackingid: trackingId,
            ),
          ));
      return null; // Return null if data retrieval failed
    }
  } catch (e) {
    print('Error: $e');
    return null; // Return null if there is an exception
  }
}

Future<Map<String, String>> detectCourier(context, String trackingId) async {
  try {
    final url = Uri.parse('https://api.trackingmore.com/v4/couriers/detect');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Tracking-Api-Key': 'avhiamkg-fspz-ak05-6pfj-essxnu03bpwv',
      },
      body: jsonEncode({
        "tracking_number": trackingId, // Correct string interpolation
      }),
    );

    if (response.statusCode == 200) {
      final decodedResponse = jsonDecode(response.body);
      final courierCode = decodedResponse['data'][0]['courier_code'];
      final courierName = decodedResponse['data'][0]['courier_name'];

      print('Courier Fetched Successfully, Courier Name is: $courierName');

      // Return both courier_code and trackingId
      return {
        'courier_code': courierCode,
        'tracking_id': trackingId,
        'courier_name': courierName
      };
    } else {
      print('Failed to detect courier: ${response.statusCode}');
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ErrorPage(
              trackingid: trackingId,
            ),
          ));
      return {};
    }
  } catch (e) {
    print('Failed to fetch Courier: $e');
    return {};
  }
}

Future<bool> createTracking(String courierCode, String trackingNumber) async {
  // API endpoint
  final url = Uri.parse('https://api.trackingmore.com/v4/trackings/create');

  // Request body
  final Map<String, dynamic> body = {
    "courier_code": courierCode,
    "tracking_number": trackingNumber
  };

  // HTTP Headers
  final headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Tracking-Api-Key': 'avhiamkg-fspz-ak05-6pfj-essxnu03bpwv'
  };

  try {
    // Make POST request
    final response = await http.post(
      url,
      headers: headers,
      body: json.encode(body),
    );

    // Check if the response is successful
    if (response.statusCode == 200) {
      print('Tracking created successfully');
      return true; // Tracking created successfully
    } else {
      print('Failed to create tracking. Status code: ${response.statusCode}');
      return false; // Failed to create tracking
    }
  } catch (e) {
    print('Error: $e');
    return false; // Error occurred while creating tracking
  }
}
