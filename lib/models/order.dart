import 'user.dart';
import 'package:intl/intl.dart';

// DEFINE ORDER CLASS
class Order {
  final String id;
  final String orderNumber;
  final User? user;
  final OrderLockerDetails? lockerDetails;
  final CollectionLockerDetails? collectionSite;
  final String serviceId;
  final List<OrderItem> orderItems;
  final double estimatedPrice;
  final double? finalPrice;
  final OrderStage? orderStage;
  final String createdAt;
  final bool selectedByRider;
  final String barcodeID;
  final int v;

  Order({
    required this.id,
    required this.orderNumber,
    required this.user,
    required this.lockerDetails,
    required this.collectionSite,
    required this.serviceId,
    required this.orderItems,
    required this.estimatedPrice,
    required this.finalPrice,
    required this.orderStage,
    required this.createdAt,
    required this.selectedByRider,
    required this.barcodeID,
    required this.v,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return (Order(
      id: json['_id'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      lockerDetails: json['locker'] != null
          ? OrderLockerDetails.fromJson(json['locker'])
          : null,
      collectionSite: json['collectionSite'] != null
          ? CollectionLockerDetails.fromJson(json['collectionSite'])
          : null,
      serviceId: json['service'] ?? '',
      orderItems: (json['orderItems'] as List<dynamic>)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      estimatedPrice: json['estimatedPrice'].toDouble() ?? 0.0,
      finalPrice: json['finalPrice']?.toDouble() ?? 0.0,
      orderStage: json['orderStage'] != null
          ? OrderStage.fromJson(json['orderStage'])
          : null, //
      createdAt: json['createdAt'] ?? '',
      selectedByRider: json['selectedByRider'],
      barcodeID: json['barcodeID'] ?? '',
      v: json['__v'] ?? 0,
    ));
  }

  String getFormattedDateTime(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    final timeZoneOffset = Duration(hours: 8);
    dateTime = dateTime.add(timeZoneOffset);
    String formattedDate = DateFormat.yMMMd().format(dateTime);
    String formattedTime = DateFormat.jm().format(dateTime);
    return '${formattedDate} / ${formattedTime}';
  }
}

class OrderLockerDetails {
  final String lockerSiteId;
  final String compartmentId;
  final String compartmentNumber;

  OrderLockerDetails({
    required this.lockerSiteId,
    required this.compartmentId,
    required this.compartmentNumber,
  });

  factory OrderLockerDetails.fromJson(Map<String, dynamic> json) {
    return (OrderLockerDetails(
      lockerSiteId: json['lockerSiteId'] ?? '',
      compartmentId: json['compartmentId'] ?? '',
      compartmentNumber: json['compartmentNumber'] ?? '',
    ));
  }
}

class CollectionLockerDetails {
  final String lockerSiteId;
  final String compartmentId;
  final String compartmentNumber;

  CollectionLockerDetails(
      {required this.lockerSiteId,
      required this.compartmentId,
      required this.compartmentNumber});

  factory CollectionLockerDetails.fromJson(Map<String, dynamic> json) {
    return (CollectionLockerDetails(
        lockerSiteId: json['lockerSiteId'] ?? '',
        compartmentId: json['compartmentId'] ?? '',
        compartmentNumber: json['compartmentNumber'] ?? ''));
  }
}

class OrderItem {
  final String id;
  final String name;
  final String unit;
  final double price;
  late final int quantity;
  final double cumPrice;

  OrderItem(
      {required this.id,
      required this.name,
      required this.unit,
      required this.price,
      required this.quantity,
      required this.cumPrice});

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return (OrderItem(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      unit: json['unit'] ?? '',
      price: json['price'].toDouble() ?? 0.0,
      quantity: json['quantity'] ?? 0,
      cumPrice: json['cumPrice'].toDouble() ?? 0.0,
    ));
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'unit': unit,
      'price': price,
      'quantity': quantity,
      'cumPrice': cumPrice,
    };
  }
}

class OrderStage {
  OrderStatus dropOff;
  OrderStatus collectedByRider;
  OrderInProgressStatus inProgress;
  OrderStatus processingComplete;
  OrderStatus outForDelivery;
  OrderStatus readyForCollection;
  OrderStatus completed;
  OrderErrorStatus orderError;

  OrderStage({
    required this.dropOff,
    required this.collectedByRider,
    required this.inProgress,
    required this.processingComplete,
    required this.outForDelivery,
    required this.readyForCollection,
    required this.completed,
    required this.orderError,
  });

  factory OrderStage.fromJson(Map<String, dynamic> json) {
    return OrderStage(
      dropOff: OrderStatus.fromJson(json['dropOff']),
      collectedByRider: OrderStatus.fromJson(json['collectedByRider']),
      inProgress: OrderInProgressStatus.fromJson(json['inProgress']),
      processingComplete: OrderStatus.fromJson(json['processingComplete']),
      outForDelivery: OrderStatus.fromJson(json['outForDelivery']),
      readyForCollection: OrderStatus.fromJson(json['readyForCollection']),
      completed: OrderStatus.fromJson(json['completed']),
      orderError: OrderErrorStatus.fromJson(json['orderError']),
    );
  }

