import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mypocket/Auth/Auth_Service.dart';
import 'package:mypocket/Home/WalletScreen.dart';
import 'package:mypocket/notifications/noti_services.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool obscureText = true;
  AuthService _auth = AuthService();
  final _storage = const FlutterSecureStorage();
  String _loginEmail = '';
  String _loginPassword = '';
  String _signUpFullName = '';
  String _signUpEmail = '';
  String _signUpPassword = '';
  String _phoneNumber = '';
  String _smsCode = '';
  String? _verificationId;
  int? _resendToken;
  bool _isLoading = false;
  String _errorMessage = '';
  bool _isPhoneVerificationStage = false;
  bool _isLoginWithEmail = true;
  String _loginPhoneNumber = '';
  String _loginIdentifier = '';
  String? _storedPhoneNumber; // Declare _storedPhoneNumber here

  GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  final FacebookAuth _facebookAuth =
      FacebookAuth.instance; // Declare _facebookLogin here

  final String? webClientId =
      '346366146881-1ii03f5c66ced5o67a9k9t1jqgneelbg.apps.googleusercontent.com'; // Replace with your actual Web Client ID

  NotificationServices notificationServices = NotificationServices();
  @override
  void initState() {
    super.initState();
    notificationServices.requestNotificationPermission();
    notificationServices.firebaseInit();
  //  notificationServices.isTokenRefresh();
    notificationServices.getDeviceToken().then((value) {
      print('device token');
      print(value);
    });
    _tabController = TabController(length: 2, vsync: this);
    _googleSignIn = GoogleSignIn(clientId: webClientId);
    _auth = AuthService();
    _loadStoredPhoneNumber();
  }

  Future<void> _loadStoredPhoneNumber() async {
    try {
      _storedPhoneNumber = await _storage.read(key: 'phNumber');
      if (_storedPhoneNumber != null) {
        setState(() {
          _loginIdentifier = _storedPhoneNumber!;
        });
      }
    } catch (e) {
      print('Error loading stored phone number: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 243, 243),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    SizedBox(
                      height: 660,
                      child: Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          physics: NeverScrollableScrollPhysics(),
                          children: [
                            _buildLoginTab(),
                            _buildSignUpTab(),
                          ],
                        ),
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
        SizedBox(height: 10),
        _buildTextField('Full Name', (value) => _signUpFullName = value),
        SizedBox(height: 20),
        _buildTextField('Email', (value) => _signUpEmail = value),
        SizedBox(height: 20),
        _buildTextField('Phone Number', (value) => _phoneNumber = value),
        SizedBox(height: 20),
        _buildPasswordField('Password', (value) => _signUpPassword = value),
        SizedBox(height: 20),
        _buildMainButton('Get Started', _handleSignUpGetStarted),
        SizedBox(height: 20),
        Center(
            child: Text('Or sign up with',
                style: GoogleFonts.roboto(
                    textStyle: Theme.of(context).textTheme.headlineMedium,
                    fontSize: 12))),
        SizedBox(height: 20),
        _buildSocialButtons(),
      ],
    );
  }

  Future<void> _handleSignUpGetStarted() async {
    if (_signUpFullName.isEmpty ||
        _signUpEmail.isEmpty ||
        _phoneNumber.isEmpty ||
        _signUpPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all the fields')),
      );
      return;
    }
    setState(() => _isLoading = true);

    try {
      final user = await _auth.createUserWithEmailAndPassword(
        _signUpFullName,
        _signUpEmail,
        _signUpPassword,
        _phoneNumber,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WalletScreen()),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign-up failed: $e')),
      );
    }
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
          "It's Nice to see you again!",
          style: TextStyle(color: Colors.grey),
        ),
        SizedBox(height: 20),
        _buildTextField(
            'Email or Phone Number', (value) => _loginIdentifier = value),
        SizedBox(height: 20),
        _buildPasswordField('Password', (value) => _loginPassword = value),
        SizedBox(height: 20),
        _buildMainButton('Login', _handleLogin),
        SizedBox(height: 20),
        Center(
            child: Text('Or Log In with',
                style: GoogleFonts.roboto(
                    textStyle: Theme.of(context).textTheme.headlineMedium,
                    fontSize: 12))),
        SizedBox(height: 20),
        _buildSocialButtons(),
      ],
    );
  }

  Future<void> _handleLogin() async {
    if (_loginIdentifier.isEmpty || _loginPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Please enter your Email/Phone Number and Password.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await _auth.loginUserWithEmailAndPassword(
          _loginIdentifier, _loginPassword);
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => WalletScreen()),
        );
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid Email/Phone Number or Password.')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    }
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

  Future<void> _handleGoogleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final User? user = await _auth.signInWithGoogle(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        if (user != null) {
          print('Google sign-in successful');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => WalletScreen()),
          );
        }
      }
    } catch (e) {
      print('Error signing in with Google: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing in with Google: $e')),
      );
    }
  }

  Future<void> _handleFacebookSignIn() async {
    try {
      final LoginResult result = await _facebookAuth.login();
      if (result.status == LoginStatus.success) {
        final AccessToken? accessToken = result.accessToken;
        if (accessToken != null) {
          try {
            final User? user = await _auth.signInWithFacebook(
                accessToken: accessToken.tokenString);
            if (user != null) {
              print('Facebook sign-in successful');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => WalletScreen()),
              );
            }
          } catch (e) {
            print('Error signing in with Facebook (Firebase): $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text('Error signing in with Facebook (Firebase): $e')),
            );
          }
        }
      } else {
        print('Facebook sign-in failed: ${result.status}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Facebook sign-in failed: ${result.status}')),
        );
      }
    } catch (e) {
      print('Error signing in with Facebook (Facebook Auth): $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Error signing in with Facebook (Facebook Auth): $e')),
      );
    }
  }

  void phoneAuthentication(String phNumber) {
    AuthService().phoneAuthentication(phNumber);
  }
}
