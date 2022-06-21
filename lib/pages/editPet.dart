import 'package:cached_network_image/cached_network_image.dart';
import 'package:carepetsapp/models/pet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import "package:flutter/material.dart";
import 'package:carepetsapp/pages/home.dart';
import 'package:carepetsapp/widgets/progress.dart';
import 'package:flutter/services.dart';

class EditPet extends StatefulWidget {
  final String petId;

  const EditPet({required this.petId});

  @override
  _EditPetState createState() => _EditPetState();
}

class _EditPetState extends State<EditPet> {
  //Variables
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  String genderValue = '';
  String typeValue = '';
  String sterilizedValue = '';
  String vaccinatedValue = '';
  String mediaUrl = "";
  String patronNombre =
      r'(^[a-zA-ZÀ-ÿ\u00f1\u00d1]+(\s*[a-zA-ZÀ-ÿ\u00f1\u00d1]*)*[a-zA-ZÀ-ÿ\u00f1\u00d1]*$)';

  bool isLoading = false;
  bool sterilized = false;
  bool vaccinated = false;

  Pet? petResult;

  TextEditingController namePetController = TextEditingController();
  TextEditingController agePetController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController numberChipController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getPet();
  }

  getPet() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await myPetsRef.doc(widget.petId).get();
    petResult = Pet.fromDocument(doc);
    mediaUrl = petResult!.mediaUrl;
    namePetController.text = petResult!.name;
    agePetController.text = petResult!.age.toString();
    descriptionController.text = petResult!.description;
    genderValue = petResult!.gender;
    typeValue = petResult!.type;
    numberChipController.text = petResult!.numberChip;

    if (petResult!.sterilized == true) {
      sterilizedValue = "Si";
    } else {
      sterilizedValue = "No";
    }
    if (petResult!.vaccinated == true) {
      vaccinatedValue = "Si";
    } else {
      vaccinatedValue = "No";
    }

    setState(() {
      isLoading = false;
    });
  }

  updatePet(userId) {
    if (sterilizedValue == "Si") {
      sterilized = true;
    } else {
      sterilized = false;
    }
    if (vaccinatedValue == "Si") {
      vaccinated = true;
    } else {
      vaccinated = false;
    }

    setState(() {
      myPetsRef.doc(petResult!.id).update({
        "name": namePetController.text,
        "mediaUrl": mediaUrl,
        "ownerId": currentUser!.id,
        "gender": genderValue,
        "age": int.parse(agePetController.text),
        "type": typeValue,
        "sterilized": sterilized,
        "vaccinated": vaccinated,
        "description": descriptionController.text,
        "numberChip": numberChipController.text,
        "id": petResult!.id,
      });

      namePetController.clear();
      agePetController.clear();
      descriptionController.clear();
      numberChipController.clear();
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Mascota actualizada")));
  }

  deletePet(BuildContext parentContext) async {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: const Text("¿Desea borrar la mascota?"),
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
    myPetsRef.doc(petResult!.id).get().then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    RegExp regExpNombre = RegExp(patronNombre);

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
          "Editar mascota",
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        color: const Color.fromARGB(255, 216, 244, 241)
                            .withOpacity(0.4),
                        padding: const EdgeInsets.all(20.0),
                        child: Center(
                          child: AspectRatio(
                            aspectRatio: 180 / 190,
                            child: CachedNetworkImage(
                                imageUrl: petResult!.mediaUrl,
                                fit: BoxFit.cover),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(
                            top: 30.0, bottom: 10.0, right: 20.0, left: 20.0),
                        child: Text(
                          "Datos de tu mascota",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Nombre *',
                          contentPadding: EdgeInsets.all(20.0),
                        ),
                        controller: namePetController,
                        keyboardType: TextInputType.name,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Añade el nombre de tu mascota';
                          } else if (!regExpNombre.hasMatch(value)) {
                            return "Nómbre erróneo (a-Z)";
                          } else if (value.length > 20) {
                            return "El nombre es demasiado largo";
                          }
                          return null;
                        },
                      ),
                      const Padding(
                        padding:
                            EdgeInsets.only(top: 10.0, right: 20.0, left: 20.0),
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Edad *',
                          contentPadding: EdgeInsets.all(20.0),
                        ),
                        controller: agePetController,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Añade la edad de tu mascota';
                          } else if (value.length > 3) {
                            return 'Escribe una edad válida (1-100)';
                          }
                          return null;
                        },
                      ),
                      const Padding(
                        padding: EdgeInsets.only(
                            top: 50.0, bottom: 10.0, right: 20.0, left: 20.0),
                        child: Text(
                          "Otros datos",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Padding(
                        padding:
                            EdgeInsets.only(top: 50.0, right: 20.0, left: 20.0),
                        child: Text(
                          "Tipo de mascota *",
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
                            'Perro',
                            'Gato',
                            'Conejo',
                            'Hamster',
                            'Hurón',
                            'Cobaya',
                            'Chinchilla',
                            'Pájaro',
                            'Pez',
                            'Tortuga',
                            'Erizo',
                            'Caballo',
                            'Otro',
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                      const Padding(
                        padding:
                            EdgeInsets.only(top: 10.0, right: 20.0, left: 20.0),
                        child: Text(
                          "Sexo *",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: DropdownButton(
                          style: const TextStyle(
                              color: Colors.black, fontSize: 16),
                          iconEnabledColor:
                              const Color.fromARGB(255, 81, 212, 212),
                          isExpanded: true,
                          value: genderValue,
                          icon: const Icon(Icons.arrow_drop_down_circle),
                          elevation: 16,
                          underline: Container(
                            height: 2,
                            color: Colors.grey,
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              genderValue = newValue!;
                            });
                          },
                          items: <String>[
                            'Macho',
                            'Hembra',
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                      const Padding(
                        padding:
                            EdgeInsets.only(top: 10.0, right: 20.0, left: 20.0),
                        child: Text(
                          "¿Está tu mascota esterilizada? *",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: DropdownButton(
                          style: const TextStyle(
                              color: Colors.black, fontSize: 16),
                          iconEnabledColor:
                              const Color.fromARGB(255, 81, 212, 212),
                          isExpanded: true,
                          value: sterilizedValue,
                          icon: const Icon(Icons.arrow_drop_down_circle),
                          elevation: 16,
                          underline: Container(
                            height: 2,
                            color: Colors.grey,
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              sterilizedValue = newValue!;
                            });
                          },
                          items: <String>[
                            'Si',
                            'No',
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                      const Padding(
                        padding:
                            EdgeInsets.only(top: 10.0, right: 20.0, left: 20.0),
                        child: Text(
                          "¿Está tu mascota vacunada? *",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: DropdownButton(
                          style: const TextStyle(
                              color: Colors.black, fontSize: 16),
                          iconEnabledColor:
                              const Color.fromARGB(255, 81, 212, 212),
                          isExpanded: true,
                          value: vaccinatedValue,
                          icon: const Icon(Icons.arrow_drop_down_circle),
                          elevation: 16,
                          underline: Container(
                            height: 2,
                            color: Colors.grey,
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              vaccinatedValue = newValue!;
                            });
                          },
                          items: <String>[
                            'Si',
                            'No',
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 10.0),
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(20.0),
                          labelText: 'Número de chip',
                        ),
                        controller: numberChipController,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            numberChipController.text = "No conocido";
                          } else if (value.length > 25) {
                            return 'Longitud máxima 25 números';
                          }
                          return null;
                        },
                      ),
                      const Padding(
                        padding: EdgeInsets.only(
                            top: 50.0, bottom: 10.0, right: 20.0, left: 20.0),
                        child: Text(
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
                      const SizedBox(height: 50, width: 200),
                      SizedBox(
                        height: 50,
                        width: 200,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: const Color.fromARGB(255, 81, 212, 212),
                          ),
                          onPressed: () {
                            // Validate returns true if the form is valid, or false otherwise.
                            if (_formKey.currentState!.validate()) {
                              updatePet(currentUser!.id);
                              Navigator.pop(context);
                              // If the form is valid, display a snackbar. In the real world,
                              // you'd often call a server or save the information in a database.
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Mascota actualizada')),
                              );
                            }
                          },
                          child: const Text(
                            'Actualizar',
                            style: TextStyle(
                              fontSize: 20.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        height: 50,
                        width: 200,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: const Color.fromARGB(255, 176, 39, 39),
                          ),
                          onPressed: () {
                            // Validate returns true if the form is valid, or false otherwise.
                            if (_formKey.currentState!.validate()) {
                              deletePet(context);

                              // If the form is valid, display a snackbar. In the real world,
                              // you'd often call a server or save the information in a database.
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Mascota eliminada')),
                              );
                            }
                          },
                          child: const Text(
                            'Eliminar mascota',
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
}
