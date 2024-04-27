import 'package:flutter_reddit_clone/core/common/error_text.dart';
import 'package:flutter_reddit_clone/core/common/loader.dart';
import 'package:flutter_reddit_clone/core/common/post_card.dart';
import 'package:flutter_reddit_clone/features/community/controller/community_controller.dart';
import 'package:flutter_reddit_clone/features/post/controller/post_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

class FeedsScreen extends ConsumerWidget {
  const FeedsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(userCommunitiesProvider).when(
          data: (communities) {
            return ref.watch(userFeedProvider(communities)).when(
                  data: (posts) {
                    if (posts.isEmpty) {
                      return const Center(
                        child: Text('No posts available'),
                      );
                    }
                    return ListView.builder(
                        itemCount: posts.length,
                        itemBuilder: (BuildContext context, index) {
                          final post = posts[index];

                          return PostCard(
                            post: post,
                          );
                        });
                  },
                  error: (error, stackTrace) {
                    print(error);
                    print(stackTrace);
                    return ErrorText(
                      error: error.toString(),
                    );
                  },
                  loading: () => const Loader(),
                );
          },
          error: (error, stackTrace) => ErrorText(
            error: error.toString(),
          ),
          loading: () => const Loader(),
        );
  }
}
