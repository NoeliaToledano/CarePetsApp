import 'package:auto_size_text/auto_size_text.dart';
import 'package:carepetsapp/models/pet.dart';
import 'package:flutter/material.dart';
import 'package:carepetsapp/pages/home.dart';
import 'package:carepetsapp/widgets/progress.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:uuid/uuid.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

class AddReminder extends StatefulWidget {
  @override
  _AddReminderState createState() => _AddReminderState();
}

class _AddReminderState extends State<AddReminder> {
  //Variables
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool isUploading = false;
  bool isLoading = false;

  String typeValue = 'Baño';
  String typeReminder = 'Recordatorio único';
  String typeProgrammingReminder = 'Diario';
  String dayOfWeek = 'Lunes';
  String petValue = '';
  String petId = "";
  String myReminderId = const Uuid().v4();

  Pet? petResult;

  TextEditingController descriptionController = TextEditingController();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  late List<PendingNotificationRequest> pendingNotificationRequests;
  DateTime currentDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    _checkPendingNotificationRequests();
  }

  Future<void> _checkPendingNotificationRequests() async {
    pendingNotificationRequests =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();

    for (var i = 0; i < pendingNotificationRequests.length; i++) {
      // print(pendingNotificationRequests[i].body);
    }
  }

  scheduledNotification(DateTime reminderDate) async {
    _checkPendingNotificationRequests();

    await flutterLocalNotificationsPlugin.zonedSchedule(
        pendingNotificationRequests.length,
        'Recordatorio',
        typeValue + ' a ' + currentUser!.displayName,
        tz.TZDateTime.from(reminderDate, tz.local)
            .add(const Duration(seconds: 2)),
        const NotificationDetails(
            android: AndroidNotificationDetails(
                'your channel id', 'your channel name')),
        payload: myReminderId,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }

  scheduleDailyNotification() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        pendingNotificationRequests.length,
        'Recordatorio',
        typeValue + ' a ' + currentUser!.displayName,
        _nextInstanceOfDaily(),
        const NotificationDetails(
          android: AndroidNotificationDetails('daily notification channel id',
              'daily notification channel name',
              channelDescription: 'daily notification description'),
        ),
        payload: myReminderId,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time);
  }

  scheduleWeeklyNotification() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        pendingNotificationRequests.length,
        'Recordatorio',
        typeValue + ' a ' + currentUser!.displayName,
        _nextInstanceOfWeekly(),
        const NotificationDetails(
          android: AndroidNotificationDetails('weekly notification channel id',
              'weekly notification channel name',
              channelDescription: 'weekly notificationdescription'),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime);
  }

  Future<void> _scheduleMonthlyNotification() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        pendingNotificationRequests.length,
        'Recordatorio',
        typeValue + ' a ' + currentUser!.displayName,
        _nextInstanceOfWeekly(),
        const NotificationDetails(
          android: AndroidNotificationDetails('monthly notification channel id',
              'monthly notification channel name',
              channelDescription: 'monthly notificationdescription'),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime);
  }

  Future<void> _scheduleYearlyNotification() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        pendingNotificationRequests.length,
        'Recordatorio',
        typeValue + ' a ' + currentUser!.displayName,
        _nextInstanceOfMonthly(),
        const NotificationDetails(
          android: AndroidNotificationDetails('yearly notification channel id',
              'yearly notification channel name',
              channelDescription: 'yearly notification description'),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dateAndTime);
  }

  tz.TZDateTime _nextInstanceOfDaily() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    DateTime reminderDate = DateTime(currentDate.year, currentDate.month,
        currentDate.day, selectedTime.hour, selectedTime.minute);
    tz.TZDateTime scheduledDate = tz.TZDateTime.from(reminderDate, tz.local);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  tz.TZDateTime _nextInstanceOfWeekly() {
    tz.TZDateTime scheduledDate = _nextInstanceOfDaily();
    int day = DateTime.monday;
    if (dayOfWeek == "Lunes") {
      day = DateTime.monday;
    } else if (dayOfWeek == "Martes") {
      day = DateTime.tuesday;
    } else if (dayOfWeek == "Miércoles") {
      day = DateTime.wednesday;
    } else if (dayOfWeek == "Jueves") {
      day = DateTime.thursday;
    } else if (dayOfWeek == "Viernes") {
      day = DateTime.friday;
    } else if (dayOfWeek == "Sábado") {
      day = DateTime.saturday;
    } else if (dayOfWeek == "Domingo") {
      day = DateTime.sunday;
    }
    while (scheduledDate.weekday != day) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  tz.TZDateTime _nextInstanceOfMonthly() {
    tz.TZDateTime scheduledDate = _nextInstanceOfDaily();
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    int day = now.day;
    while (scheduledDate.day != day) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  addReminder() async {
    if (typeReminder == "Recordatorio único") {
      DateTime reminderDate = DateTime(currentDate.year, currentDate.month,
          currentDate.day, selectedTime.hour, selectedTime.minute);

      if (!reminderDate.isBefore(tz.TZDateTime.now(tz.local))) {
        scheduledNotification(reminderDate);

        myRemindersRef
            .doc(currentUser!.id)
            .collection('reminderItems')
            .doc(myReminderId)
            .set({
          "ownerId": currentUser!.id,
          "type": typeValue,
          "description": descriptionController.text,
          "id": myReminderId,
          "petId": petId,
          "petName": currentUser!.displayName,
          "date": reminderDate,
          "reminderType": typeReminder,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recordatorio creado')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Elige una fecha posterior a la actual')),
        );
      }
      descriptionController.clear();
    } else {
      if (typeProgrammingReminder == 'Diario') {
        scheduleDailyNotification();
        myRemindersRef
            .doc(currentUser!.id)
            .collection('reminderItems')
            .doc(myReminderId)
            .set({
          "ownerId": currentUser!.id,
          "type": typeValue,
          "description": descriptionController.text,
          "id": myReminderId,
          "petId": petId,
          "petName": currentUser!.displayName,
          "date": DateTime(2300, currentDate.month, currentDate.day,
              selectedTime.hour, selectedTime.minute),
          "reminderType":
              typeReminder + " " + typeProgrammingReminder.toLowerCase(),
        });
      } else if (typeProgrammingReminder == 'Semanal') {
        scheduleWeeklyNotification();
        myRemindersRef
            .doc(currentUser!.id)
            .collection('reminderItems')
            .doc(myReminderId)
            .set({
          "ownerId": currentUser!.id,
          "type": typeValue,
          "description": dayOfWeek + "\n" + descriptionController.text,
          "id": myReminderId,
          "petId": petId,
          "petName": currentUser!.displayName,
          "date": DateTime(2300, currentDate.month, currentDate.day,
              selectedTime.hour, selectedTime.minute),
          "reminderType":
              typeReminder + " " + typeProgrammingReminder.toLowerCase(),
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recordatorio diario programado')),
      );
    }
  }

  Future<void> _cancelNotifications() async {
    for (var i = 0; i < pendingNotificationRequests.length; i++) {
      await flutterLocalNotificationsPlugin.cancel(i);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: currentDate,
        firstDate: DateTime(2015),
        lastDate: DateTime(2050));
    if (pickedDate != null && pickedDate != currentDate) {
      setState(() {
        currentDate = pickedDate;
      });
    }
  }

  _selectTime(BuildContext context) async {
    final TimeOfDay? timeOfDay = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      initialEntryMode: TimePickerEntryMode.dial,
    );
    if (timeOfDay != null && timeOfDay != selectedTime) {
      setState(() {
        selectedTime = timeOfDay;
      });
    }
  }

  Scaffold buildReminderForm() {
    MaterialLocalizations localizations = MaterialLocalizations.of(context);
    final formattedTimeOfDay = localizations.formatTimeOfDay(selectedTime);
    String formattedDate = DateFormat('dd-MM-yyyy').format(currentDate);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        actions: <Widget>[
          TextButton.icon(
            icon: const Icon(
              Icons.arrow_back,
              color: Color.fromARGB(255, 81, 212, 212),
            ),
            label: const Text('Salir',
                style: TextStyle(
                  color: Color.fromARGB(255, 81, 212, 212),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                )),
            onPressed: () => Navigator.pop(context),
          )
        ],
        backgroundColor: Colors.white,
        title: const Text(
          "Mi recordatorio",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: isLoading
          ? circularProgress()
          : SingleChildScrollView(
              child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Padding(
                        padding:
                            EdgeInsets.only(top: 50.0, right: 20.0, left: 20.0),
                        child: AutoSizeText(
                          "Tipo de recordatorio *",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: DropdownButton2(
                          style: const TextStyle(
                              color: Colors.black, fontSize: 16),
                          iconEnabledColor:
                              const Color.fromARGB(255, 81, 212, 212),
                          isExpanded: true,
                          value: typeValue,
                          icon: const Icon(Icons.arrow_drop_down_circle),
                          dropdownElevation: 16,
                          dropdownMaxHeight: 300,
                          underline: Container(
                            height: 2,
                            color: Colors.grey,
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              typeValue = newValue!;
                            });
                          },
                          items: <String>[
                            'Baño',
                            'Vacuna',
                            'Comprar comida',
                            'Revisión veterinario',
                            'Medicación',
                            'Limpiar',
                            'Cepillar',
                            'Dar paseo',
                            'Jugar',
                            'Peluquería',
                            'Otro',
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: AutoSizeText(value),
                            );
                          }).toList(),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(
                            top: 50.0, bottom: 10.0, right: 20.0, left: 20.0),
                        child: AutoSizeText(
                          "Añade una breve descripción",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(20.0),
                          labelText: 'Descripción',
                        ),
                        controller: descriptionController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            descriptionController.text = "";
                          } else if (value.length > 120) {
                            return 'Longitud máxima 120 caracteres';
                          }
                          return null;
                        },
                      ),
                      const Padding(
                        padding:
                            EdgeInsets.only(top: 50.0, right: 20.0, left: 20.0),
                        child: AutoSizeText(
                          "Tipo de recordatorio *",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: DropdownButton2(
                          style: const TextStyle(
                              color: Colors.black, fontSize: 16),
                          iconEnabledColor:
                              const Color.fromARGB(255, 81, 212, 212),
                          isExpanded: true,
                          value: typeReminder,
                          icon: const Icon(Icons.arrow_drop_down_circle),
                          dropdownElevation: 16,
                          dropdownMaxHeight: 300,
                          underline: Container(
                            height: 2,
                            color: Colors.grey,
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              typeReminder = newValue!;
                            });
                          },
                          items: <String>[
                            'Recordatorio único',
                            'Recordatorio programado',
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: AutoSizeText(value),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      if (typeReminder == "Recordatorio único")
                        Text(formattedTimeOfDay),
                      if (typeReminder == "Recordatorio único")
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: const Color.fromARGB(255, 81, 212, 212),
                          ),
                          onPressed: () {
                            _selectTime(context);
                          },
                          child: const Text("Selecciona la hora"),
                        ),
                      if (typeReminder == "Recordatorio único")
                        Text(formattedDate),
                      if (typeReminder == "Recordatorio único")
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: const Color.fromARGB(255, 81, 212, 212),
                          ),
                          onPressed: () {
                            _selectDate(context);
                          },
                          child: const Text('Selecciona la fecha'),
                        ),
                      if (typeReminder == "Recordatorio único")
                        const SizedBox(
                          height: 50,
                        ),
                      if (typeReminder == "Recordatorio programado")
                        const Padding(
                          padding: EdgeInsets.only(
                              top: 0.0, right: 20.0, left: 20.0),
                          child: AutoSizeText(
                            "Frecuencia *",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      if (typeReminder == "Recordatorio programado")
                        Container(
                          padding: const EdgeInsets.all(20),
                          child: DropdownButton2(
                            style: const TextStyle(
                                color: Colors.black, fontSize: 16),
                            iconEnabledColor:
                                const Color.fromARGB(255, 81, 212, 212),
                            isExpanded: true,
                            value: typeProgrammingReminder,
                            icon: const Icon(Icons.arrow_drop_down_circle),
                            dropdownElevation: 16,
                            dropdownMaxHeight: 300,
                            underline: Container(
                              height: 2,
                              color: Colors.grey,
                            ),
                            onChanged: (String? newValue) {
                              setState(() {
                                typeProgrammingReminder = newValue!;
                              });
                            },
                            items: <String>[
                              'Diario',
                              'Semanal',
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: AutoSizeText(value),
                              );
                            }).toList(),
                          ),
                        ),
                      if (typeProgrammingReminder == "Semanal")
                        const Padding(
                          padding: EdgeInsets.only(
                              top: 0.0, right: 20.0, left: 20.0),
                          child: AutoSizeText(
                            "Día de la semana *",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      if (typeProgrammingReminder == "Semanal")
                        Container(
                          padding: const EdgeInsets.all(20),
                          child: DropdownButton2(
                            style: const TextStyle(
                                color: Colors.black, fontSize: 16),
                            iconEnabledColor:
                                const Color.fromARGB(255, 81, 212, 212),
                            isExpanded: true,
                            value: dayOfWeek,
                            icon: const Icon(Icons.arrow_drop_down_circle),
                            dropdownElevation: 16,
                            dropdownMaxHeight: 300,
                            underline: Container(
                              height: 2,
                              color: Colors.grey,
                            ),
                            onChanged: (String? newValue) {
                              setState(() {
                                dayOfWeek = newValue!;
                              });
                            },
                            items: <String>[
                              'Lunes',
                              'Martes',
                              'Miércoles',
                              'Jueves',
                              'Sábado',
                              'Domingo'
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: AutoSizeText(value),
                              );
                            }).toList(),
                          ),
                        ),
                      if (typeReminder == "Recordatorio programado")
                        Text(formattedTimeOfDay),
                      if (typeReminder == "Recordatorio programado")
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: const Color.fromARGB(255, 81, 212, 212),
                          ),
                          onPressed: () {
                            _selectTime(context);
                          },
                          child: const Text("Selecciona la hora"),
                        ),
                      if (typeProgrammingReminder == "Semanal" ||
                          typeProgrammingReminder == 'Diario')

                        //////////////
                        /*if (typeProgrammingReminder == "Mensual")
                        Text(formattedDate),
                      if (typeProgrammingReminder == "Mensual")
                        ElevatedButton(
                          onPressed: () {
                            _selectDate(context);
                          },
                          child: const Text('Selecciona la fecha'),
                        ),
                      if (typeProgrammingReminder == "Mensual")*/

                        /*if (typeProgrammingReminder == "Mensual")
                        const Padding(
                          padding: EdgeInsets.only(
                              top: 0.0, right: 20.0, left: 20.0),
                          child: AutoSizeText(
                            "Mes *",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      if (typeProgrammingReminder == "Mensual")
                        Container(
                          padding: const EdgeInsets.all(20),
                          child: DropdownButton2(
                            style: const TextStyle(
                                color: Colors.black, fontSize: 16),
                            iconEnabledColor: const Color.fromARGB(255, 81, 212, 212),
                            isExpanded: true,
                            value: monthValue,
                            icon: const Icon(Icons.arrow_drop_down_circle),
                            dropdownElevation: 16,
                            dropdownMaxHeight: 300,
                            underline: Container(
                              height: 2,
                              color: Colors.grey,
                            ),
                            onChanged: (String? newValue) {
                              setState(() {
                                monthValue = newValue!;
                              });
                            },
                            items: <String>[
                              'Enero',
                              'Febero',
                              'Marzo',
                              'Abril',
                              'Mayo',
                              'Junio',
                              'Julio',
                              'Agosto',
                              'Septiembre',
                              'Octubre',
                              'Noviembre',
                              'Diciembre'
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: AutoSizeText(value),
                              );
                            }).toList(),
                          ),
                        ),*/
                        /////////////

                        if (typeReminder == "Recordatorio programado")
                          const SizedBox(
                            height: 50,
                          ),
                      SizedBox(
                        height: 50,
                        width: 200,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: const Color.fromARGB(255, 81, 212, 212),
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              addReminder();

                              Navigator.pop(context);
                            }
                          },
                          child: const Text(
                            'Añadir',
                            style: TextStyle(
                              fontSize: 20.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                    ],
                  )),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildReminderForm();
  }
}
