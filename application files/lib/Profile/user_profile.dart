import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mypocket/Auth/LoginScreen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mypocket/Profile/infoPage.dart';

// Divider Class (No changes needed)
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

// Profile Image Widget (Modified to handle file and network)
class _ProfileImage extends StatelessWidget {
  const _ProfileImage({
    Key? key,
    required this.profileImageUrl,
    required this.isLoading,
    required this.onTap,
    this.localImageFile, // Add this
  }) : super(key: key);

  final String profileImageUrl;
  final bool isLoading;
  final VoidCallback? onTap;
  final File? localImageFile; // Add this

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
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
                  : localImageFile != null
                      ? kIsWeb // Check if running on web
                          ? Image.network(
                              profileImageUrl, // On web, treat the path as a URL if possible
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Image.network(
                                'https://placehold.co/100x100/EEE/31343C?text=Error',
                                fit: BoxFit.cover,
                              ),
                            )
                          : Image.file(
                              // On mobile, use Image.file
                              localImageFile!,
                              fit: BoxFit.cover,
                            )
                      : Image.network(
                          profileImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Image.network(
                            'https://placehold.co/100x100/EEE/31343C?text=Error',
                            fit: BoxFit.cover,
                          ),
                        ),
            ),
          ),
        ),
      ),
    );
  }
}

// User Info Widget (Modified to fetch from Firebase)
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
        )
      ],
    );
  }
}

// Profile Button Widget (No changes needed)
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

// Logout Button Widget (No changes needed)
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
              'Log Out',
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
class UserProfileView extends StatefulWidget {
  const UserProfileView({super.key});

