import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carepetsapp/pages/post.dart';
import 'package:carepetsapp/pages/postScreen.dart';

class PostTile extends StatelessWidget {
  final Post post;

  const PostTile(this.post);

  showPost(context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PostScreen(
                  postId: post.postId,
                  userId: post.ownerId,
                )));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showPost(context),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                    child: Image(
                  image: CachedNetworkImageProvider(post.mediaUrl),
                  fit: BoxFit.cover,
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
