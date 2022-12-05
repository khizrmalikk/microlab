import 'dart:convert';

class NamedData {
  final int time;
  final int value;

  const NamedData(this.time, this.value);

  @override
  String toString() => '$NamedData {$time $value}';
}

class FirebaseNamesDecoder extends Converter<Map, Iterable<NamedData>> {
  const FirebaseNamesDecoder();
  
  @override
  Iterable<NamedData> convert(Map<dynamic, dynamic> input) {
    return input.keys.map((id) => NamedData(input[id]['time'], input[id]['value']));
  }
}