import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_musiq/src/blocs/global.dart';
import 'package:flutter_musiq/src/models/playerstate.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_musiq/src/ui/now_playing/preferences_board.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class MusicControl extends StatelessWidget {
  final PanelController panelController;

  MusicControl({@required PanelController controller}) : panelController = controller;

  String getRunningDuration(Duration duration) {
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (twoDigits(duration.inHours) != '00' && twoDigits(duration.inHours) != null) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    }
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  String getDuration(Song _song) {
    final double _temp = _song.duration / 1000;
    final int _minutes = (_temp / 60).floor();
    final int _seconds = (((_temp / 60) - _minutes) * 60).round();
    if (_seconds.toString().length != 1) {
      return _minutes.toString() + ":" + _seconds.toString();
    } else {
      return _minutes.toString() + ":0" + _seconds.toString();
    }
  }

  Widget nextButton(_globalBloc) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _globalBloc.musicPlayerBloc.playNextSong(),
        splashColor: Colors.white60,
        customBorder: CircleBorder(),
        child: Container(
          padding: EdgeInsets.all(5),
          child: Icon(
            Icons.skip_next,
            color: Colors.white,
            size: 40,
          ),
        ),
      ),
    );
  }

  Widget previousButton(_globalBloc) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _globalBloc.musicPlayerBloc.playPreviousSong(),
        splashColor: Colors.white60,
        customBorder: CircleBorder(),
        child: Container(
          padding: EdgeInsets.all(5),
          child: Icon(
            Icons.skip_previous,
            color: Colors.white,
            size: 40,
          ),
        ),
      ),
    );
  }

  Widget sliderBuilder(_globalBloc) {
    return Expanded(
      child: StreamBuilder<MapEntry<Duration, MapEntry<PlayerState, Song>>>(
        stream: Observable.combineLatest2(
            _globalBloc.musicPlayerBloc.position$, _globalBloc.musicPlayerBloc.playerState$, (a, b) => MapEntry(a, b)),
        builder: (BuildContext context, AsyncSnapshot<MapEntry<Duration, MapEntry<PlayerState, Song>>> snapshot) {
          if (!snapshot.hasData || snapshot.hasData != null && snapshot.data.value.key == PlayerState.stopped) {
            return Slider(
              value: 0,
              onChanged: (double value) => null,
              activeColor: Colors.white,
              inactiveColor: Colors.white10,
            );
          } else {
            final Duration _currentDuration = snapshot.data.key;
            final Song _currentSong = snapshot.data.value.value;
            final int _millseconds = _currentDuration.inMilliseconds;
            final int _songDurationInMilliseconds = _currentSong.duration;
            return SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3.0,
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 9),
                overlayShape: RoundSliderOverlayShape(overlayRadius: 14.0),
              ),
              child: Slider(
                min: 0,
                max: _songDurationInMilliseconds.toDouble(),
                value: _songDurationInMilliseconds > _millseconds
                    ? _millseconds.toDouble()
                    : _songDurationInMilliseconds.toDouble(),
                onChangeStart: (double value) => _globalBloc.musicPlayerBloc.invertSeekingState(),
                onChanged: (double value) {
                  final Duration _duration = Duration(milliseconds: value.toInt());
                  _globalBloc.musicPlayerBloc.updatePosition(_duration);
                },
                onChangeEnd: (double value) {
                  _globalBloc.musicPlayerBloc.invertSeekingState();
                  _globalBloc.musicPlayerBloc.audioSeek(value / 1000);
                },
                activeColor: Colors.white,
                inactiveColor: Colors.white38,
              ),
            );
          }
        },
      ),
    );
  }

  Widget playPauseButtonBuilder(_globalBloc) {
    return StreamBuilder<MapEntry<PlayerState, Song>>(
        stream: _globalBloc.musicPlayerBloc.playerState$,
        builder: (BuildContext context, AsyncSnapshot<MapEntry<PlayerState, Song>> snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }
          final PlayerState _state = snapshot.data.key;
          final Song _currentSong = snapshot.data.value;

          return GestureDetector(
            onTap: () {
              if (_currentSong.uri != null) {
                if (PlayerState.paused == _state) {
                  _globalBloc.musicPlayerBloc.playMusic(_currentSong);
                } else {
                  _globalBloc.musicPlayerBloc.pauseMusic(_currentSong);
                }
              }
            },
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromRGBO(245, 49, 96, 1),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.24),
                    blurRadius: 15,
                    offset: Offset(3, 3),
                  ),
                ],
              ),
              child: Center(
                child: AnimatedCrossFade(
                  duration: Duration(milliseconds: 200),
                  crossFadeState: _state == PlayerState.playing ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                  firstChild: Icon(
                    Icons.pause,
                    size: 50,
                    color: Colors.white,
                  ),
                  secondChild: Icon(
                    Icons.play_arrow,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          );
        });
  }

  Widget songDurationTime(_globalBloc) {
    return Padding(
      padding: EdgeInsets.only(left: 10),
      child: StreamBuilder<MapEntry<PlayerState, Song>>(
          stream: _globalBloc.musicPlayerBloc.playerState$,
          builder: (BuildContext context, AsyncSnapshot<MapEntry<PlayerState, Song>> snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }
            final Song _currentSong = snapshot.data.value;
            final PlayerState _state = snapshot.data.key;
            return Text(
              _state == PlayerState.stopped ? "0:00" : getDuration(_currentSong),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                letterSpacing: 1,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            );
          }),
    );
  }

  Widget songPlayingTime(_globalBloc) {
    return Container(
      padding: EdgeInsets.only(right: 5),
      child: StreamBuilder<Duration>(
          stream: _globalBloc.musicPlayerBloc.position$,
          builder: (BuildContext context, AsyncSnapshot<Duration> snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }
            return Text(
              getRunningDuration(snapshot.data),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                letterSpacing: 1,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            );
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final GlobalBloc _globalBloc = Provider.of<GlobalBloc>(context);
    return ClipPath(
        clipper: CurveClipper(),
        child: Container(
          padding: EdgeInsets.only(top: 50, bottom: 30),
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color.fromRGBO(245, 87, 108, 1), Color.fromRGBO(200, 23, 105, 1)])),
          child: Column(children: [
            Container(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Flexible(child: previousButton(_globalBloc)),
                    Flexible(child: playPauseButtonBuilder(_globalBloc)),
                    Flexible(child: nextButton(_globalBloc)),
                  ],
                )),
            Container(
                padding: EdgeInsets.only(top: 20, left: 20, right: 20),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                  songPlayingTime(_globalBloc),
                  sliderBuilder(_globalBloc),
                  songDurationTime(_globalBloc)
                ])),
            Container(
                padding: EdgeInsets.only(top: 14, left: 25, right: 25, bottom: 18),
                child: PreferencesBoard(controller: panelController))
          ]),
        ));
  }
}

class CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double heightOffset = 75;
    var path = new Path();
    path.moveTo(0, heightOffset);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, heightOffset);
    path.conicTo(size.width / 2, -heightOffset, 0, heightOffset, 0.9);

    // path.quadraticBezierTo(size.width / 2, -(heightOffset), 0, heightOffset);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
