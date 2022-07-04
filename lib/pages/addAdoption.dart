import 'package:auto_size_text/auto_size_text.dart';
import "package:flutter/material.dart";
import "package:carepetsapp/pages/home.dart";
import "package:carepetsapp/widgets/progress.dart";
import "package:flutter/services.dart";
import "package:geocoding/geocoding.dart";
import "package:geolocator/geolocator.dart";
import "package:image_picker/image_picker.dart";
import "package:path_provider/path_provider.dart";
import "package:uuid/uuid.dart";
import "dart:io";
import "package:dropdown_button2/dropdown_button2.dart";
import 'package:image/image.dart' as Im;

class AddAdoption extends StatefulWidget {
  @override
  _AddAdoptionState createState() => _AddAdoptionState();
}

class _AddAdoptionState extends State<AddAdoption> {
  //Variables
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final imagePicker = ImagePicker();

  File? file;

  bool isUploading = false;
  bool sterilized = false;
  bool vaccinated = false;
  bool isLoading = false;
  bool _isLoading = true;

  String postId = const Uuid().v4();
  String mediaUrlAdoption = "";
  String genderValue = "Macho";
  String typeValue = "Perro";
  String provinceValue = "A Coruña";
  String sterilizedValue = "Si";
  String vaccinatedValue = "Si";
  String adoptionId = const Uuid().v4();
  String patronCorreo =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  String patronNombre =
      r'(^[a-zA-ZÀ-ÿ\u00f1\u00d1]+(\s*[a-zA-ZÀ-ÿ\u00f1\u00d1]*)*[a-zA-ZÀ-ÿ\u00f1\u00d1]*$)';

