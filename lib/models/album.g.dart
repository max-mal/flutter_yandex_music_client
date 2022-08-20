// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'album.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AlbumAdapter extends TypeAdapter<Album> {
  @override
  final int typeId = 5;

  @override
  Album read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Album(
      id: fields[0] as int,
      title: fields[1] as String,
      releaseDate: fields[2] as DateTime?,
      coverUri: fields[3] as String,
      trackCount: fields[4] as int,
      genre: fields[5] as String,
      bestTrackIds: (fields[6] as List).cast<int>(),
      artistIds: (fields[7] as List).cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, Album obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.releaseDate)
      ..writeByte(3)
      ..write(obj.coverUri)
      ..writeByte(4)
      ..write(obj.trackCount)
      ..writeByte(5)
      ..write(obj.genre)
      ..writeByte(6)
      ..write(obj.bestTrackIds)
      ..writeByte(7)
      ..write(obj.artistIds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlbumAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
