import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_notifications/pages/home_page.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<void> messageHandler(RemoteMessage message) async {
  print(message.notification!.body);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //background and the app terminated
  FirebaseMessaging.instance.getInitialMessage().then((message) {
    if (message != null) {
      final body = message.notification!.body;
      print(body);
    }
  });
  //when app is in background and not terminated
  //it's better to use this func here outside the flutter specific classes as it will work all the time
  FirebaseMessaging.onBackgroundMessage(messageHandler);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Notifications Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Notifications Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<User?> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn();
    final googleUser = await googleSignIn.signIn();
    try {
      final googleAuth = await googleUser?.authentication;
      if (googleAuth?.idToken != null) {
        final userCredential = await FirebaseAuth.instance
            .signInWithCredential(GoogleAuthProvider.credential(
          idToken: googleAuth?.idToken,
          accessToken: googleAuth?.accessToken,
        ));
        final firebaseuid = userCredential.user!.uid;
        print('firebase user uid itself : ${FirebaseAuth.instance.currentUser!
            .uid}');
        print('firebase user uid from google signing  : $firebaseuid');
        FirebaseFirestore.instance.collection('users').doc(firebaseuid).set({
          'Name': userCredential.user!.displayName,
          'Email': userCredential.user!.email,
          'photoUrl': userCredential.user!.photoURL,
          'notification_token': '',
        }).then((value) =>
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const HomeScreen()))
        ).catchError((e) {
          print(e.toString());
        });
      }
    } on FirebaseAuthException {
      // throw FirebaseAuthException(
      //   code: 'ERROR_ABORTED_BY_USER',
      //   message: 'Sign in aborted by user',
      // );
      print("ERROR_ABORTED_BY_USER");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Sign in with Google'),
          onPressed: () {
            signInWithGoogle();
          },
        ),
      ),
    );
  }
}
