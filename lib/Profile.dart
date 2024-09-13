import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login.dart';
import 'RatingColors.dart';

final Map<String, Color> rankColorMap = {
  'null': Colors.black,
  'newbie': RatingColors.newbie,
  'pupil': RatingColors.pupil,
  'specialist': RatingColors.specialist,
  'expert': RatingColors.expert,
  'candidate master': RatingColors.candidateMaster,
  'master': RatingColors.master,
  'international master': RatingColors.internationalMaster,
  'grandmaster': RatingColors.grandmaster,
  'international grandmaster': RatingColors.internationalGrandmaster,
  'legendary grandmaster': RatingColors.legendaryGrandmaster,
  'tourist' : Colors.black,
};

class Profile extends StatelessWidget {
  final Map<String, dynamic> user;
  final String Owner;

  Profile({required this.user, required this.Owner});

  Future<List<dynamic>> fetchUserRating() async {
    final response = await http.get(Uri.parse('https://codeforces.com/api/user.rating?handle=${user['handle']}'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<dynamic> contestList = data['result'];

      // If there are more than 10 contests, take only the last 10
      if (contestList.length > 10) {
        contestList = contestList.sublist(contestList.length - 10);
      }

      return contestList.reversed.toList();
    } else {
      throw Exception('Failed to load user rating data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff334756),
      appBar: AppBar(
        title: (user['rank']=='legendary grandmaster' || user['rank']=='tourist')?
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: user['handle'][0], // The first letter of the handle
                style: TextStyle(
                  color: user['rank']=='tourist'?Colors.red:Colors.black, // Color for the first letter
                  fontWeight: FontWeight.bold, // Optional: add bold to make it stand out
                  fontSize: 30.0,
                ),
              ),
              TextSpan(
                text: user['handle'].substring(1), // The rest of the letters
                style: TextStyle(
                  color: user['rank']=='tourist'?Colors.black:Colors.red, // Color for the rest of the letters
                  fontWeight: FontWeight.bold,
                  fontSize: 30.0,
                ),
              ),
            ],
          ),
        )
            : Text(
          "${user['handle'].toString()}",
          style: TextStyle(
            color: rankColorMap[user['rank']] ?? Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 30.0,
          ),
        ),
        backgroundColor: Colors.blueGrey,//Color(0xff334756)
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Colors.white, // Change this color to the desired one
        ),
        actions: [
          if (Owner == user['handle']) // Conditionally show the logout button
            IconButton(
              icon: Icon(Icons.logout,color: Colors.white,size: 30,),
              onPressed: () {
                _showLogoutConfirmation(context);
              },
            ),
        ],
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.all(16.0),
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.blueGrey,
                  borderRadius: BorderRadius.circular(15.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26.withOpacity(0.5),
                      blurRadius: 5.0,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile Image
                    Container(
                      margin: EdgeInsets.all(8.0),
                      padding: EdgeInsets.all(2.0), // Border width
                      decoration: BoxDecoration(
                        color: Colors.white, // Border color
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 100.0,
                        backgroundImage: NetworkImage(user['titlePhoto'] ?? 'https://via.placeholder.com/150'),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    // Name
                    Text(
                      '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}', // Using null-aware operator
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16.0),
                    // Rating, Max Rating, Contribution, Registration Time
                    _buildInfoRow(
                        'Rating : ',
                        '${user['rating']?.toString() ?? 'unrated'}, ${user['rank']?.toString() ?? 'N/A'}',
                        rankColorMap[user['rank']] ?? Colors.white),
                    _buildInfoRow(
                        'Max Rating : ',
                        '${user['maxRating']?.toString() ?? 'unrated'}, ${user['maxRank']?.toString() ?? 'N/A'}',
                        rankColorMap[user['maxRank']] ?? Colors.white),
                    _buildInfoRow('Contribution : ', user['contribution']?.toString() ?? '0', Colors.white),
                    _buildInfoRow('Registration Time : ', _formatRegistrationTime(user['registrationTimeSeconds']), Colors.white),
                    SizedBox(height: 10.0),
                  ],
                ),
              ),
              // Rated contest list
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    'History of Rated Contest (Max. 10)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white,
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                child: FutureBuilder<List<dynamic>>(
                  future: fetchUserRating(),
                  builder: (context, snapshot) {
                    // Show loading indicator while the data is being fetched
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator(color: Colors.blue,strokeWidth: 6.0,));
                    }
                    // If there was an error
                    else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red)));
                    }
                    // When data is successfully fetched
                    else if (snapshot.hasData) {
                      List<dynamic> contestList = snapshot.data ?? [];

                      return LayoutBuilder(builder: (context,constraints){
                        double totalMargin = 8.0;
                        double remainingWidth = constraints.maxWidth - totalMargin;
                        double dynamicColumnWidth = remainingWidth / 4;
                        return Table(
                          defaultColumnWidth: FixedColumnWidth(dynamicColumnWidth), // You can adjust the width
                          border: TableBorder.all(
                            color: Colors.white, // Change this to any color you like
                            style: BorderStyle.solid,
                            width: 2,
                          ),
                          children: [
                            // Header row
                            TableRow(
                              children: [
                                Column(children: [Text('Contest ID', style: TextStyle(color: Colors.white, fontSize: 16))]),
                                Column(children: [Text('Rank', style: TextStyle(color: Colors.white, fontSize: 16))]),
                                Column(children: [Text('Old Rating', style: TextStyle(color: Colors.white, fontSize: 16))]),
                                Column(children: [Text('New Rating', style: TextStyle(color: Colors.white, fontSize: 16))]),
                              ],
                            ),
                            // Contest data rows
                            ...contestList.map((contest) {
                              return TableRow(
                                children: [
                                  Column(children: [Text('${contest['contestId']}', style: TextStyle(color: Colors.white))]),
                                  Column(children: [Text('${contest['rank']}', style: TextStyle(color: Colors.white))]),
                                  Column(children: [Text('${contest['oldRating']}', style: TextStyle(color: Colors.white))]),
                                  Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center, // Center the content horizontally
                                        children: [
                                          Text('${contest['newRating']}', style: TextStyle(color: Colors.white)),
                                          SizedBox(width: 5.0), // Space between rating and icon
                                          Icon(
                                            _getRatingChangeIcon(contest['newRating'], contest['oldRating']),
                                            color: _getRatingChangeIconColor(contest['newRating'], contest['oldRating']),
                                            size: 16,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            }).toList(),
                          ],
                        );
                        }
                      );

                    }
                    // In case of an empty data set
                    else {
                      return Center(child: Text('No data found', style: TextStyle(color: Colors.white)));
                    }
                  },
                ),
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$label', // The first letter of the handle
                  style: TextStyle(
                    color: Colors.white, // Color for the first letter
                    fontSize: 16, // Optional: add bold to make it stand out
                  ),
                ),
                TextSpan(
                  text: value, // The rest of the letters
                  style: TextStyle(
                    color: color, // Color for the rest of the letters
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getRatingChangeIcon(int newRating, int oldRating) {
    if (newRating > oldRating) {
      return Icons.arrow_upward;
    } else if (newRating < oldRating) {
      return Icons.arrow_downward;
    } else {
      return Icons.horizontal_rule;
    }
  }

  Color _getRatingChangeIconColor(int newRating, int oldRating) {
    if (newRating > oldRating) {
      return Colors.green;
    } else if (newRating < oldRating) {
      return Colors.red;
    } else {
      return Colors.yellow;
    }
  }

  String _formatRegistrationTime(int timestamp) {
    final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final formattedTime = DateFormat('hh:mm a, MMM dd, yyyy').format(dateTime).toUpperCase();
    return formattedTime;
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xff334756),
          title: Text('Logout',
              style: TextStyle(color: Colors.white),
          ),
          content: Text('Are you sure you want to logout?',style: TextStyle(color: Colors.white),),
          actions: <Widget>[
            TextButton(
              child: Text('No',style: TextStyle(color: Colors.white),),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Yes',style: TextStyle(color: Colors.white),),
              onPressed: () async {
                // Perform the logout operation
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pop(); // Close the dialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
