import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uts/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

class EditSejarawanScreen extends StatefulWidget {
  final Map<String, dynamic> sejarawanData;

  const EditSejarawanScreen({Key? key, required this.sejarawanData}) : super(key: key);

  @override
  _EditSejarawanScreenState createState() => _EditSejarawanScreenState();
}

class _EditSejarawanScreenState extends State<EditSejarawanScreen> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _asalController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  String _jk = 'L';
  late DateTime _selectedDate;
  File? _image;

  @override
  void initState() {
    super.initState();
    _namaController.text = widget.sejarawanData['nama_sejarawan'].toString();
    _selectedDate = DateTime.parse(widget.sejarawanData['tgl_lahir'].toString());
    _asalController.text = widget.sejarawanData['asal'].toString();
    _deskripsiController.text = widget.sejarawanData['deskripsi'].toString();
    _jk = widget.sejarawanData['jk'].toString();
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

  Future<void> _editSejarawan() async {
    // Membuat request multipart
    var request = http.MultipartRequest('POST', Uri.parse(api_url + 'edit_sejarawan.php'));

    // Mengisi data form
    request.fields['id'] = widget.sejarawanData['id_sejarawan'].toString();
    request.fields['nama_sejarawan'] = _namaController.text;
    request.fields['tgl_lahir'] = _selectedDate.toString();
    request.fields['asal'] = _asalController.text;
    request.fields['jk'] = _jk;
    request.fields['deskripsi'] = _deskripsiController.text;

    // Menambahkan gambar jika ada
    if (_image != null) {
      request.files.add(
        await http.MultipartFile.fromPath('foto_sejarawan', _image!.path),
      );
    }

    // Mengirim request ke server
    var response = await request.send();

    // Mengecek respon dari server
    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final decodedData = json.decode(responseData);
      if (decodedData['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data berhasil diperbarui')),
        );
        Navigator.pop(context, true); // Kembali ke halaman sejarawan dengan hasil pengeditan
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui data')),
        );
      }
    } else {
      throw Exception('Failed to update data. Status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Sejarawan',
          style: TextStyle(color: Colors.white),
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
              onPressed: _editSejarawan,
              child: Text('Perbarui'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  Map<String, dynamic> sejarawanData = {}; // Tentukan data sejarawan yang akan diubah
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: EditSejarawanScreen(sejarawanData: sejarawanData),
  ));
}
