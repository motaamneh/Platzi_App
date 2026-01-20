import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/constants/route_constants.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({Key? key}) : super(key: key);

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  
  void _handleSignUp() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthSignUpRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        } else if (state is AuthAuthenticated) {
          Navigator.of(context).pushReplacementNamed(RouteConstants.home);
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _nameController,
                hintText: 'Enter your name',
                label: 'Full Name',
                prefixIcon: Icons.person_outline,
                validator: Validators.validateName,
                enabled: !isLoading,
              ),
              
              const SizedBox(height: 20),
              
              CustomTextField(
                controller: _emailController,
                hintText: 'Enter your email',
                label: 'Email',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.validateEmail,
                enabled: !isLoading,
              ),
              
              const SizedBox(height: 20),
              
              CustomTextField(
                controller: _passwordController,
                hintText: 'Enter your password',
                label: 'Password',
                prefixIcon: Icons.lock_outline,
                isPassword: true,
                validator: Validators.validatePassword,
                enabled: !isLoading,
              ),
              
              const SizedBox(height: 20),
              
              CustomTextField(
                controller: _confirmPasswordController,
                hintText: 'Confirm your password',
                label: 'Confirm Password',
                prefixIcon: Icons.lock_outline,
                isPassword: true,
                validator: (value) => Validators.validateConfirmPassword(
                  value,
                  _passwordController.text,
                ),
                enabled: !isLoading,
              ),
              
              const SizedBox(height: 32),
              
              CustomButton(
                text: 'Sign Up',
                onPressed: _handleSignUp,
                isLoading: isLoading,
                icon: Icons.person_add,
              ),
            ],
          ),
        );
      },
    );
  }
}