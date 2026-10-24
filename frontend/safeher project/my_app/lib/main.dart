import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'api_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
void main() {
  runApp(SafeHerApp());
}

class SafeHerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StartPage(),
    );
  }
}

/// ---------------- START PAGE ----------------

class StartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF092A56),
              Color(0xFF0B4F8A),
              Color(0xFF0879D1),
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxHeight < 700;
              final isWide = constraints.maxWidth > 800;

              return Stack(
                children: [
                  // Top right glow
                  Positioned(
                    right: -100,
                    top: -90,
                    child: Container(
                      width: 330,
                      height: 330,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.06),
                      ),
                    ),
                  ),

                  // Bottom left glow
                  Positioned(
                    left: -150,
                    bottom: -150,
                    child: Container(
                      width: 390,
                      height: 390,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                  ),

                  Center(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isWide ? 70 : 24,
                          vertical: isSmall ? 15 : 30,
                        ),
                        child: Column(
                          children: [
                            // TOP SECTION
                            isWide
                                ? Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        flex: 5,
                                        child: _buildBrandSection(),
                                      ),
                                      Expanded(
                                        flex: 5,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            left: 20,
                                          ),
                                          child: _buildIllustration(
                                            isSmall,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      _buildBrandSection(),
                                      const SizedBox(height: 10),
                                      _buildIllustration(isSmall),
                                    ],
                                  ),

                            const SizedBox(height: 25),

                            // LOGIN CARD
                            _buildLoginCard(context),

                            const SizedBox(height: 14),

                            const Text(
                              'Your safety. Your control. Your SafeHer.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),

                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBrandSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Existing SafeHer logo style
        Container(
          width: 82,
          height: 82,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(
                Icons.shield_rounded,
                color: Colors.deepPurple,
                size: 58,
              ),
              const Icon(
                Icons.location_on_rounded,
                color: Colors.white,
                size: 25,
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // SafeHer name
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Safe',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -1.5,
                ),
              ),
              TextSpan(
                text: 'Her',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFC36BFF),
                  letterSpacing: -1.5,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 3),

        const Text(
          'Your safety companion',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 24),

        // Tagline
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 4,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFC36BFF),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(width: 14),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stay connected, stay protected.',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  'Get help when you need it most.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

 Widget _buildIllustration(bool isSmall) {
  return SizedBox(
    height: isSmall ? 250: 300,
    width: double.infinity,
    child: ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (Rect bounds) {
        return RadialGradient(
          center: Alignment.center,
          radius: 0.75,
          colors: const [
            Colors.white,
            Colors.white,
            Colors.transparent,
          ],
          stops: const [0.45, 0.72, 1.0],
        ).createShader(bounds);
      },
      child: Image.asset(
        'image/safeher_woman_shield.png',
      fit: BoxFit.cover,
      ),
    ),
  );
}

  Widget _buildLoginCard(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        maxWidth: 1000,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 34,
        vertical: 27,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(27),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.20),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Welcome to SafeHer',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF092A56),
            ),
          ),

          const SizedBox(height: 7),

          Text(
            'Login to continue or create a new account.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),

          const SizedBox(height: 22),

          // Login
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LoginPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B4F8A),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 12),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Create Account
          SizedBox(
            width: double.infinity,
            height: 54,
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SignupPage(),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0879D1),
                side: const BorderSide(
                  color: Color(0xFF0879D1),
                  width: 1.7,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          // Small shield divider
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 2,
                color: const Color(0xFFD4E4F5),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.shield_rounded,
                size: 20,
                color: Color(0xFF0879D1),
              ),
              const SizedBox(width: 12),
              Container(
                width: 90,
                height: 2,
                color: const Color(0xFFD4E4F5),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
/// ---------------- FORGOT PASSWORD PAGE ----------------
class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool otpSent = false;
  bool isSendingOtp = false;
  bool isResetting = false;
  bool obscureNewPassword = true;
  bool obscureConfirmPassword = true;

  @override
  void dispose() {
    emailController.dispose();
    otpController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> sendOtp() async {
    final email = emailController.text.trim();

    if (email.isEmpty ||
        !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address'),
        ),
      );
      return;
    }

    setState(() {
      isSendingOtp = true;
    });

    try {
      await ApiService.forgotPassword(email: email);

      if (!mounted) return;

      setState(() {
        otpSent = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP sent to your email successfully'),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send OTP: ${error.toString()}'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSendingOtp = false;
        });
      }
    }
  }

  Future<void> resetPassword() async {
    final email = emailController.text.trim();
    final otp = otpController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the OTP'),
        ),
      );
      return;
    }

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your new password'),
        ),
      );
      return;
    }

    if (newPassword.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 8 characters'),
        ),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
        ),
      );
      return;
    }

    setState(() {
      isResetting = true;
    });

    try {
      await ApiService.resetPassword(
        email: email,
        otp: otp,
        newPassword: newPassword,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset successfully!'),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LoginPage(),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reset failed: ${error.toString()}'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isResetting = false;
        });
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required TextInputType keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey[500],
          fontSize: 14,
        ),
        prefixIcon: Icon(
          icon,
          color: const Color(0xFF0879D1),
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF3F6FB),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFF0879D1),
            width: 1.5,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF092A56),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Forgot Password',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 30,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 450,
              ),
              child: Column(
                children: [
                  Container(
                    width: 78,
                    height: 78,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.lock_reset_rounded,
                      size: 44,
                      color: Color(0xFF0879D1),
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'Reset Your Password',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF092A56),
                    ),
                  ),

                  const SizedBox(height: 7),

                  Text(
                    otpSent
                        ? 'Enter the OTP sent to your email'
                        : 'Enter your registered email to receive an OTP',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),

                  const SizedBox(height: 28),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Email Address',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF092A56),
                          ),
                        ),

                        const SizedBox(height: 8),

                        _buildTextField(
                          controller: emailController,
                          hintText: 'Enter your registered email',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),

                        const SizedBox(height: 18),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: isSendingOtp ? null : sendOtp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0879D1),
                              disabledBackgroundColor:
                                  const Color(0xFF9BBED8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: isSendingOtp
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    otpSent ? 'Resend OTP' : 'Send OTP',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),

                        if (otpSent) ...[
                          const SizedBox(height: 26),

                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF5FF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.mark_email_read_outlined,
                                  color: Color(0xFF0879D1),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'OTP has been sent to ${emailController.text.trim()}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF092A56),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          const Text(
                            'Enter OTP',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF092A56),
                            ),
                          ),

                          const SizedBox(height: 8),

                          _buildTextField(
                            controller: otpController,
                            hintText: 'Enter 6-digit OTP',
                            icon: Icons.pin_outlined,
                            keyboardType: TextInputType.number,
                          ),

                          const SizedBox(height: 18),

                          const Text(
                            'New Password',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF092A56),
                            ),
                          ),

                          const SizedBox(height: 8),

                          _buildTextField(
                            controller: newPasswordController,
                            hintText: 'Enter new password',
                            icon: Icons.lock_outline_rounded,
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: obscureNewPassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscureNewPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.grey[600],
                              ),
                              onPressed: () {
                                setState(() {
                                  obscureNewPassword =
                                      !obscureNewPassword;
                                });
                              },
                            ),
                          ),

                          const SizedBox(height: 18),

                          const Text(
                            'Confirm Password',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF092A56),
                            ),
                          ),

                          const SizedBox(height: 8),

                          _buildTextField(
                            controller: confirmPasswordController,
                            hintText: 'Confirm new password',
                            icon: Icons.lock_reset_outlined,
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: obscureConfirmPassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscureConfirmPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.grey[600],
                              ),
                              onPressed: () {
                                setState(() {
                                  obscureConfirmPassword =
                                      !obscureConfirmPassword;
                                });
                              },
                            ),
                          ),

                          const SizedBox(height: 24),

                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed:
                                  isResetting ? null : resetPassword,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFF092A56),
                                disabledBackgroundColor:
                                    const Color(0xFF7890AA),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 0,
                              ),
                              child: isResetting
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Reset Password',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Back to Login',
                      style: TextStyle(
                        color: Color(0xFF0879D1),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Your safety. Your control. Your SafeHer.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
/// ---------------- HOME PAGE ----------------
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool voiceEnabled = false;
  late stt.SpeechToText _speech;
  bool isListening = false;
  String spokenText = '';
  String secretWord = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }
  Future<bool> _loadSecretWord() async {
  try {
    final user = await ApiService.getUser();

    final savedWord =
        (user['secretWord'] ?? '').toString().trim();

    if (!mounted) return false;

    setState(() {
      secretWord = savedWord;
    });

    if (savedWord.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please set your Secret Word from Profile first.',
          ),
        ),
      );

      return false;
    }

    return true;
  } catch (e) {
    debugPrint('Failed to load secret word: $e');

    if (!mounted) return false;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Unable to load secret word.',
        ),
      ),
    );

    return false;
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),

      // =====================================================
      // APP BAR
      // =====================================================
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: const Color(0xFF092A56),
        foregroundColor: Colors.white,
        titleSpacing: 18,

        title: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.shield_rounded,
                    color: Colors.deepPurple,
                    size: 33,
                  ),
                  const Icon(
                    Icons.location_on_rounded,
                    color: Colors.white,
                    size: 13,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 11),

            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SafeHer',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Your safety companion',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ),

        actions: [
          Container(
            margin: const EdgeInsets.only(right: 15),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              size: 25,
            ),
          ),
        ],
      ),

      // =====================================================
      // BODY
      // =====================================================
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // =====================================================
              // WELCOME
              // =====================================================
              const Text(
                'Welcome back! 👋',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF12243D),
                ),
              ),

              const SizedBox(height: 5),

              Text(
                'Your safety matters. We are here for you.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 20),

              // =====================================================
              // SAFETY STATUS
              // =====================================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.08),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.10),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shield_rounded,
                        color: Colors.green,
                        size: 25,
                      ),
                    ),

                    const SizedBox(width: 12),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Safety is Active',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF172033),
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Emergency protection is ready',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.green,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // =====================================================
              // SOS TITLE
              // =====================================================
              const Center(
                child: Text(
                  'Emergency SOS',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF12243D),
                  ),
                ),
              ),

              const SizedBox(height: 5),

              Center(
                child: Text(
                  'Press the button when you need immediate help',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // =====================================================
              // SOS BUTTON
              // =====================================================
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SOSPage(),
                      ),
                    );
                  },
                  child: Container(
                    width: 178,
                    height: 178,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red[700],
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.28),
                          blurRadius: 25,
                          spreadRadius: 7,
                        ),
                      ],
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red[600],
                        border: Border.all(
                          color: Colors.white.withOpacity(0.35),
                          width: 2,
                        ),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.white,
                            size: 36,
                          ),

                          SizedBox(height: 2),

                          Text(
                            'SOS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),

                          SizedBox(height: 1),

                          Text(
                            'EMERGENCY',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              const Center(
                child: Text(
                  'Press in emergency',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF50627A),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // =====================================================
              // LOCATION STATUS
              // =====================================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF5FF),
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.10),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.location_on_rounded,
                        color: Color(0xFF0879D1),
                        size: 24,
                      ),
                    ),

                    const SizedBox(width: 12),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your location is active',
                            style: TextStyle(
                              color: Color(0xFF123B68),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),

                          SizedBox(height: 3),

                          Text(
                            'Location will be shared during SOS',
                            style: TextStyle(
                              color: Color(0xFF647A91),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.blue,
                      size: 21,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // =====================================================
              // VOICE SOS
              // =====================================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(
                    color: voiceEnabled
                        ? Colors.red.withOpacity(0.25)
                        : Colors.blue.withOpacity(0.07),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.035),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: voiceEnabled
                            ? Colors.red.withOpacity(0.10)
                            : const Color(0xFFE8F0FF),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.mic_rounded,
                        color: voiceEnabled
                            ? Colors.red
                            : const Color(0xFF1769AA),
                        size: 24,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Voice SOS',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF172033),
                            ),
                          ),

                          SizedBox(height: 3),

                          Text(
                            isListening
                    ? 'Listening... Say your secret word'
                     : 'Say your secret word to trigger SOS',
               style: TextStyle(
               color: isListening
                  ? const Color(0xFFE53935)
                    : Colors.grey,
                     fontSize: 14,
                           ),
                          ),
                        ],
                      ),
                    ),

                    Switch(
                      value: voiceEnabled,
                      activeColor: Colors.red,

                      // onChanged: (value) async {
                      //   if (value) {
                      //     bool available =
                      //         await _speech.initialize();

                      //     if (available) {
                      //       setState(() {
                      //         isListening = true;
                      //         voiceEnabled = true;
                      //       });

                      //       _speech.listen(
                      //         onResult: (result) {
                      //           setState(() {
                      //             spokenText =
                      //                 result.recognizedWords;
                      //           });

                      //           if (spokenText
                      //               .toLowerCase()
                      //               .contains('help')) {
                      //             ScaffoldMessenger.of(context)
                      //                 .showSnackBar(
                      //               const SnackBar(
                      //                 content: Text(
                      //                   'SOS Triggered 🚨',
                      //                 ),
                      //               ),
                      //             );
                      //           }
                      //         },
                      //       );
                      //     }
                      //   } else {
                      //     setState(() {
                      //       isListening = false;
                      //       voiceEnabled = false;
                      //     });

                      //     _speech.stop();
                      //   }
                      // },
                      onChanged: (value) async {
  if (value) {
    // 1. Profile se secret word load karo
    final loaded = await _loadSecretWord();

    if (!loaded) {
      return;
    }

    // 2. Speech recognition start karo
    bool available = await _speech.initialize( onStatus: (status) {
    debugPrint('Speech status: $status');
  },
  onError: (error) {
    debugPrint('Speech error: $error');
  },);

    if (available) {
      setState(() {
        isListening = true;
        voiceEnabled = true;
      });

      _speech.listen(
        listenFor: const Duration(seconds: 60),
  pauseFor: const Duration(seconds: 20),
  onResult: (result) {
    debugPrint('SPOKEN: ${result.recognizedWords}');
    debugPrint('FINAL: ${result.finalResult}');

    final spoken =
        result.recognizedWords.toLowerCase().trim();

    setState(() {
      spokenText = result.recognizedWords;
    });

          // 3. Profile ke secret word se compare karo
          final savedSecretWord =
              secretWord.toLowerCase().trim();

          if (savedSecretWord.isNotEmpty &&
              spoken.contains(savedSecretWord)) {

            // Listening stop
            _speech.stop();

            setState(() {
              isListening = false;
              voiceEnabled = false;
            });

            // 4. SOS trigger
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Secret word detected. SOS activating 🚨',
                ),
              ),
            );

            // 5. Existing SOSPage open karo
            Future.delayed(
              const Duration(milliseconds: 500),
              () {
                if (!mounted) return;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SOSPage(),
                  ),
                );
              },
            );
          }
        },
      );
    }
  } else {
    // Voice SOS OFF
    setState(() {
      isListening = false;
      voiceEnabled = false;
    });

    _speech.stop();
  }
},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // =====================================================
      // CHATBOT FLOATING BUTTON
      // =====================================================
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0B4F8A).withOpacity(0.30),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: const Color(0xFF0B4F8A),
          elevation: 0,

          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatBotPage(),
              ),
            );
          },

          child: const Icon(
            Icons.chat_bubble_outline_rounded,
            color: Colors.white,
            size: 27,
          ),
        ),
      ),

      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat,

      // =====================================================
      // BOTTOM NAVIGATION
      // =====================================================
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF092A56),
        elevation: 15,
        child: SizedBox(
          height: 64,

          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [

              // =====================================================
              // HOME
              // =====================================================
              IconButton(
                splashRadius: 25,
                icon: const Icon(
                  Icons.home_rounded,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: () {},
              ),

              // =====================================================
              // MAP
              // =====================================================
              IconButton(
                splashRadius: 25,
                icon: const Icon(
                  Icons.location_on_rounded,
                  color: Colors.white70,
                  size: 27,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MapPage(),
                    ),
                  );
                },
              ),

              // Space for FAB
              const SizedBox(width: 42),

              // =====================================================
              // EMERGENCY CONTACTS
              // =====================================================
              IconButton(
                splashRadius: 25,
                icon: const Icon(
                  Icons.people_alt_rounded,
                  color: Colors.white70,
                  size: 27,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EmergencyPage(),
                    ),
                  );
                },
              ),

              // =====================================================
              // PROFILE
              // =====================================================
              IconButton(
                splashRadius: 25,
                icon: const Icon(
                  Icons.person_rounded,
                  color: Colors.white70,
                  size: 27,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfilePage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
/// ---------------- MAP PAGE ----------------

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final TextEditingController destinationController =
      TextEditingController();

  final MapController _mapController = MapController();

  latlong.LatLng _currentLocation =
      const latlong.LatLng(28.6139, 77.2090);

  latlong.LatLng _destinationLocation =
      const latlong.LatLng(28.6139, 77.2090);

  List<latlong.LatLng> _routePoints = [];

  bool _mapReady = false;
  bool _isFullScreen = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
  }

  @override
  void dispose() {
    destinationController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentLocation() async {
    try {
      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location permission is required to show your current location.',
            ),
          ),
        );

        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;

      setState(() {
        _currentLocation = latlong.LatLng(
          position.latitude,
          position.longitude,
        );

        _destinationLocation = _currentLocation;
      });

      if (_mapReady) {
        _mapController.move(_currentLocation, 14);
      }
    } catch (_) {
      if (!mounted) return;
    }
  }

  Future<void> _searchDestination(String query) async {
    final text = query.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a location to search'),
        ),
      );

      return;
    }

    try {
      setState(() => _isSearching = true);

      final results =
          await ApiService.searchMapPlaces(query: text);

      if (results.isEmpty) {
        throw Exception('No matching place found');
      }

      final result = results.first as Map<String, dynamic>;

      final lat = (result['latitude'] as num).toDouble();
      final lng = (result['longitude'] as num).toDouble();

      final placeLocation = latlong.LatLng(lat, lng);

      if (!mounted) return;

      setState(() {
        _destinationLocation = placeLocation;

        destinationController.text =
            result['name']?.toString() ?? text;
      });

      if (_mapReady) {
        _mapController.move(placeLocation, 14);
      }
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to find destination: ${error.toString()}',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  Future<void> _findSafeRoute() async {
    if (_currentLocation == _destinationLocation) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Select a destination before finding a safe route',
          ),
        ),
      );

      return;
    }

    try {
      final route = await ApiService.getWalkingRoute(
        startLatitude: _currentLocation.latitude,
        startLongitude: _currentLocation.longitude,
        endLatitude: _destinationLocation.latitude,
        endLongitude: _destinationLocation.longitude,
      );

      final routePoints =
          (route['points'] as List<dynamic>)
              .map(
                (point) => latlong.LatLng(
                  (point['latitude'] as num).toDouble(),
                  (point['longitude'] as num).toDouble(),
                ),
              )
              .toList();

      if (routePoints.length < 2) {
        throw Exception('No walking route available');
      }

      if (!mounted) return;

      setState(() {
        _routePoints = routePoints;
      });

      if (_mapReady) {
        _mapController.fitCamera(
          CameraFit.coordinates(
            coordinates: routePoints,
            padding: const EdgeInsets.all(48),
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to calculate safe route: ${error.toString()}',
          ),
        ),
      );
    }
  }

  Future<void> _goToCurrentLocation() async {
    if (_currentLocation ==
        const latlong.LatLng(28.6139, 77.2090)) {
      await _loadCurrentLocation();
    }

    if (_mapReady) {
      _mapController.move(_currentLocation, 14);
    }
  }
  void _clearRoute() {
    setState(() {
      _routePoints = [];
    });
  }

  Widget _buildMapView() {
    final mapMarkers = <Marker>[
      Marker(
        point: _currentLocation,
        width: 38,
        height: 38,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.20),
                blurRadius: 8,
              ),
            ],
          ),
          child: const Icon(
            Icons.my_location_rounded,
            color: Color(0xFFE53935),
            size: 26,
          ),
        ),
      ),

      if (_destinationLocation != _currentLocation)
        Marker(
          point: _destinationLocation,
          width: 38,
          height: 38,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.20),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: Color(0xFF00A86B),
              size: 28,
            ),
          ),
        ),
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(
        _isFullScreen ? 0 : 20,
      ),
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _currentLocation,
          initialZoom: 14,
          onMapReady: () {
            _mapReady = true;
            _mapController.move(_currentLocation, 14);
          },
          onTap: (tapPosition, point) {
            setState(() {
              _destinationLocation = point;
              destinationController.text = 'Selected on map';
            });
          },
        ),
        children: [
          TileLayer(
            urlTemplate:
                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.safeher',
          ),

          if (_routePoints.length > 1)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: _routePoints,
                  strokeWidth: 8,
                  color: const Color(0xFF00A86B),
                  borderColor: Colors.white,
                  borderStrokeWidth: 4,
                ),
              ],
            ),

          MarkerLayer(
            markers: mapMarkers,
          ),

          RichAttributionWidget(
            attributions: [
              TextSourceAttribution(
                'OpenStreetMap contributors',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _mapControlButton({
    required String heroTag,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: FloatingActionButton.small(
        heroTag: heroTag,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF092A56),
        elevation: 0,
        onPressed: onPressed,
        child: Icon(icon),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),

      appBar: _isFullScreen
          ? null
          : AppBar(
              automaticallyImplyLeading: true,
              backgroundColor: const Color(0xFF092A56),
              foregroundColor: Colors.white,
              elevation: 0,
              title: const Text(
                'Safe Route Map',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
            ),

      body: SafeArea(
        child: Column(
          children: [
            if (!_isFullScreen)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  12,
                ),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.blue.withOpacity(0.08),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: destinationController,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.search,
                        onSubmitted: _searchDestination,
                        decoration: InputDecoration(
                          hintText: 'Where do you want to go?',
                          hintStyle: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 13,
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: Color(0xFF0B4F8A),
                          ),
                          suffixIcon: _isSearching
                              ? const Padding(
                                  padding: EdgeInsets.all(14),
                                  child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : IconButton(
                                  icon: const Icon(
                                    Icons.arrow_forward_rounded,
                                    color: Color(0xFF0B4F8A),
                                  ),
                                  onPressed: () {
                                    _searchDestination(
                                      destinationController.text,
                                    );
                                  },
                                ),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _findSafeRoute,
                        icon: const Icon(
                          Icons.shield_rounded,
                          size: 21,
                        ),
                        label: const Text(
                          'Suggest Safe Route',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF0B4F8A),
                          foregroundColor: Colors.white,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            Expanded(
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      _isFullScreen ? 0 : 12,
                      0,
                      _isFullScreen ? 0 : 12,
                      _isFullScreen ? 0 : 12,
                    ),
                    child: _buildMapView(),
                  ),

                  Positioned(
                    top: 15,
                    right: 15,
                    child: Column(
                      children: [
                        _mapControlButton(
                          heroTag: 'my_location',
                          icon: Icons.my_location_rounded,
                          onPressed: _goToCurrentLocation,
                        ),

                        const SizedBox(height: 9),

                        _mapControlButton(
                          heroTag: 'zoom_in',
                          icon: Icons.add_rounded,
                          onPressed: () {
                            _mapController.move(
                              _mapController.camera.center,
                              _mapController.camera.zoom + 1,
                            );
                          },
                        ),

                        const SizedBox(height: 9),

                        _mapControlButton(
                          heroTag: 'zoom_out',
                          icon: Icons.remove_rounded,
                          onPressed: () {
                            _mapController.move(
                              _mapController.camera.center,
                              _mapController.camera.zoom - 1,
                            );
                          },
                        ),

                        const SizedBox(height: 9),

                        _mapControlButton(
                          heroTag: 'fullscreen',
                          icon: _isFullScreen
                              ? Icons.fullscreen_exit_rounded
                              : Icons.fullscreen_rounded,
                          onPressed: () {
                            setState(() {
                              _isFullScreen = !_isFullScreen;
                            });
                          },
                        ),

                        const SizedBox(height: 9),

                        _mapControlButton(
                          heroTag: 'clear_route',
                          icon: Icons.clear_rounded,
                          onPressed: _clearRoute,
                        ),
                      ],
                    ),
                  ),

                  if (_routePoints.length > 1)
                    Positioned(
                      left: 25,
                      bottom: 27,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  Colors.black.withOpacity(0.12),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.shield_rounded,
                              color: Color(0xFF00A86B),
                              size: 18,
                            ),
                            SizedBox(width: 7),
                            Text(
                              'Safe route active',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF123B68),
                              ),
                            ),
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
    );
  }
}

/// ---------------- SignupPage ----------------

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  Future<void> signup() async {
    final name = nameController.text.trim();
    final contact = contactController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (name.isEmpty ||
        contact.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All fields are required'),
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await ApiService.register(
        name: name,
        email: email,
        password: password,
        phone: contact,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully!'),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LoginPage(),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Registration failed: ${error.toString()}',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    contactController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),

      appBar: AppBar(
        backgroundColor: const Color(0xFF092A56),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'SafeHer',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 21,
          ),
        ),
      ),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 25,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 450,
              ),
              child: Column(
                children: [
                  // SafeHer Logo
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.10),
                          blurRadius: 18,
                          offset: const Offset(0, 7),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: const [
                        Icon(
                          Icons.shield_rounded,
                          color: Colors.deepPurple,
                          size: 50,
                        ),
                        Icon(
                          Icons.location_on_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Create Your Account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF092A56),
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Join SafeHer and stay connected & protected',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Signup Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Full Name',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF092A56),
                          ),
                        ),

                        const SizedBox(height: 8),

                        _buildTextField(
                          controller: nameController,
                          hintText: 'Enter your full name',
                          icon: Icons.person_outline_rounded,
                          keyboardType: TextInputType.name,
                        ),

                        const SizedBox(height: 16),

                        const Text(
                          'Contact Number',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF092A56),
                          ),
                        ),

                        const SizedBox(height: 8),

                        _buildTextField(
                          controller: contactController,
                          hintText: 'Enter your contact number',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),

                        const SizedBox(height: 16),

                        const Text(
                          'Email',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF092A56),
                          ),
                        ),

                        const SizedBox(height: 8),

                        _buildTextField(
                          controller: emailController,
                          hintText: 'Enter your email',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),

                        const SizedBox(height: 16),

                        const Text(
                          'Password',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF092A56),
                          ),
                        ),

                        const SizedBox(height: 8),

                        _buildTextField(
                          controller: passwordController,
                          hintText: 'Create a password',
                          icon: Icons.lock_outline_rounded,
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: obscurePassword,
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        const Text(
                          'Confirm Password',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF092A56),
                          ),
                        ),

                        const SizedBox(height: 8),

                        _buildTextField(
                          controller: confirmPasswordController,
                          hintText: 'Re-enter your password',
                          icon: Icons.lock_reset_outlined,
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: obscureConfirmPassword,
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                obscureConfirmPassword =
                                    !obscureConfirmPassword;
                              });
                            },
                            icon: Icon(
                              obscureConfirmPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        // Signup Button
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : signup,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0B4F8A),
                              disabledBackgroundColor:
                                  const Color(0xFF8BA9C4),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 23,
                                    height: 23,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Create Account',
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 22,
                                      ),
                                    ],
                                  ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        // Login link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account?',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 14,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => LoginPage(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Login',
                                style: TextStyle(
                                  color: Color(0xFF0879D1),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'Your safety. Your control. Your SafeHer.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required TextInputType keyboardType,
    bool obscureText = false,
    IconButton? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey[500],
          fontSize: 14,
        ),
        prefixIcon: Icon(
          icon,
          color: const Color(0xFF0879D1),
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF3F6FB),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFF0879D1),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
// ---------------- LoginPage ----------------
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
  }

  Future<void> _loadSavedEmail() async {
    final savedEmail = await ApiService.getLastLoginEmail();

    if (!mounted || savedEmail == null || savedEmail.isEmpty) {
      return;
    }

    setState(() {
      emailController.text = savedEmail;
      emailController.selection = TextSelection.fromPosition(
        TextPosition(offset: savedEmail.length),
      );
    });
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter email and password'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await ApiService.login(
        email: email,
        password: password,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomePage(),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Login failed: ${error.toString()}',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),

      appBar: AppBar(
        backgroundColor: const Color(0xFF092A56),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'SafeHer',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 21,
          ),
        ),
      ),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 30,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 450,
              ),
              child: Column(
                children: [
                  // SafeHer Logo
                  Container(
                    width: 78,
                    height: 78,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.10),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: const [
                        Icon(
                          Icons.shield_rounded,
                          color: Colors.deepPurple,
                          size: 55,
                        ),
                        Icon(
                          Icons.location_on_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF092A56),
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Login to continue using SafeHer',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Login Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Email',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF092A56),
                          ),
                        ),

                        const SizedBox(height: 8),

                        _buildTextField(
                          controller: emailController,
                          hintText: 'Enter your email',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),

                        const SizedBox(height: 18),

                        const Text(
                          'Password',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF092A56),
                          ),
                        ),

                        const SizedBox(height: 8),

                        _buildTextField(
                          controller: passwordController,
                          hintText: 'Enter your password',
                          icon: Icons.lock_outline_rounded,
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: obscurePassword,
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),

                        const SizedBox(height: 6),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ForgotPasswordPage(),
                                ),
                              );
                            },
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: Color(0xFF0879D1),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0B4F8A),
                              disabledBackgroundColor:
                                  const Color(0xFF8BA9C4),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 23,
                                    height: 23,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Login',
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 22,
                                      ),
                                    ],
                                  ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        // Divider
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 1,
                                color: Colors.grey[300],
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                'OR',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 1,
                                color: Colors.grey[300],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Signup
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'New user?',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 14,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SignupPage(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Create Account',
                                style: TextStyle(
                                  color: Color(0xFF0879D1),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Your safety. Your control. Your SafeHer.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

Widget _buildTextField({
  required TextEditingController controller,
  required String hintText,
  required IconData icon,
  required TextInputType keyboardType,
  bool obscureText = false,
  IconButton? suffixIcon,
}) {
  return TextField(
    controller: controller,
    keyboardType: keyboardType,
    obscureText: obscureText,
    decoration: InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: Colors.grey[500],
        fontSize: 14,
      ),
      prefixIcon: Icon(
        icon,
        color: const Color(0xFF0879D1),
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF3F6FB),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFF0879D1),
          width: 1.5,
        ),
      ),
    ),
  );
}
}

