class ZoneData {
  double time = 0;
  int value = 0;

  ZoneData(this.time, this.value);

  Map toJson() => {'time': time, 'value': value};
}