  // Map<String, dynamic> toJson() {
  //   return {
  //     'dropOff': dropOff.toJson(),
  //     'collectedByRider': collectedByRider.toJson(),
  //     'inProgress': inProgress.toJson(),
  //     'processingComplete': processingComplete.toJson(),
  //     'outForDelivery': outForDelivery.toJson(),
  //     'readyForCollection': readyForCollection.toJson(),
  //     'completed': completed.toJson(),
  //     'orderError': orderError.toJson(),
  //   };
  // }

  OrderStatus operator [](String key) {
    switch (key) {
      case 'dropOff':
        return dropOff;
      case 'collectedByRider':
        return collectedByRider;
      // case 'inProgress':
      //   return inProgress;
      case 'processingComplete':
        return processingComplete;
      case 'outForDelivery':
        return outForDelivery;
      case 'readyForCollection':
        return readyForCollection;
      case 'completed':
        return completed;
      // case 'orderError':
      //   return orderError;

      default:
        throw ArgumentError('Invalid status key: $key');
    }
  }

  String getMostRecentStatus() {
    if (completed.status) {
      return 'Completed';
    }
    if (readyForCollection.status) {
      return 'Ready for Collection';
    }
    if (outForDelivery.status) {
      return 'Out for Delivery';
    }
    if (processingComplete.status) {
      return 'Processing Complete';
    }
    if (inProgress.status) {
      return 'In Progress';
    }
    if (collectedByRider.status) {
      return 'Collected by Rider';
    }
    if (dropOff.status) {
      return 'Drop Off';
    }
    return 'Drop Off Pending';
  }

  DateTime? getMostRecentDateUpdated() {
    List<DateTime?> dateUpdatedList = [
      dropOff.dateUpdated,
      collectedByRider.dateUpdated,
      inProgress.dateUpdated,
      processingComplete.dateUpdated,
      outForDelivery.dateUpdated,
      readyForCollection.dateUpdated,
      completed.dateUpdated,
      orderError.dateUpdated,
    ];

    dateUpdatedList.removeWhere((date) => date == null);

    if (dateUpdatedList.isEmpty) {
      return null;
    }

    return dateUpdatedList
        .reduce((maxDate, date) => date!.isAfter(maxDate!) ? date : maxDate);
  }

  String getInProgressStatus() {
    if (processingComplete.status) {
      return 'Ready';
    }
    if (orderError.status && orderError.userRejected) {
      return 'Pending Return Approval';
    }
    if (orderError.status) {
      return 'Order Error';
    }
    if (!inProgress.verified.status) {
      return 'Pending Verification';
    }
    if (inProgress.verified.status && inProgress.processing.status) {
      return 'Processing';
    }
    return 'Unusual Status';
  }
}

class OrderStatus {
  bool status;
  DateTime? dateUpdated;

  OrderStatus({
    required this.status,
    this.dateUpdated,
  });

  factory OrderStatus.fromJson(Map<String, dynamic> json) {
    return OrderStatus(
      status: json['status'] ?? false,
      dateUpdated: json['dateUpdated'] != null
          ? DateTime.parse(json['dateUpdated'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'dateUpdated': dateUpdated?.toIso8601String(),
    };
  }
}

class OrderInProgressStatus {
  bool status;
  DateTime? dateUpdated;
  OrderStatus verified;
  OrderStatus processing;

  OrderInProgressStatus({
    required this.status,
    this.dateUpdated,
    required this.verified,
    required this.processing,
  });

  factory OrderInProgressStatus.fromJson(Map<String, dynamic> json) {
    return OrderInProgressStatus(
        status: json['status'] ?? false,
        dateUpdated: json['dateUpdated'] != null
            ? DateTime.parse(json['dateUpdated'])
            : null,
        verified: OrderStatus.fromJson(json['verified'] ?? {}),
        processing: OrderStatus.fromJson(json['processing'] ?? {}));
  }
}

class OrderErrorStatus {
  bool status;
  DateTime? dateUpdated;
  List<String> proofPicUrl;
  bool userRejected;

  OrderErrorStatus({
    required this.status,
    this.dateUpdated,
    required this.proofPicUrl,
    required this.userRejected,
  });

  factory OrderErrorStatus.fromJson(Map<String, dynamic> json) {
    return OrderErrorStatus(
        status: json['status'] ?? false,
        dateUpdated: json['dateUpdated'] != null
            ? DateTime.parse(json['dateUpdated'])
            : null,
        proofPicUrl: List<String>.from(json['proofPicUrl'] ?? []),
        userRejected: json['userRejected'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'dateUpdated': dateUpdated?.toIso8601String(),
      'proofPicUrls': proofPicUrl,
      'userejected': userRejected,
    };
  }
}
