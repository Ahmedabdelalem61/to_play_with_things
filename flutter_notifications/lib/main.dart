import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_notifications/services/local_notifications_service.dart';
Future<void> messageHandler(RemoteMessage message)async{
  print(message.notification!.body);
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //background and the app terminated
  FirebaseMessaging.instance.getInitialMessage().then((message) {
    if(message!=null)
      {
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
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  void initState() {
    FirebaseMessaging.instance.getInitialMessage();
    LocalNotificationService.initialize(context);
    //foreground
    FirebaseMessaging.onMessage.listen((message) {
      if(message != null){
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
