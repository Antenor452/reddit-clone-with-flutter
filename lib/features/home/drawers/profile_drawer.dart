import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:flutter_reddit_clone/theme/pallete.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class ProfileDrawer extends ConsumerWidget {
  const ProfileDrawer({super.key});

  void logOut(WidgetRef ref) {
    ref.read(authControllerProvider.notifier).logOut();
  }

  void navigateToProfileScreen(BuildContext context, String uid) {
    Routemaster.of(context).push('u/$uid');
  }

  void toggleTheme(WidgetRef ref) {
    ref.read(themeNotifierProvider.notifier).toggleTheme();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(
                user.profilePic,
              ),
              radius: 70,
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              'u/${user.name}',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 18,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Divider(
              color: Pallete.greyColor,
            ),
            ListTile(
              leading: const Icon(
                Icons.person,
              ),
              title: const Text('My profile'),
              onTap: () => navigateToProfileScreen(
                context,
                user.uid,
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.login_sharp,
                color: Pallete.redColor,
              ),
              title: const Text('Log out '),
              onTap: () => logOut(ref),
            ),
            const SizedBox(
              height: 10,
            ),
            Center(
              child: Switch.adaptive(
                value: ref.watch(themeNotifierProvider.notifier).mode ==
                    ThemeMode.dark,
                onChanged: (value) => toggleTheme(ref),
                activeColor: Colors.green,
                inactiveTrackColor:
                    Pallete.darkModeAppTheme.scaffoldBackgroundColor,
              ),
            )
          ],
        ),
      ),
    );
  }
}
