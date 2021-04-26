class Item {
  Item(this.id, this.title, this.timestamp);
  int id;
  String title;
  int timestamp;

  toJson() => {'id': id, 'title': title, 'timestamp': timestamp};
}
