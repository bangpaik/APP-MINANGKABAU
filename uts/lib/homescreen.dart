import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:uts/sejarawanscreen.dart';
import 'package:uts/loginscreen.dart';
import 'package:uts/galleryscreen.dart';
import 'package:uts/profilescreen.dart';
import 'package:uts/main.dart';

class Budaya {
  final String judul;
  final String konten;
  final String gambar;

  Budaya({
    required this.judul,
    required this.konten,
    required this.gambar,
  });

  factory Budaya.fromJson(Map<String, dynamic> json) {
    return Budaya(
      judul: json['judul'],
      konten: json['konten'],
      gambar: json['gambar'],
    );
  }
}

class HomeScreen extends StatefulWidget {
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<Budaya> budayaList;
  late List<Budaya> filteredBudayaList;
  bool isLoading = false;
  String? namaUser;
  TextEditingController searchController = TextEditingController();
  int _selectedIndex = 0;


  void initState() {
    super.initState();
    fetchData();
    getNama();
    filteredBudayaList = [];
  }

  Future<void> getNama() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      namaUser = prefs.getString('nama');
    });
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http
          .get(Uri.parse(api_url + 'get_budaya.php'));

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body)['data'];
        setState(() {
          budayaList =
              responseData.map((item) => Budaya.fromJson(item)).toList();
          filteredBudayaList = List.from(budayaList);
          isLoading = false;
        });
      } else {
        throw Exception(
            'Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    getNama();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  Future<void> gallery() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GalleryScreen()),
    );
  }

  void searchBudaya(String query) {
    setState(() {
      filteredBudayaList = budayaList.where((budaya) {
        return budaya.judul.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title:
        Text(
          'Seputar Budaya',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF166F52),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(8),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Cari info budaya...',
              ),
              onChanged: (value) {
                searchBudaya(value);
              },
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredBudayaList.isEmpty
                ? Center(child: Text('Tidak ada data'))
                : ListView.builder(
              itemCount: filteredBudayaList.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 5,
                    child: ListTile(
                      title: Text(filteredBudayaList[index].judul),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${filteredBudayaList[index].konten.length > 50 ? filteredBudayaList[index].konten.substring(0, 50) + '...' : filteredBudayaList[index].konten}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailScreen(
                                      budaya:
                                      filteredBudayaList[index]),
                                ),
                              );
                            },
                            child: Text(
                              'Selengkapnya',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ButtonStyle(
                              backgroundColor:
                              MaterialStateProperty.all(
                                Color(0xFF166F52),
                              ),
                            ),
                          ),
                        ],
                      ),
                      leading: CircleAvatar(
                        backgroundColor: Color(0xFF166F52),
                        backgroundImage: NetworkImage(
                          '$api_url/gambar/${filteredBudayaList[index].gambar}',
                        ),
                      ),
                      trailing: Text(filteredBudayaList[index]
                          .gambar), // Tampilkan nama gambar di sini
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Color(0xFF166F52),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.home),
                  color: Colors.white,
                  tooltip: 'Kebudayaan Minangkabau',
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
                  },
                ),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.photo),
                  color: Colors.white,
                  tooltip: 'Gallery',
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => GalleryScreen()),
                    );
                  },
                ),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.history),
                  color: Colors.white,
                  tooltip: 'Sejarawan',
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => SejarawanScreen()),
                    );
                  },
                ),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.person),
                  color: Colors.white,
                  tooltip: 'Profil',
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => ProfileScreen()),
                    );
                  },
                ),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.logout),
                  color: Colors.white,
                  tooltip: 'Logout',
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  final Budaya budaya;

  DetailScreen({required this.budaya});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          budaya.judul,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF166F52),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                budaya.konten,
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 20),
              Image.network(
                '$api_url/gambar/${budaya.gambar}',
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return CircularProgressIndicator();
                },
                errorBuilder: (context, error, stackTrace) {
                  return Text('Failed to load image');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
