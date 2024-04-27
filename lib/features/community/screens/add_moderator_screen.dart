import 'package:flutter/material.dart';
import 'package:flutter_reddit_clone/core/common/error_text.dart';
import 'package:flutter_reddit_clone/core/common/loader.dart';
import 'package:flutter_reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:flutter_reddit_clone/features/community/controller/community_controller.dart';
import 'package:flutter_reddit_clone/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddModeratorScreen extends ConsumerStatefulWidget {
  final String name;
  const AddModeratorScreen({
    super.key,
    required this.name,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddModeratorScreenState();
}

class _AddModeratorScreenState extends ConsumerState<AddModeratorScreen> {
  Set<String> uids = {};
  int ctr = 0;

  void addUid(String uid) {
    setState(() {
      uids.add(uid);
    });
  }

  void removeUid(String uid) {
    setState(() {
      uids.remove(uid);
    });
  }

  void saveMods() async {
    ref.read(communityControllerProvider.notifier).addMods(
          context,
          widget.name,
          uids.toList(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: saveMods,
            icon: const Icon(
              Icons.done,
            ),
          )
        ],
      ),
      body: ref.watch(getCommunityByNameProvider(widget.name)).when(
            data: (community) {
              return ListView.builder(
                itemCount: community.members.length,
                itemBuilder: (context, index) {
                  final member = community.members[index];
                  final isLoading = ref.watch(communityControllerProvider);
                  if (isLoading) {
                    return const Loader();
                  }
                  return ref.watch(getUserDataProvider(member)).when(
                        data: (user) {
                          if (community.mods.contains(member) &&
                              ctr < community.mods.length) {
                            uids.add(member);
                          }

                          ctr++;
                          return CheckboxListTile(
                            value: uids.contains(
                              user.uid,
                            ),
                            onChanged: (value) {
                              if (value!) {
                                addUid(member);
                              } else {
                                removeUid(member);
                              }
                            },
                            title: Text(user.name),
                          );
                        },
                        error: (err, stackTrace) => ErrorText(
                          error: err.toString(),
                        ),
                        loading: () => const Loader(),
                      );
                },
              );
            },
            error: (err, stackTrace) => ErrorText(
              error: err.toString(),
            ),
            loading: () => const Loader(),
          ),
    );
  }
}
