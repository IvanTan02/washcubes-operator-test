// ignore_for_file: use_build_context_synchronously, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import './models/order.dart';

class ReadyOrderDetails extends StatefulWidget {
  final Order? order;
  final String serviceName;

  const ReadyOrderDetails({
    super.key,
    required this.order,
    required this.serviceName,
  });

  @override
  ReadyOrderDetailsState createState() => ReadyOrderDetailsState();
}

class ReadyOrderDetailsState extends State<ReadyOrderDetails> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final orderItems = widget.order?.orderItems;

    return AlertDialog(
      title: Column(
        children: [
          const SizedBox(height: 15.0),
          Text(
            'Order Number: ${widget.order?.orderNumber ?? 'Loading...'}',
            textAlign: TextAlign.center,
            //style: CTextTheme.blackTextTheme.headlineLarge,
          ),
          const SizedBox(height: 20.0),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'Order Received: ${widget.order?.orderStage?.inProgress.dateUpdated ?? 'Loading...'}'),
                  Text('Operator ID:'),
                  Text(
                      'Barcode ID: ${widget.order?.barcodeID ?? 'Loading...'}'),
                ],
              ),
              const SizedBox(width: 100.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'User: ${widget.order?.user?.phoneNumber.toString() ?? 'Loading...'}'),
                  Text('Service ID: ${widget.serviceName}'),
                  Text('Processing Status: COMPLETED'),
                ],
              ),
            ],
          ),
          const Divider(),
        ],
      ),
      content: Column(
        children: [
          const SizedBox(height: 20.0),
          const Text('Verification'),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Column(
                children: [
                  Text('Service Type: ${widget.serviceName}'),
                  Text(
                      'Final Price: RM${widget.order?.finalPrice?.toStringAsFixed(2)}'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20.0),
          orderItems != null
              ? Container(
                  height: 300,
                  width: 800,
                  child: ListView.builder(
                    itemCount: orderItems.length,
                    itemBuilder: (context, index) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(orderItems[index].name),
                          Text(
                              '${orderItems[index].price}/${orderItems[index].unit}'),
                          Text(orderItems[index].quantity.toString()),
                          Text(orderItems[index].cumPrice.toStringAsFixed(2)),
                        ],
                      );
                    },
                  ),
                )
              : Text('Loading...')
        ],
      ),
      actions: <Widget>[
        Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.blue[100]!)),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Back',
                      //style: CTextTheme.blackTextTheme.headlineSmall,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10.0),
          ],
        ),
      ],
    );
  }
}
