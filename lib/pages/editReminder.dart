/*import 'package:carepetsapp/models/reminder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import "package:flutter/material.dart";
import 'package:carepetsapp/pages/home.dart';
import 'package:carepetsapp/widgets/progress.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class EditReminder extends StatefulWidget {
  final String reminderId;
  const EditReminder({required this.reminderId});

  @override
  _EditReminderState createState() => _EditReminderState();
}

class _EditReminderState extends State<EditReminder> {
  //Variables
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  String typeValue = 'Baño';
  String petValue = '';
  String dateValue = "";
  String petId = "";

  bool isLoading = false;

  Reminder? reminderResult;

  TextEditingController descriptionController = TextEditingController();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  late List<PendingNotificationRequest> pendingNotificationRequests;
  @override
  void initState() {
    super.initState();
    getPet();
    _checkPendingNotificationRequests();
  }

  Future<void> _checkPendingNotificationRequests() async {
    pendingNotificationRequests =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  Future<void> _cancelNotification() async {
    _checkPendingNotificationRequests();

    for (var i = 0; i < pendingNotificationRequests.length; i++) {
      if (pendingNotificationRequests[i].payload == reminderResult!.id) {
        print(pendingNotificationRequests[i].payload);
        await flutterLocalNotificationsPlugin.cancel(i);
      }
    }
  }

  getPet() async {
    setState(() {
      isLoading = true;
    });

    DocumentSnapshot doc = await myRemindersRef
        .doc(currentUser!.id)
        .collection('reminderItems')
        .doc(widget.reminderId)
        .get();
    reminderResult = Reminder.fromDocument(doc);
    descriptionController.text = reminderResult!.description;
    typeValue = reminderResult!.type;
    petValue = reminderResult!.petName;

    var date = DateTime.parse(reminderResult!.date.toDate().toString());
    dateValue = DateFormat('yyyy-MM-dd  kk:mm').format(date);

    setState(() {
      isLoading = false;
    });
  }

  deleteReminder(BuildContext parentContext) async {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: const Text("¿Desea borrar el recordatorio?"),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  delete();
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

  delete() {
    _cancelNotification();

    myRemindersRef
        .doc(currentUser!.id)
        .collection('reminderItems')
        .doc(reminderResult!.id)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recordatorio eliminado')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        actions: <Widget>[
          TextButton.icon(
            icon: const Icon(Icons.arrow_back),
            label: const Text('Salir',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                )),
            onPressed: () => Navigator.pop(context),
          )
        ],
        backgroundColor: Colors.white,
        title: const Text(
          "Recordatorio",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: isLoading
          ? circularProgress()
          : SingleChildScrollView(
              child: Card(
                child: Column(
                  children: <Widget>[
                    ListTile(
                      contentPadding: const EdgeInsets.all(20),
                      title: Text(
                        typeValue + ' a ' + petValue,
                      ),
                      subtitle: Text(dateValue),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
*/