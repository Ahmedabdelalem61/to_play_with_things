import 'dart:convert';
import 'package:flutter_notifications/constants/constants.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/local_notifications_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  storeNotificationToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({'token': token}, SetOptions(merge: true));
  }

  @override
  void initState() {
    FirebaseMessaging.instance.getInitialMessage();
    LocalNotificationService.initialize(context);
    //foreground
    FirebaseMessaging.onMessage.listen((message) {
      if (message != null) {
        print(message.notification!.title);
        print(message.notification!.body);
        //as firebase doesn't support the pop up notifications in foreground we should use the local notification package
        LocalNotificationService.display(message);
      }
    });
    //background
    //when app is in background and not terminated
    FirebaseMessaging.onMessageOpenedApp.listen((backgroundMessage) {
      print(backgroundMessage.notification!.body);
      LocalNotificationService.display(backgroundMessage);
    });
    //save token to notify users with
    storeNotificationToken();
    super.initState();

  }

  sendNotification(String title, String token) async {
    final data = {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      'id': '1',
      'status': 'done',
      'message': title,
    };

    try {
      http.Response response =
      await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': 'key=$FCMsrviceKey' // ADD-YOUR-SERVER-KEY-HERE
          },
          body: jsonEncode(<String, dynamic>{
            'notification': <String, dynamic>{
              'title': title,
              'body': 'someone notified you'
            },
            'priority': 'high',
            'data': data,
            'to': '$token'
          }));

      if (response.statusCode == 200) {
        print("Your notification is sent");
      } else {
        print("Error");
      }
    } catch (e) {}
  }

  sendNotificationToTopic(String title) async {
    final data = {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      'id': '1',
      'status': 'done',
      'message': title,
    };

    try {
      http.Response response =
      await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization':
            'key=$FCMsrviceKey'
          },
          body: jsonEncode(<String, dynamic>{
            'notification': <String, dynamic>{
              'title': title,
              'body': 'You are notified by someone'
            },
            'priority': 'high',
            'data': data,
            'to': '/topics/subscription'
          }));

      if (response.statusCode == 200) {
        print("Yeh notification is sent");
      } else {
        print("Error");
      }
    } catch (e) {
      print(e.toString());
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          ElevatedButton(
              onPressed: () {
                GoogleSignIn().disconnect();
                Navigator.pop(context);
              },
              child: const Text('sign out')),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.separated(
                  itemCount: snapshot.data!.docs.length,
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(),
                  itemBuilder: (BuildContext context, int index) {
                    return Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          child: Image(
                              image: NetworkImage(
                                  snapshot.data!.docs[index].get('photoUrl'))),
                        ),
                         const SizedBox(width: 20,),
                        Text('${snapshot.data!.docs[index].get('Name')}'),
                        const Spacer(),
                        TextButton(onPressed: (){
                          sendNotification('hi',snapshot.data!.docs[index].get('token'));
                        }, child: const Text('notify me'),)
                      ],
                    );
                  },
                ),
              );
            }
            return const CircularProgressIndicator();
          }),
    );
  }
}
