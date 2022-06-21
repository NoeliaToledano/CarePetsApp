import 'dart:io';

import 'package:carepetsapp/pages/likesScreen.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:animator/animator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carepetsapp/models/user.dart';
import 'package:carepetsapp/pages/activity_feed.dart';
import 'package:carepetsapp/pages/comments.dart';
import 'package:carepetsapp/pages/home.dart';
import 'package:carepetsapp/widgets/progress.dart';

class Post extends StatefulWidget {
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  final Timestamp timestamp;
  final dynamic likes;

  const Post({
    required this.postId,
    required this.ownerId,
    required this.username,
    required this.location,
    required this.description,
    required this.mediaUrl,
    required this.timestamp,
    required this.likes,
  });

  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      postId: doc['postId'],
      ownerId: doc['ownerId'],
      username: doc['username'],
      location: doc['location'],
      description: doc['description'],
      mediaUrl: doc['mediaUrl'],
      timestamp: doc['timestamp'],
      likes: doc['likes'],
    );
  }

  int getLikeCount(likes) {
    // if no likes, return 0
    if (likes == null) {
      return 0;
    }
    int count = 0;
    // if the key is explicitly set to true, add a like
    likes.values.forEach((val) {
      if (val == true) {
        count += 1;
      }
    });
    return count;
  }

  @override
  _PostState createState() => _PostState(
        postId: postId,
        ownerId: ownerId,
        username: username,
        location: location,
        description: description,
        mediaUrl: mediaUrl,
        likes: likes,
        likeCount: getLikeCount(likes),
      );
}

class _PostState extends State<Post> {
  final String currentUserId = currentUser!.id;
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  bool showHeart = false;
  bool isLiked = false;
  int likeCount;
  Map likes;

  _PostState({
    required this.postId,
    required this.ownerId,
    required this.username,
    required this.location,
    required this.description,
    required this.mediaUrl,
    required this.likes,
    required this.likeCount,
  });

  buildPostHeader() {
    return FutureBuilder(
      future: usersRef.doc(ownerId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        User user = User.fromDocument(snapshot.data as DocumentSnapshot);
        bool isPostOwner = currentUserId == ownerId;
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(user.photoUrl),
            backgroundColor: Colors.grey,
          ),
          title: GestureDetector(
            onTap: () => showProfile(context, profileId: user.id),
            child: Text(
              user.username,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          subtitle: Text(
            location,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          /*trailing: isPostOwner
              ? IconButton(
                  onPressed: () => showPopupMenu(details),
                  icon: const Icon(Icons.more_vert),
                )
              : const Text(''),*/
          trailing: isPostOwner
              ? GestureDetector(
                  onTapUp: (details) => showPopupMenu(details.globalPosition),
                  child: const Icon(Icons.more_vert),
                )
              : const Text(''),
        );
      },
    );
  }

  showPopupMenu(details) {
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(details.dx, details.dy, 10, 100),
      items: [
        const PopupMenuItem<String>(child: Text('Eliminar'), value: '1'),
      ],
      elevation: 8.0,
    ).then((value) {
      if (value == "1") {
        handleDeletePost(context);
      }
    });

    setState(() {});
  }

