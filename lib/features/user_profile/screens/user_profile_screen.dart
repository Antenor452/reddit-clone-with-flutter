import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reddit_clone/core/common/error_text.dart';
import 'package:flutter_reddit_clone/core/common/loader.dart';
import 'package:flutter_reddit_clone/core/common/post_card.dart';
import 'package:flutter_reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:flutter_reddit_clone/features/post/controller/post_controller.dart';
import 'package:flutter_reddit_clone/features/user_profile/controllers/user_profile_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class UserProfileScreen extends ConsumerWidget {
  final String uid;
  const UserProfileScreen({super.key, required this.uid});



  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void navigateToEditProfileScreen(BuildContext context) {
      Routemaster.of(context).push('/edit-profile/$uid');
    }

    return Scaffold(
      body: ref.watch(getUserDataProvider(uid)).when(
            data: (user) {
              return NestedScrollView(
                headerSliverBuilder: (context, innerBoxScroll) {
                  return [
                    SliverAppBar(
                      expandedHeight: 250,
                      floating: true,
                      snap: true,
                      flexibleSpace: Stack(
                        children: [
                          Positioned.fill(
                            child: CachedNetworkImage(
                              imageUrl: user.banner,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            left: 20,
                            bottom: 0,
                            child: Container(
                              // padding: const EdgeInsets.all(20),
                              alignment: Alignment.bottomLeft,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    backgroundImage: CachedNetworkImageProvider(
                                      user.profilePic,
                                    ),
                                    radius: 35,
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        navigateToEditProfileScreen(context),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.all(0),
                                      textStyle: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    child: const Text('Edit Profile'),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'u/${user.name}',
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                '${user.karma} karma',
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Divider(
                              thickness: 2,
                            )
                          ],
                        ),
                      ),
                    )
                  ];
                },
                body: ref.watch(userPostsProvider(user.uid)).when(
                      data: (posts) {
                        if (posts.isEmpty) {
                          return const Center(
                            child: Text('User has not posts'),
                          );
                        }
                        return CustomScrollView(
                          slivers: [
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                childCount: posts.length,
                                (context, index) {
                                  final post = posts[index];
                                  return PostCard(post: post);
                                },
                              ),
                            )
                          ],
                        );
                        // return ListView.builder(
                        //   itemCount: posts.length,
                        //   itemBuilder: (BuildContext context, index) {
                        //     final post = posts[index];

                        //     return PostCard(
                        //       post: post,
                        //     );
                        //   },
                        // );
                      },
                      error: (error, stackTrace) => ErrorText(
                        error: error.toString(),
                      ),
                      loading: () => const Loader(),
                    ),
              );
            },
            error: (error, stackTrace) {
              return ErrorText(
                error: error.toString(),
              );
            },
            loading: () => const Loader(),
          ),
    );
  }
}
