import 'package:flutter/material.dart';
import 'package:gif_finder/pages/gif_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _search;
  int _offSet = 0;
  final _searchController = TextEditingController();

  Future<Map> _getGifs() async {
    http.Response response;

    if (_search == null) {
      response = await http.get("https://api.giphy.com/v1/gifs/trending?api_key=${YOUR_KEY}&limit=20&rating=G");
    } else {
      response = await http.get(
          "https://api.giphy.com/v1/gifs/search?api_key=${YOUR_KEY}&q=$_search&limit=19&offset=$_offSet&rating=G&lang=en");
    }

    return json.decode(response.body);
  }

  @override
  void initState() {
    super.initState();
    _getGifs().then((map) {
      
    });
  }

  int _getCount(List data) {
    if (_search == null) {
      return data.length;
    } else {
      return data.length + 1;
    }
  }


  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
      padding: EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10
      ),
      itemCount: _getCount(snapshot.data["data"]),
      itemBuilder: (context, index) {
        if (_search == null || index < snapshot.data["data"].length) {
          return GestureDetector(
            child: FadeInImage.memoryNetwork(
              image: snapshot.data["data"][index]["images"]["fixed_height"]["url"],
              height: 300,
              fit: BoxFit.cover,
              placeholder: kTransparentImage,
            ),
            onTap: () {
              Navigator.push(context,
                MaterialPageRoute(builder: (context) => GifPage(snapshot.data["data"][index]))
                );
            },
            onLongPressStart: (a) {
              Share.share(snapshot.data["data"][index]["images"]["fixed_height"]["url"]);
            },
          );
        } else {
          return Container(
            child: GestureDetector(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 70,
                  ),
                  Text(
                    "Load more",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22
                    ),
                  )
                ],
              ),
              onTap: () {
                setState(() {
                  _offSet += 19;
                });
              },
            ),
          );
        }
        
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(
            "https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif"),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(15),
              child: TextField(
                decoration: InputDecoration(
                  labelText: "Search for gifs",
                  labelStyle: TextStyle(
                    color: Colors.white,
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                ),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18
                ),
                textAlign: TextAlign.center,
                controller: _searchController,
                onSubmitted: (value) {
                  setState(() {
                    if (_searchController.text.isEmpty) {
                      _search = null;
                      _offSet = 0;
                      _getGifs();
                    } else {
                      _search = _searchController.text;
                      _offSet = 0;
                      _getGifs();
                    }
                  });
                },
              ),
            ),
            Expanded(
              child: FutureBuilder(
                future: _getGifs(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return Container(
                        width: 200,
                        height: 200,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 5.0,
                        ),
                      );
                      default:
                        if (snapshot.hasError) {
                          return Container();
                        } else {
                          return _createGifTable(context, snapshot);
                        }
                  }
                },
              ),
            )
          ],
        ),
    );
  }
}