  TextEditingController captionController = TextEditingController();
  TextEditingController namePetController = TextEditingController();
  TextEditingController agePetController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController numberPhoneController = TextEditingController();
  TextEditingController petBreedController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getImageFileFromAssets();
  }

  getImageFileFromAssets() async {
    final byteData = await rootBundle.load('assets/images/photo.png');

    String tempPath = (await getTemporaryDirectory()).path;
    setState(() {
      _isLoading = false;
      file = File('$tempPath/photo.png');
    });

    await file!.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
  }

  handleSubmit() async {
    setState(() {
      isUploading = true;
    });
    await compressImage();
    if (file != null) {
      String mediaUrl = await uploadImage(file);
      addPet(
        mediaUrl: mediaUrl,
      );
    } else {
      addPet(
          mediaUrl:
              "https://firebasestorage.googleapis.com/v0/b/carepetsapp-511b4.appspot.com/o/without_photo.png?alt=media&token=a8f57435-0e9b-4173-88d3-cef273c651fd");
    }

    if (mounted) {
      setState(() {
        file = null;
        isUploading = false;
        postId = const Uuid().v4();
      });
    }
  }

  addPet({required String mediaUrl}) async {
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
    if (numberPhoneController.text == "") {
      numberPhoneController.text = "0";
    }
    adoptionsRef.doc(adoptionId).set({
      "name": namePetController.text,
      "mediaUrl": mediaUrl,
      "ownerId": currentUser!.id,
      "gender": genderValue,
      "age": int.parse(agePetController.text),
      "email": emailController.text,
      "numberPhone": int.parse(numberPhoneController.text),
      "type": typeValue,
      "province": provinceValue,
      "petBreed": petBreedController.text,
      "sterilized": sterilized,
      "vaccinated": vaccinated,
      "location": locationController.text,
      "description": descriptionController.text,
      "id": adoptionId,
      "timeStamp": DateTime.now(),
    });

    captionController.clear();
    namePetController.clear();
    agePetController.clear();
    emailController.clear();
    numberPhoneController.clear();
    petBreedController.clear();
    locationController.clear();
    descriptionController.clear();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Mascota en adopción añadida")));
    }
  }

  getUserLocation() async {
    LocationPermission permission =
        await Geolocator.requestPermission(); //solicitar permiso app
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return Future.error("Location Not Available");
      }
    } else {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark placemark = placemarks[0];
      String formattedAddress = "${placemark.locality}, ${placemark.country}";
      locationController.text = formattedAddress;
    }
  }

  handleTakePhoto() async {
    Navigator.pop(context);
    final picked = await imagePicker.getImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() {
        file = File(picked.path);
      });
    }
  }

  handleChooseFromGallery() async {
    Navigator.pop(context);
    final picked = await imagePicker.getImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        file = File(picked.path);
      });
    }
  }

  selectImage(parentContext) {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: const Text("Subir una imagen"),
            children: <Widget>[
              SimpleDialogOption(
                child: const Text("Cámara"),
                onPressed: handleTakePhoto,
              ),
              SimpleDialogOption(
                child: const Text("Galería"),
                onPressed: handleChooseFromGallery,
              ),
              SimpleDialogOption(
                child: const Text("Cancelar"),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        });
  }

  clearImage() {
    setState(() {
      file = null;
    });
  }

  Future<String> uploadImage(imageFile) async {
    await storageRef.ref("post_$postId.jpg").putFile(imageFile);
    String downloadURL =
        await storageRef.ref("post_$postId.jpg").getDownloadURL();
    return downloadURL;
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image? imageFile = Im.decodeImage(file!.readAsBytesSync().toList());
    final compressedImageFile = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile!, quality: 85));
    setState(() {
      file = compressedImageFile;
    });
  }

  Scaffold buildAdoptFormScreen() {
    RegExp regExpCorreo = RegExp(patronCorreo);
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
            label: const Text("Salir",
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
                      const SizedBox(
                        height: 20,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          if (_isLoading == false)
                            GestureDetector(
                                child: CircleAvatar(
                                  radius: 130.0,
                                  backgroundImage: FileImage(file!),
                                ),
                                onTap: () => selectImage(context)),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.only(
                            top: 30.0, bottom: 10.0, right: 20.0, left: 20.0),
                        child: AutoSizeText(
                          "Datos de tu mascota",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Nombre *",
                          contentPadding: EdgeInsets.all(20.0),
                        ),
                        controller: namePetController,
                        keyboardType: TextInputType.name,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Añade el nombre de tu mascota";
                          } else if (!regExpNombre.hasMatch(value)) {
                            return "Nómbre erróneo (a-Z)";
                          } else if (value.length > 20) {
                            return "El nombre es demasiado largo";
                          } else {
                            return null;
                          }
                        },
                      ),
                      const Padding(
                        padding:
                            EdgeInsets.only(top: 10.0, right: 20.0, left: 20.0),
                      ),
                      TextFormField(
                          decoration: const InputDecoration(
                            labelText: "Edad *",
                            contentPadding: EdgeInsets.all(20.0),
                          ),
                          controller: agePetController,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Añade la edad de tu mascota";
                            } else if (value.length > 3) {
                              return "Escribe una edad válida (1-100)";
                            } else {
                              return null;
                            }
                          }),
                      const Padding(
                        padding:
                            EdgeInsets.only(top: 10.0, right: 20.0, left: 20.0),
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(20.0),
                          labelText: "Raza",
                        ),
                        controller: petBreedController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            petBreedController.text = "No especificada";
                          } else if (!regExpNombre.hasMatch(value)) {
                            return "Raza errónea (a-Z)";
                          } else if (value.length > 20) {
                            return "El nombre de la raza es demasiado largo";
                          } else {
                            return null;
                          }
                        },
                      ),
                      const Padding(
                        padding: EdgeInsets.only(
                            top: 50.0, bottom: 10.0, right: 20.0, left: 20.0),
                        child: AutoSizeText(
                          "Otros datos",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Padding(
                        padding:
                            EdgeInsets.only(top: 50.0, right: 20.0, left: 20.0),
                        child: AutoSizeText(
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
                            "Perro",
                            "Gato",
                            "Conejo",
                            "Hamster",
                            "Hurón",
                            "Cobaya",
                            "Chinchilla",
                            "Pájaro",
                            "Pez",
                            "Tortuga",
                            "Erizo",
                            "Caballo",
                            "Otro",
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: AutoSizeText(value),
                            );
                          }).toList(),
                        ),
                      ),
                      const Padding(
                        padding:
                            EdgeInsets.only(top: 10.0, right: 20.0, left: 20.0),
                        child: AutoSizeText(
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
                            "Macho",
                            "Hembra",
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: AutoSizeText(value),
                            );
                          }).toList(),
                        ),
                      ),
                      const Padding(
                        padding:
                            EdgeInsets.only(top: 10.0, right: 20.0, left: 20.0),
                        child: AutoSizeText(
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
                            "Si",
                            "No",
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: AutoSizeText(value),
                            );
                          }).toList(),
                        ),
                      ),
                      const Padding(
                        padding:
                            EdgeInsets.only(top: 10.0, right: 20.0, left: 20.0),
                        child: AutoSizeText(
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
                            "Si",
                            "No",
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: AutoSizeText(value),
                            );
                          }).toList(),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 10.0),
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
                          labelText: "Descripción",
                        ),
                        controller: descriptionController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            descriptionController.text = "";
                          } else if (value.length > 120) {
                            return "Longitud máxima 120 caracteres";
                          } else {
                            return null;
                          }
                        },
                      ),
                      const Padding(
                        padding: EdgeInsets.only(
                            top: 50.0, bottom: 10.0, right: 20.0, left: 20.0),
                        child: AutoSizeText(
                          "Datos de contacto",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(20.0),
                          labelText: "Email *",
                        ),
                        controller: emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Escribe un correo de contacto";
                          } else if (!regExpCorreo.hasMatch(value)) {
                            return "Correo inválido (XXX@XXX.XXX)";
                          } else {
                            return null;
                          }
                        },
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 10.0),
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(20.0),
                          labelText: "Número de teléfono",
                        ),
                        controller: numberPhoneController,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (numberPhoneController.text == "0") {
                            numberPhoneController.text = "";
                          }

                          if (value == null || value.isEmpty) {
                            numberPhoneController.text = "";
                          } else if (value.length != 9) {
                            return "Teléfono inválido (9 números)";
                          } else {
                            return null;
                          }
                        },
                      ),
                      const Padding(
                        padding:
                            EdgeInsets.only(top: 50.0, right: 20.0, left: 20.0),
                        child: AutoSizeText(
                          "Provincia *",
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
                          value: provinceValue,
                          icon: const Icon(Icons.arrow_drop_down_circle),
                          dropdownElevation: 16,
                          dropdownMaxHeight: 300,
                          underline: Container(
                            height: 2,
                            color: Colors.grey,
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              provinceValue = newValue!;
                            });
                          },
                          items: <String>[
                            "A Coruña",
                            "Alava",
                            "Albacete",
                            "Alicante",
                            "Almería",
                            "Asturias",
                            "Avila",
                            "Badajoz",
                            "Barcelona",
                            "Burgos",
                            "Cáceres",
                            "Cádiz",
                            "Cantabria",
                            "Castellón",
                            "Ceuta",
                            "Ciudad Real",
                            "Córdoba",
                            "Cuenca",
                            "Formentera",
                            "Girona",
                            "Granada",
                            "Guadalajara",
                            "Guipuzcoa",
                            "Huelva",
                            "Huesca",
                            "Ibiza",
                            "Jaén",
                            "La Rioja",
                            "León",
                            "Lérida",
                            "Lugo",
                            "Madrid",
                            "Málaga",
                            "Mallorca",
                            "Menorca",
                            "Murcia",
                            "Navarra",
                            "Orense",
                            "Palencia",
                            "Pontevedra",
                            "Salamanca",
                            "Segovia",
                            "Sevilla",
                            "Soria",
                            "Tarragona",
                            "Teruel",
                            "Toledo",
                            "Valencia",
                            "Valladolid",
                            "Vizcaya",
                            "Zamora",
                            "Zaragoza",
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: AutoSizeText(value),
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
                          labelText: "Localización *",
                        ),
                        controller: locationController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Localización mascota";
                          } else {
                            return null;
                          }
                        },
                      ),
                      Container(
                        height: 150.0,
                        alignment: Alignment.center,
                        child: RaisedButton.icon(
                          label: const Text(
                            "Buscar ubicación",
                            style: TextStyle(color: Colors.white),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          color: const Color.fromARGB(255, 81, 212, 212),
                          onPressed: getUserLocation,
                          icon: const Icon(
                            Icons.my_location,
                            color: Colors.white,
                          ),
                        ),
                      ),
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
                              handleSubmit();
                              Navigator.pop(context);
                              // If the form is valid, display a snackbar. In the real world,
                              // you"d often call a server or save the information in a database.
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Mascota añadida")),
                              );
                            }
                          },
                          child: const Text(
                            "Dar en adopción",
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
    return buildAdoptFormScreen();
  }
}
