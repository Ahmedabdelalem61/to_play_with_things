import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_notifications/services/local_notifications_service.dart';
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
  Future<User> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn();
    final googleUser = await googleSignIn.signIn();
    if (googleUser != null) {
      final googleAuth = await googleUser.authentication;
      if (googleAuth.idToken != null) {
        final userCredential = await FirebaseAuth.instance
            .signInWithCredential(GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken,
        ));
        //TODO: get use from the credentail and register it in the firestore
        final firebaseUser = userCredential.user;
        if (firebaseUser != null) {
          // Check is already sign up
          final QuerySnapshot result = await FirebaseFirestore.instance
              .collection('users')
              .where('id', isEqualTo: firebaseUser.uid)
              .get();
          final List<DocumentSnapshot> documents = result.docs;
          if (documents.length == 0) {
            // Update data to server if new user
            FirebaseFirestore.instance
                .collection('users')
                .doc(firebaseUser.uid)
                .set({
              'nickname': firebaseUser.displayName,
              'photoUrl': firebaseUser.photoURL,
              'id': firebaseUser.uid
            });
          }
        }

        return userCredential.user!;
      } else {
        throw FirebaseAuthException(
          code: 'ERROR_MISSING_GOOGLE_ID_TOKEN',
          message: 'Missing Google ID Token',
        );
      }
    } else {
      throw FirebaseAuthException(
        code: 'ERROR_ABORTED_BY_USER',
        message: 'Sign in aborted by user',
      );
    }
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Sign in'),
          onPressed: () {
            signInWithGoogle();
          },
        ),
      ),
    );
  }
}
