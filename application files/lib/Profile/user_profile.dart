import 'package:flutter/material.dart';
import 'package:mypocket/Auth/LoginScreen.dart';
import 'package:mypocket/Home/WalletScreen.dart';
import 'package:mypocket/Profile/infoPage.dart';
import 'package:url_launcher/url_launcher.dart'; // Import the url_launcher package

// Divider Class
class MyDivider extends StatelessWidget {
  const MyDivider({
    Key? key,
    this.height = 1.0,
    this.thickness = 1.0,
    this.indent = 24.0,
    this.endIndent = 24.0,
    this.color = const Color(0xFFE0E3E7),
  }) : super(key: key);

  final double height;
  final double thickness;
  final double indent;
  final double endIndent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: height,
      thickness: thickness,
      indent: indent,
      endIndent: endIndent,
      color: color,
    );
  }
}

// Profile Image Widget
class _ProfileImage extends StatelessWidget {
  const _ProfileImage({
    Key? key,
    required this.profileImageUrl,
    required this.isLoading,
  }) : super(key: key);

  final String profileImageUrl;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(60.0),
          child: SizedBox(
            width: 100.0,
            height: 100.0,
            child: isLoading
                ? const CircularProgressIndicator()
                : Image.network(
                    profileImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Image.network(
                      'https://placehold.co/100x100/EEE/31343C?text=Error',
                      fit: BoxFit.cover,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// User Info Widget
class _UserInfo extends StatelessWidget {
  const _UserInfo({
    Key? key,
    required this.userName,
    required this.userEmail,
  }) : super(key: key);

  final String userName;
  final String userEmail;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: Text(
            userName,
            style: textTheme.headlineSmall?.copyWith(
              fontFamily: 'Urbanist',
              letterSpacing: 0.0,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            userEmail,
            style: textTheme.titleSmall?.copyWith(
              fontFamily: 'Manrope',
              color: colorScheme.secondary,
              letterSpacing: 0.0,
            ),
          ),
        ),
      ],
    );
  }
}

// Profile Button Widget
class _ProfileButton extends StatelessWidget {
  const _ProfileButton({
    Key? key,
    required this.icon,
    required this.text,
    this.onTap,
  }) : super(key: key);

  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: const Color(0xFFE0E3E7),
              width: 2.0,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Icon(
                    icon,
                    size: 24.0,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Text(
                    text,
                    style: textTheme.bodyMedium?.copyWith(
                      fontFamily: 'Manrope',
                      letterSpacing: 0.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Logout Button Widget
class _LogoutButton extends StatelessWidget {
  const _LogoutButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => LoginScreen(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          fixedSize: const Size(230.0, 50.0),
          textStyle: textTheme.bodyLarge?.copyWith(
            fontFamily: 'Manrope',
            color: Colors.white,
            letterSpacing: 0.0,
          ),
          padding: EdgeInsets.zero,
          elevation: 3.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(34),
          ),
          backgroundColor: Colors.indigoAccent,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              'Log Out', // Changed the text
              style: textTheme.bodyLarge?.copyWith(
                fontFamily: 'Manrope',
                color: Colors.white,
                letterSpacing: 0.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Main UserProfileView Widget
class UserProfileView extends StatelessWidget {
  const UserProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data for the UI.
    const String profileImageUrl = 'assets/logo.png';
    const String userName = 'Guest User';
    const String userEmail = 'guest.user@example.com';
    const bool isLoading = false;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          actions: [
            Padding(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 12.0, 0.0),
              child: IconButton(
                icon: Icon(
                  Icons.info_outline,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  size: 30.0,
                ),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => InfoPage(),
                    ),
                  );
                },
              ),
            ),
          ],
          centerTitle: false,
          elevation: 0.0,
        ),
        body: SafeArea(
          top: true,
          child: Column(
            children: [
              _ProfileImage(
                profileImageUrl: profileImageUrl,
                isLoading: isLoading,
              ),
              _UserInfo(userName: userName, userEmail: userEmail),
              const MyDivider(height: 44.0),
              _ProfileButton(
                icon: Icons.account_circle_outlined,
                text: 'Edit Profile',
                onTap: () {
                  // Handle edit profile
                },
              ),
              _ProfileButton(
                icon: Icons.settings_outlined,
                text: 'Account Settings',
                onTap: () {
                  // Handle account settings
                },
              ),
              _ProfileButton(
                icon: Icons.support_agent,
                text: 'Support',
                onTap: () {
                  // Handle support
                },
              ),
              const _LogoutButton(),
            ],
          ),
        ),
      ),
    );
  }
}
