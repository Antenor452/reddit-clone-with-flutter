import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reddit_clone/core/common/error_text.dart';
import 'package:flutter_reddit_clone/core/common/loader.dart';
import 'package:flutter_reddit_clone/features/community/controller/community_controller.dart';
import 'package:flutter_reddit_clone/models/community_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class CommunityListDrawer extends ConsumerWidget {
  const CommunityListDrawer({super.key});

  void navigateToCreateCommunity(BuildContext context) {
    Routemaster.of(context).push('/create-community');
  }

  void navigateToCommunityScreen(BuildContext context, Community community) {
    Routemaster.of(context).push('/r/${community.name}');
  }

  void closeDrawer(BuildContext context) {
    Scaffold.of(context).closeDrawer();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: SafeArea(
          child: Column(
        children: [
          ListTile(
            title: const Text('Create a community'),
            leading: const Icon(Icons.add),
            onTap: () => navigateToCreateCommunity(context),
          ),
          ref.watch(userCommunitiesProvider).when(data: (communities) {
            return Expanded(
              child: ListView.builder(
                itemCount: communities.length,
                itemBuilder: (context, index) {
                  final community = communities[index];
                  return ListTile(
                    title: Text('r/${community.name}'),
                    leading: CircleAvatar(
                      backgroundImage: CachedNetworkImageProvider(
                        community.avatar,
                      ),
                    ),
                    onTap: () {
                      navigateToCommunityScreen(
                        context,
                        community,
                      );
                      closeDrawer(context);
                    },
                  );
                },
              ),
            );
          }, error: (error, stackTrace) {
            return ErrorText(
              error: error.toString(),
            );
          }, loading: () {
            return const Loader();
          })
        ],
      )),
    );
  }
}
