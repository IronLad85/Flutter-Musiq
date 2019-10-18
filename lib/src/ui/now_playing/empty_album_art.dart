import 'package:flutter/material.dart';

class EmptyAlbumArtContainer extends StatelessWidget {
  const EmptyAlbumArtContainer({
    Key key,
    @required double radius,
    @required double albumArtSize,
    @required double iconSize,
  })  : _radius = radius,
        _iconSize = iconSize,
        super(key: key);

  final double _radius;
  final double _iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(shape: BoxShape.circle),
        padding: EdgeInsets.only(top: 40, left: 40, right: 40, bottom: 40),
        alignment: Alignment.center,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_radius),
          child: Stack(
            children: <Widget>[
              AspectRatio(
                  aspectRatio: 1 / 1,
                  child: Container(
                    color: Colors.grey[400],
                    child: Center(
                      child: Icon(
                        Icons.music_note,
                        size: _iconSize,
                        color: Colors.black,
                      ),
                    ),
                  )),
              Opacity(
                opacity: 0.55,
                child: AspectRatio(
                  aspectRatio: 1 / 1,
                  child: Container(
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
                ),
              ),
            ],
          ),
        ));
  }
}
