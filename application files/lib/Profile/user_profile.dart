import 'package:flutter/material.dart';
import 'package:mypocket/Auth/LoginScreen.dart';
import 'package:mypocket/Home/WalletScreen.dart';
import 'package:mypocket/Profile/infoPage.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:image_cropper/image_cropper.dart'; // Import the image_cropper package
import 'package:camera/camera.dart'; // Import the camera package
// import 'package:universal_html/html.dart' as web; // Import for web compatibility - removed to fix error

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
  String profileImageUrl = 'assets/logo.png';
  String userName = 'Guest User';
  String userEmail = 'guest.user@example.com';
  bool isLoading = false;
  File? _profileImageFile;
  CameraController? _cameraController; // Camera controller

  @override
  void initState() {
    super.initState();
    // _loadUserData();
  }

  @override
  void dispose() {
    _cameraController?.dispose(); // Dispose the camera controller
    super.dispose();
  }

  // Initialize the camera
  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        // check if cameras are available
        final firstCamera = cameras.first;
        _cameraController = CameraController(
          firstCamera,
          ResolutionPreset.medium, // You can change the resolution
        );
        await _cameraController!.initialize();
        if (!mounted) return;
        setState(() {});
      } else {
        print(
            "No cameras available."); // Handle the case where no cameras are available.
      }
    } catch (e) {
      print("Error initializing camera: $e");
      // Handle error (e.g., show a message to the user)
    }
  }

  Future<void> _pickAndCropImage(ImageSource source) async {
    // Added source
    if (_cameraController == null) {
      await _initializeCamera();
    }
    final pickedFile =
        await ImagePicker().pickImage(source: source); // Use source
    if (pickedFile != null) {
      File? croppedFile = await cropImage(File(pickedFile.path));
      if (croppedFile != null) {
        setState(() {
          _profileImageFile = croppedFile;
          profileImageUrl = croppedFile
              .path; // Update the image URL  IMPORTANT - use croppedFile
          // _uploadImageToFirebase();  // call firebase upload
        });
      }
    }
  }

  Future<File?> cropImage(File imageFile) async {
    try {
      // added try catch
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        //       compressFormat: ImageFormat.jpg,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.blue,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Crop Image',
          ),
        ],
      );
      if (croppedFile != null) {
        return File(croppedFile.path);
      }
      return null;
    } catch (e) {
      print("Error during image cropping: $e");
      return null;
    }
  }

  // // Future<void> _uploadImageToFirebase() async {
  // //   try {
  // //     User? user = FirebaseAuth.instance.currentUser;
  // //     if (user != null && _profileImageFile != null) {
  // //       String fileName = DateTime.now().millisecondsSinceEpoch.toString();
  // //       Reference storageReference =
  // //           FirebaseStorage.instance.ref().child('profile_images/$fileName');
  // //       UploadTask uploadTask = storageReference.putFile(_profileImageFile!);
  // //       await uploadTask.whenComplete(() => null);
  // //       String imageUrl = await storageReference.getDownloadURL();
  // //       setState(() {
  // //         profileImageUrl = imageUrl;
  // //       });
  // //       await FirebaseFirestore.instance
  // //           .collection('users')
  // //           .doc(user.uid)
  // //           .update({'profileImageUrl': imageUrl});
  // //     }
  // //   } catch (e) {
  // //     print('Error uploading image: $e');
  // //   }
  // // }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: Color.fromARGB(241, 244, 248, 255),
        appBar: AppBar(
          backgroundColor: Color.fromARGB(241, 244, 248, 255),
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
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      String newName = userName;
                      return StatefulBuilder(
                        builder: (context, setState) {
                          return AlertDialog(
                            title: Text('Edit Profile'),
                            content: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Stack(
                                    children: [
                                      CircleAvatar(
                                        radius: 60,
                                        backgroundImage:
                                            _profileImageFile != null
                                                ? FileImage(_profileImageFile!)
                                                : NetworkImage(profileImageUrl)
                                                    as ImageProvider,
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: PopupMenuButton<ImageSource>(
                                          // PopupMenuButton
                                          onSelected: (ImageSource source) {
                                            _pickAndCropImage(
                                                source); // Pass source
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
                                    decoration:
                                        InputDecoration(labelText: 'Name'),
                                    controller:
                                        TextEditingController(text: userName),
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  setState(() {
                                    userName = newName;
                                  });
                                  // User? user = FirebaseAuth.instance.currentUser;
                                  // if (user != null) {
                                  //   await FirebaseFirestore.instance
                                  //       .collection('users')
                                  //       .doc(user.uid)
                                  //       .update({'name': newName});
                                  // }
                                  Navigator.pop(context);
                                },
                                child: Text('Save'),
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