// /// ---------------- PROFILE PAGE ----------------
class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userName = 'User Name';
  String userEmail = 'user@email.com';
  String secretWord = '';
  String homeAddress = '';

  XFile? profileImage;
  bool showSecretWord = false;
  @override
void initState() {
  super.initState();
  loadUserProfile();
}

Future<void> loadUserProfile() async {
  try {
    final user = await ApiService.getUser();

    if (!mounted) return;

    setState(() {
      userName = user['name'] ?? 'User Name';
      userEmail = user['email'] ?? 'user@email.com';
      secretWord = user['secretWord'] ?? '';
      homeAddress = user['homeAddress'] ?? '';

    });
  } catch (e) {
    debugPrint('Failed to load profile: $e');
  }
}

  Future<void> pickProfileImage() async {
    final picker = ImagePicker();

    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (pickedImage != null) {
      setState(() {
        profileImage = pickedImage;
      });
    }
  }

  void removeProfileImage() {
    setState(() {
      profileImage = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile photo removed'),
      ),
    );
  }

  void showProfilePhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(22),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Profile Photo',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF12243D),
                  ),
                ),

                const SizedBox(height: 18),

                _bottomSheetOption(
                  icon: Icons.photo_library_rounded,
                  title: 'Choose from Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    pickProfileImage();
                  },
                ),

                if (profileImage != null)
                  _bottomSheetOption(
                    icon: Icons.delete_outline_rounded,
                    title: 'Remove Photo',
                    iconColor: Colors.red,
                    titleColor: Colors.red,
                    onTap: () {
                      Navigator.pop(context);
                      removeProfileImage();
                    },
                  ),

                _bottomSheetOption(
                  icon: Icons.close_rounded,
                  title: 'Cancel',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _bottomSheetOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = const Color(0xFF0B4F8A),
    Color titleColor = const Color(0xFF172033),
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 3,
      ),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: iconColor,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: onTap,
    );
  }

  void showEditProfileDialog() {
    final nameController = TextEditingController(text: userName);
    final emailController = TextEditingController(text: userEmail);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Edit Profile',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF12243D),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Name',
                  prefixIcon: const Icon(
                    Icons.person_outline_rounded,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B4F8A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              // onPressed: () {
              //   final name = nameController.text.trim();
              //   final email = emailController.text.trim();

              //   if (name.isEmpty || email.isEmpty) {
              //     ScaffoldMessenger.of(context).showSnackBar(
              //       const SnackBar(
              //         content: Text('Name and email cannot be empty'),
              //       ),
              //     );
              //     return;
              //   }

              //   setState(() {
              //     userName = name;
              //     userEmail = email;
              //   });

              //   Navigator.pop(context);

              //   ScaffoldMessenger.of(context).showSnackBar(
              //     const SnackBar(
              //       content: Text('Profile updated successfully'),
              //     ),
              //   );
              // },
              onPressed: () async {
  final name = nameController.text.trim();
  final email = emailController.text.trim();

  if (name.isEmpty || email.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Name and email cannot be empty'),
      ),
    );
    return;
  }

  try {
    final response = await ApiService.updateProfile(
      name: name,
      email: email,
    );

    if (!mounted) return;

    setState(() {
      userName = response['user']['name'] ?? name;
      userEmail = response['user']['email'] ?? email;
    });

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully'),
      ),
    );
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to update profile: $e'),
      ),
    );
  }
},
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void showSecretWordDialog() {
    final secretController = TextEditingController(
      text: secretWord,
    );

    bool dialogObscure = true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Secret Word',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF12243D),
                ),
              ),
              content: TextField(
                controller: secretController,
                obscureText: dialogObscure,
                decoration: InputDecoration(
                  labelText: 'Secret Word',
                  hintText: 'Enter your secret word',
                  prefixIcon: const Icon(
                    Icons.lock_outline_rounded,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      dialogObscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      setDialogState(() {
                        dialogObscure = !dialogObscure;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),

                // ElevatedButton(
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: const Color(0xFF0B4F8A),
                //     foregroundColor: Colors.white,
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(10),
                //     ),
                //   ),
                //   onPressed: () {
                //     final value = secretController.text.trim();

                //     if (value.isEmpty) {
                //       ScaffoldMessenger.of(context).showSnackBar(
                //         const SnackBar(
                //           content: Text('Please enter a secret word'),
                //         ),
                //       );
                //       return;
                //     }

                //     setState(() {
                //       secretWord = value;
                //     });

                //     Navigator.pop(context);

                //     ScaffoldMessenger.of(context).showSnackBar(
                //       const SnackBar(
                //         content: Text('Secret word saved'),
                //       ),
                //     );
                //   },
                //   child: const Text('Save'),
                // ),
                ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF0B4F8A),
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  ),
  onPressed: () async {
    final value = secretController.text.trim();

    if (value.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a secret word'),
        ),
      );
      return;
    }

    try {
      final response = await ApiService.updateProfile(
        secretWord: value,
      );

      if (!mounted) return;

      setState(() {
        secretWord = response['user']['secretWord'] ?? value;
      });

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Secret word saved'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save secret word: $e'),
        ),
      );
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
  }

  void showAddressDialog() {
    final addressController = TextEditingController(
      text: homeAddress,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Home Address',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF12243D),
            ),
          ),
          content: TextField(
            controller: addressController,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: 'Main / Home Address',
              hintText: 'Enter your home address',
              prefixIcon: const Padding(
                padding: EdgeInsets.only(bottom: 45),
                child: Icon(
                  Icons.home_outlined,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),

            // ElevatedButton(
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: const Color(0xFF0B4F8A),
            //     foregroundColor: Colors.white,
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(10),
            //     ),
            //   ),
            //   onPressed: () {
            //     setState(() {
            //       homeAddress = addressController.text.trim();
            //     });

            //     Navigator.pop(context);

            //     ScaffoldMessenger.of(context).showSnackBar(
            //       const SnackBar(
            //         content: Text('Home address updated'),
            //       ),
            //     );
            //   },
            //   child: const Text('Save'),
            // ),
            ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF0B4F8A),
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  ),
  onPressed: () async {
    final address = addressController.text.trim();

    if (address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your home address'),
        ),
      );
      return;
    }

    try {
      final response = await ApiService.updateProfile(
        homeAddress: address,
      );

      if (!mounted) return;

      setState(() {
        homeAddress = response['user']['homeAddress'] ?? address;
      });

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Home address updated'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update home address: $e'),
        ),
      );
    }
  },
  child: const Text('Save'),
),
          ],
        );
      },
    );
  }

  String get secretWordDisplay {
    if (secretWord.isEmpty) {
      return 'Not set';
    }

    if (!showSecretWord) {
      return '••••••••';
    }

    return secretWord;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),

      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF092A56),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 25, 20, 30),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 25,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: showProfilePhotoOptions,
                        child: Container(
                          width: 92,
                          height: 92,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F0FF),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF0B4F8A)
                                  .withOpacity(0.15),
                              width: 2,
                            ),
                            image: profileImage != null
                                ? DecorationImage(
                                    image: FileImage(
                                      File(profileImage!.path),
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: profileImage == null
                              ? const Icon(
                                  Icons.person_rounded,
                                  size: 47,
                                  color: Color(0xFF0B4F8A),
                                )
                              : null,
                        ),
                      ),

                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: GestureDetector(
                          onTap: showProfilePhotoOptions,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0B4F8A),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              size: 15,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Text(
                    userName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF12243D),
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    userEmail,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified_user_rounded,
                          size: 15,
                          color: Colors.green,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Safety Account Active',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            _profileOption(
              icon: Icons.edit_rounded,
              title: 'Edit Profile',
              subtitle: 'Update your name and email',
              onTap: showEditProfileDialog,
            ),

            const SizedBox(height: 12),

            _profileOption(
              icon: Icons.people_alt_rounded,
              title: 'Emergency Contacts',
              subtitle: 'Manage people who receive SOS alerts',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EmergencyPage(),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            _profileOption(
              icon: Icons.lock_rounded,
              title: 'Secret Word',
              subtitle: secretWord.isEmpty
                  ? 'Set a word for voice SOS'
                  : 'Secret word is set',
              trailing: secretWord.isNotEmpty
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          secretWordDisplay,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF0B4F8A),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            showSecretWord
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 19,
                            color: const Color(0xFF0B4F8A),
                          ),
                          onPressed: () {
                            setState(() {
                              showSecretWord = !showSecretWord;
                            });
                          },
                        ),
                      ],
                    )
                  : null,
              onTap: showSecretWordDialog,
            ),

            const SizedBox(height: 12),

            _profileOption(
              icon: Icons.home_rounded,
              title: 'Home Address',
              subtitle: homeAddress.isEmpty
                  ? 'Add your main address'
                  : homeAddress,
              onTap: showAddressDialog,
            ),

            const SizedBox(height: 12),

            _profileOption(
              icon: Icons.logout_rounded,
              title: 'Logout',
              subtitle: 'Sign out from your account',
              iconColor: Colors.red,
              titleColor: Colors.red,
              onTap: () async {
                await ApiService.logout();

                if (!mounted) return;

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StartPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
    Color iconColor = const Color(0xFF0B4F8A),
    Color titleColor = const Color(0xFF172033),
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: Colors.blue.withOpacity(0.07),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.035),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.09),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 23,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              if (trailing != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: trailing,
                )
              else
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.grey[500],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
/// ---------------- EMERGENCY PAGE ----------------
class EmergencyPage extends StatefulWidget {
  @override
  _EmergencyPageState createState() => _EmergencyPageState();
}

