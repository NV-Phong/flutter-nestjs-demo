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
    var url = Uri.parse('http://localhost:3000/users'); // API mẫu
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

  Future<void> deleteUser(String id) async {
    var url = Uri.parse('http://localhost:3000/users/$id'); // API xóa
    try {
      var response = await http.delete(url);
      if (response.statusCode == 200) {
        var deletedUser = _apiData.firstWhere((user) => user['_id'] == id);
        var deletedUserName = deletedUser['name'];
        setState(() {
          _apiData.removeWhere((user) => user['_id'] == id);
          // Cập nhật danh sách
        });
        // Hiển thị thông báo khi xóa thành công
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xóa người dùng: $deletedUserName'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Không thể xóa người dùng. Mã lỗi: ${response.statusCode}'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      Exception(e);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchApiData(); // Gọi API khi màn hình khởi tạo
  }

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
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        // Hiện thông báo xác nhận trước khi xóa
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Xác nhận xóa'),
                              content: Text(
                                  'Bạn có chắc chắn muốn xóa người dùng này không?'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context); // Đóng dialog
                                    deleteUser(
                                        _apiData[index]['_id']); // Gọi hàm xóa
                                  },
                                  child: Text('Có'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('Không'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: fetchApiData,
              child: const Text('Bấm vô đây để tải lại Data nè fen'),
            ),
          ],
        ),
      ),
    );
  }
}
