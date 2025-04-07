import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mypocket/Auth/Auth_Service.dart';
import 'package:mypocket/Home/WalletScreen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool obscureText = true;
  final AuthService _auth = AuthService();
  final _storage = const FlutterSecureStorage();
  String _loginEmail = '';
  String _loginPassword = '';
  String _signUpFullName = '';
  String _signUpEmail = '';
  String _signUpPassword = '';
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 243, 243),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
        _buildTextField('Full Name', (value) => _signUpFullName = value),
        SizedBox(height: 20),
        _buildTextField('Email', (value) => _signUpEmail = value),
        SizedBox(height: 20),
        _buildPasswordField('Password', (value) => _signUpPassword = value),
        SizedBox(height: 20),
        _buildMainButton('Get Started', _handleSignUp),
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
        _buildSocialButtons(),
      ],
    );
  }

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
        _buildTextField('Email', (value) => _loginEmail = value),
        SizedBox(height: 20),
        _buildPasswordField('Password', (value) => _loginPassword = value),
        SizedBox(height: 20),
        _buildMainButton('Login', _handleLogin),
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

  Widget _buildTextField(String label, Function(String) onChanged) {
    return TextField(
      onChanged: onChanged,
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

  Widget _buildPasswordField(String label, Function(String) onChanged) {
    return TextField(
      onChanged: onChanged,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color.fromARGB(255, 255, 255, 255),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() {
              obscureText = !obscureText;
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

  Widget _buildMainButton(String text, VoidCallback onPressed) {
    return Center(
      child: ElevatedButton(
        onPressed: onPressed,
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
            _handleGoogleSignIn();
          } else if (text == 'Continue with Facebook') {
            _handleFacebookSignIn();
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

  Future<void> _handleLogin() async {
    try {
      final user = await _auth.loginUserWithEmailAndPassword(
          _loginEmail, _loginPassword);
      if (user != null) {
        print('Login successful');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => WalletScreen()),
        );
      }
    } catch (e) {
      print('Login failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    }
  }

  Future<void> _handleSignUp() async {
    try {
      final user = await _auth.createUserWithEmailAndPassword(
          _signUpEmail, _signUpPassword);
      if (user != null) {
        print('Sign up successful');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => WalletScreen()),
        );
      }
    } catch (e) {
      print('Sign up failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign up failed: $e')),
      );
    }
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
        final user = await _auth.signInWithGoogle(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        if (user != null) {
          print(
              'Google Sign-In successful: ${googleUser.displayName}, ${googleUser.email}');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => WalletScreen()),
          );
        }
      } else {
        print('Google Sign-In canceled by user.');
      }
    } catch (error) {
      print('Error during Google Sign-In: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Sign-In failed: $error')),
      );
    }
  }

  Future<void> _handleFacebookSignIn() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        final userData = await FacebookAuth.instance.getUserData();
        // Debug: Inspect the AccessToken object
        final accessToken = result.accessToken;
        print('AccessToken: $accessToken');
        print('AccessToken type: ${accessToken.runtimeType}');
        // Use the correct property (should be 'token' in flutter_facebook_auth)
        final String? fbToken = accessToken?.token;
        if (fbToken == null) {
          throw Exception('Facebook token is null');
        }
        final user = await _auth.signInWithFacebook(accessToken: fbToken);
        if (user != null) {
          print(
              'Facebook Sign-In successful: ${userData['name']}, ${userData['email']}');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => WalletScreen()),
          );
        }
      } else {
        print(
            'Facebook Sign-In canceled or failed: ${result.status}, ${result.message}');
      }
    } catch (error) {
      print('Error during Facebook Sign-In: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Facebook Sign-In failed: $error')),
      );
    }
  }
}

extension on AccessToken? {
  String? get token => null;
}