class _EmergencyPageState extends State<EmergencyPage> {
  List<Map<String, dynamic>> contacts = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadContacts();
  }

  // ================= LOAD CONTACTS =================

  Future<void> loadContacts() async {
    if (mounted) {
      setState(() => isLoading = true);
    }

    try {
      final result = await ApiService.getContacts();

      if (!mounted) return;

      setState(() {
        contacts = result.map<Map<String, dynamic>>((contact) {
          return {
            'id': contact['_id']?.toString() ?? '',
            'name': contact['name']?.toString() ?? 'Emergency Contact',
            'phone': contact['phone']?.toString() ?? '',
            'email': contact['email']?.toString() ?? '',
          };
        }).toList();
      });
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to load contacts: ${error.toString()}',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // ================= ADD CONTACT =================

  Future<void> addContact(
    String name,
    String phone,
    String email,
  ) async {
    if (name.isEmpty || (phone.isEmpty && email.isEmpty)) {
      return;
    }

    try {
      await ApiService.addContact(
        name: name,
        phone: phone,
        email: email,
      );

      await loadContacts();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contact added successfully'),
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to add contact: ${error.toString()}',
          ),
        ),
      );
    }
  }

  // ================= UPDATE CONTACT =================

  Future<void> updateContact(
    String id,
    String name,
    String phone,
    String email,
  ) async {
    if (id.isEmpty ||
        name.isEmpty ||
        (phone.isEmpty && email.isEmpty)) {
      return;
    }

    try {
      await ApiService.updateContact(
        id: id,
        name: name,
        phone: phone,
        email: email,
      );

      await loadContacts();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contact updated successfully'),
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update contact: ${error.toString()}',
          ),
        ),
      );
    }
  }

  // ================= DELETE CONTACT =================

  Future<void> deleteContact(String id) async {
    if (id.isEmpty) return;

    try {
      await ApiService.deleteContact(id: id);

      await loadContacts();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contact deleted successfully'),
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to delete contact: ${error.toString()}',
          ),
        ),
      );
    }
  }

  // ================= ADD DIALOG =================

  void showAddDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Add Emergency Contact',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF092A56),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Name *',
                    hintText: 'Enter contact name',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    hintText: '+919876543210',
                    helperText: 'Optional',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    hintText: 'example@gmail.com',
                    helperText: 'Optional',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Enter at least a phone number or an email address.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B4F8A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                final name = nameController.text.trim();
                final phone = phoneController.text.trim();
                final email = emailController.text.trim();

                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter contact name'),
                    ),
                  );
                  return;
                }

                if (phone.isEmpty && email.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Enter phone number or email address',
                      ),
                    ),
                  );
                  return;
                }

                addContact(name, phone, email);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // ================= EDIT DIALOG =================

  void showEditDialog(Map<String, dynamic> contact) {
    final nameController =
        TextEditingController(text: contact['name'] ?? '');

    final phoneController =
        TextEditingController(text: contact['phone'] ?? '');

    final emailController =
        TextEditingController(text: contact['email'] ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Edit Emergency Contact',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF092A56),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Name *',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    hintText: '+919876543210',
                    helperText: 'Optional',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    hintText: 'example@gmail.com',
                    helperText: 'Optional',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'At least one contact method is required.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B4F8A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                final id = contact['id']?.toString() ?? '';
                final name = nameController.text.trim();
                final phone = phoneController.text.trim();
                final email = emailController.text.trim();

                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter contact name'),
                    ),
                  );
                  return;
                }

                if (phone.isEmpty && email.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Enter phone number or email address',
                      ),
                    ),
                  );
                  return;
                }

                updateContact(
                  id,
                  name,
                  phone,
                  email,
                );

                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // ================= DELETE CONFIRMATION =================

  void showDeleteDialog(Map<String, dynamic> contact) {
    final name =
        contact['name']?.toString() ?? 'this contact';

    final id =
        contact['id']?.toString() ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Delete Contact?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF092A56),
            ),
          ),
          content: Text(
            'Are you sure you want to delete $name?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.pop(context);
                deleteContact(id);
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),

      appBar: AppBar(
        title: const Text(
          'Emergency Contacts',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF092A56),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF0B4F8A),
              ),
            )
          : contacts.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5EEF8),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.contacts_outlined,
                            size: 60,
                            color: Color(0xFF0B4F8A),
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          'No Emergency Contacts',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF092A56),
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          'Add someone you trust for emergency alerts.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: contacts.length,
                  itemBuilder: (context, index) {
                    final contact = contacts[index];

                    final phone =
                        contact['phone']?.toString() ?? '';

                    final email =
                        contact['email']?.toString() ?? '';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 14),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 27,
                                  backgroundColor:
                                      const Color(0xFFE5EEF8),
                                  child: const Icon(
                                    Icons.person,
                                    color: Color(0xFF0B4F8A),
                                    size: 29,
                                  ),
                                ),

                                const SizedBox(width: 13),

                                Expanded(
                                  child: Text(
                                    contact['name'] ??
                                        'Emergency Contact',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF092A56),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            if (phone.isNotEmpty)
                              Row(
                                children: [
                                  const Icon(
                                    Icons.phone_outlined,
                                    size: 18,
                                    color: Color(0xFF0B4F8A),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      phone,
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                            if (phone.isNotEmpty &&
                                email.isNotEmpty)
                              const SizedBox(height: 8),

                            if (email.isNotEmpty)
                              Row(
                                children: [
                                  const Icon(
                                    Icons.email_outlined,
                                    size: 18,
                                    color: Color(0xFF0B4F8A),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      email,
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                            const SizedBox(height: 12),

                            const Divider(),

                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: () {
                                    showEditDialog(contact);
                                  },
                                  icon: const Icon(
                                    Icons.edit,
                                    size: 18,
                                  ),
                                  label: const Text('Edit'),
                                ),

                                const SizedBox(width: 8),

                                TextButton.icon(
                                  onPressed: () {
                                    showDeleteDialog(contact);
                                  },
                                  icon: const Icon(
                                    Icons.delete,
                                    size: 18,
                                    color: Colors.red,
                                  ),
                                  label: const Text(
                                    'Delete',
                                    style: TextStyle(
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0B4F8A),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: showAddDialog,
      ),
    );
  }
}
/// --------------- ChatBot ----------------
class ChatBotPage extends StatefulWidget {
  @override
  _ChatBotPageState createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final TextEditingController controller = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();

  final List<String> messages = [];

  bool _isSending = false;

  bool _needsNearbyLookup(String input) => RegExp(
        r'(?:\b(near(?:by|est)?|around me|police|hospital|clinic|emergency room|someone is following me|being followed|immediate danger|unsafe right now)\b|पास|नज़दीक|नजदीक|अस्पताल|थाना|अभी खतरे में|मेरा पीछा कर रहा)',
        caseSensitive: false,
      ).hasMatch(input);

  bool _hasRouteIntent(String input) => RegExp(
        r'\b(route|directions|walking route|safe way|which way|go to|travel to|how do i get|rasta|raasta|jana hai|jaana hai)\b|रास्ता|रास्ते|रूट|जाना है',
        caseSensitive: false,
      ).hasMatch(input);

  bool _hasDestination(String input) => RegExp(
        r'\bto\s+\S+|\bgo to\s+\S+|\btravel to\s+\S+|\bjana hai|\bjaana hai|तक जाना|तक जाना है',
        caseSensitive: false,
      ).hasMatch(input);

  bool _hasRouteDestination(
    String input,
    List<Map<String, String>> history,
  ) {
    if (_hasRouteIntent(input)) {
      return _hasDestination(input);
    }

    final routePreviouslyRequested = history.any(
      (turn) =>
          turn['role'] == 'user' &&
          _hasRouteIntent(turn['content'] ?? ''),
    );

    final reply = input.trim();

    return routePreviouslyRequested &&
        reply.length > 2 &&
        !RegExp(
          r'^(yes|yeah|ok|okay|haan|ha|no|nahi|नहीं|नही)$',
          caseSensitive: false,
        ).hasMatch(reply);
  }

  String _buildSafetyReply(
    String input, {
    List<Map<String, String>> history = const [],
    bool requestFailed = false,
    bool locationAvailable = false,
  }) {
    final routeRequested = _hasRouteIntent(input) ||
        history.any(
          (turn) =>
              turn['role'] == 'user' &&
              _hasRouteIntent(turn['content'] ?? ''),
        );

    final needsNearby = _needsNearbyLookup(input);

    final urgent = RegExp(
      r'\b(immediate danger|in danger right now|unsafe right now|someone is following me|being followed|attacked|help me now|emergency right now)\b|अभी खतरे में|अभी असुरक्षित|मेरा पीछा कर रहा|(?:mujhe|main)\s+abhi\s+(?:khatra|danger)|koi\s+(?:mera\s+)?peecha\s+kar\s+raha',
      caseSensitive: false,
    ).hasMatch(input);

    final vague = RegExp(
      r'^(hi|hello|hey|help|help me|i need help|can you help me|i feel unsafe|i feel scared|i am scared|i\x27m scared|मदद|मुझे मदद चाहिए|हेलो|नमस्ते)[.!?\s]*$',
      caseSensitive: false,
    ).hasMatch(input.trim());

    final reply = urgent
        ? 'Move to a safer public place if possible. If you are in immediate danger, call 112 in India and alert someone you trust. You can also use the app SOS.'
        : vague
            ? 'Are you in immediate danger right now? If not, what would you like help with: safety advice, nearby services, or route options?'
            : routeRequested && !_hasRouteDestination(input, history)
                ? 'Where are you going? Tell me the destination first; I will then ask to use your current location and compare walking options.'
                : routeRequested
                    ? 'I am preparing to compare available walking routes. Allow location access if prompted.'
                    : 'I can help with safety steps, SOS, trusted contacts, or finding nearby emergency services.';

    if (!needsNearby) return reply;

    if (requestFailed) {
      return locationAvailable
          ? '$reply I could not load nearby facility listings just now. Please try again, or call 112 if this is urgent.'
          : '$reply Allow location access to find actual nearby police and hospital listings, or call 112 if this is urgent.';
    }

    return '$reply I’m checking current nearby police and hospital listings. Allow location access if prompted.';
  }

  Future<Map<String, double>?> _getLocationForMessage(
    String input,
    List<Map<String, String>> history,
  ) async {
    if (!_needsNearbyLookup(input) &&
        !_hasRouteDestination(input, history)) {
      return null;
    }

    try {
      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
      };
    } catch (_) {
      return null;
    }
  }

  void _scrollChatToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_chatScrollController.hasClients) return;

      _chatScrollController.animateTo(
        _chatScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> sendMessage() async {
    final input = controller.text.trim();

    if (input.isEmpty || _isSending) return;

    final userMessage = input;

    final historyStart =
        messages.length > 12 ? messages.length - 12 : 0;

    final history = [
      for (var index = historyStart; index < messages.length; index++)
        {
          'role': index.isEven ? 'user' : 'assistant',
          'content': messages[index],
        },
    ];

    final fallbackReply =
        _buildSafetyReply(userMessage, history: history);

    controller.clear();

    final replyIndex = messages.length + 1;

    setState(() {
      messages.add(userMessage);
      messages.add(fallbackReply);
      _isSending = true;
    });

    _scrollChatToBottom();

    Map<String, double>? location;

    try {
      location = await _getLocationForMessage(
        userMessage,
        history,
      );

      final response = await ApiService.askAssistant(
        message: userMessage,
        history: history,
        latitude: location?['latitude'],
        longitude: location?['longitude'],
      );

      final reply =
          (response['reply'] ?? fallbackReply).toString();

      if (!mounted) return;

      setState(() {
        messages[replyIndex] = reply;
        _isSending = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        messages[replyIndex] = _buildSafetyReply(
          userMessage,
          history: history,
          requestFailed: true,
          locationAvailable: location != null,
        );

        _isSending = false;
      });
    }

    _scrollChatToBottom();
  }

  Widget _buildMessageBubble(
    String message,
    bool isUserMessage,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
      ),
      child: Row(
        mainAxisAlignment: isUserMessage
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUserMessage) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFE5F0FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                color: Color(0xFF0B4F8A),
                size: 21,
              ),
            ),
            const SizedBox(width: 8),
          ],

          Flexible(
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 310,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: isUserMessage
                    ? const Color(0xFF0B4F8A)
                    : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(
                    isUserMessage ? 18 : 4,
                  ),
                  bottomRight: Radius.circular(
                    isUserMessage ? 4 : 18,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: isUserMessage
                      ? Colors.white
                      : const Color(0xFF1E293B),
                ),
              ),
            ),
          ),

          if (isUserMessage) ...[
            const SizedBox(width: 8),
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFFDCEBFA),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_rounded,
                color: Color(0xFF0B4F8A),
                size: 21,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),

      appBar: AppBar(
        backgroundColor: const Color(0xFF092A56),
        elevation: 0,
        centerTitle: false,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 21,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        titleSpacing: 0,

        title: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.14),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),

            const SizedBox(width: 10),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SafeHer Assistant',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 2),

                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4ADE80),
                        shape: BoxShape.circle,
                      ),
                    ),

                    const SizedBox(width: 5),

                    Text(
                      'Here to help you stay safe',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          if (messages.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                18,
                16,
                8,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5F0FF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.support_agent_rounded,
                        color: Color(0xFF0B4F8A),
                        size: 29,
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Hi! I’m your SafeHer Assistant 👋',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF102A43),
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            'Ask me about safety, emergency services, SOS or nearby help.',
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.35,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if (messages.isEmpty)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(
                    bottom: 20,
                  ),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 78,
                        height: 78,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5F0FF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.chat_bubble_outline_rounded,
                          color: Color(0xFF0B4F8A),
                          size: 38,
                        ),
                      ),

                      const SizedBox(height: 16),

                      const Text(
                        'How can I help you?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF102A43),
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        'Type your question below',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                controller: _chatScrollController,
                padding: const EdgeInsets.only(
                  top: 12,
                  bottom: 10,
                ),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final isUserMessage = index.isEven;

                  return _buildMessageBubble(
                    messages[index],
                    isUserMessage,
                  );
                },
              ),
            ),

          Container(
            padding: const EdgeInsets.fromLTRB(
              12,
              10,
              12,
              12,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F6FB),
                        borderRadius:
                            BorderRadius.circular(25),
                        border: Border.all(
                          color: const Color(0xFFE1E8F0),
                        ),
                      ),
                      child: TextField(
                        controller: controller,
                        onSubmitted: (_) => sendMessage(),
                        minLines: 1,
                        maxLines: 4,
                        textInputAction:
                            TextInputAction.send,
                        decoration: const InputDecoration(
                          hintText:
                              'Ask something...',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding:
                              EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 13,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B4F8A),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0B4F8A)
                              .withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: _isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                      onPressed:
                          _isSending ? null : sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- SOS Page ----------------
