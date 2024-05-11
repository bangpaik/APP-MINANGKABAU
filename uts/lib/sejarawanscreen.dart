import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:uts/loginscreen.dart';
import 'package:uts/homescreen.dart';
import 'package:uts/galleryscreen.dart';
import 'package:uts/profilescreen.dart';
import 'package:uts/detailsejarawanscreen.dart';
import 'package:uts/addsejarawanscreen.dart';
import 'package:uts/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uts/edit_sejarawanscreen.dart';

class SejarawanScreen extends StatefulWidget {
  @override
  _SejarawanScreenState createState() => _SejarawanScreenState();
}

class _SejarawanScreenState extends State<SejarawanScreen> {
  late List<dynamic>? _sejarawanData;
  late List<dynamic> _searchResult = [];
  final TextEditingController _searchController = TextEditingController();

  Future<void> _fetchData() async {
    final response = await http.get(Uri.parse(api_url + 'get_sejarawan.php'));
    if (response.statusCode == 200) {
      setState(() {
        _sejarawanData = json.decode(response.body)['data'];
        _searchResult = _sejarawanData ?? [];
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ModalRoute.of(context)?.settings.arguments == true) {
      _fetchData(); // Reload data jika ada perubahan
    }
  }

  void _filterSearchResults(String query) {
    List<dynamic> searchResults = [];
    searchResults.addAll(_sejarawanData!);
    if (query.isNotEmpty) {
      List<dynamic> dummyListData = [];
      searchResults.forEach((item) {
        if (item['nama_sejarawan'].toString().toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      });
      setState(() {
        _searchResult = [];
        _searchResult = dummyListData;
      });
      return;
    } else {
      setState(() {
        _searchResult = [];
        _searchResult = _sejarawanData ?? [];
      });
    }
  }

  Future<void> _deleteSejarawan(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id_sejarawan = prefs.getString('id_sejarawan');

    // Hapus data sejarawan jika tidak ada masalah dengan ID
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi'),
        content: Text('Apakah Anda yakin ingin menghapus data sejarawan?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Tutup dialog
            },
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Tutup dialog
              try {
                final response = await http.post(
                  Uri.parse(api_url + 'delete_sejarawan.php'),
                  body: {'id': id},
                );

                if (response.statusCode == 200) {
                  final responseData = json.decode(response.body);
                  if (responseData['status'] == 'success') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Data berhasil dihapus')),
                    );
                    _fetchData(); // Reload data setelah penghapusan
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal menghapus data')),
                    );
                  }
                } else {
                  throw Exception('Failed to delete data. Status code: ${response.statusCode}');
                }
              } catch (error) {
                print('Error: $error');
              }
            },
            child: Text('Ya'),
          ),
        ],
      ),
    );
  }


  void _editSejarawan(String id) async {
    // Navigasi ke halaman EditSejarawanScreen dengan membawa data sejarawan yang akan diedit
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditSejarawanScreen(sejarawanData: _sejarawanData!.firstWhere((element) => element['id_sejarawan'] == id)),
      ),
    );

    if (result != null && result == true) {
      // Jika hasil pengeditan berhasil, refresh halaman SejarawanScreen
      _fetchData();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Sejarawan Minangkabau',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF166F52),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari Sejarawan...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                _filterSearchResults(value);
              },
            ),
          ),
          Expanded(
            child: _searchResult == null
                ? Center(child: CircularProgressIndicator())
                : _searchResult!.isEmpty
                ? Center(child: Text('Tidak ada data yang tersedia'))
                : ListView.builder(
              itemCount: _searchResult!.length,
              itemBuilder: (context, index) {
                final item = _searchResult![index];
                final thumbnailUrl = '$api_url/sejarawan/${item['foto_sejarawan']}';
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 5,
                    color: Color(0xFFFFFFFF),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(thumbnailUrl),
                      ),
                      title: Text(item['nama_sejarawan'].toString()),
                      subtitle: Text(item['asal'].toString()),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove_red_eye),
                            tooltip: 'Detail',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailSejarawanScreen(sejarawanData: item),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.edit),
                            tooltip: 'Edit',
                            onPressed: () {
                              // Call edit function when edit button is pressed
                              _editSejarawan(item['id_sejarawan']);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            tooltip: 'Hapus',
                            onPressed: () {
                              // Call delete confirmation dialog when delete button is pressed
                              _deleteSejarawan(item['id_sejarawan']);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddSejarawanScreen()),
          );
        },
        tooltip: 'Add Sejarawan',
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: Color(0xFF166F52),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Color(0xFF166F52),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SejarawanScreen(),
  ));
}
