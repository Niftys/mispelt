import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/constants.dart';
import '../services/user_service.dart';
import '../widgets/app_logo.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLoading = false;
  bool _isSignUp = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.background,
              AppColors.secondary.withOpacity(0.3),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: GameConstants.maxContentWidth,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(GameConstants.spacingXl),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // App Logo - PNG with dictionary definition
                      const AppLogo(
                        size: 250,
                        useImage: true,
                        imagePath: 'assets/images/mispelt_logo.png',
                        showSubtitle: true,
                      ),

                      const SizedBox(height: GameConstants.spacingXxl),

                      // Online Mode Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(GameConstants.spacingXl),
                        decoration: BoxDecoration(
                          gradient: AppColors.cardGradient,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.2),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.text.withOpacity(0.08),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.highlight1,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.leaderboard_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: GameConstants.spacingMd),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Online Mode',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.text,
                                        ),
                                      ),
                                      Text(
                                        'Create account to compete on leaderboards',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: GameConstants.spacingLg),

                            // Email/Password Form
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  if (_isSignUp) ...[
                                    TextFormField(
                                      controller: _usernameController,
                                      decoration: const InputDecoration(
                                        labelText: 'Username',
                                        prefixIcon: Icon(
                                          Icons.person_outline_rounded,
                                        ),
                                        helperText:
                                            '3-20 characters, letters, numbers, and underscores only',
                                      ),
                                      validator: (value) {
                                        if (_isSignUp &&
                                            (value == null || value.isEmpty)) {
                                          return 'Please enter a username';
                                        }
                                        if (_isSignUp &&
                                            value != null &&
                                            value.length < 3) {
                                          return 'Username must be at least 3 characters';
                                        }
                                        if (_isSignUp &&
                                            value != null &&
                                            !UserService.isValidUsername(
                                              value,
                                            )) {
                                          return 'Username can only contain letters, numbers, and underscores';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(
                                      height: GameConstants.spacingMd,
                                    ),
                                  ],
                                  TextFormField(
                                    controller: _emailController,
                                    decoration: InputDecoration(
                                      labelText:
                                          _isSignUp
                                              ? 'Email'
                                              : 'Email or Username',
                                      hintText:
                                          _isSignUp
                                              ? 'Enter your email'
                                              : 'Enter your email or username',
                                      prefixIcon: const Icon(
                                        Icons.email_outlined,
                                      ),
                                      helperText:
                                          _isSignUp
                                              ? null
                                              : 'Enter your email or username',
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your email or username';
                                      }
                                      if (_isSignUp &&
                                          !RegExp(
                                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                          ).hasMatch(value)) {
                                        return 'Please enter a valid email';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(
                                    height: GameConstants.spacingMd,
                                  ),
                                  TextFormField(
                                    controller: _passwordController,
                                    decoration: const InputDecoration(
                                      labelText: 'Password',
                                      prefixIcon: Icon(
                                        Icons.lock_outline_rounded,
                                      ),
                                    ),
                                    obscureText: true,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your password';
                                      }
                                      if (_isSignUp && value.length < 6) {
                                        return 'Password must be at least 6 characters';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(
                                    height: GameConstants.spacingLg,
                                  ),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed:
                                          _isLoading ? null : _signInWithEmail,
                                      child: Text(
                                        _isLoading
                                            ? 'Loading...'
                                            : (_isSignUp
                                                ? 'Sign Up'
                                                : 'Sign In'),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: GameConstants.spacingMd,
                                  ),
                                  TextButton(
                                    onPressed:
                                        _isLoading
                                            ? null
                                            : () {
                                              setState(() {
                                                _isSignUp = !_isSignUp;
                                              });
                                            },
                                    child: Text(
                                      _isSignUp
                                          ? 'Already have an account? Sign In'
                                          : 'Don\'t have an account? Sign Up',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: GameConstants.spacingLg),

                      // Or divider
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: AppColors.textMuted.withOpacity(0.3),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: GameConstants.spacingLg,
                            ),
                            child: Text(
                              'or',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.textMuted),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: AppColors.textMuted.withOpacity(0.3),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: GameConstants.spacingLg),

                      // Offline Mode Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(GameConstants.spacingXl),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.textMuted.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.textMuted,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.offline_bolt_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: GameConstants.spacingMd),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Offline Mode',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.text,
                                        ),
                                      ),
                                      Text(
                                        'Play without account, no leaderboards',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: GameConstants.spacingLg),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed:
                                    _isLoading ? null : _signInAnonymously,
                                icon: const Icon(Icons.play_arrow_rounded),
                                label: const Text('Start Playing'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.text,
                                  side: BorderSide(color: AppColors.textMuted),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: GameConstants.spacingXl,
                                    vertical: GameConstants.spacingLg,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
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
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signInWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isSignUp) {
        // Check username uniqueness for signup
        final username = _usernameController.text.trim();
        final isUnique = await UserService.isUsernameUnique(username);

        if (!isUnique) {
          throw FirebaseAuthException(
            code: 'username-already-in-use',
            message:
                'This username is already taken. Please choose a different one.',
          );
        }

        // Create account
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        // Create user document with username
        await UserService.createUserDocument(
          userCredential.user!.uid,
          username,
          _emailController.text.trim(),
        );

        // Update display name with username
        await userCredential.user?.updateDisplayName(username);
      } else {
        // Sign in with username or email
        final identifier = _emailController.text.trim();
        final userId = await UserService.getUserIdByUsernameOrEmail(identifier);

        if (userId == null) {
          throw FirebaseAuthException(
            code: 'user-not-found',
            message: 'No user found with that email or username.',
          );
        }

        // Get user data to find the email
        final userData = await UserService.getUserData(userId);
        if (userData == null) {
          throw FirebaseAuthException(
            code: 'user-not-found',
            message: 'User data not found.',
          );
        }

        // Sign in with the actual email
        await _auth.signInWithEmailAndPassword(
          email: userData['email'],
          password: _passwordController.text,
        );

        // Update last login
        await UserService.updateLastLogin(userId);
      }

      if (mounted) {
        Navigator.of(
          context,
        ).pushReplacement(AppPageRoutes.scaleAndFade(const HomeScreen()));
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Authentication failed';
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists for that email.';
      } else if (e.code == 'username-already-in-use') {
        message = e.message ?? 'This username is already taken.';
      } else if (e.code == 'user-not-found') {
        message = e.message ?? 'No user found with that email or username.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided.';
      } else if (e.code == 'invalid-email') {
        message = e.message ?? 'Please enter a valid email address.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.error),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInAnonymously() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.signInAnonymously();

      if (mounted) {
        Navigator.of(
          context,
        ).pushReplacement(AppPageRoutes.scaleAndFade(const HomeScreen()));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start offline mode: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
