import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_musiq/src/blocs/global.dart';
import 'package:flutter_musiq/src/blocs/music_player.dart';
import 'package:flutter_musiq/src/ui/albums/albums_screen.dart';
import 'package:flutter_musiq/src/ui/all_songs/all_songs_screen.dart';
import 'package:flutter_musiq/src/ui/favorites/favorites_screen.dart';
import 'package:flutter_musiq/src/ui/music_homepage/bottom_panel.dart';
import 'package:flutter_musiq/src/ui/now_playing/now_playing_screen.dart';
import 'package:flutter_musiq/src/ui/search/search_screen.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class MusicHomepage extends StatefulWidget {
  final MusicPlayerBloc _musicPlayerBloc;
  MusicHomepage({@required MusicPlayerBloc musicPlayerBloc}) : _musicPlayerBloc = musicPlayerBloc;

  @override
  _MusicHomepageState createState() => _MusicHomepageState();
}

class _MusicHomepageState extends State<MusicHomepage> {
  PanelController _panelController;
  String currentSongURI;
  bool isPanelVisible = false;

  _MusicHomepageState() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.blueAccent));
  }

  @override
  void initState() {
    _panelController = new PanelController();
    super.initState();
    widget._musicPlayerBloc.playerState$.stream.listen((data) {
      currentSongURI = data.value.uri;
      if (currentSongURI != null && isPanelVisible != true) {
        _panelController.show();
        isPanelVisible = true;
      }
    });
  }

  @override
  void dispose() {
    _panelController.close();
    super.dispose();
  }

  panelCollapsedView(_radius) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(_radius),
          topRight: Radius.circular(_radius),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.7],
          colors: [Color(0xFF47ACE1), Color(0xFFDF5F9D)],
        ),
      ),
      child: BottomPanel(controller: _panelController),
    );
  }

  panelOpenedView(_radius) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(_radius),
        topRight: Radius.circular(_radius),
      ),
      child: NowPlayingScreen(controller: _panelController),
    );
  }

  tabHeaderView() {
    return TabBar(
      indicatorColor: Color(0xFFD9EAF1),
      indicatorPadding: EdgeInsets.all(4),
      labelColor: Colors.white,
      unselectedLabelColor: Color(0xFF274D85).withOpacity(0.6),
      tabs: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Text("Songs", style: TextStyle(fontSize: 20.0, color: Colors.white)),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Text("Albums", style: TextStyle(fontSize: 20.0, color: Colors.white)),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Text("Favorites", style: TextStyle(fontSize: 20.0, color: Colors.white)),
        ),
      ],
    );
  }

  pageBodyView() {
    return DefaultTabController(
      length: 3,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.blueAccent,
          title: Text(
            "Flutter Player",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SearchScreen()));
                },
                icon: Icon(Icons.search, color: Colors.white, size: 35),
              ),
            )
          ],
          bottom: tabHeaderView(),
          elevation: 0.0,
        ),
        body: TabBarView(
          key: UniqueKey(),
          physics: BouncingScrollPhysics(),
          children: <Widget>[
            AllSongsScreen(),
            AlbumsScreen(),
            FavoritesScreen(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final GlobalBloc _globalBloc = Provider.of<GlobalBloc>(context);

    final double _radius = 25.0;
    return WillPopScope(
      onWillPop: () {
        if (!_panelController.isPanelClosed()) {
          _panelController.close();
        } else {
          _showExitDialog(_globalBloc);
        }
        return Future<bool>.value(false);
      },
      child: Scaffold(
        body: SlidingUpPanel(
          minHeight: 115,
          isPanelVisible: true,
          panelSnapping: true,
          panel: panelOpenedView(_radius),
          controller: _panelController,
          maxHeight: MediaQuery.of(context).size.height,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(_radius), topRight: Radius.circular(_radius)),
          collapsed: panelCollapsedView(_radius),
          body: pageBodyView(),
        ),
      ),
    );
  }

  void _showExitDialog(_globalBloc) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Flutter Player",
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          content: Text(
            "Are you sure you want to close the app?",
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          actions: <Widget>[
            FlatButton(
              textColor: Color(0xFFDF5F9D),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("NO"),
            ),
            FlatButton(
              textColor: Color(0xFFDF5F9D),
              onPressed: () {
                SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                _globalBloc.dispose();
              },
              child: Text("YES"),
            ),
          ],
        );
      },
    );
  }
}
