import 'package:cached_network_image/cached_network_image.dart';
import 'package:carepetsapp/pages/FollowersScreen.dart';
import 'package:carepetsapp/pages/followingScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:carepetsapp/models/user.dart';
import 'package:carepetsapp/pages/editProfile.dart';
import 'package:carepetsapp/pages/home.dart';
import 'package:carepetsapp/widgets/headerTitle.dart';
import 'package:carepetsapp/pages/post.dart';
import 'package:carepetsapp/pages/postTile.dart';
import 'package:carepetsapp/widgets/progress.dart';
import 'package:auto_size_text/auto_size_text.dart';

class Profile extends StatefulWidget {
  final String profileId;

  const Profile({required this.profileId});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  //Variables
  bool isFollowing = false;
  bool isLoading = false;
  final String currentUserId = currentUser!.id;
  String postOrientation = "grid";
  List<Post> posts = [];
  int postCount = 0;
  int followerCount = 0;
  int followingCount = 0;
  User? profile;
  DocumentSnapshot? following;

  @override
  void initState() {
    super.initState();
    getProfilePosts();
    getFollowers();
    getFollowing();
    checkIfFollowing();
    getProfile();
  }

  getProfile() async {
    DocumentSnapshot following = await usersRef.doc(widget.profileId).get();
    profile = User.fromDocument(following);
  }

  checkIfFollowing() async {
    DocumentSnapshot doc = await followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId)
        .get();
    setState(() {
      isFollowing = doc.exists;
    });
  }

  getFollowers() async {
    QuerySnapshot snapshot = await followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .get();
    setState(() {
      followerCount = snapshot.docs.length;
    });
  }

  getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .doc(widget.profileId)
        .collection('userFollowing')
        .get();
    setState(() {
      followingCount = snapshot.docs.length;
    });
  }

  getProfilePosts() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await postsRef
        .doc(widget.profileId)
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .get();
    setState(() {
      isLoading = false;
      postCount = snapshot.docs.length;
      posts = snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
    });
  }

  Column buildCountColumn(String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          count.toString(),
          style: const TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
        ),
        Flexible(
          child: AutoSizeText(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 15.0,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  editProfile() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditProfile(currentUserId: currentUserId)));
  }

  Container buildButton({required String text, required Function function}) {
    return Container(
      padding: const EdgeInsets.only(top: 2.0),
      child: FlatButton(
        onPressed: function(),
        child: Container(
          width: 250.0,
          height: 27.0,
          child: AutoSizeText(
            text,
            style: TextStyle(
              color: isFollowing ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isFollowing
                ? Colors.white
                : const Color.fromARGB(255, 81, 212, 212),
            border: Border.all(
              color: isFollowing
                  ? Colors.grey
                  : const Color.fromARGB(255, 81, 212, 212),
            ),
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
      ),
    );
  }

  buildProfileButton() {
    // viewing your own profile - should show edit profile button
    bool isProfileOwner = currentUserId == widget.profileId;

    if (isProfileOwner) {
      return Container();
    } else if (isFollowing) {
      return TextButton(
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all<Color>(
              const Color.fromARGB(255, 81, 212, 212)),
        ),
        onPressed: () => handleUnfollowUser(),
        child: const Text('No seguir'),
      );
    } else if (!isFollowing) {
      return TextButton(
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all<Color>(
              const Color.fromARGB(255, 81, 212, 212)),
        ),
        onPressed: () => handleFollowUser(),
        child: const Text('Seguir'),
      );
    }
  }

  handleUnfollowUser() {
    setState(() {
      isFollowing = false;
    });
    followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    followingRef
        .doc(currentUserId)
        .collection('userFollowing')
        .doc(widget.profileId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    activityFeedRef
        .doc(widget.profileId)
        .collection('feedItems')
        .doc(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    setState(() {
      followerCount = followerCount - 1;
    });
  }

  handleFollowUser() {
    setState(() {
      isFollowing = true;
    });
    followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId)
        .set({
      "id": currentUserId,
      "username": currentUser!.username,
      "email": currentUser!.email,
      "photoUrl": currentUser!.photoUrl,
      "displayName": currentUser!.displayName,
      "bio": currentUser!.bio,
    });
    followingRef
        .doc(currentUserId)
        .collection('userFollowing')
        .doc(widget.profileId)
        .set({
      "id": widget.profileId,
      "username": profile!.username,
      "email": profile!.email,
      "photoUrl": profile!.photoUrl,
      "displayName": profile!.displayName,
      "bio": profile!.bio,
    });
    activityFeedRef
        .doc(widget.profileId)
        .collection('feedItems')
        .doc(currentUserId)
        .set({
      "type": "follow",
      "ownerId": widget.profileId,
      "username": currentUser!.username,
      "userId": currentUserId,
      "userProfileImg": currentUser!.photoUrl,
      "timestamp": DateTime.now(),
      "postId": "",
      "mediaUrl": "",
      "commentData": "",
    });
    setState(() {
      followerCount = followerCount + 1;
    });
  }

  buildProfileHeader() {
    return FutureBuilder(
      future: usersRef.doc(widget.profileId).get(), //error
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        User user = User.fromDocument(snapshot.data as DocumentSnapshot);
        return Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  CircleAvatar(
                    radius: 40.0,
                    backgroundColor: Colors.grey,
                    backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                  ),
                ],
              ),
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.only(top: 12.0),
                child: AutoSizeText(
                  user.username,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.only(top: 4.0),
                child: AutoSizeText(
                  user.displayName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10.0),
                child: AutoSizeText(user.bio, textAlign: TextAlign.center),
              ),
              Container(
                padding: const EdgeInsets.only(top: 20.0),
              ),
              Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () => showFollowers(),
                        child:
                            buildCountColumn("Seguidores", followerCount - 1),
                      ),
                      buildCountColumn("Publicaciones", postCount),
                      GestureDetector(
                        onTap: () => showFollowing(),
                        child: buildCountColumn("Siguiendo", followingCount),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      buildProfileButton(),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  showFollowers() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FollowersScreen(
          userId: widget.profileId,
        ),
      ),
    );
  }

  showFollowing() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FollowingScreen(
          userId: widget.profileId,
        ),
      ),
    );
  }

  buildProfilePosts() {
    if (isLoading) {
      return circularProgress();
    } else if (postOrientation == "grid") {
      List<GridTile> gridTiles = [];
      for (var post in posts) {
        gridTiles.add(GridTile(child: PostTile(post)));
      }
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: gridTiles,
      );
    } else if (postOrientation == "list") {
      return Column(
        children: posts,
      );
    }
  }

  setPostOrientation(String postOrientation) {
    setState(() {
      this.postOrientation = postOrientation;
    });
  }

  buildTogglePostOrientation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          onPressed: () => setPostOrientation("grid"),
          icon: const Icon(Icons.grid_on),
          color: postOrientation == 'grid'
              ? Theme.of(context).primaryColor
              : Colors.grey,
        ),
        IconButton(
          onPressed: () => setPostOrientation("list"),
          icon: const Icon(Icons.list),
          color: postOrientation == 'list'
              ? Theme.of(context).primaryColor
              : Colors.grey,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: headerTitle(context, titleText: "Perfil"),
      body: ListView(
        children: <Widget>[
          buildProfileHeader(),
          const Divider(),
          buildTogglePostOrientation(),
          const Divider(
            height: 0.0,
          ),
          buildProfilePosts(),
        ],
      ),
    );
  }
}
