import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'sejarawanscreen.dart';
import 'package:uts/main.dart';
import 'package:image_picker/image_picker.dart';

class AddSejarawanScreen extends StatefulWidget {
  @override
  _AddSejarawanScreenState createState() => _AddSejarawanScreenState();
}

class _AddSejarawanScreenState extends State<AddSejarawanScreen> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _asalController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  String _jk = 'L';
  late DateTime _selectedDate;
  File? _image;

  @override
    void initState() {
      super.initState();
      _selectedDate = DateTime.now();
    }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadData() async {
    // Validasi formulir
    if (_namaController.text.isEmpty ||
        _asalController.text.isEmpty ||
        _deskripsiController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Peringatan'),
            content: Text('Silakan lengkapi semua bidang formulir.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    // Jika ada gambar yang dipilih
    if (_image != null) {
      final uri = Uri.parse(api_url + 'tambahsejarawan.php');
      final request = http.MultipartRequest('POST', uri);

      // Tambahkan gambar ke request
      request.files.add(await http.MultipartFile.fromPath(
        'foto_sejarawan', // Sesuaikan dengan nama parameter file di PHP
        _image!.path,
      ));

      request.fields['nama_sejarawan'] = _namaController.text;
      request.fields['tgl_lahir'] = _selectedDate.toString();
      request.fields['asal'] = _asalController.text;
      request.fields['jk'] = _jk;
      request.fields['deskripsi'] = _deskripsiController.text;

      // Set header Content-Type
      request.headers['Content-Type'] = 'multipart/form-data';

      final response = await request.send();

      if (response.statusCode == 200) {
        // Data berhasil diunggah
        // Tampilkan SejarawanScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SejarawanScreen()),
        );
      } else {
        // Terjadi kesalahan saat mengunggah data
        // Tampilkan pesan kesalahan atau tangani sesuai kebutuhan
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Terjadi kesalahan saat mengunggah data: ${response.reasonPhrase}'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } else {
      // Jika tidak ada gambar yang dipilih
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Peringatan'),
            content: Text('Silakan pilih gambar terlebih dahulu.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tambah Sejarawan',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF166F52),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _namaController,
              decoration: InputDecoration(labelText: 'Nama Sejarawan'),
            ),
            SizedBox(height: 16.0),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: TextFormField(
                  controller: TextEditingController(text: _selectedDate.toString().split(" ")[0]),
                  decoration: InputDecoration(labelText: 'Tanggal Lahir'),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _asalController,
              decoration: InputDecoration(labelText: 'Asal'),
            ),
            SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: _jk,
              decoration: InputDecoration(labelText: 'Jenis Kelamin'),
              onChanged: (value) {
                setState(() {
                  _jk = value!;
                });
              },
              items: ['L', 'P'].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _deskripsiController,
              decoration: InputDecoration(labelText: 'Deskripsi'),
              maxLines: 3,
            ),
            SizedBox(height: 16.0),
            GestureDetector(
              onTap: _selectImage,
              child: Container(
                width: 120,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.black,
                ),
                child: Center(
                  child: Text(
                    'Upload Image',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20,),
            if (_image != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.file(
                  _image!,
                  height: 200,
                ),
              ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: _uploadData,
              child: Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
