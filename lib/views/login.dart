import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/authentication.dart';
import 'home_page.dart';
import 'sign_up_page.dart';
import '../viewmodels/login_model.dart';// Ensure you import the SignUpScreen

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: Scaffold(
        backgroundColor: Color.fromRGBO(134, 86, 210, 1.0),
        appBar: AppBar(
          title: Text('Login'),
          backgroundColor: Color.fromRGBO(134, 86, 210, 1.0),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer<LoginViewModel>(  // Consumer to listen to viewmodel updates
            builder: (context, viewModel, child) {
              return Form(
                key: viewModel.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Email field
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        filled: true,
                        fillColor: Color.fromRGBO(245, 198, 82, 1.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: Color.fromRGBO(245, 198, 82, 1.0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: Color.fromRGBO(245, 198, 82, 1.0),
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        } else if (!viewModel.emailRegex.hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                      onChanged: (value) => viewModel.email = value,
                    ),
                    SizedBox(height: 16.0),

                    // Password field
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        filled: true,
                        fillColor: Color.fromRGBO(245, 198, 82, 1.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: Color.fromRGBO(245, 198, 82, 1.0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: Color.fromRGBO(245, 198, 82, 1.0),
                          ),
                        ),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        } else if (value.length < 8) {
                          return 'Password must be at least 8 characters long';
                        }
                        return null;
                      },
                      onChanged: (value) => viewModel.password = value,
                    ),
                    SizedBox(height: 16.0),

                    // Login button
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (viewModel.validateForm()) {
                            String result = await AuthMethod().loginUser(
                              email: viewModel.email,
                              password: viewModel.password,
                            );
                            if (result == "success") {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => HomePage()),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(result)),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(245, 198, 82, 1.0),
                        ),
                        child: viewModel.isLoading
                            ? CircularProgressIndicator()
                            : Text('Login'),
                      ),
                    ),
                    SizedBox(height: 16.0),

                    // Sign Up Redirect
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SignUpScreen()),
                          );
                        },
                        child: Text(
                          'Don\'t have an account? Sign Up',
                          style: TextStyle(
                            color: Color.fromRGBO(245, 198, 82, 1.0),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
