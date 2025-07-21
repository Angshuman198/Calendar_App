import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:main1/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const homme());
}

class homme extends StatelessWidget {
  const homme({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Home Page',
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 13, 90, 18),
        scaffoldBackgroundColor: const Color.fromARGB(255, 1, 30, 1),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color.fromARGB(255, 10, 81, 13),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 10, 81, 13),
            foregroundColor: Colors.white,
          ),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? selectedOption;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveAnswerToFirebase(String question, String answer) async {
    User? user = _auth.currentUser;
    if (user == null) {
      // Prompt login or sign in anonymously
      UserCredential cred = await _auth.signInAnonymously();
      user = cred.user;
    }
    final emailOrUid = user?.email ?? user?.uid;
    if (emailOrUid == null) return;

    try {
      await _firestore
          .collection('user_answers')
          .doc(emailOrUid)
          .collection('preferences')
          .add({
        'question': question,
        'answer': answer,
        'timestamp': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved for $emailOrUid')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Widget buildQuestion(String questionText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          questionText,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 255, 253, 194),
          ),
        ),
        ...['Mathematics', 'Physics', 'Chemistry', 'Biology'].map(
          (option) => RadioListTile<String>(
            title: Text(option, style: const TextStyle(color: Color.fromARGB(255, 255, 253, 194))),
            value: option,
            groupValue: selectedOption,
            onChanged: (value) {
              setState(() {
                selectedOption = value;
              });
            },
            activeColor: const Color.fromARGB(255, 241, 176, 176),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferences'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildQuestion('Question 1: Which subject do you prefer?'),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (selectedOption != null) {
                    saveAnswerToFirebase('Preferred subjects', selectedOption!);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select an option')),
                    );
                  }
                  MaterialPageRoute(builder: (context) => const HomeApp());
                },
                child: const Text('Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
