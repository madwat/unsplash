/*
Добовляю нужные библиотеки.
*/
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
/* 
Использую классы Photo, User, PhotoUrls для приема данных JSON.
Внутри классов объявляю переменные. В одноименных конструкторах присваиваю значения переменным.
Возвращаю значения которые вдальнейшем использую в прогррамме.
*/
class Photo {
  String description;
  PhotoUrls urls;
  User user;
  Photo({
    this.description,
    this.urls,
    this.user,
  });
  static Photo fromJson(Map<String, dynamic> json) {
    return Photo(
      description: json['description'],
      user: User.fromJson(json['user']),
      urls: PhotoUrls.fromJson(json['urls']),
    );
  }
}

class User {
  String username;
  String name;
  String bio;
  User({this.username, this.name, this.bio});
  static User fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      name: json['name'],
      bio: json['bio'],
    );
  }
}

class PhotoUrls {
  String regular;
  String small;
  PhotoUrls({this.regular, this.small});
  static PhotoUrls fromJson(Map<String, dynamic> json) {
    return PhotoUrls(
      regular: json['regular'],
      small: json['small'],
    );
  }
}
/*
Точка входа в программу.
*/
void main() => runApp(MyApp());
/*
MyApp получает свойства изменяемого виджета.
*/
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}
/*
Приватному классу _MyAppState передаю свойства универсального класса State, специализированного для использования с MyApp
*/
class _MyAppState extends State<MyApp> {
  Future<List<Photo>> photos;
  Future<List<Photo>> fetchPhotos() async {
    final String baseUrl = "https://api.unsplash.com/photos/";
    final String _clientId =
        "896d4f52c589547b2134bd75ed48742db637fa51810b49b607e37e46ab2c0043";
    List<Photo> list = [];
    String url = baseUrl + "?per_page=30&client_id=$_clientId";
    final response = await http.get(url);
    if (response.statusCode == 200) {
      List decodedJson = json.decode(response.body);
      print(json.decode(response.body));
      print(decodedJson.length);
      for (int i = 0; i < decodedJson.length; i++) {
        list.add(Photo.fromJson(decodedJson[i]));
      }
      return list;
    } else {
      throw Exception('Failed to load photos');
    }
  }
/*
Переопределяю метод initState()
*/
  @override
  void initState() {
    super.initState();
    photos = fetchPhotos();
  }
/*
В функции сборщика создаю виджет Padding
*/
  buildPhotosListView(AsyncSnapshot<List<Photo>> snapshot) {
    return ListView.builder(
      itemCount: snapshot.data.length,
      itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: ImageW(snapshot.data[index]),
          ),
    );
  }
/*

*/
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.orange),
      home: Scaffold(
        appBar: AppBar(
          leading: Icon(
            Icons.image,
            size: 40.0,
          ),
          title: Text("Photos"),
          centerTitle: true,
        ),
        body: FutureBuilder<List<Photo>>(
          future: photos,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return buildPhotosListView(snapshot);
            } else if (snapshot.hasError) {
              return Center(
                child: Text("${snapshot.error}"),
              );
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}
/*
ImageW получает свойства неизменяемого виджета.
*/
class ImageW extends StatelessWidget {
  final Photo data;
  const ImageW(this.data);
  buildBottomText() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        color: Colors.black38,
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "${data.user.name}\n${data.user.bio != null ? data.user.bio : data.description != null ? data.description : data.user.username}",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
          ),
        ),
      ),
    );
  }
/*

*/
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => Detail(data),
          ),
        );
      },
      child: Container(
        height: 200.0,
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: Image.network(
                data.urls.small,
                fit: BoxFit.cover,
              ),
            ),
            buildBottomText(),
          ],
        ),
      ),
    );
  }
}
/*

*/
class Detail extends StatelessWidget {
  final Photo photoList;
  Detail(this.photoList);
  buildBackIcon(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CircleAvatar(
          backgroundColor: Colors.black12,
          child: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }
/*

*/
  buildImage() {
    return Align(
      alignment: Alignment.center,
      child: Image.network(
        photoList.urls.regular,
        height: double.maxFinite,
        width: double.maxFinite,
        fit: BoxFit.contain,
      ),
    );
  }
/*

*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black38,
      body: Stack(
        children: <Widget>[
          buildImage(),
          BottomAlignedText(photoList.user),
          buildBackIcon(context),
        ],
      ),
    );
  }
}
/*

*/
class BottomAlignedText extends StatelessWidget {
  final User user;
  BottomAlignedText(this.user);
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        color: Colors.black38,
        width: double.infinity,
        child: Wrap(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "${user.username}",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
