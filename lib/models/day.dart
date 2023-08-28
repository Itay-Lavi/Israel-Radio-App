// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

class DayItem extends Equatable {
  final int id;
  final String hebName;
  final String engName;
  final bool selected;

  const DayItem(this.id, this.hebName, this.engName, this.selected);

  @override
  List<Object> get props => [id, hebName, engName, selected];
}
