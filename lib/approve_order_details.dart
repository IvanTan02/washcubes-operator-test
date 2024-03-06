// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import './models/order.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import './config.dart';

class ApproveOrderDetails extends StatefulWidget {
  final Order? order;
  final String serviceName;

  const ApproveOrderDetails({
    super.key,
    required this.order,
    required this.serviceName,
  });

  @override
  State<ApproveOrderDetails> createState() => ApproveOrderDetailsState();
}

class ApproveOrderDetailsState extends State<ApproveOrderDetails> {
  Future<void> approveOrderDetails() async {
    if (widget.order != null) {
      try {
        final Map<String, dynamic> data = {'orderId': widget.order?.id};
        final response = await http.post(
          Uri.parse('${url}orders/operator/approve-order-details'),
          body: json.encode(data),
          headers: {'Content-Type': 'application/json'},
        );
        if (response.statusCode == 200) {
          Navigator.pop(context);
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  'Verification Complete',
                  textAlign: TextAlign.center,
                ),
                content: Text(
                  'The order items for Order ${widget.order?.orderNumber} has been verified.',
                  textAlign: TextAlign.center,
                  // style: CTextTheme.blackTextTheme.headlineSmall,
                ),
                actions: <Widget>[
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Nice!',
                            //style: CTextTheme.blackTextTheme.headlineSmall,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        }
      } catch (error) {
        print('Error approve order details: $error');
      }
    }
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
                  Text(
                      'Processing Status: ${widget.order?.orderStage?.getInProgressStatus() ?? 'Loading...'}'),
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
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Receiving Details'),
                  Text('Date / Time:'),
                ],
              ),
              const SizedBox(width: 100.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Rider ID:'),
                  Text('Received By:'),
                ],
              ),
            ],
          ),
          const Divider(),
          const Text('Verification'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text('Service Type: ${widget.serviceName}'),
                  Text(
                      'Payment Price: RM${widget.order?.estimatedPrice.toStringAsFixed(2)}'),
                ],
              ),
              const SizedBox(width: 100.0),
              Row(
                children: [
                  ElevatedButton(onPressed: () {}, child: Text('Edit')),
                  ElevatedButton(
                      onPressed: () async {
                        await approveOrderDetails();
                      },
                      child: Text('Approve')),
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
