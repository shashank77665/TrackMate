import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trackmate/apicall.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  var trackinginfo;
  TextEditingController input = TextEditingController();
  var fetchedData;
  bool isLoading = false;
  bool isStarted = false;

  String formatDate(String dateString) {
    DateTime parsedDate = DateTime.parse(dateString);
    return DateFormat('d MMMM').format(parsedDate);
  }

  String formatDateTime(String dateTimeString) {
    DateTime parsedDateTime = DateTime.parse(dateTimeString);
    return DateFormat('d MMMM hh:mm a').format(parsedDateTime);
  }

  void track(String trackingId) async {
    setState(() {
      isLoading = true; // Start loading
    });
    trackinginfo = await detectCourier(context, trackingId);

    print(" trackinginfo :  $trackinginfo");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Courier Detected : ${trackinginfo['courier_name']}'),
        duration: const Duration(
            seconds:
                2), // Duration for how long the Snackbar should be displayed
      ),
    );

    fetchedData = await getData(
        context, trackinginfo['tracking_id'], trackinginfo['courier_code']);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Status : ${fetchedData['data'][0]['delivery_status']}'),
        duration: const Duration(
            seconds:
                2), // Duration for how long the Snackbar should be displayed
      ),
    );

    setState(() {
      isLoading = false; // Stop loading
    });
    print('getData Completed :  $fetchedData');
    print('track completed');
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: [
          Text(
            'Track any Parcel',
            style: TextStyle(fontSize: 20),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(25)),
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                    controller: input,
                    decoration: InputDecoration(
                        hintText: "Type to Search",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(10)),
                  )),
                  GestureDetector(
                    onTap: () async {
                      if (input.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Please enter a tracking ID'),
                            duration: const Duration(
                                seconds:
                                    2), // Duration for how long the Snackbar should be displayed
                          ),
                        );
                        return;
                      }
                      track(input.text);
                      setState(() {
                        input.clear();
                        isStarted = true;
                      });
                    },
                    child: Icon(
                      Icons.search,
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  )
                ],
              ),
            ),
          ),
          isLoading
              ? Center(
                  child: CircularProgressIndicator()) // Show loading indicator
              : (isStarted)
                  ? trackinginfo != null
                      ? Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(left: 10, right: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //  Key Information Display
                                Card(
                                  elevation: 5,
                                  color:
                                      const Color.fromARGB(255, 228, 232, 245),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Source -> Destination
                                        Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            '${fetchedData['data'][0]['origin_city'] ?? 'Unknown'} → '
                                            ' ${fetchedData['data'][0]['destination_city'] ?? 'Unknown'}',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Shipped By:${trackinginfo['courier_name']}',
                                          style: TextStyle(fontSize: 14),
                                        ),

                                        SizedBox(height: 2),

                                        // Current Status
                                        Text(
                                          'Current Status: ${fetchedData['data'][0]['delivery_status'] ?? 'Unknown'}',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        SizedBox(height: 2),

                                        // Delivery Date
                                        Text(
                                          'Delivery Date: ${formatDate(fetchedData['data'][0]['scheduled_delivery_date'])}',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        SizedBox(height: 2),

                                        // Last Location
                                        Text(
                                          'Last Update: ${fetchedData['data'][0]['latest_event'] ?? 'No recent updates'}',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                Divider(),

                                // Parcel Update Route (Checkpoints)
                                Text(
                                  'Parcel Route Updates:',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: fetchedData['data'][0]
                                            ['origin_info']['trackinfo']
                                        .length,
                                    itemBuilder: (context, index) {
                                      final checkpoint = fetchedData['data'][0]
                                          ['origin_info']['trackinfo'][index];
                                      return ListTile(
                                        leading: Icon(Icons.location_on),
                                        title:
                                            Text(checkpoint['tracking_detail']),
                                        subtitle: Text(
                                            '${checkpoint['location']} - ${formatDateTime(checkpoint['checkpoint_date'])}' // Use checkpoint_date instead
                                            ),
                                        trailing: Text(checkpoint[
                                            'checkpoint_delivery_status']),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Text(
                          'This courier partner not available now, try another ')
                  : Center(
                      child: Text(
                      'Start Searching',
                      style: TextStyle(fontSize: 18),
                    ))
        ],
      )),
    );
  }
}
