import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_musiq/src/blocs/music_player.dart';
import 'dart:io';
import 'package:flutter_musiq/src/models/playerstate.dart';

class AlbumArtContainer extends StatefulWidget {
  const AlbumArtContainer({
    Key key,
    @required double radius,
    @required double albumArtSize,
    @required Song currentSong,
    @required MusicPlayerBloc musicBlocState,
  })  : _radius = radius,
        _albumArtSize = albumArtSize,
        _currentSong = currentSong,
        _musicBlocState = musicBlocState,
        super(key: key);

  State<AlbumArtContainer> createState() => _AlbumArtContailerState(_musicBlocState);

  final double _radius;
  final double _albumArtSize;
  final Song _currentSong;
  final MusicPlayerBloc _musicBlocState;
}

class _AlbumArtContailerState extends State<AlbumArtContainer> with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  double tickerValue = 0;
  double seekRotationValue = 0;
  bool isAudioSeeking = false;
  bool isPlaying = true;

  _AlbumArtContailerState(MusicPlayerBloc _musicBlocState) {
    _musicBlocState.position$.stream.listen((data) {
      setState(() {
        seekRotationValue = (data.inSeconds / 50);
      });
    });
    _musicBlocState.isAudioSeeking$.stream.listen((isSeeking) {
      setState(() {
        isAudioSeeking = isSeeking;
      });
      if (isAudioSeeking == true) {
        _animationController.stop(canceled: false);
      } else {
        _animationController.forward();
      }
    });
    _musicBlocState.playerState$.stream.listen((playerState) {
      setState(() {
        isPlaying = playerState.key == PlayerState.playing;
      });
      if (playerState.key == PlayerState.playing) {
        _animationController.forward();
      } else {
        _animationController.stop(canceled: false);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this, // the SingleTickerProviderStateMixin
      duration: Duration(hours: 1),
    )..repeat();
    _animationController.addListener(() {
      if (isPlaying) {
        setState(() {
          tickerValue = _animationController.value * 800 * math.pi;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  renderGradient() {
    return Opacity(
      opacity: 0.4,
      child: Container(
        width: double.infinity,
        height: widget._albumArtSize,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            stops: [
              0.0,
              0.85,
            ],
            colors: [
              Color(0xFF47ACE1),
              Color(0xFFDF5F9D),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 50, left: 50, right: 50, bottom: 20),
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(widget._radius), boxShadow: [
          BoxShadow(color: Color.fromRGBO(255, 182, 193, 0.75), offset: Offset(0, 2), spreadRadius: 0.1, blurRadius: 20)
        ]),
        child: Transform.rotate(
          angle: isAudioSeeking == true ? seekRotationValue : tickerValue,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget._radius),
            child: AspectRatio(
              aspectRatio: 1 / 1,
              child: Stack(
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    child: FadeInImage(
                      placeholder: FileImage(File(widget._currentSong.albumArt)),
                      image: AssetImage(
                        widget._currentSong.albumArt,
                      ),
                      fit: BoxFit.fill,
                    ),
                  ),
                  renderGradient()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
