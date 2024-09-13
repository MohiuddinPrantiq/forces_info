import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Alert_service.dart';
import 'RatingColors.dart';
import 'Friends.dart';
import 'Contest.dart';
import 'Profile.dart';
import 'package:flutter_svg/flutter_svg.dart';

final Map<String, Color> rankColorMap = {
  'null' : Colors.black,
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
};

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Map<String, dynamic>? user;

  @override
  void initState() {
    super.initState();
    get_data();
  }

  Future<void> get_data() async {
    try {
      final user_id = FirebaseAuth.instance.currentUser?.uid;

      DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('users').doc(user_id).get();
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      var url = Uri.parse(
          "https://codeforces.com/api/user.info?handles=${userData['handle'].toString()}");
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        var userInfo = jsonResponse['result'][0];
        setState(() {
          user = userInfo;
        });
      } else {
        print("Failed to load user information: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching user information: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff334756),//Color(0xff082032)
      appBar: AppBar(
        title: Text("Dashboard",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey,//Color(0xff334756)
        centerTitle: true,
      ),
      body: user == null
          ? Center(child: CircularProgressIndicator(color: Colors.blue,strokeWidth: 6.0,))
          : SingleChildScrollView(
        child: Column(
          children: [
            // Codeforces Logo
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: SvgPicture.asset(
                  'assets/images/CfVector.svg', // Using local image
                  width: 200,
                ),
              ),
            ),
            // User Info
            GestureDetector(
              onTap: () {
                // Navigate to user profile page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Profile(user: user!,Owner: user?['handle']),
                  ),
                );
              },
              child: Container(
                margin: EdgeInsets.all(16.0),
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.blueGrey,//Color(0xff334756)
                  borderRadius: BorderRadius.circular(15.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26.withOpacity(0.3),
                      blurRadius: 5.0,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.network(
                        user!['titlePhoto'].toString(), // Profile picture URL
                        width: 85,
                        height: 85,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${user!['handle'].toString()}",
                          style: TextStyle(
                            color: rankColorMap[user!['rank']] ?? Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                          ),
                        ),
                        Text.rich(
                          TextSpan(
                              children: [
                                TextSpan(
                                    text: 'Rating : ',
                                    style: TextStyle(color: Colors.white,
                                      fontSize: 18,
                                    )
                                ),
                                TextSpan(
                                    text: '${user!['rating'].toString()}, ${user!['rank']}',
                                    style: TextStyle(color: rankColorMap[user!['rank']] ?? Colors.black,
                                      fontSize: 18,
                                    )
                                )
                              ]
                          ),
                        ),
                        Text.rich(
                          TextSpan(
                              children: [
                                TextSpan(
                                    text: 'Max : ',
                                    style: TextStyle(color: Colors.white,
                                      fontSize: 18,
                                    )
                                ),
                                TextSpan(
                                    text: '${user!['maxRating'].toString()}, ${user!['maxRank']}',
                                    style: TextStyle(color: rankColorMap[user!['maxRank']] ?? Colors.black,
                                      fontSize: 18,
                                    )
                                )
                              ]
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Contest List
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Isn't this your handle?",
                    style: TextStyle(fontSize: 12, color: Colors.white54),
                  ),
                  SizedBox(width: 5), // Add some space between the texts
                  GestureDetector(
                    onTap: _updateHandle,
                    child: Text(
                      'Update',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xff40826d), // Highlight the clickable text

                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10,),
            GestureDetector(
              onTap: () {
                // Navigate to contest list page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Contest()),
                );
              },
              child: Container(
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
                child: Row(
                  children: [
                    Icon(Icons.emoji_events, color: Colors.white),
                    SizedBox(width: 16),
                    Text(
                      "Contests",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Friends List
            GestureDetector(
              onTap: () {
                // Navigate to friends list page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Friends()),
                );
              },
              child: Container(
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
                child: Row(
                  children: [
                    Icon(Icons.people, color: Colors.white),
                    SizedBox(width: 16),
                    Text(
                      "Friends",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _newHandle ='';
  void _updateHandle() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xff334756),
          title: Text("Update Handle",
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: BorderSide(
                color: Color.fromRGBO(255, 255, 255, 1),
                width: 2.0,
                ),
              ),
              hintText: 'Enter New Handle',
              hintStyle: TextStyle(color: Colors.grey),
            ),
            onChanged: (value) {
              setState(() {
                _newHandle = value;
              });
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog on 'No'
              },
              child: Text("No",
                style: TextStyle(color: Colors.white),),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                await _fetchAndUpdateHandle(); // Call the function to fetch and update
              },
              child: Text("Yes",
                style: TextStyle(color: Colors.white),),
            ),
          ],
        );
      },
    );
  }

  // Function to fetch data from Codeforces API and update handle in Firebase
  Future<void> _fetchAndUpdateHandle() async {
    if (_newHandle.isEmpty) {
      AlertService.showToast(
          context: context,
          text: "Handle cannot be empty",
          icon: Icons.error_outline,
          color: Colors.red
      );
      return;
    }

    try {
      var url = Uri.parse("https://codeforces.com/api/user.info?handles=${_newHandle.toString()}");
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == "OK" && jsonResponse['result'] != null) {
          // Handle found, update Firebase
          var updatedUser = jsonResponse['result'][0];
          final user_id = FirebaseAuth.instance.currentUser?.uid;
          await FirebaseFirestore.instance.collection('users').doc(user_id).update({
            'handle': updatedUser['handle'],
          });
          setState(() {
            user = updatedUser;
          });

          AlertService.showToast(
              context: context,
              text: "Handle updated successfully",
              icon: Icons.check_box_outlined,
              color: Colors.green
          );
        } else {
          // Handle not found
          AlertService.showToast(
              context: context,
              text: "$_newHandle not found",
              icon: Icons.error_outline,
              color: Colors.red
          );
        }
      } else {
        AlertService.showToast(
            context: context,
            text: "Error fetching data from Codeforces",
            icon: Icons.error_outline,
            color: Colors.red
        );
      }
    } catch (e) {
      AlertService.showToast(
          context: context,
          text: "Error: $e",
          icon: Icons.error_outline,
          color: Colors.red
      );
    }
  }
}
