import 'package:carepetsapp/models/adoption.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:carepetsapp/pages/home.dart';
import 'package:carepetsapp/widgets/progress.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

class ViewAdoption extends StatefulWidget {
  final String adoptionId;

  const ViewAdoption({required this.adoptionId});

  @override
  _ViewAdoptionState createState() => _ViewAdoptionState();
}

class _ViewAdoptionState extends State<ViewAdoption> {
  //Variables
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool isLoading = false;
  bool description = false;

  String sterilizedValue = '';
  String vaccinatedValue = '';

  Adoption? adoptionResult;

  @override
  void initState() {
    super.initState();
    getPet();
  }

  getPet() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await adoptionsRef.doc(widget.adoptionId).get();
    adoptionResult = Adoption.fromDocument(doc);

    if (adoptionResult!.description != "") {
      description = true;
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (adoptionResult?.sterilized == true) {
      sterilizedValue = "Si";
    } else {
      sterilizedValue = "No";
    }
    if (adoptionResult?.vaccinated == true) {
      vaccinatedValue = "Si";
    } else {
      vaccinatedValue = "No";
    }
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
          "Mascota en adopción",
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
                      Container(
                        color: const Color.fromARGB(255, 216, 244, 241)
                            .withOpacity(0.4),
                        padding: const EdgeInsets.all(20.0),
                        child: Center(
                          child: AspectRatio(
                            aspectRatio: 180 / 190,
                            child: Image.network(
                              adoptionResult!.mediaUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        color: const Color.fromARGB(255, 216, 244, 241)
                            .withOpacity(0.4),
                        child: Column(children: [
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              "Hola, me llamo " + adoptionResult!.name,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(
                                top: 30.0,
                                bottom: 10.0,
                                right: 20.0,
                                left: 20.0),
                            child: Text(
                              "Datos de la mascota",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text.rich(
                                TextSpan(
                                  text: "Edad: " +
                                      adoptionResult!.age.toString() +
                                      "\n\n"
                                          "Raza: " +
                                      adoptionResult!.petBreed,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 18.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (adoptionResult!.gender == "Macho")
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text.rich(
                                  TextSpan(
                                    text: "Sexo: " + adoptionResult!.gender,
                                    children: const [
                                      WidgetSpan(
                                        child: Icon(
                                          Icons.male,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ],
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          if (adoptionResult!.gender == "Hembra")
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text.rich(
                                  TextSpan(
                                    text: "Sexo: " + adoptionResult!.gender,
                                    children: const [
                                      WidgetSpan(
                                        child: Icon(
                                          Icons.female,
                                          color: Colors.pink,
                                        ),
                                      ),
                                    ],
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          const Divider(),
                          if (description)
                            const Padding(
                              padding: EdgeInsets.only(
                                  top: 30.0,
                                  bottom: 10.0,
                                  right: 20.0,
                                  left: 20.0),
                              child: Text(
                                "Descripción",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          if (description)
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                adoptionResult!.description + "\n\n",
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 18.0,
                                ),
                              ),
                            ),
                          if (description) const Divider(),
                          const Padding(
                            padding: EdgeInsets.only(
                                top: 30.0,
                                bottom: 10.0,
                                right: 20.0,
                                left: 20.0),
                            child: Text(
                              "Otros datos",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Esterilizado/a: " +
                                    sterilizedValue +
                                    "\n\n"
                                        "Vacunado/a: " +
                                    vaccinatedValue +
                                    "\n",
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 18.0,
                                ),
                              ),
                            ),
                          ),
                          const Divider(),
                          const Padding(
                            padding: EdgeInsets.only(
                                top: 30.0,
                                bottom: 10.0,
                                right: 20.0,
                                left: 20.0),
                            child: Text(
                              "Datos de contacto",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Align(
                              child: Text(
                                "Localización: " +
                                    adoptionResult!.location +
                                    "\n\n",
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 18.0,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 50, //height of button
                            width: 200,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary:
                                    const Color.fromARGB(255, 81, 212, 212),
                              ),
                              child: const Text('Enviar correo'),
                              onPressed: () async {
                                EmailContent email = EmailContent(
                                  to: [
                                    adoptionResult!.email,
                                  ],
                                  subject: 'CarePetsApp: Adopción ' +
                                      adoptionResult!.name,
                                  body: 'Hola, \n\n me gustaría adoptar a ' +
                                      adoptionResult!.name,
                                );

                                OpenMailAppResult result =
                                    await OpenMailApp.composeNewEmailInMailApp(
                                        nativePickerTitle:
                                            'Selecciona la aplicación de correo',
                                        emailContent: email);
                                if (!result.didOpen && !result.canOpen) {
                                  showNoMailAppsDialog(context);
                                } else if (!result.didOpen && result.canOpen) {
                                  showDialog(
                                    context: context,
                                    builder: (_) => MailAppPickerDialog(
                                      mailApps: result.options,
                                      emailContent: email,
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          if (adoptionResult!.numberPhone != 0)
                            SizedBox(
                              height: 50, //height of button
                              width: 200,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary:
                                      const Color.fromARGB(255, 81, 212, 212),
                                ),
                                child: const Text("Llamar"),
                                onPressed: () async {
                                  FlutterPhoneDirectCaller.callNumber(
                                      adoptionResult!.numberPhone.toString());
                                },
                              ),
                            ),
                          const SizedBox(
                            height: 50,
                          ),
                        ]),
                      ),
                    ],
                  )),
            ),
    );
  }
}

void showNoMailAppsDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Abrir aplicación de correo"),
        content: const Text("No ninguna aplicación de correo instalada"),
        actions: <Widget>[
          TextButton(
            child: const Text("OK"),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      );
    },
  );
}
