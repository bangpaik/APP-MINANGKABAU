import 'package:flutter/material.dart';
import 'package:uts/loginscreen.dart'; // Ganti dengan file loginscreen.dart yang sesuai

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Mengubah latar belakang menjadi putih
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Color(0xFF166F52), // Warna hijau sesuai kode #166F52
                borderRadius: BorderRadius.circular(60),
              ),
            ),
          ),
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Color(0xFF166F52), // Warna hijau sesuai kode #166F52
                borderRadius: BorderRadius.circular(60),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.png',
                width: 350,
              ),
              SizedBox(height: 20),
              Text(
                'UTS Pemrograman Mobile',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Ubah warna teks menjadi hitam
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 50.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 300,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      // primary: Color(0xFF166F52), // Warna hijau sesuai kode #166F52
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // Border radius sedikit
                      ),
                    ).
                    copyWith(
                        backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF166F52))
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10), // Jarak antara tombol
                SizedBox(
                  width: 300,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => RegisterScreen()),
                      // );
                    },
                    style: ElevatedButton.styleFrom(
                      // primary: Colors.blue, // Warna biru untuk tombol register
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // Border radius sedikit
                      ),
                    ).
                    copyWith(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.white)
                    ), // menetapkan warna primary
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text(
                        'Register',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black, // Menetapkan warna putih
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
