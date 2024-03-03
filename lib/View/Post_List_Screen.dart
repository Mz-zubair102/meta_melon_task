import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity/connectivity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Post_Detail_Screen.dart';
import '../Models/Post_Models.dart';

class PostListScreen extends StatefulWidget {
  const PostListScreen({super.key});

  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  @override
  List<Post> _posts = [];
  bool _isLoading = false;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }
  /// Fetch Data From Api
  Future<void> _fetchPosts() async {
    setState(() {
      _isLoading = true;
      _isError = false;
    });

    try {
      final response = await http
          .get(Uri.parse('https://jsonplaceholder.typicode.com/posts'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _posts = data.map((item) => Post.fromJson(item)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _isError = true;
        });
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
        _isError = true;
      });
    }
  }
 ///Refresh Post Method
  Future<void> _refreshPosts() async {
    bool isConnected = await _checkConnectivity();
    if (!isConnected) {
      // Show popup error if there is no internet connection
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('No Internet Connection'),
            content:
                Text('Please check your internet connection and try again.'),
            actions: <Widget>[
              // ElevatedButton(onPressed: (){}, child: Text('ok')),
              FlatButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }
    // Proceed with data fetching if internet connection is available
    // Simulate fetching new posts
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      // Replace posts with new data
      _fetchPosts();
      // posts = ['New Post 1', 'New Post 2', 'New Post 3'];
    });
  }
  /// Internet Conectivity Method
  Future<bool> _checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Post",
          style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.cyan.shade400,
          centerTitle: true,
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _isError
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Failed to fetch posts.'),
                        ElevatedButton(
                            onPressed: _fetchPosts, child: Text('Retry')),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _refreshPosts,
                    child: ListView.builder(
                        itemCount: _posts.length,
                        itemBuilder: (context, index) {
                          final post = _posts[index];
                          return Card(
                            child: ListTile(
                                title: Text("Tittle : ${post.title}",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.lightBlue),
                                ),
                                subtitle: Text("Body : ${post.body}"),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => PostDetailScreen(
                                                post: post,
                                              )));
                                }),
                          );
                        }),
                  ));
  }

  FlatButton({required child, required Null Function() onPressed}) {
    child:Text(
      child,
      style: TextStyle(
        fontSize: 18,
        color: Colors.white,
      ),
    );
    color:
    Colors.blue;
    padding:
    EdgeInsets.symmetric(horizontal: 20, vertical: 10);
    shape:
    RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    );
  }
}
