import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../viewmodels/signup_viewmodel.dart';
import 'home_page.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SignUpViewModel(),
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(134, 86, 210, 1.0),
        appBar: AppBar(
          title: const Text('Sign Up'),
          backgroundColor: const Color.fromRGBO(134, 86, 210, 1.0),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer<SignUpViewModel>(  // Listen to changes in SignUpViewModel
            builder: (context, viewModel, child) {
              return Form(
                key: viewModel.formKey,
                child: ListView(
                  children: [
                    _buildTextField(
                      label: 'Username',
                      onChanged: (value) => viewModel.username = value,
                      validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter your username' : null,
                    ),
                    const SizedBox(height: 16.0),
                    _buildTextField(
                      label: 'Email',
                      onChanged: (value) => viewModel.email = value,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    _buildDatePickerField(context, viewModel),
                    const SizedBox(height: 16.0),
                    _buildTextField(
                      label: 'Password',
                      obscureText: true,
                      onChanged: (value) => viewModel.password = value,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter your password';
                        }
                        if (value!.length < 8) {
                          return 'Password must be at least 8 characters long';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    _buildGenderSelection(viewModel),
                    const SizedBox(height: 16.0),
                    _buildTextField(
                      label: 'Phone Number',
                      onChanged: (value) => viewModel.phoneNumber = value,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (viewModel.validateForm()) {
                            String? errorMessage = await viewModel.signUp(context);
                            if (errorMessage == null) {
                              // Navigate to the HomePage if sign-up is successful
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => HomePage()),
                              );
                            } else {
                              // Show error message if sign-up fails
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(errorMessage)),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(245, 198, 82, 1.0),
                        ),
                        child: Text('Sign Up'),
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

  Widget _buildTextField({
    required String label,
    required Function(String) onChanged,
    required String? Function(String?) validator,
    bool obscureText = false,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        filled: true,
        fillColor: const Color.fromRGBO(245, 198, 82, 1.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(
            color: Color.fromRGBO(245, 198, 82, 1.0),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(
            color: Color.fromRGBO(245, 198, 82, 1.0),
          ),
        ),
      ),
      obscureText: obscureText,
      onChanged: onChanged,
      validator: validator,
    );
  }

  Widget _buildDatePickerField(BuildContext context, SignUpViewModel viewModel) {
    return GestureDetector(
      onTap: () => viewModel.selectDate(context),
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            labelText: viewModel.dob != null
                ? DateFormat('dd/MM/yy').format(viewModel.dob!)
                : 'Date of Birth',
            hintText: 'Date of Birth',
            hintStyle: const TextStyle(color: Colors.white),
            labelStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            filled: true,
            fillColor: const Color.fromRGBO(245, 198, 82, 1.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          validator: (value) =>
          viewModel.dob == null ? 'Please select your date of birth' : null,
        ),
      ),
    );
  }

  Widget _buildGenderSelection(SignUpViewModel viewModel) {
    return Row(
      children: [
        Expanded(
          child: RadioListTile<String>(
            title: const Text('Male', style: TextStyle(color: Colors.white)),
            value: 'Male',
            groupValue: viewModel.gender,
            onChanged: (value) {
              viewModel.gender = value;
              viewModel.notifyListeners();
            },
            activeColor: const Color.fromRGBO(245, 198, 82, 1.0),
          ),
        ),
        Expanded(
          child: RadioListTile<String>(
            title: const Text('Female', style: TextStyle(color: Colors.white)),
            value: 'Female',
            groupValue: viewModel.gender,
            onChanged: (value) {
              viewModel.gender = value;
              viewModel.notifyListeners();
            },
            activeColor: const Color.fromRGBO(245, 198, 82, 1.0),
          ),
        ),
      ],
    );
  }
}
