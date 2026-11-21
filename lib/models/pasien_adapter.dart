import 'package:hive/hive.dart';
import 'pasien.dart';

/// Hive TypeAdapter untuk model Pasien dengan typeId: 0
/// Urutan field konsisten antara read dan write:
/// 0: noRekamMedis (String)
/// 1: nama (String)
/// 2: tanggalLahir (DateTime)
/// 3: jenisKelamin (String)
/// 4: golonganDarah (String)
/// 5: keluhan (String)
class PasienAdapter extends TypeAdapter<Pasien> {
  @override
  final int typeId = 0;

  @override
  Pasien read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Pasien(
      noRekamMedis: fields[0] as String,
      nama: fields[1] as String,
      tanggalLahir: fields[2] as DateTime,
      jenisKelamin: fields[3] as String,
      golonganDarah: fields[4] as String,
      keluhan: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Pasien obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.noRekamMedis)
      ..writeByte(1)
      ..write(obj.nama)
      ..writeByte(2)
      ..write(obj.tanggalLahir)
      ..writeByte(3)
      ..write(obj.jenisKelamin)
      ..writeByte(4)
      ..write(obj.golonganDarah)
      ..writeByte(5)
      ..write(obj.keluhan);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PasienAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
