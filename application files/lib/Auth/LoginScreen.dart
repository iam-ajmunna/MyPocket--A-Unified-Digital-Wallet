import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:mypocket/Home/WalletScreen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool obscureText = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

// Not For Me
/* This is the Whole Body that is Containing a Container Under a Column */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 243, 243),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            // This is the Begining of the container
            children: [
              // This container Shows the Brand And Logo
              Container(
                height: 200,
                width: 420,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(73, 140, 157, 255),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Center(
                  child: Image.asset(
                    'MyPocketBrand.png',
                    width: 150,
                    height: 150,
                  ),
                ),
              ),

              // This Container is the Tab View
              Container(
                width: 550,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 20),
                    TabBar(
                      controller: _tabController,
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.indigoAccent[100],
                      indicatorWeight: 4,
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelStyle: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Manrope',
                          letterSpacing: 0.0),
                      tabs: [
                        Tab(text: 'Log In'),
                        Tab(text: 'Create Account'),
                      ],
                    ),
                    SizedBox(height: 16),
                    Container(
                      height: 570,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildLoginTab(),
                          _buildSignUpTab(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// This Widget is for the Create Account Tab
  Widget _buildSignUpTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create Account',
          style: GoogleFonts.urbanist(
            textStyle: Theme.of(context).textTheme.headlineMedium,
            fontSize: 28,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 5),
        Text(
          "We are very happy to have you on board!",
          style: TextStyle(color: Colors.grey),
        ),
        SizedBox(height: 20),
        _buildTextField('Full Name'),
        SizedBox(height: 20),
        _buildTextField('Email'),
        SizedBox(height: 20),
        _buildPasswordField('Password'),
        SizedBox(height: 20),
        _buildMainButton('Get Started'),
        SizedBox(height: 20),
        Center(
            child: Text(
          'Or sign up with',
          style: GoogleFonts.roboto(
            textStyle: Theme.of(context).textTheme.headlineMedium,
            fontSize: 12,
          ),
        )),
        SizedBox(height: 20),
        _buildSocialButtons(), // This Creates the Social button
      ],
    );
  }

// This Widget is for the Log In Page
  Widget _buildLoginTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome Back!',
          style: GoogleFonts.urbanist(
            textStyle: Theme.of(context).textTheme.headlineMedium,
            fontSize: 28,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 5),
        Text(
          "Its Nice to see you again!",
          style: TextStyle(color: Colors.grey),
        ),
        SizedBox(height: 20),
        _buildTextField('Email'),
        SizedBox(height: 20),
        _buildPasswordField('Password'),
        SizedBox(height: 20),
        _buildMainButton('Login'),
        SizedBox(height: 20),
        Center(
            child: Text('Or Log In with',
                style: GoogleFonts.roboto(
                  textStyle: Theme.of(context).textTheme.headlineMedium,
                  fontSize: 12,
                ))),
        SizedBox(height: 20),
        _buildSocialButtons(),
      ],
    );
  }

//This widget is for the Text Fields
  Widget _buildTextField(String label) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color.fromARGB(255, 255, 255, 255),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: Colors.grey,
            width: 1.5,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.indigoAccent, width: 2.0),
        ),
      ),
    );
  }

//This Widget is for the Password Field
  Widget _buildPasswordField(String label) {
    return TextField(
      obscureText: obscureText, // Use the class-level variable
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color.fromARGB(255, 255, 255, 255),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText
                ? Icons.visibility_off
                : Icons.visibility, // Update the icon dynamically
          ),
          onPressed: () {
            setState(() {
              obscureText = !obscureText; // Toggle password visibility
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey, width: 1.5),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.indigoAccent, width: 2.0),
        ),
      ),
    );
  }

// This widget is for the Login or Get Started Button
  Widget _buildMainButton(String text) {
    return Center(
      child: ElevatedButton(
        /* Going to The Dashboard from here */

        onPressed: () {
          // Space for having validation here, e.g., checking if the email and password are correct
          bool isValidInput = true; // Replace this with actual validation

          if (isValidInput) {
            // Navigate to WalletScreen if the input is valid
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => WalletScreen()),
            );
            // ignore: dead_code
          } else {
            // You can show an error message or a dialog here if the input is invalid
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Invalid credentials, please try again.')),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 173, 139, 252),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          padding: EdgeInsets.symmetric(horizontal: 100, vertical: 20),
        ),
        child: Text(
          text,
          style: GoogleFonts.manrope(
              textStyle: Theme.of(context).textTheme.headlineMedium,
              color: Colors.white,
              fontSize: 16),
        ),
      ),
    );
  }

//This Widget is for the Social Button
  Widget _buildSocialButtons() {
    return Column(
      children: [
        _buildSocialButton('Continue with Google', 'google_logo.svg'),
        SizedBox(height: 20),
        _buildSocialButton('Continue with Facebook', 'facebook_logo.svg'),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSocialButton(String text, dynamic icon) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () async {
          if (text == 'Continue with Google') {
            // Google Sign-In Logic
            try {
              GoogleSignInAccount? user = await _googleSignIn.signIn();
              if (user != null) {
                // User successfully signed in
                print('Google User Info: ${user.displayName}, ${user.email}');
                // Handle user data, for example:
                // - Navigate to the next screen
                // - Store user info in the database
              } else {
                print('Google Sign-In canceled by user.');
              }
            } catch (error) {
              print('Error during Google Sign-In: $error');
            }
          } else if (text == 'Continue with Facebook') {
            // Facebook Sign-In Logic
            try {
              final LoginResult result = await FacebookAuth.instance.login();
              if (result.status == LoginStatus.success) {
                final userData = await FacebookAuth.instance.getUserData();
                print(
                    'Facebook User Info: ${userData['name']}, ${userData['email']}');
                // Handle user data
              } else {
                print(
                    'Facebook Sign-In canceled or failed: ${result.status}, ${result.message}');
              }
            } catch (error) {
              print('Error during Facebook Sign-In: $error');
            }
          }
        },
        icon: icon is IconData
            ? Icon(
                icon,
                color: Colors.black,
                size: 20,
              )
            : SvgPicture.asset(
                icon,
                height: 20,
                width: 20,
              ),
        label: Text(
          text,
          style: GoogleFonts.manrope(
              textStyle: Theme.of(context).textTheme.headlineMedium,
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
            side: BorderSide(color: Colors.black12),
          ),
          padding: EdgeInsets.symmetric(horizontal: 60, vertical: 20),
        ),
      ),
    );
  }
}

GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
