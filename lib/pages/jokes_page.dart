import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart'; // Pour un partage amélioré
import 'dart:convert';
import 'dart:math';
import '../services/auth_service.dart'; // Service d'authentification
import 'auth_page.dart';

class JokesPage extends StatefulWidget {
  const JokesPage({super.key});

  @override
  State<JokesPage> createState() => _JokesPageState();
}

class _JokesPageState extends State<JokesPage> {
  String currentJoke = "Appuyez sur le bouton pour obtenir une blague !";
  bool isLoading = false;
  List<String> favorites = [];

  final List<String> arabicJokes = [
    'ما هو الشيء الذي كلما زاد نقص؟ العمر.',
    'لماذا لا يزرع الناس التين في الصحراء؟ لأنهم يخافون من التين في الرمال.',
    'ما هو الحيوان الذي لا يلد ولا يبيض؟ ذكر الحيوان.',
  ];

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  Future<void> fetchJokeFromAPI(String url, String language) async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse(url), headers: {'Accept': 'application/json'});

      if (response.statusCode == 200) {
        final jokeData = json.decode(response.body);
        String joke = '';
        if (language == 'en') {
          joke = jokeData['joke'];
        } else if (language == 'fr') {
          joke = jokeData['setup'] != null ? "${jokeData['setup']} ${jokeData['delivery']}" : jokeData['joke'];
        }
        setState(() => currentJoke = joke);
      } else {
        setState(() => currentJoke = "Erreur lors de la récupération de la blague.");
      }
    } catch (e) {
      setState(() => currentJoke = "Erreur de connexion. Vérifiez votre réseau.");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void addToFavorites() async {
    if (!favorites.contains(currentJoke)) {
      setState(() => favorites.add(currentJoke));
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('favorites').doc(user.uid).set({'jokes': favorites});
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ajoutée aux favoris !')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Déjà dans les favoris !')));
    }
  }

  Future<void> loadFavorites() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('favorites').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        setState(() => favorites = List<String>.from(doc.data()!['jokes'] ?? []));
      }
    }
  }

  void fetchArabicJoke() {
    setState(() => currentJoke = arabicJokes[Random().nextInt(arabicJokes.length)]);
  }

  void shareJoke() {
    if (currentJoke.isNotEmpty) {
      final message = "$currentJoke\n\n🎭 Découvrez plus de blagues amusantes dans notre application Blagues Dynamiques !";
      Share.share(message, subject: "Blague du jour ! 🎉");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aucune blague à partager !')));
    }
  }

  Future<void> signOut() async {
    await AuthService().signOut();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AuthPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blagues Dynamiques'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => FavoritesPage(favorites: favorites)));
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: signOut,
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      body: Center(
        child: AnimatedContainer(
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.purple[50],
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.purple.withOpacity(0.2), spreadRadius: 3, blurRadius: 10),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              isLoading
                  ? const CircularProgressIndicator()
                  : Text(
                      currentJoke,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic, color: Colors.purple[900]),
                    ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () => fetchJokeFromAPI('https://icanhazdadjoke.com/', 'en'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: const Text('Anglais', style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: () => fetchJokeFromAPI('https://v2.jokeapi.dev/joke/Any?lang=fr', 'fr'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Français', style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: fetchArabicJoke,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    child: const Text('Arabe', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    onPressed: addToFavorites,
                    icon: const Icon(Icons.favorite_border),
                    color: Colors.red,
                  ),
                  IconButton(
                    onPressed: shareJoke,
                    icon: const Icon(Icons.share),
                    color: Colors.blue,
                    tooltip: 'Partager cette blague',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  final List<String> favorites;

  const FavoritesPage({super.key, required this.favorites});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes Favoris')),
      body: ListView.builder(
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(favorites[index]),
            leading: const Icon(Icons.favorite, color: Colors.red),
          );
        },
      ),
    );
  }
}
