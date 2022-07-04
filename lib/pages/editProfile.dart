import 'dart:io';
import 'dart:math';
import 'package:carepetsapp/pages/comments.dart';
import 'package:carepetsapp/pages/post.dart';
import 'package:http/http.dart' as http;
import "package:flutter/material.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carepetsapp/models/user.dart';
import 'package:carepetsapp/pages/home.dart';
import 'package:carepetsapp/widgets/progress.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:auto_size_text/auto_size_text.dart';

class EditProfile extends StatefulWidget {
  final String currentUserId;

  const EditProfile({required this.currentUserId});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  //Variables
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final imagePicker = ImagePicker();
  TextEditingController displayNameController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  String patronNombre =
      r'(^[a-zA-ZÀ-ÿ\u00f1\u00d1]+(\s*[a-zA-ZÀ-ÿ\u00f1\u00d1]*)*[a-zA-ZÀ-ÿ\u00f1\u00d1]*$)';
  bool isLoading = false;
  bool _displayNameValid = true;
  bool _bioValid = true;
  bool _userNameValid = true;
  bool _isLoading = true;
  File? file;
  User? user;
  String mediaUrl = "";
  String userName = "";
  String mediaId = const Uuid().v4();
  List<String> users = [];
  List<Post> posts = [];

  @override
  void initState() {
    super.initState();
    getUser();
    getUserNames();
  }

  getUserNames() async {
    QuerySnapshot snapshot = await usersRef.get();

    for (var doc in snapshot.docs) {
      User user = User.fromDocument(doc);
      users.add(user.username);
    }
  }

  getImageFileFromAssets() async {
    if (mediaUrl != "") {
      var rng = Random();

      Directory tempDir = await getTemporaryDirectory();

      String tempPath = tempDir.path;

      http.Response response = await http.get(Uri.parse(mediaUrl));

      setState(() {
        _isLoading = false;
        file = File('$tempPath' + (rng.nextInt(100)).toString() + '.png');
      });

      await file!.writeAsBytes(response.bodyBytes);
    } else {
      final byteData = await rootBundle.load('assets/images/photo.png');

      String tempPath = (await getTemporaryDirectory()).path;
      setState(() {
        _isLoading = false;
        file = File('$tempPath/profile.png');
      });

      await file!.writeAsBytes(byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    }
  }

  getUser() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await usersRef.doc(widget.currentUserId).get();
    user = User.fromDocument(doc);
    userName = user!.username;
    displayNameController.text = user!.displayName;
    userNameController.text = user!.username;
    bioController.text = user!.bio;
    mediaUrl = user!.photoUrl;
    getImageFileFromAssets();
    setState(() {
      isLoading = false;
    });
  }

