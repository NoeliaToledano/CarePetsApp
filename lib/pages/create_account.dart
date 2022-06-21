import 'dart:io';
import 'package:carepetsapp/models/user.dart';
import 'package:carepetsapp/pages/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:carepetsapp/widgets/headerTitle.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  //Variables
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formUserKey = GlobalKey<FormState>();
  final _formDisplayNameKey = GlobalKey<FormState>();
  final imagePicker = ImagePicker();
  String username = "";
  String displayName = "";
  String mediaUrl = "";
  String mediaId = const Uuid().v4();
  List<String> users = [];
  List<String> account = [];
  File? file;
  bool _isLoading = true;
  int _control = 0;
  String patronNombre =
      r'(^[a-zA-ZÀ-ÿ\u00f1\u00d1]+(\s*[a-zA-ZÀ-ÿ\u00f1\u00d1]*)*[a-zA-ZÀ-ÿ\u00f1\u00d1]*$)';
  @override
  void initState() {
    super.initState();
    getUserNames();
    getImageFileFromAssets();
  }

  getImageFileFromAssets() async {
    final byteData = await rootBundle.load('assets/images/photo.png');

    String tempPath = (await getTemporaryDirectory()).path;
    setState(() {
      _control = 1;
      _isLoading = false;
      file = File('$tempPath/photo.png');
    });

    await file!.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
  }

  submit() async {
    final formUserKey = _formUserKey.currentState;
    final formDisplayNameKey = _formDisplayNameKey.currentState;

    if (formUserKey!.validate() && formDisplayNameKey!.validate()) {
      //revisar
      formUserKey.save();
      formDisplayNameKey.save();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("¡Bienvenid@ $displayName!")));

      await compressImage();
      mediaUrl = await uploadImage(file);

      account.add(username);
      account.add(displayName);
      account.add(mediaUrl);

      Navigator.pop(context, account);
      //Navigator.pop(context, account);
    }
  }

  Future<String> uploadImage(imageFile) async {
    await storageRef.ref("post_$mediaId.jpg").putFile(imageFile);
    String downloadURL =
        await storageRef.ref("post_$mediaId.jpg").getDownloadURL();
    return downloadURL;
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    /*Im.Image? imageFile = Im.decodeImage(file?.readAsBytesSync().toList());
    final compressedImageFile = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile!, quality: 85));
    setState(() {
      file = compressedImageFile;
    });*/
  }

  getUserNames() async {
    QuerySnapshot snapshot = await usersRef.get();

    for (var doc in snapshot.docs) {
      User user = User.fromDocument(doc);
      users.add(user.username);
    }
  }

  handleTakePhoto() async {
    _control = 1;
    Navigator.pop(context);
    final picked = await imagePicker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() {
        file = File(picked.path);
      });
    }
  }

  handleChooseFromGallery() async {
    _control = 1;
    Navigator.pop(context);
    final picked = await imagePicker.pickImage(source: ImageSource.gallery);
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
            title: const Text('Subir una imagen'),
            children: <Widget>[
              SimpleDialogOption(
                child: const Text('Cámara'),
                onPressed: handleTakePhoto,
              ),
              SimpleDialogOption(
                child: const Text('Galería'),
                onPressed: handleChooseFromGallery,
              ),
              SimpleDialogOption(
                child: const Text('Cancelar'),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext parentContext) {
    RegExp regExpNombre = RegExp(patronNombre);

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: headerTitle(context, titleText: "Crea su perfil"),
        body: ListView(
          children: <Widget>[
            Column(
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.all(30.0),
                  child: Text(
                    "\"Tu mascota también necesita su propia app\"",
                    style: TextStyle(fontSize: 14.0),
                  ),
                ),
                Column(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            if (_isLoading == false)
                              GestureDetector(
                                  child: CircleAvatar(
                                    radius: 80.0,
                                    backgroundImage: FileImage(file!),
                                  ),
                                  onTap: () => selectImage(context)),
                          ],
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 30.0),
                      child: Center(
                        child: Text(
                          "Escribe el nombre completo de tu mascota",
                          style: TextStyle(fontSize: 15.0),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formUserKey,
                        autovalidateMode: AutovalidateMode.always,
                        child: TextFormField(
                          validator: (val) {
                            if (_control == 0) {
                              if (val!.trim().length < 3 || val.isEmpty) {
                                return "El nombre es muy corto";
                              } else if (!regExpNombre.hasMatch(val)) {
                                return "Nómbre erróneo (a-Z)";
                              } else if (val.trim().length > 15) {
                                return "El nombre es muy largo";
                              } else {
                                return null;
                              }
                            }
                          },
                          onSaved: (val) => displayName = val!,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.teal, width: 0.0),
                            ),
                            labelText: "Nombre",
                            labelStyle: TextStyle(fontSize: 15.0),
                            hintText: "Al menos tres caracteres",
                          ),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 15.0),
                      child: Center(
                        child: Text(
                          "Escribe el apodo de tu mascota",
                          style: TextStyle(fontSize: 15.0),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formDisplayNameKey,
                        autovalidateMode: AutovalidateMode.always,
                        child: TextFormField(
                          validator: (val) {
                            if (_control == 0) {
                              if (users.contains(val!.toLowerCase())) {
                                return "El nombre de usuario ya está existe";
                              }
                              if (val.trim().length < 3 || val.isEmpty) {
                                return "El nombre de usuario es muy corto";
                              } else if (val.contains(" ")) {
                                return "El nombre no puede contener espacios";
                              } else if (!regExpNombre.hasMatch(val)) {
                                return "Nómbre erróneo (a-Z)";
                              } else if (val.trim().length > 15) {
                                return "El nombre de usuario es muy largo";
                              } else {
                                return null;
                              }
                            } else {
                              _control = 0;
                            }
                          },
                          onSaved: (val) => username = val!,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.teal, width: 0.0),
                            ),
                            labelText: "Nombre de usuario",
                            labelStyle: TextStyle(fontSize: 15.0),
                            hintText: "Al menos tres caracteres",
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    GestureDetector(
                      onTap: submit,
                      child: Container(
                        height: 50.0,
                        width: 250.0,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 81, 212, 212),
                          borderRadius: BorderRadius.circular(7.0),
                        ),
                        child: const Center(
                          child: Text(
                            "Enviar",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
