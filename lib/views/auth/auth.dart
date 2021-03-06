import 'package:animations/animations.dart';
import 'package:instaStore/views/auth/complete_registration.dart';
import 'package:lit_firebase_auth/lit_firebase_auth.dart';
import '../background_painter.dart';
import 'package:flutter/material.dart';
import '../home/home.dart';
import './sign_in.dart';
import './register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../Controllers/palette.dart';
import '../../models/Customer.dart';
import 'package:firebase_database/firebase_database.dart';

class AuthScreen extends StatefulWidget {
  static String routeName = "/auth";
  const AuthScreen({Key key}) : super(key: key);

  static MaterialPageRoute get route => MaterialPageRoute(
        builder: (context) => const AuthScreen(),
      );

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  List<Customer> _customersList = [];

  AnimationController _controller;

  User mCurrentUser;
  FirebaseAuth _auth;
  ValueNotifier<bool> showSignInPage = ValueNotifier<bool>(true);

  @override
  void initState() {
    _auth = FirebaseAuth.instance;

    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    super.initState();
    DatabaseReference customersRef =
        FirebaseDatabase.instance.reference().child("customer");
    customersRef.once().then((DataSnapshot snap) {
      var KEYS = snap.value.keys;
      var DATA = snap.value;

      _customersList.clear();
      print(DATA);
      for (var key in KEYS) {
        Customer costumer = new Customer(
            phone: DATA[key]['Phone'], name: DATA[key]['Name'], id: key);
        _customersList.add(costumer);
        print(key);
        print("lala");
      }

      setState(() {
        print('Length: ${_customersList.length}');
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LitAuth.custom(
        errorNotification: const NotificationConfig(
          backgroundColor: Palette.darkPink,
          icon: Icon(
            Icons.error_outline,
            color: Colors.white,
            size: 32,
          ),
        ),
        successNotification: const NotificationConfig(
          backgroundColor: Palette.darkPink,
          icon: Icon(
            Icons.check,
            color: Colors.white,
            size: 32,
          ),
        ),
        onAuthSuccess: () {
          final User user = FirebaseAuth.instance.currentUser;
          String userId = user.uid;
          //   Navigator.of(context)
          //       .pushReplacementNamed(CompleteRegistration.routeName);
          bool b = false;
          for (Customer c in _customersList) {
            print(c.id);

            print("yessss");
            if (c.id != userId) {
              b = false;
            } else {
              b = true;
              break;
            }
          }
          if (b) {
            Navigator.of(context).pushReplacement(HomeScreen.route);
          } else {
            Navigator.of(context)
                .pushReplacementNamed(CompleteRegistration.routeName);
          }
        },
        child: Stack(
          children: [
            SizedBox.expand(
                child: CustomPaint(
                    painter: BackgroundPainter(
              animation: _controller.view,
            ))),
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 800),
                child: ValueListenableBuilder<bool>(
                    valueListenable: showSignInPage,
                    builder: (context, value, child) {
                      return PageTransitionSwitcher(
                        reverse: !value,
                        duration: Duration(milliseconds: 800),
                        transitionBuilder:
                            (child, animation, secondaryAnimation) {
                          return SharedAxisTransition(
                            animation: animation,
                            secondaryAnimation: secondaryAnimation,
                            transitionType: SharedAxisTransitionType.vertical,
                            fillColor: Colors.transparent,
                            child: child,
                          );
                        },
                        child: value
                            ? SignIn(
                                key: ValueKey('SignIn'),
                                onRegisterClicked: () {
                                  context.resetSignInForm();
                                  showSignInPage.value = false;
                                  _controller.forward();
                                },
                              )
                            : Register(
                                key: ValueKey('Register'),
                                onSignInPressed: () {
                                  context.resetSignInForm();
                                  showSignInPage.value = true;
                                  _controller.reverse();
                                }),
                      );
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
