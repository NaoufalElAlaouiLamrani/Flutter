import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'jokes_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';
  bool _isLoading = false;

  Future<void> _signIn() async {
    setState(() => _isLoading = true);
    try {
      await _authService.signInWithEmailPassword(
          _emailController.text.trim(), _passwordController.text.trim());
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const JokesPage()),
      );
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    }
    setState(() => _isLoading = false);
  }

  Future<void> _signUp() async {
    setState(() => _isLoading = true);
    try {
      await _authService.signUpWithEmailPassword(
          _emailController.text.trim(), _passwordController.text.trim());
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const JokesPage()),
      );
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Authentification')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Mot de passe'),
            ),
            const SizedBox(height: 20),
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            if (_isLoading)
              const CircularProgressIndicator()
            else
              Column(
                children: [
                  ElevatedButton(
                    onPressed: _signIn,
                    child: const Text('Se connecter'),
                  ),
                  ElevatedButton(
                    onPressed: _signUp,
                    child: const Text("S'inscrire"),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
