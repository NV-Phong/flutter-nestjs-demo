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
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 255, 0, 89)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Phuoc Oc Bo'),
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

  Future<void> FindUserEmail(String email) async {
    var url = Uri.parse(
        'http://192.168.3.113:3000/users/findemail/$email'); // API tìm
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var users = response.body.isNotEmpty
            ? jsonDecode(response.body)
            : null; // Giải mã JSON trả về
        setState(() {
          if (users != null) {
            // Cập nhật danh sách chỉ chứa người dùng tìm thấy
            _apiData = users;
          } else {
            // Nếu không tìm thấy, có thể hiển thị danh sách trống
            _apiData = [];
          }
        });
      }
    } catch (e) {
      Exception(e);
    }
  }

  // Hàm gọi API
  Future<void> fetchApiData() async {
    var url = Uri.parse('http://192.168.3.113:3000/users'); // API mẫu
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
            // Thêm TextField cho tìm kiếm email
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onChanged: (value) {
                  // Gọi hàm tìm kiếm khi người dùng nhập email
                  fetchApiData();
                  FindUserEmail(value);
                },
                decoration: InputDecoration(
                  labelText: 'Nhập email để tìm kiếm',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
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
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            // Hiện dialog để cập nhật thông tin người dùng
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                TextEditingController nameController =
                                    TextEditingController(
                                        text: _apiData[index]['name']);
                                TextEditingController emailController =
                                    TextEditingController(
                                        text: _apiData[index]['email']);
                                return AlertDialog(
                                  title: Text('Cập nhật người dùng'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextField(
                                        controller: nameController,
                                        decoration:
                                            InputDecoration(labelText: 'Tên'),
                                      ),
                                      TextField(
                                        controller: emailController,
                                        decoration:
                                            InputDecoration(labelText: 'Email'),
                                      ),
                                    ],
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context); // Đóng dialog
                                      },
                                      child: Text('Hủy'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context); // Đóng dialog
                                        updateUser(
                                          _apiData[index]['_id'],
                                          nameController.text,
                                          emailController.text,
                                        ); // Gọi hàm updateUser
                                      },
                                      child: Text('Cập nhật'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
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
                                        deleteUser(_apiData[index]
                                            ['_id']); // Gọi hàm xóa
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
                      ],
                    ),

                    /*trailing: IconButton(
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
                    ),*/
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

  //Update funtion
  Future<void> updateUser(String id, String name, String email) async {
    var url = Uri.parse(
        'http://localhost:3000/users/updateuser/$id'); // API cập nhật ng dùng
    try {
      var response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          var updatedUser = _apiData.firstWhere((user) => user['_id'] == id);
          updatedUser['name'] = name;
          updatedUser['email'] = email;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã cập nhật người dùng thành công: $name'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cập nhật thất bại. Mã lỗi: ${response.statusCode}'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi gọi API: $e'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
