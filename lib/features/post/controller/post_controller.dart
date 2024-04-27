import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_reddit_clone/core/enums.dart';
import 'package:flutter_reddit_clone/core/providers/storage_repository.dart';
import 'package:flutter_reddit_clone/core/utils.dart';
import 'package:flutter_reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:flutter_reddit_clone/features/post/repository/post_repository.dart';
import 'package:flutter_reddit_clone/features/user_profile/controllers/user_profile_controller.dart';
import 'package:flutter_reddit_clone/models/comment_model.dart';
import 'package:flutter_reddit_clone/models/community_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uuid/uuid.dart';

import '../../../models/post_model.dart';

final postControllerProvider =
    StateNotifierProvider<PostController, bool>((ref) {
  return PostController(
      postRepository: ref.watch(postRepositoryProvider),
      storageRepository: ref.watch(
        firebaseStorageProvider,
      ),
      ref: ref);
});

final userFeedProvider =
    StreamProvider.family((ref, List<Community> communities) {
  final postController = ref.read(postControllerProvider.notifier);
  return postController.fetchUserPosts(communities);
});

final getPostByIdProvider =
    StreamProvider.family<Post, String>((ref, String postId) {
  final postController = ref.read(postControllerProvider.notifier);
  return postController.getPostById(postId);
});

final getPostCommentsProvider =
    StreamProvider.family<List<Comment>, String>((ref, String postId) {
  final postController = ref.read(postControllerProvider.notifier);
  return postController.fetchPostComments(postId);
});

class PostController extends StateNotifier<bool> {
  final PostRepository _postRepository;
  final Ref _ref;
  final StorageRepository _storageRepository;
  PostController(
      {required PostRepository postRepository,
      required StorageRepository storageRepository,
      required Ref ref})
      : _postRepository = postRepository,
        _storageRepository = storageRepository,
        _ref = ref,
        super(false);

  void shareTextPost({
    required BuildContext context,
    required String title,
    required Community community,
    required String description,
  }) async {
    state = true;

    final user = _ref.read(userProvider)!;
    final String id = const Uuid().v4();

    final post = Post(
      id: id,
      uid: user.uid,
      title: title,
      type: 'text',
      communityProfilePic: community.avatar,
      username: user.name,
      createdAt: DateTime.now(),
      awards: [],
      upvotes: [],
      downvotes: [],
      commentCount: 0,
      communityName: community.name,
      description: description,
    );

    final res = await _postRepository.addPost(post);
    _ref
        .read(userProfileControllerProvider.notifier)
        .updateUserKarma(UserKarma.textPost);
    state = false;
    res.fold(
        (l) => showSnackBar(
              context,
              l.message,
            ), (r) {
      showSnackBar(context, 'Posted successful');
      Routemaster.of(context).pop();
    });
  }

  void shareLinkPost({
    required BuildContext context,
    required String title,
    required Community community,
    required String link,
  }) async {
    state = true;

    final user = _ref.read(userProvider)!;
    final String id = const Uuid().v4();

    final post = Post(
      id: id,
      uid: user.uid,
      title: title,
      type: 'link',
      communityProfilePic: community.avatar,
      username: user.name,
      createdAt: DateTime.now(),
      awards: [],
      upvotes: [],
      downvotes: [],
      commentCount: 0,
      communityName: community.name,
      link: link,
    );

    final res = await _postRepository.addPost(post);
    state = false;
    res.fold(
        (l) => showSnackBar(
              context,
              l.message,
            ), (r) {
      showSnackBar(context, 'Posted successful');
      _ref
          .read(userProfileControllerProvider.notifier)
          .updateUserKarma(UserKarma.linkPost);
      Routemaster.of(context).pop();
    });
  }

  void shareImagePost({
    required BuildContext context,
    required String title,
    required Community community,
    required File imagePostFile,
  }) async {
    print('uploading image');
    state = true;

    final user = _ref.read(userProvider)!;
    final String id = const Uuid().v4();

    final response = await _storageRepository.storeFile(
      path: 'posts/${community.name}',
      id: id,
      file: imagePostFile,
    );

    response.fold((l) {
      state = false;
      showSnackBar(
        context,
        l.message,
      );
    }, (r) async {
      final post = Post(
        id: id,
        uid: user.uid,
        title: title,
        type: 'image',
        communityProfilePic: community.avatar,
        username: user.name,
        createdAt: DateTime.now(),
        awards: [],
        upvotes: [],
        downvotes: [],
        commentCount: 0,
        communityName: community.name,
        link: r,
      );

      final res = await _postRepository.addPost(post);
      state = false;
      res.fold(
          (l) => showSnackBar(
                context,
                l.message,
              ), (r) {
        showSnackBar(context, 'Posted successful');
        _ref
            .read(userProfileControllerProvider.notifier)
            .updateUserKarma(UserKarma.imagePost);
        Routemaster.of(context).pop();
      });
    });
  }

  void deletePost(BuildContext context, Post post) async {
    final res = await _postRepository.deletePost(post);
    res.fold(
      (l) => showSnackBar(
        context,
        l.message,
      ),
      (r) {
        showSnackBar(context, 'Post deleted');
        _ref
            .read(userProfileControllerProvider.notifier)
            .updateUserKarma(UserKarma.deletePost);
      },
    );
  }

  void upvotePost(Post post) {
    final uid = _ref.read(userProvider)!.uid;
    _postRepository.upvotePost(post, uid);
  }

  void downvotePost(Post post) {
    final uid = _ref.read(userProvider)!.uid;
    _postRepository.downvotePost(post, uid);
  }

  Stream<List<Post>> fetchUserPosts(List<Community> communities) {
    if (communities.isNotEmpty) {
      return _postRepository.fetchUserPosts(communities);
    }
    return Stream.value([]);
  }

  Stream<Post> getPostById(String postId) {
    return _postRepository.getPostById(postId);
  }

  Stream<List<Comment>> fetchPostComments(String postId) {
    return _postRepository.fetchPostComments(postId);
  }

  void addComment({
    required BuildContext context,
    required String text,
    required String postId,
  }) async {
    final user = _ref.read(userProvider)!;
    final commentId = const Uuid().v4();
    Comment comment = Comment(
      id: commentId,
      text: text,
      createdAt: DateTime.now(),
      postId: postId,
      username: user.name,
      profilePic: user.profilePic,
      uid: user.uid,
    );

    final response = await _postRepository.addComment(comment);
    response.fold(
        (l) => showSnackBar(
              context,
              l.message,
            ), (r) {
      showSnackBar(context, 'comment posted successfully');
      _ref.read(userProfileControllerProvider.notifier).updateUserKarma(
            UserKarma.comment,
          );
    });
  }

  void awardPost({
    required Post post,
    required String award,
    required BuildContext context,
  }) async {
    final user = _ref.read(userProvider)!;

    final res = await _postRepository.awardPost(
      post: post,
      award: award,
      senderId: user.uid,
    );

    res.fold((l) => showSnackBar(context, l.message), (r) {
      //update user karma if award was successful
      _ref
          .read(userProfileControllerProvider.notifier)
          .updateUserKarma(UserKarma.awardPost);

      //update user state
      _ref.read(userProvider.notifier).update((state) {
        state?.awards.remove(award);
        return state;
      });

      Routemaster.of(context).pop();
    });
  }
}
