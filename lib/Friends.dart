import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:forces_info/login.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Alert_service.dart';
import 'signup.dart';
import 'RatingColors.dart';
import 'Profile.dart';

class Friends extends StatefulWidget {
  const Friends({super.key});

  @override
  State<Friends> createState() => _FriendsState();
}

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

class _FriendsState extends State<Friends> {
  List<dynamic> friendInfoList = [];
  TextEditingController _friends = TextEditingController();
  String allFriends = '';
  String Owner = 'none';

  @override
  void initState() {
    super.initState();
  }

  Future<List<dynamic>> fetchFriendInfo() async {
    try {
      final user_id = FirebaseAuth.instance.currentUser?.uid;
      DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('users').doc(user_id).get();
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      allFriends = userData['friends'];
      Owner = userData['handle'];

      if (allFriends.isEmpty) {
        print('No friends added yet!');
        return [];
      }

      var url = Uri.parse(
          "https://codeforces.com/api/user.info?handles=${userData['friends'].toString()}");
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        friendInfoList = jsonResponse['result'];
        return friendInfoList;
      } else {
        print("Failed to load friend information: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Error fetching user information: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff334756),
      appBar: AppBar(
        title: Text(
          "Friends",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Colors.white, // Change this color to the desired one
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white,size: 30,),
            onPressed: _showAddFriendDialog, // Same function as floating action button
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchFriendInfo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: Colors.blue,strokeWidth: 6.0,),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white)),
            );
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'None is added as your friend',
                style: TextStyle(color: Colors.white, fontSize: 16.0),
              ),
            );
          } else if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                var friendInfo = snapshot.data![index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            Profile(user: friendInfo, Owner: Owner),
                      ),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    padding: EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey,
                      borderRadius: BorderRadius.circular(15.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 8.0,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30.0,
                          backgroundImage: NetworkImage(
                            friendInfo['titlePhoto'].toString(),
                          ),
                        ),
                        SizedBox(width: 16.0),
                        Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                (friendInfo['rank']=='legendary grandmaster' || friendInfo['rank']=='tourist')?
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: friendInfo['handle'][0], // The first letter of the handle
                                        style: TextStyle(
                                          color: friendInfo['rank']=='tourist'?Colors.red:Colors.black, // Color for the first letter
                                          fontWeight: FontWeight.bold, // Optional: add bold to make it stand out
                                            fontSize: 18
                                        ),
                                      ),
                                      TextSpan(
                                        text: friendInfo['handle'].substring(1), // The rest of the letters
                                        style: TextStyle(
                                          color: friendInfo['rank']=='tourist'?Colors.black:Colors.red, // Color for the rest of the letters
                                          fontWeight: FontWeight.bold,
                                            fontSize: 18
                                        ),
                                      ),
                                    ],
                                  ),
                                )

                                    :Text('${friendInfo['handle'].toString()}',
                                  style: TextStyle(
                                      color: rankColorMap[friendInfo['rank']] ??
                                          Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      '${friendInfo['rating']?.toString() ?? 'unrated'}',
                                      style: TextStyle(
                                          color: rankColorMap[friendInfo['rank']] ??
                                              Colors.black,
                                          fontSize: 15),
                                    ),
                                    SizedBox(width: 10),
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: ' (max : ', // Text for ', (max : '
                                            style: TextStyle(
                                              color: Colors.white, // Color for other characters
                                              fontSize: 15,
                                            ),
                                          ),
                                          TextSpan(
                                            text: '${friendInfo['maxRating']?.toString() ?? 'unrated'}', // Text for the max rating
                                            style: TextStyle(
                                              color: rankColorMap[friendInfo['maxRank']] ??
                                                  Colors.black, // Color for '1827'
                                                fontSize: 15,
                                            ),
                                          ),
                                          TextSpan(
                                            text: ')', // Text for ')'
                                            style: TextStyle(
                                              color: Colors.white, // Color for ')'
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )

                                  ],
                                ),
                              ],
                            ),
                        ),
                        // Delete button
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _showDeleteConfirmationDialog(context, index, friendInfo['handle']);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(
              child: Text(
                'Unexpected Error',
                style: TextStyle(color: Colors.white),
              ),
            );
          }
        },
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, int index, String handle) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xff334756),
          title: Text(
            "Delete Friend",
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            "Are you sure you want to delete $handle from your friends?",
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              child: Text("No", style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text("Yes", style: TextStyle(color: Colors.red)),
              onPressed: () {
                _deleteFriend(index, handle);
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteFriend(int index, String handle) async {
    try {
      // Remove the friend from the list
      friendInfoList.removeAt(index);

      // Update the 'friends' field in Firestore
      var userId = FirebaseAuth.instance.currentUser?.uid;
      DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);

      // Update the friends string
      List<String> friendsList = allFriends.split(';');
      //print(friendsList);
      friendsList.remove(handle);
      //print('to delete : ${handle}');
      //print(friendsList);
      allFriends = friendsList.join(';');

      await userDocRef.update({'friends': allFriends});
      //print(allFriends);
      // Refresh the UI
      setState(() {});
    } catch (e) {
      print("Error deleting friend: $e");
    }
  }

  void _showAddFriendDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Color(0xff334756),
              title: Text(
                "Add Friends by Handle",
                style: TextStyle(color: Colors.white),
              ),
              content: TextField(
                controller: _friends,
                keyboardType: TextInputType.text,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: BorderSide(
                      color: Color.fromRGBO(255, 255, 255, 1),
                      width: 2.0,
                    ),
                  ),
                  hintText: 'Enter friend\'s handle',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                onChanged: (text) {
                  setState(() {});
                },
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.search, color: Colors.white),
                  onPressed: _friends.text.trim().isNotEmpty
                      ? () {
                    _onButtonPressed();
                    Navigator.of(context).pop();
                  }
                      : null,
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _onButtonPressed() async {
    print('Button pressed with text: ${_friends.text}');
    var url = Uri.parse(
        "https://codeforces.com/api/user.info?handles=${_friends.text.trim()}");
    var response = await http.get(url);

    if (response.statusCode == 200) {
      print('${_friends.text.trim()} is found');
      var jsonResponse = json.decode(response.body);
      var userInfo = jsonResponse['result'][0];
      if (allFriends.contains(userInfo['handle'].toString())) {
        AlertService.showToast(
            context: context,
            text: '${userInfo['handle']} has already been added',
            icon: Icons.error_outline,
            color: Colors.red,
            bgcolor: Color(0xff334756)
        );
        _friends.clear();
        return; // Exit the function early
      }
      if (allFriends.isEmpty) {
        allFriends = userInfo['handle'].toString();
      } else {
        allFriends += ';' + userInfo['handle'].toString();
      }
      var userId = FirebaseAuth.instance.currentUser?.uid;

      DocumentReference userDocRef =
      FirebaseFirestore.instance.collection('users').doc(userId);

      await userDocRef.update({'friends': allFriends});
      friendInfoList.add(userInfo);
      setState(() {}); // Refresh the UI to reflect changes
      _friends.clear();
    } else {
      _friends.clear();
      AlertService.showToast(
          context: context,
          text: 'Error: This handle isn\'t found!',
          icon: Icons.error_outline,
          color: Colors.red,
          bgcolor: Color(0xff334756)
      );
      print("Failed to load user information: ${response.statusCode}");
    }
  }
}
