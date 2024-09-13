import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:forces_info/Notification.dart'; // Import the Notification_Sch class
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

import 'Alert_service.dart';

class Contests {
  final int id;
  final String name;
  final int startTime;
  final int duration;
  final String phase;

  Contests({
    required this.id,
    required this.name,
    required this.startTime,
    required this.duration,
    required this.phase,
  });
}

class Contest extends StatefulWidget {
  const Contest({super.key});

  @override
  State<Contest> createState() => _ContestState();
}

class _ContestState extends State<Contest> {
  List<Contests> contestList = [];
  bool isLoading = true;

  final Map<int, bool> alarmStateMap = {};

  @override
  void initState() {
    super.initState();
    fetchContestList();
    Notification_Sch.init(); // Initialize notifications
  }

  Future<void> fetchContestList() async {
    final response =
    await http.get(Uri.parse("https://codeforces.com/api/contest.list"));

    if (response.statusCode == 200) {
      setState(() {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> resultList = responseData['result'];
        contestList = resultList
            .where((element) =>
        element['phase'] == 'BEFORE' || element['phase'] == 'CODING')
            .map((contestData) => Contests(
          id: contestData['id'],
          name: contestData['name'],
          startTime: contestData['startTimeSeconds'],
          duration: contestData['durationSeconds'],
          phase: contestData['phase'],
        ))
            .toList();

        contestList.sort((a, b) => a.startTime.compareTo(b.startTime));

        isLoading = false;

        loadSavedAlarmStates();
      });
    } else {
      throw Exception('Failed to load contest list');
    }
  }

  String formatStartTime(int startTime) {
    DateTime startDate = DateTime.fromMillisecondsSinceEpoch(startTime * 1000);
    return DateFormat('dd MMM hh:mm a').format(startDate);
  }

  Future<void> saveAlarmState(int contestId, bool isAlarmOn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('alarm_$contestId', isAlarmOn);
  }

  Future<bool?> getAlarmState(int contestId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('alarm_$contestId');
  }

  Future<void> loadSavedAlarmStates() async {
    for (final contest in contestList) {
      final isAlarmOn = await getAlarmState(contest.id);
      if (isAlarmOn != null) {
        setState(() {
          alarmStateMap[contest.id] = isAlarmOn;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff334756),
      appBar: AppBar(
        title: Text(
          "Upcoming Contests",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: Colors.blue,
          strokeWidth: 6.0,
        ),
      )
          : ListView.builder(
        itemCount: contestList.length,
        itemBuilder: (context, index) {
          final contest = contestList[index];
          DateTime contestStartTime = DateTime.fromMillisecondsSinceEpoch(
              contest.startTime * 1000);

          bool isAlarmOn = alarmStateMap[contest.id] ?? false;

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              color: Colors.blueGrey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 5,
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            contest.name,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: contest.phase == 'CODING'
                                      ? 'Started at ${formatStartTime(contest.startTime)}, '
                                      : 'Start Time: ${formatStartTime(contest.startTime)}',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14),
                                ),
                                if (contest.phase == 'CODING')
                                  TextSpan(
                                    text: 'RUNNING',
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Duration: ${contest.duration ~/ 3600}h ${contest.duration % 3600 ~/ 60}m',
                            style: TextStyle(
                                color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Builder(
                        builder: (context) {
                          // Calculate the time 30 minutes before the contest start time
                          DateTime notificationTime = contestStartTime
                              .subtract(Duration(minutes: 30));

                          // Check if the current time is after the notification time
                          bool isButtonDisabled =
                          DateTime.now().isAfter(notificationTime);

                          return IconButton(
                            icon: Icon(
                              Icons.alarm,
                              color: isAlarmOn
                                  ? Colors.green
                                  : Colors.white,
                            ),
                            onPressed: isButtonDisabled
                                ?  (){
                                  AlertService.showToast(
                                      context: context,
                                      text: isAlarmOn == true ? 'You have already been notified for ${contest.name}'
                                          :'Notification can\'t be set for ${contest.name} As contest is starting in less than 30 minutes!',
                                      icon:Icons.error_outline,
                                      color: Colors.red
                                  );
                                }
                                : () async {
                              // Schedule notification using Notification_Sch class

                              setState(() {
                                isAlarmOn = !isAlarmOn;
                                alarmStateMap[contest.id] =
                                    isAlarmOn;
                              });

                              if(isAlarmOn){
                                // Convert startTimeSeconds to DateTime
                                DateTime contestStartTime = DateTime.fromMillisecondsSinceEpoch(contest.startTime * 1000);

                                // Subtract 30 minutes to get notification time
                                DateTime scheduledNotificationTime = contestStartTime.subtract(const Duration(minutes: 30));

                                print(scheduledNotificationTime);
                                // Convert notificationTime to tz.TZDateTime for time zone support
                                tz.TZDateTime tzNotificationTime = tz.TZDateTime.from(scheduledNotificationTime, tz.local);
                                print(tzNotificationTime);
                                Notification_Sch.scheduledNotification(
                                    'Contest Reminder',
                                    '30 minutes left until the ${contest.name} contest starts!',
                                    tzNotificationTime,
                                    contest.id,
                                );
                                print('Notification scheduled via Notification_Sch class');
                              }
                              else {

                                await Notification_Sch.cancelNotification(contest.id);

                              }

                              await saveAlarmState(
                                  contest.id, isAlarmOn);

                              AlertService.showToast(
                                  context: context,
                                  text: isAlarmOn == true ? 'You will be notified for ${contest.name} before 30 minutes to start!'
                                      : 'Notification canceled for ${contest.name}.',
                                  icon:isAlarmOn? Icons.check_box_outlined:Icons.error_outline,
                                  color: isAlarmOn?Colors.green:Colors.red,
                                  bgcolor: Color(0xff334756)
                              );

                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