  @override
  _UserProfileViewState createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<UserProfileView> {
  String profileImageUrl = 'assets/logo.png'; // Default
  String userName = 'Guest User'; // Default
  String userEmail = 'guest.user@example.com'; // Default
  bool isLoading = false;
  File? _profileImageFile;
  final ImagePicker _picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance; // Get instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; //instance
  Uint8List? _profileImageBytesWeb;

  @override
  void initState() {
    super.initState();
    _loadUserProfile(); // Load user data on init
  }

  // Function to load user data from Firebase
  Future<void> _loadUserProfile() async {
    setState(() {
      isLoading = true;
    });
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Fetch additional user data from Firestore using the user.uid
        final userDoc =
            await _firestore.collection('Users').doc(user.uid).get();

        if (userDoc.exists) {
          final userData = userDoc.data();
          setState(() {
            userName =
                userData?['fullName'] ?? 'No Name'; // Use a default if null
            userEmail = user.email ?? 'No Email'; // Use a default if null
            profileImageUrl = 'assets/logo.png';
          });
        } else {
          setState(() {
            userName = user.displayName ?? "Name Not Available";
            userEmail = user.email ?? "Email Not Available";
          });
        }
      }
    } catch (e) {
      print("Error loading user data: $e");
      // Handle error (e.g., show a message to the user)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profile data: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _profileImageBytesWeb = bytes;
            profileImageUrl = pickedFile.path; // You might need to adjust this
            _profileImageFile = null; // Ensure _profileImageFile is null on web
          });
        } else {
          setState(() {
            _profileImageFile = File(pickedFile.path);
            profileImageUrl = pickedFile.path; // Update for local display
            _profileImageBytesWeb =
                null; // Ensure _profileImageBytesWeb is null on mobile
          });
        }
      }
    } catch (e) {
      print("Error during pick and crop: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: const Color.fromARGB(241, 244, 248, 255),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(241, 244, 248, 255),
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
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      File? dialogProfileImageFile = _profileImageFile; //shadow
                      return StatefulBuilder(
                        builder: (context, setState) {
                          return AlertDialog(
                            backgroundColor: Colors.white,
                            title: const Text('Change Profile Picture'),
                            content: SingleChildScrollView(
                              child: ListBody(
                                children: <Widget>[
                                  GestureDetector(
                                    child: const Text('Take Photo'),
                                    onTap: () async {
                                      await _pickImage(ImageSource.camera);
                                      setState(() {
                                        dialogProfileImageFile =
                                            _profileImageFile;
                                      });
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  const Padding(padding: EdgeInsets.all(8.0)),
                                  GestureDetector(
                                    child: const Text('Choose from Gallery'),
                                    onTap: () async {
                                      await _pickImage(ImageSource.gallery);
                                      setState(() {
                                        dialogProfileImageFile =
                                            _profileImageFile;
                                      });
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  if (dialogProfileImageFile != null) {
                                    // No upload to Firebase Storage
                                    setState(() {
                                      // Null check *inside* setState, using a local variable
                                      final imageFile =
                                          dialogProfileImageFile; // Create a local variable
                                      if (imageFile != null) {
                                        profileImageUrl = imageFile.path;
                                        _profileImageFile = imageFile;
                                      }
                                    });
                                    Navigator.of(context).pop();
                                  } else {
                                    //no new image
                                    Navigator.of(context).pop();
                                  }
                                },
                                child: const Text('Save'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
                localImageFile: kIsWeb ? null : _profileImageFile,
              ),
              _UserInfo(userName: userName, userEmail: userEmail),
              const MyDivider(height: 44.0),
              _ProfileButton(
                icon: Icons.account_circle_outlined,
                text: 'Edit Profile',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      String newName = userName;
                      File? dialogProfileImageFile =
                          _profileImageFile; // Use _profileImageFile
                      return StatefulBuilder(
                        builder: (context, setState) {
                          return AlertDialog(
                            backgroundColor: Colors.white,
                            title: const Text('Edit Profile'),
                            content: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Stack(
                                    children: [
                                      CircleAvatar(
                                        radius: 60,
                                        backgroundImage:
                                            dialogProfileImageFile != null
                                                ? FileImage(
                                                    dialogProfileImageFile!)
                                                : NetworkImage(profileImageUrl)
                                                    as ImageProvider,
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: PopupMenuButton<ImageSource>(
                                          onSelected:
                                              (ImageSource source) async {
                                            final pickedFile = await _picker
                                                .pickImage(source: source);
                                            if (pickedFile != null) {
                                              final tempFile =
                                                  File(pickedFile.path);
                                              setState(() {
                                                dialogProfileImageFile =
                                                    tempFile;
                                              });
                                            }
                                          },
                                          itemBuilder: (
                                            BuildContext context,
                                          ) {
                                            return [
                                              const PopupMenuItem(
                                                value: ImageSource.camera,
                                                child: Text('Take Photo'),
                                              ),
                                              const PopupMenuItem(
                                                value: ImageSource.gallery,
                                                child:
                                                    Text('Choose from Gallery'),
                                              ),
                                            ];
                                          },
                                          child: const Icon(
                                            Icons.edit,
                                            size: 20,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  TextField(
                                    onChanged: (value) => newName = value,
                                    decoration: const InputDecoration(
                                        labelText: 'Name'),
                                    controller:
                                        TextEditingController(text: userName),
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  setState(() {
                                    userName = newName;
                                    isLoading =
                                        true; //start loading, for the ui
                                  });
                                  // No Firebase Storage upload
                                  if (dialogProfileImageFile != null) {
                                    setState(() {
                                      // Add null check here using a local variable
                                      final imageFile = dialogProfileImageFile;
                                      if (imageFile != null) {
                                        profileImageUrl = imageFile.path;
                                        _profileImageFile = imageFile;
                                      }
                                    });
                                  }
                                  try {
                                    await _firestore
                                        .collection('Users')
                                        .doc(_auth.currentUser?.uid)
                                        .update({'fullName': newName});
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Failed to update profile: $e')),
                                    );
                                  }

                                  setState(() {
                                    isLoading =
                                        false; //stop loading, for the ui
                                  });
                                  Navigator.pop(context);
                                },
                                child: const Text('Save'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
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