  Column buildDisplayNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(
            padding: EdgeInsets.only(top: 12.0),
            child: AutoSizeText(
              "Nombre completo de tu mascota ",
              style: TextStyle(color: Colors.grey),
            )),
        TextField(
          controller: displayNameController,
          decoration: InputDecoration(
            hintText: "Actualizar nombre completo",
            errorText: _displayNameValid ? null : "Formato incorrecto",
          ),
        )
      ],
    );
  }

  Column buildUserNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(
            padding: EdgeInsets.only(top: 12.0),
            child: AutoSizeText(
              "Escribe el apodo de tu mascota",
              style: TextStyle(color: Colors.grey),
            )),
        TextField(
          controller: userNameController,
          decoration: InputDecoration(
            hintText: "Actualizar apodo",
            errorText: _userNameValid
                ? null
                : "El nombre de usuario ya está existe o formato incorrecto ",
          ),
        )
      ],
    );
  }

  Column buildBioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: AutoSizeText(
            "Biografía",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          controller: bioController,
          decoration: InputDecoration(
            hintText: "Actualizar Biografía",
            errorText: _bioValid ? null : "Biografía muy larga",
          ),
        )
      ],
    );
  }

  Future<String> uploadImage(imageFile) async {
    await storageRef.ref("post_$mediaId.jpg").putFile(imageFile);
    String downloadURL =
        await storageRef.ref("post_$mediaId.jpg").getDownloadURL();
    return downloadURL;
  }

  comments() async {
    QuerySnapshot snapshot = await usersRef.get();

    for (var u in snapshot.docs) {
      User user = User.fromDocument(u);

      QuerySnapshot snapshotPost =
          await postsRef.doc(user.id).collection("userPosts").get();

      for (var p in snapshotPost.docs) {
        Post post = Post.fromDocument(p);

        QuerySnapshot snapshotComments = await commentsRef
            .doc(post.postId)
            .collection("comments")
            .where("username", isEqualTo: userName)
            .get();
        for (var c in snapshotComments.docs) {
          Comment comment = Comment.fromDocument(c);

          commentsRef
              .doc(post.postId)
              .collection("comments")
              .doc(comment.commentId)
              .set({
            "username": userNameController.text.toLowerCase(),
            "comment": comment.comment,
            "timestamp": comment.timestamp,
            "avatarUrl": mediaUrl,
            "userId": comment.userId,
            "commentId": comment.commentId
          });
        }
      }
    }
  }

  /*notifications() async {
    QuerySnapshot snapshot = await usersRef.get();

    for (var us in snapshot.docs) {
      User user = User.fromDocument(us);

      QuerySnapshot snapshotNotifications = await activityFeedRef
          .doc(user.id)
          .collection("feedItems")
          .where("username", isEqualTo: userName)
          .get();

      for (var n in snapshotNotifications.docs) {
        ActivityFeedItem activityItem = ActivityFeedItem.fromDocument(n);
        print(activityItem.type);
        print(activityItem.username);
        activityFeedRef
            .doc(user.id)
            .collection("feedItems")
            .doc(activityItem.id)
            .set({
          "username": userNameController.text.toLowerCase(),
          "comment": comment.comment,
          "timestamp": comment.timestamp,
          "avatarUrl": mediaUrl,
          "userId": comment.userId,
          "commentId": comment.commentId
        });
      }
    }
  }*/

  publications() async {
    QuerySnapshot snapshot =
        await postsRef.doc(widget.currentUserId).collection("userPosts").get();

    for (var doc in snapshot.docs) {
      Post post = Post.fromDocument(doc);

      postsRef
          .doc(widget.currentUserId)
          .collection("userPosts")
          .doc(post.postId)
          .set({
        "postId": post.postId,
        "ownerId": post.ownerId,
        "username": userNameController.text.toLowerCase(),
        "mediaUrl": post.mediaUrl,
        "description": post.description,
        "location": post.location,
        "likes": post.likes,
        "timestamp": post.timestamp,
      });
    }
  }

  updateProfileData() async {
    RegExp regExpNombre = RegExp(patronNombre);
    mediaUrl = await uploadImage(file);
    setState(() {
      displayNameController.text.trim().length < 3 ||
              displayNameController.text.trim().length > 15 ||
              displayNameController.text.isEmpty ||
              !regExpNombre.hasMatch(displayNameController.text)
          ? _displayNameValid = false
          : _displayNameValid = true;
      userNameController.text.trim().length < 3 ||
              userNameController.text.trim().length > 15 ||
              userNameController.text.isEmpty ||
              (users.contains(userNameController.text.toLowerCase()) &&
                  userNameController.text != userName) ||
              userNameController.text.contains(" ") ||
              !regExpNombre.hasMatch(userNameController.text)
          ? _userNameValid = false
          : _userNameValid = true;
      bioController.text.trim().length > 50
          ? _bioValid = false
          : _bioValid = true;
    });

    if (_displayNameValid && _bioValid && _userNameValid) {
      comments();
      //notifications();
      publications();

      usersRef.doc(widget.currentUserId).update({
        "displayName": displayNameController.text,
        "bio": bioController.text,
        "username": userNameController.text.toLowerCase(),
        "photoUrl": mediaUrl,
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Perfil actualizado")));
    }
  }

  handleTakePhoto() async {
    Navigator.pop(context);
    final picked = await imagePicker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() {
        file = File(picked.path);
      });
    }
  }

  handleChooseFromGallery() async {
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
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Editar Perfil",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
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
          ),
        ],
      ),
      body: isLoading
          ? circularProgress()
          : ListView(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.only(
                        top: 16.0,
                        bottom: 8.0,
                      ),
                    ),
                    if (_isLoading == false)
                      GestureDetector(
                          child: CircleAvatar(
                            radius: 80.0,
                            backgroundImage: FileImage(file!),
                          ),
                          onTap: () => selectImage(context)),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: <Widget>[
                          buildDisplayNameField(),
                          buildUserNameField(),
                          buildBioField(),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: const Color.fromARGB(255, 81, 212, 212),
                      ),
                      onPressed: updateProfileData,
                      child: const Text(
                        "Actualizar Perfil",
                        style: TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
