enum TransactionType { Add, Modify, Remove }

class Transaction {
  TransactionType type;
  Item item;
  int id;
  Transaction({this.id, this.type, this.item});

  toJson() => {
        'transaction_id': id,
        'transaction_type': getStringForTransactionType(type),
        'item_id': item.id,
        'arb_order': item.theOrder,
        'title': item.title,
        'details': item.details,
        'timestamp': item.timestamp,
        'important': item.important
      };

  bool operator ==(Object t) {
    if (t is Transaction) {
      return t.id == id;
    } else {
      return false;
    }
  }

  @override
  int get hashCode => id;
}

String getStringForTransactionType(TransactionType type) {
  switch (type) {
    case TransactionType.Add:
      return 'Add';
    case TransactionType.Modify:
      return 'Modify';
    case TransactionType.Remove:
      return 'Remove';
  }
}

class Item {
  Item(this.id, this.theOrder, this.title, this.details, this.timestamp,
      this.important);
  int id;
  int theOrder;
  String title;
  String details;
  int timestamp;
  bool important;

  toJson() => {
        'id': id,
        'the_order': theOrder,
        'title': title,
        'details': details,
        'timestamp': timestamp,
        'important': important
      };
}
