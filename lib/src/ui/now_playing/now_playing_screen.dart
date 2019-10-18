import 'dart:ui';

import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_musiq/src/blocs/global.dart';
import 'package:flutter_musiq/src/models/playerstate.dart';
import 'package:flutter_musiq/src/ui/now_playing/album_art_container.dart';
import 'package:flutter_musiq/src/ui/now_playing/empty_album_art.dart';
import 'package:flutter_musiq/src/ui/now_playing/music_control.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class NowPlayingScreen extends StatelessWidget {
  final PanelController _controller;

  NowPlayingScreen({@required PanelController controller}) : _controller = controller;

  renderSongInfo(_globalBloc) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: StreamBuilder<MapEntry<PlayerState, Song>>(
        stream: _globalBloc.musicPlayerBloc.playerState$,
        builder: (BuildContext context, AsyncSnapshot<MapEntry<PlayerState, Song>> snapshot) {
          if (!snapshot.hasData || snapshot.data.key == PlayerState.stopped) {
            return Container();
          }

          final Song _currentSong = snapshot.data.value;

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Divider(
                height: 10,
                color: Colors.transparent,
              ),
              Text(
                _currentSong.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  color: Color(0xFF4D6B9C),
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Divider(
                height: 7,
                color: Colors.transparent,
              ),
              Text(
                "Album:  " + _currentSong.album,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black38,
                  letterSpacing: 0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget topbar() {
    return Container(
      padding: EdgeInsets.only(top: 20, left: 10, right: 20),
      child: (Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          InkWell(
            customBorder: CircleBorder(),
            splashColor: Colors.black38,
            onTap: _controller.close,
            child: Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.arrow_back_ios, color: Colors.black54),
            ),
          ),
          Expanded(
              child: Text(
            "Now Playing",
            style: TextStyle(fontSize: 24, color: Colors.black45, fontWeight: FontWeight.w600, letterSpacing: 0.5),
            textAlign: TextAlign.center,
          )),
          Icon(Icons.arrow_back_ios, color: Colors.transparent)
        ],
      )),
    );
  }

  Widget songInfoBuilder(snapshot, _radius, _globalBloc, _albumArtSize) {
    if (!snapshot.hasData || snapshot.data.value.albumArt == null) {
      return EmptyAlbumArtContainer(
        radius: _radius,
        albumArtSize: _albumArtSize,
        iconSize: _albumArtSize / 2.5,
      );
    } else {
      final Song _currentSong = snapshot.data.value;
      return Container(
          padding: EdgeInsets.only(left: 10, right: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AlbumArtContainer(
                radius: _radius,
                albumArtSize: _albumArtSize,
                currentSong: _currentSong,
                musicBlocState: _globalBloc.musicPlayerBloc,
              ),
              renderSongInfo(_globalBloc)
            ],
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final GlobalBloc _globalBloc = Provider.of<GlobalBloc>(context);
    final double _radius = 200;
    final double _albumArtSize = MediaQuery.of(context).size.height / 2.1;
    return Scaffold(
      body: Container(
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                topbar(),
                Expanded(
                  child: StreamBuilder<MapEntry<PlayerState, Song>>(
                    stream: _globalBloc.musicPlayerBloc.playerState$,
                    builder: (BuildContext context, AsyncSnapshot<MapEntry<PlayerState, Song>> snapshot) {
                      return songInfoBuilder(snapshot, _radius, _globalBloc, _albumArtSize);
                    },
                  ),
                ),
                Container(
                  child: MusicControl(controller: _controller),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
