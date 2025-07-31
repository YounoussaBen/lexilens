import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseTestScreen extends StatefulWidget {
  const FirebaseTestScreen({super.key});

  @override
  State<FirebaseTestScreen> createState() => _FirebaseTestScreenState();
}

class _FirebaseTestScreenState extends State<FirebaseTestScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _status = 'Not connected';
  User? _user;

  @override
  void initState() {
    super.initState();
    _checkFirebaseConnection();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        _user = user;
      });
    });
  }

  void _checkFirebaseConnection() async {
    try {
      // Test Firestore connection
      await FirebaseFirestore.instance.collection('test').limit(1).get();
      setState(() {
        _status = 'Firebase connected successfully!';
      });
    } catch (e) {
      setState(() {
        _status = 'Firebase connection failed: $e';
      });
    }
  }

  void _signUp() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      setState(() {
        _status = 'Sign up successful!';
      });
    } catch (e) {
      setState(() {
        _status = 'Sign up failed: $e';
      });
    }
  }

  void _signIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      setState(() {
        _status = 'Sign in successful!';
      });
    } catch (e) {
      setState(() {
        _status = 'Sign in failed: $e';
      });
    }
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    setState(() {
      _status = 'Signed out';
    });
  }

  void _testFirestore() async {
    if (_user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_user!.uid)
            .set({
          'email': _user!.email,
          'testData': 'Firebase test successful',
          'timestamp': FieldValue.serverTimestamp(),
        });
        setState(() {
          _status = 'Firestore write successful!';
        });
      } catch (e) {
        setState(() {
          _status = 'Firestore write failed: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Test'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Firebase Status',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(_status),
                    const SizedBox(height: 8),
                    if (_user != null)
                      Text('Logged in as: ${_user!.email}')
                    else
                      const Text('Not logged in'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _signUp,
                    child: const Text('Sign Up'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _signIn,
                    child: const Text('Sign In'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _user != null ? _signOut : null,
              child: const Text('Sign Out'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _user != null ? _testFirestore : null,
              child: const Text('Test Firestore Write'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _checkFirebaseConnection,
              child: const Text('Test Connection'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}