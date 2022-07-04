import 'package:carepetsapp/models/reminder.dart';
import 'package:carepetsapp/pages/addReminder.dart';
import 'package:carepetsapp/pages/careMyPets.dart';
import 'package:carepetsapp/pages/editReminder.dart';
import 'package:carepetsapp/widgets/headerTitle.dart';
import 'package:carepetsapp/widgets/progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:carepetsapp/pages/home.dart';
import 'package:carepetsapp/widgets/menu.dart';
import 'package:intl/intl.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

late List<PendingNotificationRequest> pendingNotificationRequests;
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class MyReminders extends StatefulWidget {
  @override
  _MyRemindersState createState() => _MyRemindersState();
}

class _MyRemindersState extends State<MyReminders> {
  //Variables
  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot>? searchResultsFuture;

  @override
  void dispose() {
    super.dispose();
  }

  void initState() {
    super.initState();
    _checkPendingNotificationRequests();
  }

  Future<void> _checkPendingNotificationRequests() async {
    pendingNotificationRequests =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();

    for (var i = 0; i < pendingNotificationRequests.length; i++) {
      //print(pendingNotificationRequests[i].body);
    }
  }

  buildPetsResults(userId) {
    Future<QuerySnapshot> reminders = myRemindersRef
        .doc(currentUser!.id)
        .collection('reminderItems')
        .where("ownerId", isEqualTo: currentUser!.id)
        .get();
    setState(() {
      searchResultsFuture = reminders;
    });
    return FutureBuilder<QuerySnapshot>(
      future: searchResultsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<ReminderResult> searchResults = [];
        for (var doc in snapshot.data!.docs) {
          Reminder reminder = Reminder.fromDocument(doc);
          if (isBeforeToday(reminder.date) == false) {
            delete(reminder.id);
          } else {
            ReminderResult searchResult = ReminderResult(reminder);
            searchResults.add(searchResult);
          }
        }
        return ListView(
          children: searchResults,
        );
      },
    );
  }

  bool isBeforeToday(Timestamp timestamp) {
    return DateTime.now().toUtc().isBefore(
          DateTime.fromMillisecondsSinceEpoch(
            timestamp.millisecondsSinceEpoch,
            isUtc: false,
          ).toUtc(),
        );
  }

  delete(reminderId) {
    myRemindersRef
        .doc(currentUser!.id)
        .collection('reminderItems')
        .doc(reminderId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  @override
  Widget build(context) {
    return RefreshIndicator(
      onRefresh: () => _pullRefresh(),
      child: Scaffold(
        appBar: headerTitle(
          context,
          titleText: "Mis recordatorios",
        ),
        drawer: Drawer(child: construirListView(context, currentUser)),
        body: buildPetsResults(currentUser!.id),
        floatingActionButton: SizedBox(
          height: 60.0,
          width: 60.0,
          child: FittedBox(
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddReminder())
                      ..completed.then(
                        (_) {
                          Navigator.pop(context);
                          Route ruta = MaterialPageRoute(
                              builder: (context) => CareMyPets());
                          Navigator.push(context, ruta).then((value) => null);
                        },
                      ));
              },
              child: const Icon(Icons.add),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pullRefresh() async {
    Future<QuerySnapshot> pets =
        myRemindersRef.doc(currentUser!.id).collection('userPets').get();
    setState(() {
      searchResultsFuture = pets;
    });
  }
}

class ReminderResult extends StatelessWidget {
  final Reminder reminder;
  String petName = "";
  ReminderResult(this.reminder);

  bool isBath = false,
      isVaccination = false,
      isBuyFood = false,
      isVeterinaryCheckup = false,
      isMedication = false,
      isClean = false,
      isBrush = false,
      isWalk = false,
      isPlay = false,
      isHairSalon = false,
      isOther = false;

  checkType() {
    if (reminder.type == "Baño") {
      isBath = true;
    } else if (reminder.type == "Vacuna") {
      isVaccination = true;
    } else if (reminder.type == "Comprar comida") {
      isBuyFood = true;
    } else if (reminder.type == "Revisión veterinario") {
      isVeterinaryCheckup = true;
    } else if (reminder.type == "Medicación") {
      isMedication = true;
    } else if (reminder.type == "Limpiar") {
      isClean = true;
    } else if (reminder.type == "Cepillar") {
      isBrush = true;
    } else if (reminder.type == "Dar paseo") {
      isWalk = true;
    } else if (reminder.type == "Jugar") {
      isPlay = true;
    } else if (reminder.type == "Peluquería") {
      isHairSalon = true;
    } else {
      isOther = true;
    }
  }

  deleteReminder(BuildContext parentContext) async {
    _checkPendingNotificationRequests();
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: const Text("¿Desea borrar el recordatorio?",
                style: TextStyle(
                  fontSize: 19,
                )),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  deleteNotification(context);
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text(
                  'Borrar',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              SimpleDialogOption(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar')),
            ],
          );
        });
  }

  Future<void> _checkPendingNotificationRequests() async {
    pendingNotificationRequests =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();

    for (var i = 0; i < pendingNotificationRequests.length; i++) {
      //print(pendingNotificationRequests[i].body);
    }
  }

  Future<void> _cancelNotification() async {
    for (var i = 0; i < pendingNotificationRequests.length; i++) {
      if (pendingNotificationRequests[i].payload == reminder.id) {
        await flutterLocalNotificationsPlugin.cancel(i);
      }
    }
  }

  Future<void> _cancelNotifications() async {
    for (var i = 0; i < pendingNotificationRequests.length; i++) {
      await flutterLocalNotificationsPlugin.cancel(i);
    }
  }

  deleteNotification(context) {
    _cancelNotification();

    myRemindersRef
        .doc(currentUser!.id)
        .collection('reminderItems')
        .doc(reminder.id)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recordatorio eliminado')),
    );
  }

  @override
  Widget build(BuildContext context) {
    _checkPendingNotificationRequests();
    var date = DateTime.parse(reminder.date.toDate().toString());
    String formattedDate = DateFormat('yyyy-MM-dd  kk:mm').format(date);
    checkType();
    return Container(
      height: 150,
      color: const Color.fromARGB(255, 218, 240, 236),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (isBath)
                Image.asset(
                  'assets/images/bañera.png',
                  scale: 11,
                ),
              if (isVaccination)
                Image.asset(
                  'assets/images/vacuna.png',
                  scale: 11,
                ),
              if (isBuyFood)
                Image.asset(
                  'assets/images/comidaMascota.png',
                  scale: 11,
                ),
              if (isVeterinaryCheckup)
                Image.asset(
                  'assets/images/veterinario.png',
                  scale: 11,
                ),
              if (isMedication)
                Image.asset(
                  'assets/images/medicacion.png',
                  scale: 11,
                ),
              if (isClean)
                Image.asset(
                  'assets/images/limpiar.png',
                  scale: 11,
                ),
              if (isBrush)
                Image.asset(
                  'assets/images/cepillar.png',
                  scale: 11,
                ),
              if (isWalk)
                Image.asset(
                  'assets/images/paseo.png',
                  scale: 11,
                ),
              if (isPlay)
                Image.asset(
                  'assets/images/jugar.png',
                  scale: 11,
                ),
              if (isHairSalon)
                Image.asset(
                  'assets/images/peluqueria.png',
                  scale: 11,
                ),
              if (isOther)
                const Icon(
                  Icons.pets,
                  size: 40,
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (reminder.reminderType ==
                          "Recordatorio programado semanal" ||
                      reminder.reminderType == "Recordatorio programado diario")
                    ListTile(
                      onLongPress: () {
                        deleteReminder(context);
                      },
                      title: Center(
                        child: AutoSizeText(
                          reminder.reminderType,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                      subtitle: Center(
                        child: Column(
                          children: [
                            Text(formattedDate.substring(10)),
                            if (reminder.description != "")
                              Text(reminder.description),
                          ],
                        ),
                      ),
                    ),
                  if (reminder.reminderType == "Recordatorio único")
                    if (reminder.description != "")
                      ListTile(
                        onLongPress: () {
                          deleteReminder(context);
                        },
                        title: Center(
                          child: Column(
                            children: [
                              Text(reminder.description),
                              Text(
                                reminder.reminderType,
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        subtitle: Center(
                          child: AutoSizeText(
                            formattedDate,
                          ),
                        ),
                      ),
                  if (reminder.reminderType == "Recordatorio único")
                    if (reminder.description == "")
                      ListTile(
                        onLongPress: () {
                          deleteReminder(context);
                        },
                        title: Center(
                          child: AutoSizeText(
                            reminder.reminderType,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ),
                        subtitle: Center(
                          child: AutoSizeText(
                            formattedDate,
                          ),
                        ),
                      ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
