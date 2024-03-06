// ignore_for_file: use_build_context_synchronously, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import './models/order.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './config.dart';

class ProcessingComplete extends StatefulWidget {
  final Order? order;
  final String serviceName;

  const ProcessingComplete({
    super.key,
    required this.order,
    required this.serviceName,
  });

  @override
  ProcessingCompleteState createState() => ProcessingCompleteState();
}

class ProcessingCompleteState extends State<ProcessingComplete> {
  List<bool> itemChecklist = [];

  @override
  void initState() {
    super.initState();
    itemChecklist = List.generate(
      widget.order?.orderItems.length ?? 0,
      (index) => false,
    );
  }

  Future<void> confirmProcessingComplete() async {
    try {
      print('YO');
      final Map<String, dynamic> data = {'orderId': widget.order?.id};
      final response = await http.post(
        Uri.parse('${url}orders/operator/confirm-processing-complete'),
        body: json.encode(data),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        Navigator.pop(context);
        print('YO2');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'Processing Complete',
                textAlign: TextAlign.center,
              ),
              content: Text(
                'The order status for Order ${widget.order?.orderNumber} has been set to Processing Complete.',
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

  @override
  Widget build(BuildContext context) {
    final orderItems = widget.order?.orderItems;
    final allItemsChecked = itemChecklist.every((item) => item);

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
                      'Final Price: RM${widget.order?.finalPrice?.toStringAsFixed(2)}'),
                ],
              ),
              const SizedBox(width: 100.0),
              Row(
                children: [
                  ElevatedButton(
                      onPressed: () async {
                        if (allItemsChecked) {
                          await confirmProcessingComplete();
                        } else {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(
                                  'Some Order Items are Unchecked',
                                  textAlign: TextAlign.center,
                                ),
                                content: Text(
                                  'Please ensure that all order items are in the right quantity.',
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
                                            'OK',
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
                      return CheckboxListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(orderItems[index].name),
                            Text(
                                '${orderItems[index].price}/${orderItems[index].unit}'),
                            Text(orderItems[index].quantity.toString()),
                            Text(orderItems[index].cumPrice.toStringAsFixed(2)),
                          ],
                        ),
                        value: itemChecklist[index],
                        onChanged: (checked) {
                          setState(() {
                            itemChecklist[index] = checked ?? false;
                          });
                        },
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