  handleDeletePost(BuildContext parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: const Text("¿Desea borrar la publicación?"),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  deletePost();
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

  deletePost() async {
    postsRef.doc(ownerId).collection('userPosts').doc(postId).get().then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    storageRef.ref().child("post_$postId.jpg").delete();
    QuerySnapshot activityFeedSnapshot = await activityFeedRef
        .doc(ownerId)
        .collection("feedItems")
        .where('postId', isEqualTo: postId)
        .get();
    for (var doc in activityFeedSnapshot.docs) {
      //revisar
      if (doc.exists) {
        doc.reference.delete();
      }
    }

    QuerySnapshot commentsSnapshot =
        await commentsRef.doc(postId).collection("comments").get();

    for (var doc in commentsSnapshot.docs) {
      //revisar
      if (doc.exists) {
        doc.reference.delete();
      }
    }
  }

  handleLikePost() {
    bool _isLiked = likes[currentUserId] == true;

    if (_isLiked) {
      postsRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .update({'likes.$currentUserId': false});
      removeLikeFromActivityFeed();
      setState(() {
        likeCount -= 1;
        isLiked = false;
        likes[currentUserId] = false;
      });
    } else if (!_isLiked) {
      postsRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .update({'likes.$currentUserId': true});
      addLikeToActivityFeed();
      setState(() {
        likeCount += 1;
        isLiked = true;
        likes[currentUserId] = true;
        showHeart = true;
      });
      Timer(const Duration(milliseconds: 500), () {
        setState(() {
          showHeart = false;
        });
      });
    }
  }

  addLikeToActivityFeed() {
    bool isNotPostOwner = currentUserId != ownerId;
    if (isNotPostOwner) {
      activityFeedRef.doc(ownerId).collection("feedItems").doc(postId).set({
        "type": "like",
        "username": currentUser!.username,
        "userId": currentUser!.id,
        "userProfileImg": currentUser!.photoUrl,
        "postId": postId,
        "mediaUrl": mediaUrl,
        "timestamp": DateTime.now(),
        "commentData": "",
      });
    }
  }

  removeLikeFromActivityFeed() {
    bool isNotPostOwner = currentUserId != ownerId;
    if (isNotPostOwner) {
      activityFeedRef
          .doc(ownerId)
          .collection("feedItems")
          .doc(postId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
    }
  }

  buildPostImage() {
    return GestureDetector(
      onDoubleTap: handleLikePost,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Image(
                  image: CachedNetworkImageProvider(mediaUrl),
                  fit: BoxFit.fill,
                ),
              ),
            ],
          ),
          //cachedNetworkImage(mediaUrl),
          showHeart
              // Show heartbeat animation while showHeart is true
              ? Animator(
                  duration: const Duration(milliseconds: 700),
                  tween: Tween(begin: 1.0, end: 0.0),
                  curve: Curves.easeOut,
                  cycles: 0,
                  builder: (context, animatorState, child) => Transform.scale(
                    scale: 0.5, //revisar
                    child: const Opacity(
                      opacity: 0.5,
                      child: Icon(
                        Icons.pets,
                        size: 250,
                        color: Colors.red,
                      ),
                    ),
                  ),
                )
              // Show nothing if showHeart is false
              : const Text(""),
        ],
      ),
    );
  }

  buildPostFooter() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const Padding(padding: EdgeInsets.only(top: 40.0, left: 20.0)),
            GestureDetector(
              onTap: handleLikePost,
              child: Image.asset(
                isLiked
                    ? 'assets/images/pets.png'
                    : 'assets/images/pets_border.png',
                scale: 9,
              ),
            ),
            const Padding(padding: EdgeInsets.only(right: 20.0)),
            GestureDetector(
              onTap: () => showComments(
                context,
                postId: postId,
                ownerId: ownerId,
                mediaUrl: mediaUrl,
              ),
              child: const Icon(
                Icons.chat,
                size: 28.0,
                color: Color.fromARGB(255, 10, 169, 169),
              ),
            ),
            /* Container(
              margin: const EdgeInsets.only(left: 30.0),
              child: Text(
                "Etiquetad@: " + currentUser!.displayName,
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),*/
          ],
        ),
        Row(
          children: <Widget>[
            const SizedBox(
              height: 20,
            ),
            Container(
              margin: const EdgeInsets.only(left: 20.0),
              child: GestureDetector(
                onTap: () => showLikes(),
                child: Text(
                  "$likeCount Me gusta",
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(left: 20.0),
              child: Text(
                "$username ",
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(child: Text(description)),
            const SizedBox(
              height: 100,
            ),
          ],
        ),
      ],
    );
  }

  showLikes() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LikesScreen(
          userId: widget.ownerId,
          postId: widget.postId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    isLiked = (likes[currentUserId] == true);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildPostHeader(),
        buildPostImage(),
        buildPostFooter()
      ],
    );
  }
}

showComments(BuildContext context,
    {String postId = "",
    String ownerId = "",
    String mediaUrl = "",
    String commentId = ""}) {
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return Comments(
      postId: postId,
      postOwnerId: ownerId,
      postMediaUrl: mediaUrl,
      commentId: commentId,
    );
  }));
}
