import 'package:hive/hive.dart';

part 'sticker.g.dart';

@HiveType(typeId: 1)
class Sticker extends HiveObject {
  @HiveField(0)
  String imagePath;

  @HiveField(1)
  double dx;

  @HiveField(2)
  double dy;

  Sticker({required this.imagePath, required this.dx, required this.dy});
}
