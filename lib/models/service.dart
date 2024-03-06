//SERVICE
class Service {
  final String id;
  final String name;
  final List<ServiceItem> items;
  final int v;

  Service({
    required this.id,
    required this.name,
    required this.items,
    required this.v,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return (Service(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      items: (json['items'] as List<dynamic>)
          .map((item) => ServiceItem.fromJson(item))
          .toList(),
      v: json['__v'] ?? 0,
    ));
  }
}

class ServiceItem {
  final String id;
  final String name;
  final String unit;
  final double price;

  ServiceItem({
    required this.id,
    required this.name,
    required this.unit,
    required this.price,
  });

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    return (ServiceItem(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      unit: json['unit'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    ));
  }
}
