// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playlist.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlaylistAdapter extends TypeAdapter<Playlist> {
  @override
  final int typeId = 2;

  @override
  Playlist read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Playlist(
      uid: fields[0] as int,
      kind: fields[1] as int,
      title: fields[2] as String,
      description: fields[3] as String,
      trackCount: fields[4] as int,
      coverUri: fields[5] as String,
      backgroundImageUrl: fields[7] as String,
      backgroundVideoUrl: fields[6] as String,
      ownerLogin: fields[9] as String,
      ownerName: fields[10] as String,
      ownerUid: fields[8] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Playlist obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.kind)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.trackCount)
      ..writeByte(5)
      ..write(obj.coverUri)
      ..writeByte(6)
      ..write(obj.backgroundVideoUrl)
      ..writeByte(7)
      ..write(obj.backgroundImageUrl)
      ..writeByte(8)
      ..write(obj.ownerUid)
      ..writeByte(9)
      ..write(obj.ownerLogin)
      ..writeByte(10)
      ..write(obj.ownerName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaylistAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
