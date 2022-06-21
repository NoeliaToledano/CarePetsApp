import 'package:flutter/material.dart';
import 'package:carepetsapp/pages/careMyPets.dart';
import 'package:carepetsapp/pages/lostPets.dart';
import 'package:carepetsapp/pages/tips.dart';
import 'package:carepetsapp/pages/adoptions.dart';
import 'package:carepetsapp/pages/home.dart';
import 'package:carepetsapp/pages/editProfile.dart';

ListView construirListView(BuildContext context, currentUser) {
  final temp = currentUser?.displayName.toString();
  return ListView(children: <Widget>[
    DrawerHeader(
        margin: const EdgeInsets.all(0.0),
        padding: const EdgeInsets.all(0.0),
        child: ListView(
          padding: const EdgeInsets.all(18.0),
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  "Bienvenid@ " + temp!,
                ),
              ],
            ),
            ListTile(
              contentPadding: const EdgeInsets.only(top: 8.0),
              title: const Text(
                "Editar Perfil",
                style: TextStyle(
                  color: const Color.fromARGB(255, 81, 212, 212),
                ),
              ),
              onTap: () => editProfile(context, currentUser),
            ),
            ListTile(
              contentPadding: const EdgeInsets.only(top: 0.0),
              title: const Text(
                "Cerrar sesión",
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: const Text(
                            "¿Estás seguro de que quieres cerrar sesión?"),
                        actions: <Widget>[
                          FlatButton(
                            child: const Text(
                              "No",
                              style: TextStyle(color: Colors.black),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          FlatButton(
                            child: const Text(
                              "Si",
                              style: TextStyle(color: Colors.red),
                            ),
                            onPressed: () => logoutUser(context, googleSignIn),
                          ),
                        ],
                      );
                    });
              },
            ),
          ],
        )),
    const SizedBox(
      height: 40,
    ),
    ListTile(
      leading: const Icon(Icons.group),
      title: const Text(
        "Red Social",
        style: TextStyle(fontSize: 17.0),
      ),
      onTap: () {
        Route ruta = MaterialPageRoute(builder: (context) => Home());
        Navigator.push(context, ruta);
      },
    ),

    ListTile(
      leading: const Icon(Icons.health_and_safety_rounded),
      contentPadding: const EdgeInsets.all(18.0),
      title: const Text(
        "Cuida de tu mascota",
        style: TextStyle(fontSize: 17.0),
      ),
      onTap: () {
        Route ruta = MaterialPageRoute(builder: (context) => CareMyPets());
        Navigator.push(context, ruta);
      },
    ),

    ListTile(
      leading: const Icon(Icons.search),
      title: const Text(
        "Animales perdidos",
        style: TextStyle(fontSize: 17.0),
      ),
      onTap: () {
        Route ruta = MaterialPageRoute(builder: (context) => LostPets());
        Navigator.push(context, ruta);
      },
    ),

    ListTile(
      leading: const Icon(Icons.pets),
      contentPadding: const EdgeInsets.all(18.0),
      title: const Text(
        "Adopciones",
        style: TextStyle(fontSize: 17.0),
      ),
      onTap: () {
        Route ruta = MaterialPageRoute(builder: (context) => Adoptions());
        Navigator.push(context, ruta);
      },
    ),

    ListTile(
      leading: const Icon(Icons.check),
      title: const Text(
        "Consejos",
        style: TextStyle(
          fontSize: 17.0,
        ),
      ),
      onTap: () {
        Route ruta = MaterialPageRoute(builder: (context) => Tips());
        Navigator.push(context, ruta);
      },
    ),

    //_construirItem(context, Icons.person, "Perfil", "/perfil"),
    //_construirItem(context, Icons.help, "Ayuda", "/ayuda"),
    /*AboutListTile(
        child: const Text("Información"),
        applicationIcon: const Icon(Icons.info),
        icon: const Icon(Icons.info),
        applicationName: "CarePetsApp",
        applicationVersion: "v1.0",
        aboutBoxChildren: <Widget>[
          Text("Desarrollado por Noelia Toledano Campos")
        ],
      ),*/
  ]);
}

editProfile(context, currentUser) {
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => EditProfile(currentUserId: currentUser!.id)));
}

logoutUser(context, googleSignIn) async {
  await googleSignIn.signOut();
  Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
}
