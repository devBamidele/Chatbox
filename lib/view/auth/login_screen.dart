import 'dart:async';

import 'package:auto_route/annotations.dart';
import 'package:chatbox/res/color.dart';
import 'package:chatbox/res/components/custom/custom_back_button.dart';
import 'package:chatbox/res/components/custom/custom_check_box.dart';
import 'package:chatbox/res/components/custom/custom_text_field.dart';
import 'package:chatbox/res/components/login_options.dart';
import 'package:chatbox/res/style/app_text_style.dart';
import 'package:chatbox/res/style/component_style.dart';
import 'package:chatbox/utils/app_router/router.dart';
import 'package:chatbox/utils/app_utils.dart';
import 'package:chatbox/utils/services/auth_service.dart';
import 'package:chatbox/utils/widget_functions.dart';
import 'package:chatbox/view_model/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:provider/provider.dart';
import 'package:uni_links/uni_links.dart';

import '../../res/components/shake_error.dart';
import '../../utils/extensions.dart';

@RoutePage()
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late StreamSubscription? deepLinkSubscription;

  late final AuthService _authService = AuthService();
  late AuthProvider authProvider;

  final myEmailController = TextEditingController();
  final myPasswordController = TextEditingController();

  final passwordFocusNode = FocusNode();
  final emailFocusNode = FocusNode();

  final formKey1 = GlobalKey<FormState>();
  final formKey2 = GlobalKey<FormState>();

  final shakeState1 = GlobalKey<ShakeWidgetState>();
  final shakeState2 = GlobalKey<ShakeWidgetState>();

  Color passwordColor = AppColors.hintTextColor;
  Color fillPasswordColor = AppColors.inputBackGround;

  Color emailColor = AppColors.hintTextColor;
  Color fillEmailColor = AppColors.inputBackGround;

  late bool _passwordVisible;
  bool _isChecked = false;

  late bool isRootScreen;

  bool _isPasswordEmpty = true;
  bool _isEmailEmpty = true;

  @override
  void initState() {
    super.initState();

    linkStreamListen();

    isRootScreen = isRoot(context);

    _passwordVisible = true;

    myPasswordController.addListener(_updatePasswordEmpty);

    passwordFocusNode.addListener(_updatePasswordColor);

    myEmailController.addListener(_updateEmailEmpty);

    emailFocusNode.addListener(_updateEmailColor);

    authProvider = Provider.of<AuthProvider>(context, listen: false);
  }

  void _updatePasswordEmpty() {
    setState(() {
      _isPasswordEmpty = myPasswordController.text.isEmpty;
    });
  }

  void _updateEmailEmpty() {
    setState(() {
      _isEmailEmpty = myEmailController.text.isEmpty;
    });
  }

  void _updatePasswordColor() {
    setState(() {
      passwordColor = passwordFocusNode.hasFocus
          ? AppColors.selectedFieldColor
          : _isPasswordEmpty
              ? AppColors.hintTextColor
              : Colors.black87;
      fillPasswordColor = passwordFocusNode.hasFocus
          ? AppColors.selectedBackgroundColor
          : AppColors.inputBackGround;
    });
  }

  void _updateEmailColor() {
    setState(() {
      emailColor = emailFocusNode.hasFocus
          ? AppColors.selectedFieldColor
          : _isEmailEmpty
              ? AppColors.hintTextColor
              : Colors.black87;
      fillEmailColor = emailFocusNode.hasFocus
          ? AppColors.selectedBackgroundColor
          : AppColors.inputBackGround;
    });
  }

  @override
  void dispose() {
    myEmailController.dispose();
    myPasswordController.dispose();

    passwordFocusNode.dispose();
    emailFocusNode.dispose();

    formKey1.currentState?.dispose();
    formKey2.currentState?.dispose();

    shakeState1.currentState?.dispose();
    shakeState2.currentState?.dispose();

    disposeDeepLink();
    super.dispose();
  }

  void disposeDeepLink() {
    if (deepLinkSubscription != null) {
      deepLinkSubscription!.cancel();
      deepLinkSubscription = null;
    }
  }

  void showSnackbar(String message) {
    if (mounted) {
      AppUtils.showSnackbar(message);
    }
  }

  void onContinuePressed() {
    final email = formKey1.currentState?.validate();
    final password = formKey2.currentState?.validate();

    if (!email! && !password!) {
      shakeState1.currentState?.shake();
      shakeState2.currentState?.shake();
    } else if (!email) {
      shakeState1.currentState?.shake();
    } else if (!password!) {
      shakeState2.currentState?.shake();
    } else {
      loginWithEmailAndPassword();
      return;
    }
    Vibrate.feedback(FeedbackType.heavy);
  }

  void linkStreamListen() {
    deepLinkSubscription = linkStream.listen(
      (String? value) {
        authProvider.gitLinkStream(
          value,
          showSnackbar: showSnackbar,
          onAuthenticate: onAuthenticate,
        );
      },
      cancelOnError: true,
    );
  }

  Future<void> loginWithGoogle() async {
    await authProvider.loginWithGoogle(
      showSnackbar: showSnackbar,
      onAuthenticate: onAuthenticate,
    );
  }

  Future<void> loginWithGithub() async {
    await authProvider.handleGitUrlLaunch(showSnackbar: showSnackbar);
  }

  Future<void> loginWithEmailAndPassword() async {
    final String email = myEmailController.text.trim();
    final String password = myPasswordController.text;

    await authProvider.loginWithEmailAndPassword(
      context: context,
      email: email,
      password: password,
      showSnackbar: showSnackbar,
      onAuthenticate: onAuthenticate,
    );
  }

  void onAuthenticate() {
    _authService.updateUserOnlineStatus(true).then((_) => gotoHome());
  }

  gotoHome() => {};

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Padding(
            padding: pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Visibility(
                  visible: isRootScreen,
                  replacement: const CustomBackButton(
                    padding: EdgeInsets.only(left: 0, top: 25),
                  ),
                  child: addHeight(50),
                ),
                addHeight(20),
                const Text(
                  'Login to your Account',
                  style: AppTextStyles.headlineLarge,
                ),
                addHeight(10),
                Container(
                  alignment: Alignment.topLeft,
                  child: const Text(
                    'Enter your email and password below',
                    textAlign: TextAlign.left,
                    style: AppTextStyles.headlineSmall,
                  ),
                ),
                addHeight(55),
                Form(
                  key: formKey1,
                  child: ShakeWidget(
                    key: shakeState1,
                    shakeCount: 3,
                    shakeOffset: 6,
                    child: CustomTextField(
                      focusNode: emailFocusNode,
                      textController: myEmailController,
                      customFillColor: fillEmailColor,
                      hintText: 'Email',
                      prefixIcon: Icon(
                        IconlyBold.message,
                        color: emailColor,
                      ),
                      validation: (email) => email.validateEmail(),
                    ),
                  ),
                ),
                Form(
                  key: formKey2,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 20,
                      bottom: 20,
                    ),
                    child: ShakeWidget(
                      key: shakeState2,
                      shakeCount: 3,
                      shakeOffset: 6,
                      child: CustomTextField(
                        focusNode: passwordFocusNode,
                        textController: myPasswordController,
                        customFillColor: fillPasswordColor,
                        action: TextInputAction.done,
                        hintText: 'Password',
                        obscureText: _passwordVisible,
                        validation: (value) => value.validatePassword(),
                        prefixIcon: Icon(
                          IconlyBold.lock,
                          color: passwordColor,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            // Based on passwordVisible state choose the icon
                            _passwordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: passwordColor,
                          ),
                          onPressed: () {
                            // Update the state i.e. toggle the state of passwordVisible variable
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomCheckbox(
                        value: _isChecked,
                        onChanged: (value) {
                          setState(() {
                            _isChecked = value ?? false;
                          });
                        },
                      ),
                      const Text(
                        'Remember me',
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [shadow],
                  ),
                  child: ElevatedButton(
                    style: elevatedButton,
                    onPressed: onContinuePressed,
                    child: const Text(
                      'Continue',
                      style: AppTextStyles.labelMedium,
                    ),
                  ),
                ),
                addHeight(28),
                GestureDetector(
                  onTap: () => navPush(context, null),
                  child: const Text(
                    'Forgot the password?',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.labelSmall,
                  ),
                ),
                addHeight(40),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    const Divider(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      color: Colors.white,
                      child: const Text(
                        'or continue with',
                        style: AppTextStyles.titleSmall,
                      ),
                    ),
                  ],
                ),
                addHeight(20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    LoginOptions(
                      scale: 0.9,
                      onTap: () => loginWithGoogle(),
                      path: 'assets/images/google.svg',
                    ),
                    LoginOptions(
                      scale: 0.9,
                      onTap: () => loginWithGithub(),
                      path: 'assets/images/github.svg',
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}