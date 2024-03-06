import 'package:flutter/material.dart';
import './models/order.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import './config.dart';
import './order_details.dart';
import './models/service.dart';

class OperatorPage extends StatefulWidget {
  const OperatorPage({super.key});

  @override
  State<OperatorPage> createState() => OperatorPageState();
}

class OperatorPageState extends State<OperatorPage> {
  List<Order> orders = [];

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      final response = await http.get(
        Uri.parse('${url}orders/operator'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        //print(response.body)
        final Map<String, dynamic> data = json.decode(response.body);
        //print(data);
        if (data.containsKey('orders')) {
          final List<dynamic> orderData = data['orders'];
          final List<Order> fetchedOrders =
              orderData.map((order) => Order.fromJson(order)).toList();
          //print(fetchedOrders);
          setState(() {
            orders = fetchedOrders;
          });
        } else {
          print('Response data does not contain services.');
        }
      } else {
        print('Error: ${response.statusCode}');
        print('Error message: ${response.body}');
      }
    } catch (error) {
      print('Error Fetching Orders: $error');
    }
  }

  Future<String> getServiceName(String serviceId) async {
    String serviceName = 'Loading...';
    try {
      final response = await http.get(Uri.parse('${url}services/$serviceId'),
          headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print(data);
        if (data.containsKey('service')) {
          final dynamic serviceData = data['service'];
          final Service service = Service.fromJson(serviceData);
          serviceName = service.name;
        }
      }
    } catch (error) {
      print('Error Fetching Service Name: $error');
    }
    return serviceName;
  }

  void viewOrder(Order order, String serviceName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return OrderDetails(
          order: order,
          serviceName: serviceName,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Orders'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'OPERATORRR',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Table(
                border: TableBorder.all(),
                columnWidths: const {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(1),
                },
                children: [
                  const TableRow(
                    children: [
                      TableCell(child: Center(child: Text('Order ID'))),
                      TableCell(child: Center(child: Text('Date / Time'))),
                      TableCell(child: Center(child: Text('Barcode ID'))),
                      TableCell(
                          child: Center(child: Text('User Phone Number'))),
                      TableCell(child: Center(child: Text('Service'))),
                      TableCell(child: Center(child: Text('Status'))),
                      TableCell(child: Center(child: Text('ACTION'))),
                    ],
                  ),
                  for (Order order in orders)
                    TableRow(
                      children: [
                        TableCell(
                            child: Center(child: Text(order.orderNumber))),
                        TableCell(
                            child: Center(
                                child: Text(order
                                    .getFormattedDateTime(order.createdAt)))),
                        TableCell(child: Center(child: Text(order.barcodeID))),
                        TableCell(
                            child: Center(
                                child: Text(
                                    order.user?.phoneNumber.toString() ?? ''))),
                        TableCell(
                            child: Center(
                          child: FutureBuilder<String>(
                            future: getServiceName(order.serviceId),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Text('Loading...');
                              } else if (snapshot.hasError) {
                                return const Text('Error');
                              } else {
                                return Text(snapshot.data ??
                                    'Service Name Not Available');
                              }
                            },
                          ),
                        )),
                        TableCell(
                            child: Center(
                                child: Text(order.orderStage?.processingComplete
                                            .status ==
                                        true
                                    ? 'Ready'
                                    : order.orderStage?.getInProgressStatus() ??
                                        'Loading...'))),
                        TableCell(
                            child: Center(
                                child: ElevatedButton(
                          onPressed: () async {
                            String serviceName =
                                await getServiceName(order.serviceId);
                            viewOrder(order, serviceName);
                          },
                          child: const Text('Check'),
                        ))),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
