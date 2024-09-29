import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Để chuyển đổi JSON

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'healthcare',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 48, 198, 103)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Nguyên Óc Chóa'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Danh sách lưu trữ kết quả từ API
  List<dynamic> _apiData = [];

  // Hàm gọi API
  Future<void> fetchApiData() async {
    var url = Uri.parse('http://192.168.3.112:3000/users'); // API mẫu
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body); // Chuyển đổi JSON
        setState(() {
          _apiData = data; // Lưu trữ danh sách người dùng từ API
        });
      } else {
        setState(() {
          _apiData = []; // Xử lý lỗi khi không lấy được dữ liệu
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Lỗi'),
                content: Text(
                    'Không thể lấy dữ liệu từ API: ${response.statusCode}'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Đóng'),
                  ),
                ],
              );
            },
          );
        });
      }
    } catch (e) {
      setState(() {
        _apiData = []; // Xử lý lỗi khi gọi API
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Lỗi'),
              content: Text('Lỗi khi gọi API: $e'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Đóng'),
                ),
              ],
            );
          },
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchApiData(); // Gọi API khi màn hình khởi tạo
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Dữ liệu từ API:',
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _apiData.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(_apiData[index]['name']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Email: ${_apiData[index]['email']}'),
                        Text('IDUser: ${_apiData[index]['_id']}'),
                        Text('Version: ${_apiData[index]['__v']}'),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: fetchApiData, // Nút để gọi API lại khi bấm
              child: const Text('Bấm vô đây để tải lại Data nè fen'),
            ),
          ],
        ),
      ),
    );
  }
}
