// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TrackAdapter extends TypeAdapter<Track> {
  @override
  final int typeId = 3;

  @override
  Track read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Track(
      id: fields[0] as int,
      title: fields[1] as String,
      duration: fields[2] as Duration,
      coverUri: fields[3] as String,
      hasLyrics: fields[4] as bool,
      artistIds: (fields[5] as List).cast<int>(),
      albumIds: (fields[6] as List).cast<int>(),
      localPath: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Track obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.duration)
      ..writeByte(3)
      ..write(obj.coverUri)
      ..writeByte(4)
      ..write(obj.hasLyrics)
      ..writeByte(5)
      ..write(obj.artistIds)
      ..writeByte(6)
      ..write(obj.albumIds)
      ..writeByte(7)
      ..write(obj.localPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