class SOSPage extends StatefulWidget {
  @override
  _SOSPageState createState() => _SOSPageState();
}

class _SOSPageState extends State<SOSPage> {
  int seconds = 3;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (t) {
      print("TIMER: $seconds");
      if (seconds == 0) {
        t.cancel();
        triggerSOS();
      } else {
        setState(() => seconds--);
      }
    });
  }

 
  Future<void> sendOfflineSMS(String phoneNumber, double latitude, double longitude) async {
  final message =
      'SAFEHER EMERGENCY! I AM IN DANGER. Location: https://maps.google.com/?q=$latitude,$longitude';

  final Uri smsUri = Uri(
    scheme: 'sms',
    path: phoneNumber,
    queryParameters: {
      'body': message,
    },
  );

  if (await canLaunchUrl(smsUri)) {
    await launchUrl(smsUri);
  } else {
    print("Could not open SMS app");
  }
}
Future<Position?> getCurrentLocation() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

  if (!serviceEnabled) {
    print("LOCATION SERVICE IS OFF");
    return null;
  }

  LocationPermission permission =
      await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    print("LOCATION PERMISSION NOT AVAILABLE");
    return null;
  }

  return await Geolocator.getCurrentPosition();
}
Future<void> triggerSOS() async {
   print("SOS TRIGGERED - API CALLING LOCATION");

  final position = await getCurrentLocation();

  final double? latitude = position?.latitude;
  final double? longitude = position?.longitude;

  print("CURRENT LOCATION: $latitude, $longitude");
  try {
    final response = await ApiService.sendAlert(
      latitude: latitude,
      longitude: longitude,
    );

    print("SOS RESPONSE: $response");
  } catch (error) {
    print("INTERNET SOS FAILED: $error");

    try {
      final contacts = await ApiService.getContacts();

      if (contacts.isNotEmpty) {
        final phone = contacts.first['phone']?.toString() ?? '';

        if (phone.isNotEmpty) {
          await sendOfflineSMS(
            phone,
            latitude!,
            longitude!,
          );
        }
      }
    } catch (contactError) {
      print("CONTACT FETCH FAILED: $contactError");
    }
  }

  Navigator.pop(context);
}

void cancelSOS() {
  timer?.cancel();
  Navigator.pop(context);
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.red,
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'SOS ACTIVATING...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Text(
            '$seconds',
            style: TextStyle(
              color: Colors.white,
              fontSize: 60,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
            ),
            onPressed: cancelSOS,
            child: Text(
              'CANCEL',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    ),
  );
}
}