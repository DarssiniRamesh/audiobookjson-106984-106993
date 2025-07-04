import 'package:flutter/material.dart';
import 'dart:convert';

// PUBLIC_INTERFACE
void main() {
  runApp(const MyApp());
}

// PUBLIC_INTERFACE
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Audiobook App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Audiobook App'),
    );
  }
}

// PUBLIC_INTERFACE
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Audiobooks"),
      ),
      body: AudiobookListScreen(),
    );
  }
}

// PUBLIC_INTERFACE
class Audiobook {
  final String title;
  final String author;
  final String coverUrl;
  final String audioUrl;
  final String description;

  Audiobook({
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.audioUrl,
    required this.description,
  });

  factory Audiobook.fromJson(Map<String, dynamic> json) {
    return Audiobook(
      title: json['title'] ?? "",
      author: json['author'] ?? "",
      coverUrl: json['cover_url'] ?? "",
      audioUrl: json['audio_url'] ?? "",
      description: json['description'] ?? "",
    );
  }
}

// PUBLIC_INTERFACE
class AudiobookListScreen extends StatefulWidget {
  @override
  State<AudiobookListScreen> createState() => _AudiobookListScreenState();
}

class _AudiobookListScreenState extends State<AudiobookListScreen> {
  late Future<List<Audiobook>> _audiobooks;

  @override
  void initState() {
    super.initState();
    _audiobooks = loadAudiobooks();
  }

  Future<List<Audiobook>> loadAudiobooks() async {
    final String jsonString =
        await DefaultAssetBundle.of(context).loadString('assets/audiobooks.json');
    final dynamic parsed = json.decode(jsonString);
    final List<dynamic> list = parsed is List ? parsed : [];
    return list.map((item) => Audiobook.fromJson(item)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Audiobook>>(
      future: _audiobooks,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error loading audiobooks"));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("No audiobooks available"));
        }
        final audiobooks = snapshot.data!;
        return ListView.builder(
          itemCount: audiobooks.length,
          itemBuilder: (context, index) {
            final book = audiobooks[index];
            return Card(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: book.coverUrl.isNotEmpty
                    ? Image.network(book.coverUrl, width: 48, height: 48, fit: BoxFit.cover)
                    : Icon(Icons.book, size: 40, color: Colors.grey),
                title: Text(book.title, style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(book.author),
                onTap: () {
                  // Placeholder for future Book Detail/Play screen navigation
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(book.title),
                      content: Text(book.description),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('Close'),
                        )
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
