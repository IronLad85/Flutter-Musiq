import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_musiq/src/blocs/global.dart';
import 'package:flutter_musiq/src/common/music_icons.dart';
import 'package:flutter_musiq/src/models/playerstate.dart';
import 'package:provider/provider.dart';

class SongTile extends StatelessWidget {
  final Song _song;
  String _artists;
  String _duration;
  SongTile({Key key, @required Song song})
      : _song = song,
        super(key: key);

  inlineSliderWidget(_globalBloc, _currentSong, _isSelectedSong) {
    if (_isSelectedSong) {
      return Row(
        children: <Widget>[
          Flexible(
            flex: 2,
            child: Container(
              width: double.infinity,
            ),
          ),
          Flexible(
            flex: 14,
            child: StreamBuilder<Duration>(
              stream: _globalBloc.musicPlayerBloc.position$,
              builder: (BuildContext context, AsyncSnapshot<Duration> snapshot) {
                if (!snapshot.hasData) {
                  return Slider(
                    value: 0,
                    onChanged: (double value) => null,
                    activeColor: Colors.transparent,
                    inactiveColor: Colors.transparent,
                  );
                }
                final Duration _currentDuration = snapshot.data;
                final int _millseconds = _currentDuration.inMilliseconds;
                final int _songDurationInMilliseconds = _currentSong.duration;
                return Slider(
                  min: 0,
                  max: _songDurationInMilliseconds.toDouble(),
                  value: _songDurationInMilliseconds > _millseconds
                      ? _millseconds.toDouble()
                      : _songDurationInMilliseconds.toDouble(),
                  onChangeStart: (double value) => _globalBloc.musicPlayerBloc.invertSeekingState(),
                  onChanged: (double value) {
                    final Duration _duration = Duration(
                      milliseconds: value.toInt(),
                    );
                    _globalBloc.musicPlayerBloc.updatePosition(_duration);
                  },
                  onChangeEnd: (double value) {
                    _globalBloc.musicPlayerBloc.invertSeekingState();
                    _globalBloc.musicPlayerBloc.audioSeek(value / 1000);
                  },
                  activeColor: Colors.blue,
                  inactiveColor: Color(0xFFCEE3EE),
                );
              },
            ),
          ),
        ],
      );
    }
    return Container();
  }

  playButton(_isSelectedSong, _state) {
    return Flexible(
      flex: 2,
      child: Container(
        width: double.infinity,
        alignment: Alignment.centerLeft,
        child: AnimatedCrossFade(
          duration: Duration(milliseconds: 150),
          firstChild: PauseIcon(color: Color(0xFF6D84C1)),
          secondChild: PlayIcon(color: Color(0xFFA1AFBC)),
          crossFadeState:
              _isSelectedSong && _state == PlayerState.playing ? CrossFadeState.showFirst : CrossFadeState.showSecond,
        ),
      ),
    );
  }

  songDuration(_duration) {
    return Flexible(
      flex: 2,
      child: Container(
        width: double.infinity,
        alignment: Alignment.centerRight,
        child: Text(_duration,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF94A6C5)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
      ),
    );
  }

  songInfo() {
    return Flexible(
      flex: 8,
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Container(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                _song.title,
                style: TextStyle(fontSize: 19, color: Color(0xFF4D6B9C), fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Divider(height: 5, color: Colors.transparent),
              Text(
                _artists.toUpperCase(),
                style: TextStyle(fontSize: 14, color: Color.fromRGBO(163, 178, 201, 1), letterSpacing: 0.1),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  gradientDecoration(_isSelectedSong) {
    return BoxDecoration(
      gradient: _isSelectedSong
          ? LinearGradient(
              colors: [Color.fromRGBO(210, 237, 250, 1).withOpacity(1), Color.fromRGBO(240, 248, 252, 1)],
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final GlobalBloc _globalBloc = Provider.of<GlobalBloc>(context);
    parseArtists();
    parseDuration();
    return StreamBuilder<MapEntry<PlayerState, Song>>(
        stream: _globalBloc.musicPlayerBloc.playerState$,
        builder: (BuildContext context, AsyncSnapshot<MapEntry<PlayerState, Song>> snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }
          final PlayerState _state = snapshot.data.key;
          final Song _currentSong = snapshot.data.value;
          final bool _isSelectedSong = _song == _currentSong;
          return AnimatedContainer(
            duration: Duration(milliseconds: 250),
            decoration: gradientDecoration(_isSelectedSong),
            child: Container(
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black12, width: 0.5))),
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      playButton(_isSelectedSong, _state),
                      songInfo(),
                      songDuration(_duration),
                    ],
                  ),
                  // inlineSliderWidget(_globalBloc, _currentSong, _isSelectedSong)
                ],
              ),
            ),
          );
        });
  }

  void parseDuration() {
    final double _temp = _song.duration / 1000;
    final int _minutes = (_temp / 60).floor();
    final int _seconds = (((_temp / 60) - _minutes) * 60).round();
    if (_seconds.toString().length != 1) {
      _duration = _minutes.toString() + ":" + _seconds.toString();
    } else {
      _duration = _minutes.toString() + ":0" + _seconds.toString();
    }
  }

  void parseArtists() {
    _artists = _song.artist.split(";").reduce((String a, String b) {
      return a + " & " + b;
    });
  }
}
