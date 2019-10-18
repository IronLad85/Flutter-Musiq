import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_musiq/src/blocs/global.dart';
import 'package:flutter_musiq/src/models/playback.dart';
import 'package:flutter_musiq/src/models/playerstate.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_musiq/src/common/music_icons.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class PreferencesBoard extends StatelessWidget {
  final PanelController panelController;

  PreferencesBoard({@required PanelController controller}) : panelController = controller;

  @override
  Widget build(BuildContext context) {
    final GlobalBloc _globalBloc = Provider.of<GlobalBloc>(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        StreamBuilder<MapEntry<MapEntry<PlayerState, Song>, List<Song>>>(
          stream: Observable.combineLatest2(
            _globalBloc.musicPlayerBloc.playerState$,
            _globalBloc.musicPlayerBloc.favorites$,
            (a, b) => MapEntry(a, b),
          ),
          builder: (BuildContext context, AsyncSnapshot<MapEntry<MapEntry<PlayerState, Song>, List<Song>>> snapshot) {
            if (!snapshot.hasData) {
              return Icon(CupertinoIcons.heart, size: 32, color: Color(0xFFC7D2E3));
            }
            final PlayerState _state = snapshot.data.key.key;
            if (_state == PlayerState.stopped) {
              return Icon(CupertinoIcons.heart, size: 32, color: Color(0xFFC7D2E3));
            }

            final Song _currentSong = snapshot.data.key.value;
            final List<Song> _favorites = snapshot.data.value;
            final bool _isFavorited = _favorites.contains(_currentSong);
            return Material(
              color: Colors.transparent,
              child: InkWell(
                splashColor: Colors.white54,
                customBorder: CircleBorder(),
                onTap: () {
                  if (_isFavorited) {
                    _globalBloc.musicPlayerBloc.removeFromFavorites(_currentSong);
                  } else {
                    _globalBloc.musicPlayerBloc.addToFavorites(_currentSong);
                  }
                },
                child: Icon(
                  !_isFavorited ? CupertinoIcons.heart : CupertinoIcons.heart_solid,
                  size: 32,
                  color: Colors.white,
                ),
              ),
            );
          },
        ),
        StreamBuilder<List<Playback>>(
          stream: _globalBloc.musicPlayerBloc.playback$,
          builder: (BuildContext context, AsyncSnapshot<List<Playback>> snapshot) {
            if (!snapshot.hasData) {
              return Icon(CupertinoIcons.loop, size: 34, color: Color(0xFFC7D2E3));
            }
            final List<Playback> _playbackList = snapshot.data;
            final bool _isSelected = _playbackList.contains(Playback.repeatSong);
            return Material(
              color: Colors.transparent,
              child: InkWell(
                splashColor: Colors.white54,
                customBorder: CircleBorder(),
                onTap: () {
                  if (!_isSelected) {
                    _globalBloc.musicPlayerBloc.updatePlayback(Playback.repeatSong);
                  } else {
                    _globalBloc.musicPlayerBloc.removePlayback(Playback.repeatSong);
                  }
                },
                child: !_isSelected
                    ? Icon(CupertinoIcons.loop, size: 40, color: Colors.white54)
                    : Icon(CupertinoIcons.loop_thick, size: 40, color: Colors.white),
              ),
            );
          },
        ),
        StreamBuilder<List<Playback>>(
          stream: _globalBloc.musicPlayerBloc.playback$,
          builder: (BuildContext context, AsyncSnapshot<List<Playback>> snapshot) {
            if (!snapshot.hasData) {
              return Icon(Icons.loop, size: 32, color: Color(0xFFC7D2E3));
            }
            final List<Playback> _playbackList = snapshot.data;
            final bool _isSelected = _playbackList.contains(Playback.shuffle);
            return Material(
              color: Colors.transparent,
              child: InkWell(
                splashColor: Colors.white54,
                customBorder: CircleBorder(),
                onTap: () {
                  if (!_isSelected) {
                    _globalBloc.musicPlayerBloc.updatePlayback(Playback.shuffle);
                  } else {
                    _globalBloc.musicPlayerBloc.removePlayback(Playback.shuffle);
                  }
                },
                child: !_isSelected
                    ? Icon(CupertinoIcons.shuffle_medium, size: 32, color: Colors.white54)
                    : Icon(CupertinoIcons.shuffle_thick, size: 32, color: Colors.white),
              ),
            );
          },
        ),
        Flexible(
          flex: 2,
          child: GestureDetector(
            onTap: () => panelController.close(),
            child: HideIcon(
              color: Colors.white,
            ),
          ),
        )
      ],
    );
  }
}
