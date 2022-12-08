class UserData {
  String date = '';
  int time = 0;
  int zone = 0;
  int id = 0;

  UserData(this.date, this.time, this.zone, this.id);

  Map toJson() => {'id': id};
}
