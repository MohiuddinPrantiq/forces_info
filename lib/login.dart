import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:forces_info/Alert_service.dart';
import 'package:forces_info/main.dart';
import 'package:http/http.dart' as http;
import 'signup.dart';
import 'Home.dart';


Color BG = Color(0xFF212529);
Color TXT = Colors.white;
class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final _formKey = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false; // Add this loading state variable

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xff334756),
        body: SingleChildScrollView(
          //heightFactor: 1200,
            child: Container(
              //height: 500,
              child: Column(
                children: <Widget>[
                  SizedBox(height: 170,),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0), // Set border radius
                                borderSide: BorderSide(
                                  color: Color.fromRGBO(143, 148, 251, 1), // Set border color
                                  width: 2.0, // Set border width
                                ),
                              ),
                              labelText: 'Email Address',
                              labelStyle: TextStyle(color: TXT),
                            ),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please enter your email address';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16.0),

                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0), // Set border radius
                                borderSide: BorderSide(
                                  color: Color.fromRGBO(143, 148, 251, 1), // Set border color
                                  width: 2.0, // Set border width
                                ),
                              ),
                              labelText: 'Password',
                              labelStyle: TextStyle(color: TXT),
                              suffixIcon: IconButton(
                                icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off,color: Colors.white,),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20.0),
                          Container(
                            width: double.infinity,
                            child: _isLoading? Center(child: CircularProgressIndicator(color: Colors.blueGrey,),) // Show progress indicator when loading
                               :ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                fixedSize: Size.fromHeight(50),
                                backgroundColor: Colors.blueGrey,// Adjust the height as needed
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0), // Set border radius
                                ),
                              ),
                              onPressed: _submitForm,
                              child: Text(
                                'Log In',
                                style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: TXT),
                              ),
                            ),
                          ),
                          SizedBox(height: 20.0),
                          Center(
                            child: TextButton(
                              onPressed: () {
                                ForgetPassword(context);
                              },
                              child: Text(
                                'Forget Password?',
                                style: TextStyle(color: TXT, fontSize: 16),
                              ),
                            ),
                          ),
                          SizedBox(height: 40.0),
                          Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => SigninPage()), // Replace SignUpPage with your actual sign-up page
                                );
                              },
                              child: Text(
                                'Create account!',
                                style: TextStyle(color: TXT, fontSize: 16),
                              ),
                            ),
                          ),
                          SizedBox(height: 70),

                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )

          ),

    );
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? true) {
      // Form is valid, handle login logic here using _emailController.text and _passwordController.text
      // For simplicity, just print the values for now
      setState(() {
        _isLoading = true; // Start loading
      });
      print('Email: ${_emailController.text}');
      print('Password: ${_passwordController.text}');

      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      if(email == "" || password=="") {
        setState(() {
          _isLoading = false; // Stop loading
        });
        print("please fill all the fields");
        AlertService.showToast(context: context,text: 'Enter valid email and pass!',icon:Icons.error_outline,color: Colors.red);

      } else {
        try{
          UserCredential userCredential = await FirebaseAuth.instance.
          signInWithEmailAndPassword(email: email, password: password);

          if(userCredential.user != null){
            print('acc. matched');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Home()), // Replace LoginPage with your actual login page
            );
          }
        } on FirebaseAuthException catch (ex){
          setState(() {
            _isLoading = false; // Stop loading
          });
          print(ex.code.toString()); // good to create a snackbar
          AlertService.showToast(
              context: context,
              text: 'Error: ${ex.message ?? 'Unknown error occurred'}',
              icon:Icons.error_outline,
              color: Colors.red
          );
        }
      }

    }
  }
  void ForgetPassword(BuildContext context) {
    TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xff334756),
          title: Text("Reset Password",
            style: TextStyle(color: Colors.white),),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Do you want to reset your password?",
                style: TextStyle(color: Colors.white),),
              SizedBox(height: 16),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Enter your email",
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0), // Set border radius
                    borderSide: BorderSide(
                      color: Color.fromRGBO(143, 148, 251, 1), // Set border color
                      width: 2.0, // Set border width
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Cancel",
                style: TextStyle(color: Colors.white),),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                String email = emailController.text.trim();
                if (email.isNotEmpty) {
                  try {
                    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                    AlertService.showToast(
                        context: context,
                        text: 'Password reset email sent to $email',
                        icon:Icons.check_box_outlined,
                        color: Colors.green
                    );
                  } catch (e) {
                    AlertService.showToast(
                        context: context,
                        text: 'Error: ${e.toString()}',
                        icon:Icons.error_outline,
                        color: Colors.red
                    );
                  }
                } else {
                  AlertService.showToast(
                      context: context,
                      text: 'Please enter your email address',
                      icon:Icons.error_outline,
                      color: Colors.red
                  );
                }
              },
              child: Text("Yes",
                style: TextStyle(color: Colors.white),),
            ),
          ],
        );
      },
    );
  }
}