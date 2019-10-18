import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_musiq/src/blocs/global.dart';
import 'package:flutter_musiq/src/models/album.dart';
import 'package:flutter_musiq/src/models/playerstate.dart';
import 'package:flutter_musiq/src/ui/all_songs/song_tile.dart';
import 'package:provider/provider.dart';
import 'dart:io';

class SpecificAlbumScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Album _album = Provider.of<Album>(context);
    final GlobalBloc _globalBloc = Provider.of<GlobalBloc>(context);

    playNewSong(newSong) {
      _globalBloc.musicPlayerBloc.stopMusic();
      _globalBloc.musicPlayerBloc.playMusic(newSong);
    }

    pauseSong(currentSong) {
      _globalBloc.musicPlayerBloc.pauseMusic(currentSong);
    }

    playSong(currentSong) {
      _globalBloc.musicPlayerBloc.playMusic(currentSong);
    }

    albumImageView() {
      if (_album.art != null) {
        return FileImage(File(_album.art));
      } else {
        return AssetImage('asset/images/music-placeholder.png');
      }
    }

    albumSongsListView() {
      return StreamBuilder<List<Song>>(
        stream: _globalBloc.musicPlayerBloc.songs$,
        builder: (BuildContext context, AsyncSnapshot<List<Song>> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final List<Song> _allSongs = snapshot.data;
          List<Song> _albumSongs = [];
          for (var song in _allSongs) {
            if (song.albumId == _album.id) {
              _albumSongs.add(song);
            }
          }

          return ListView.builder(
            key: UniqueKey(),
            padding: const EdgeInsets.only(bottom: 16.0, top: 5),
            physics: BouncingScrollPhysics(),
            itemCount: _albumSongs.length,
            itemExtent: 90,
            itemBuilder: (BuildContext context, int index) {
              return StreamBuilder<MapEntry<PlayerState, Song>>(
                stream: _globalBloc.musicPlayerBloc.playerState$,
                builder: (BuildContext context, AsyncSnapshot<MapEntry<PlayerState, Song>> snapshot) {
                  if (!snapshot.hasData) {
                    return Container();
                  }
                  final PlayerState _state = snapshot.data.key;
                  final Song _currentSong = snapshot.data.value;
                  final bool _isSelectedSong = _currentSong == _albumSongs[index];
                  return GestureDetector(
                    onTap: () {
                      _globalBloc.musicPlayerBloc.updatePlaylist(_albumSongs);
                      switch (_state) {
                        case PlayerState.playing:
                          if (_isSelectedSong) {
                            pauseSong(_currentSong);
                          } else {
                            playNewSong(_albumSongs[index]);
                          }
                          break;
                        case PlayerState.paused:
                          if (_isSelectedSong) {
                            playSong(_albumSongs[index]);
                          } else {
                            playNewSong(_albumSongs[index]);
                          }
                          break;
                        case PlayerState.stopped:
                          playSong(_albumSongs[index]);
                          break;
                        default:
                          break;
                      }
                    },
                    child: SongTile(
                      song: _albumSongs[index],
                    ),
                  );
                },
              );
            },
          );
        },
      );
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Color(0xFF274D85), size: 35),
            onPressed: () => Navigator.pop(context),
          ),
          title:
              Text(_album.name, style: TextStyle(color: Color(0xFF274D85), fontWeight: FontWeight.bold, fontSize: 24)),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(2),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Container(width: double.infinity, height: 2, color: Color(0xFFD9EAF1)),
            ),
          ),
          elevation: 0.0,
          backgroundColor: Colors.transparent,
        ),
        body: Column(
          children: [
            Hero(
              tag: "albumImage${_album.id}",
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(image: albumImageView(), fit: BoxFit.cover),
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                          color: Color.fromRGBO(209, 209, 209, 1),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: Offset(0, 2))
                    ],
                  ),
                ),
              ),
            ),
            Expanded(child: albumSongsListView()),
          ],
        ),
      ),
    );
  }
}
