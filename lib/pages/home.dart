import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carepetsapp/models/user.dart';
import 'package:carepetsapp/pages/activity_feed.dart';
import 'package:carepetsapp/pages/create_account.dart';
import 'package:carepetsapp/pages/profile.dart';
import 'package:carepetsapp/pages/search.dart';
import 'package:carepetsapp/pages/timeline.dart';
import 'package:carepetsapp/pages/upload.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:carepetsapp/widgets/menu.dart';
import 'package:carepetsapp/widgets/headerBack.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

//Variables
final GoogleSignIn googleSignIn = GoogleSignIn();
final firebase_storage.FirebaseStorage storageRef =
    firebase_storage.FirebaseStorage.instance;
final usersRef = FirebaseFirestore.instance.collection('users');
final postsRef = FirebaseFirestore.instance.collection('posts');
final commentsRef = FirebaseFirestore.instance.collection('comments');
final activityFeedRef = FirebaseFirestore.instance.collection('feed');
final followersRef = FirebaseFirestore.instance.collection('followers');
final followingRef = FirebaseFirestore.instance.collection('following');
final timelineRef = FirebaseFirestore.instance.collection('timeline');
final tipsRef = FirebaseFirestore.instance.collection('tips');
final adoptionsRef = FirebaseFirestore.instance.collection('adoptions');
final lostPetsRef = FirebaseFirestore.instance.collection('lostPets');
final myPetsRef = FirebaseFirestore.instance.collection('pets');
final myRemindersRef = FirebaseFirestore.instance.collection('reminders');

final DateTime timestamp = DateTime.now();

User? currentUser;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  bool isAuth = false;
  bool isNotification = false;
  PageController? pageController;
  int pageIndex = 0;
  DateTime currentDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  FlutterLocalNotificationsPlugin flutterNotificationPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    // Detects when user signed in
    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account!);
    }, onError: (err) {
      // print('Error signing in: $err');
    });
    // Reauthenticate user when app is opened
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handleSignIn(account!);
    }).catchError((err) {
      //print('Error signing in: $err');
    });
    tz.initializeTimeZones();
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('logo');

    var initializationSettingsIOS = const IOSInitializationSettings();

    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    flutterNotificationPlugin = FlutterLocalNotificationsPlugin();

    flutterNotificationPlugin.initialize(initializationSettings);
  }

  handleSignIn(GoogleSignInAccount account) async {
    if (account != null) {
      await createUserInFirestore();
      setState(() {
        isAuth = true;
      });
      configurePushNotifications();
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  configurePushNotifications() {
    final GoogleSignInAccount user = googleSignIn.currentUser!;
    if (Platform.isIOS) getiOSPermission();

    _firebaseMessaging.getToken().then((token) {
      // print("Firebase Messaging Token: $token\n");
      usersRef.doc(user.id).update({"androidNotificationToken": token});
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final String recipientId = message.data.toString();
      final String? body = message.notification?.body.toString();

      if (recipientId.contains(user.id)) {
        //print("Notification shown!");
        isNotification = true;
        var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
          'repeatDailyAtTime channel id',
          'repeatDailyAtTime channel name',
          importance: Importance.max,
          ledColor: Color(0xFF3EB16F),
          ledOffMs: 1000,
          ledOnMs: 1000,
          enableLights: true,
        );
        var iOSPlatformChannelSpecifics = const IOSNotificationDetails();
        var platformChannelSpecifics = NotificationDetails(
            android: androidPlatformChannelSpecifics,
            iOS: iOSPlatformChannelSpecifics);

        flutterNotificationPlugin.zonedSchedule(
          4,
          'Notificación',
          body,
          tz.TZDateTime.now(tz.local).add(const Duration(seconds: 1)),
          platformChannelSpecifics,
          payload: "Hello",
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );

        setState(() {});
      } else {
        isNotification = false;
        //print("Notification NOT shown");
      }
    });
  }

  getiOSPermission() {
    _firebaseMessaging.requestPermission(alert: true, badge: true, sound: true);
    /*_firebaseMessaging.onIosSettingsRegistered.listen((settings) {
      print("Settings registered: $settings");
    });*/
  }

  createUserInFirestore() async {
    final GoogleSignInAccount user = googleSignIn.currentUser!;
    DocumentSnapshot doc = await usersRef.doc(user.id).get();

    if (!doc.exists) {
      final List<String> account = await Navigator.push(
          context, MaterialPageRoute(builder: (context) => CreateAccount()));

      final username = account[0];
      final displayName = account[1];
      final mediaUrl = account[2];

      usersRef.doc(user.id).set({
        "id": user.id,
        "username": username.toLowerCase(),
        "photoUrl": mediaUrl,
        "email": user.email,
        "displayName": displayName,
        "bio": "",
        "timestamp": DateTime.now(),
      });

      await followersRef
          .doc(user.id)
          .collection('userFollowers')
          .doc(user.id)
          .set({
        "id": user.id,
        "username": username.toLowerCase(),
        "photoUrl": mediaUrl,
        "email": user.email,
        "displayName": displayName,
        "bio": "",
      });

      doc = await usersRef.doc(user.id).get();
    }

    currentUser = User.fromDocument(doc);
  }

  @override
  void dispose() {
    pageController!.dispose();
    super.dispose();
  }

  login() {
    googleSignIn.signIn();
  }

  logout() {
    googleSignIn.signOut();
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    if (pageIndex == 3) {
      isNotification = false;
    }
    setState(() {});
    pageController!.animateToPage(
      pageIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Scaffold buildAuthScreen() {
    return Scaffold(
      key: _scaffoldKey,
      appBar: headerBack(context, titleText: "Mi red social"),
      drawer: Drawer(child: construirListView(context, currentUser)),
      body: PageView(
        children: <Widget>[
          Timeline(currentUser: currentUser!),
          Search(),
          Upload(currentUser: currentUser!),
          ActivityFeed(),
          Profile(profileId: currentUser!.id),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: const NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
          currentIndex: pageIndex,
          onTap: onTap,
          activeColor: const Color.fromARGB(255, 81, 212, 212),
          items: [
            const BottomNavigationBarItem(icon: Icon(Icons.history)),
            const BottomNavigationBarItem(icon: Icon(Icons.search)),
            const BottomNavigationBarItem(icon: Icon(Icons.photo_camera)),
            if (isNotification == true)
              BottomNavigationBarItem(
                icon: Stack(children: const <Widget>[
                  Icon(Icons.notifications),
                  Positioned(
                    top: 0.0,
                    right: 0.0,
                    child: Icon(Icons.brightness_1,
                        size: 8.0, color: Colors.redAccent),
                  )
                ]),
              )
            else
              const BottomNavigationBarItem(icon: Icon(Icons.notifications)),
            const BottomNavigationBarItem(icon: Icon(Icons.account_circle)),
          ]),
    );
  }

  Scaffold buildUnAuthScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Theme.of(context).accentColor,
              Theme.of(context).primaryColor,
            ],
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // const Image(
            //   image: AssetImage('assets/images/logo.png'),
            // ),
            const Text(
              'CarePetsApp',
              style: TextStyle(
                fontFamily: "Signatra",
                fontSize: 90.0,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            GestureDetector(
              onTap: login,
              child: Container(
                width: 260.0,
                height: 60.0,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      'assets/images/google_signin_button.png',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}
