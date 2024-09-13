import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'Alert_service.dart';
import 'login.dart';

Color BG = Color(0xFF212529);

class SigninPage extends StatefulWidget {
  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {

  final _formKey = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _handleController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false; // Add this loading state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xff334756),
        body: SingleChildScrollView(
          child: Container(
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
                            labelStyle: TextStyle(color: Colors.white),
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
                          controller: _handleController,
                          keyboardType: TextInputType.text,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0), // Set border radius
                              borderSide: BorderSide(
                                color: Color.fromRGBO(143, 148, 251, 1), // Set border color
                                width: 2.0, // Set border width
                              ),
                            ),
                            labelText: 'CF Handle',
                            labelStyle: TextStyle(color: Colors.white),
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please enter your CF Handle';
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
                            labelStyle: TextStyle(color: Colors.white),
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
                        SizedBox(height: 24.0),
                        Container(
                          width: double.infinity,
                          child: _isLoading?Center(child: CircularProgressIndicator(color: Colors.blueGrey,),)
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
                              'Sign Up',
                              style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(height: 16.0),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Log in',
                            style: TextStyle(color: TXT, fontSize: 16),
                          ),
                        ),
                        SizedBox(height: 70),

                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? true) {
      // Form is valid, handle login logic here using _emailController.text and _passwordController.text
      // For simplicity, just print the values for now
      print('Email : ${_emailController.text}');
      print('Password : ${_passwordController.text}');
      print('Handle : ${_handleController.text}');

      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();
      String handle = _handleController.text.trim();

      if(email == "" || password=="" || handle=="") {
        print("please fill all the fields");
      } else {
        try{
          var url = Uri.parse("https://codeforces.com/api/user.info?handles=${handle}");
          var response = await http.get(url);
          if(response.statusCode!=200) {
            AlertService.showToast(
                context: context,
                text: "Handle not found!",
                icon: Icons.error_outline,
                color: Colors.red
            );
            return;
          }
          UserCredential userCredential = await FirebaseAuth.instance.
          createUserWithEmailAndPassword(email: email, password: password);

          if(userCredential.user != null && response.statusCode==200){
            //acc. creation confirmation
            AlertService.showToast(
                context: context,
                text: "Account created successfully!",
                icon: Icons.check_box_outlined,
                color: Colors.green
            );
            print('acc. created');

            Map<String, dynamic> newUser={
              "email" : email,
              "handle" : handle,
              "friends" : "",
            };
            await FirebaseFirestore.instance.collection('users').
            doc(userCredential.user!.uid).set(newUser);
            Navigator.pop(context);
          }
        } on FirebaseAuthException catch (ex){
          print(ex.code.toString()); // good to create a snackbar
          AlertService.showToast(
              context: context,
              text: 'Error: ${ex.message ?? 'Unknown error occurred'}',
              icon: Icons.error_outline,
              color: Colors.red
          );
        }
      }
    }
  }
}