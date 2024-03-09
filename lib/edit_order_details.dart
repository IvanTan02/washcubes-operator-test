// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'dart:typed_data';

import 'package:flutter/material.dart';
import './models/order.dart';
import './models/service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import './config.dart';
import 'package:file_picker/file_picker.dart';

class EditOrderDetails extends StatefulWidget {
  final Order? order;
  final String serviceName;

  const EditOrderDetails({
    super.key,
    required this.order,
    required this.serviceName,
  });

  @override
  State<EditOrderDetails> createState() => EditOrderDetailsState();
}

class EditOrderDetailsState extends State<EditOrderDetails> {
  Map<String, int> updatedOrderItems = {};
  Service? service;
  ServiceItem? selectedItem;
  List<OrderItem> orderItems = [];
  List<Uint8List> fileBytesList = [];
  List<String> fileNamesList = [];
  List<String> imagesUrl = [];

  @override
  void initState() {
    super.initState();
    getServiceDetails();
    orderItems = widget.order?.orderItems ?? [];
  }

  Future<void> getServiceDetails() async {
    try {
      final response = await http.get(
        Uri.parse('${url}services/${widget.order?.serviceId}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data.containsKey('service')) {
          final dynamic serviceData = data['service'];
          final Service fetchedService = Service.fromJson(serviceData);
          print(fetchedService);
          setState(() {
            service = fetchedService;
          });
        }
      }
    } catch (error) {
      print('Error getting service details: $error');
    }
  }

  Future<void> editOrderDetails() async {
    if (widget.order != null) {
      try {
        final Map<String, dynamic> data = {
          'orderId': widget.order?.id,
          'orderItems': orderItems.map((item) => item.toJson()).toList(),
          'proofPicUrl': jsonEncode(imagesUrl)
        };
        final response = await http.patch(
          Uri.parse('${url}orders/operator/edit-order-details'),
          body: json.encode(data),
          headers: {'Content-Type': 'application/json'},
        );
        if (response.statusCode == 200) {
          Navigator.pop(context);
          Navigator.pop(context);
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  'Order Details Updated',
                  textAlign: TextAlign.center,
                ),
                content: Text(
                  'The user has been notified of the order error.',
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
      } catch (error) {
        print('Error Edit order details: $error');
      }
    }
  }

  double updateEstimatedPrice() {
    double estimatedPrice = 0.0;
    if (selectedItem != null) {
      int quantity = updatedOrderItems[selectedItem?.id] ?? 0;
      estimatedPrice = (selectedItem?.price ?? 0) * quantity;
    }
    return estimatedPrice;
  }

  selectImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: true,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
    );
    if (result != null) {
      for (var pickedFile in result.files) {
        Uint8List? fileBytes = pickedFile.bytes;
        var fileName = pickedFile.name;
        if (fileBytes != null) {
          fileBytesList.add(fileBytes);
          setState(() {
            fileNamesList.add(fileName);
          });
        }
      }
    }
  }

  Future<void> uploadImage() async {
    for (int index = 0; index < fileBytesList.length; index++) {
      try {
        final url = Uri.parse('https://api.cloudinary.com/v1_1/ddweldfmx/upload');
        final request = http.MultipartRequest('POST', url)
          ..fields['upload_preset'] = 'xcbbr3ok'
          ..files.add(
            http.MultipartFile.fromBytes(
              'file',
              fileBytesList[index],
              filename: fileNamesList[index],
            ),
          );
        final response = await request.send();
        if (response.statusCode == 200) {
          final responseData = await response.stream.toBytes();
          final responseString = utf8.decode(responseData);
          final jsonMap = jsonDecode(responseString);
          final url = jsonMap['url'];
          imagesUrl.add(url);
        }
      } catch (error) {
        print('Error uploading image: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Cancel')),
                  ElevatedButton(
                      onPressed: () async {
                        await selectImage();
                      },
                      child: Text('Upload Proof')),
                  ElevatedButton(
                      onPressed: () async {
                        await uploadImage();
                        await editOrderDetails();
                      },
                      child: Text('Update Order')
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20.0),
          if (fileNamesList.isNotEmpty) 
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                Text(
                  'Selected Image Files:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: fileNamesList
                      .map(
                        (fileName) => Text(fileName),
                      )
                      .toList(),
                ),
                const Divider(),
              ],
            ),
          SizedBox(
            height: 300,
            width: 800,
            child: ListView.builder(
              itemCount: orderItems.length + 1,
              itemBuilder: (context, index) {
                if (index < orderItems.length) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(orderItems[index].name),
                      Text(
                          '${orderItems[index].price.toStringAsFixed(2)}/${orderItems[index].unit}'),
                      QuantitySelector(
                          initialQuantity: orderItems[index].quantity,
                          onChanged: (quantity) {
                            setState(() {
                              updatedOrderItems[orderItems[index].id] =
                                  quantity;
                            });
                          }),
                      Text(orderItems[index].cumPrice.toStringAsFixed(2)),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            orderItems.removeAt(index);
                          });
                        },
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          DropdownButton<ServiceItem>(
                            value: selectedItem,
                            onChanged: (ServiceItem? newValue) {
                              setState(() {
                                selectedItem = newValue;
                              });
                            },
                            hint: Text('Select Items'),
                            items: service?.items
                                .map<DropdownMenuItem<ServiceItem>>(
                                    (ServiceItem item) {
                              return DropdownMenuItem<ServiceItem>(
                                value: item,
                                child: Text(item.name),
                              );
                            }).toList(),
                          ),
                          selectedItem != null
                              ? Text(
                                  'RM${selectedItem?.price.toStringAsFixed(2)}/${selectedItem?.unit}')
                              : Text('RM0.00/unit'),
                          QuantitySelector(
                              initialQuantity: 0,
                              onChanged: (quantity) {
                                setState(() {
                                  if (selectedItem != null) {
                                    updatedOrderItems[
                                        selectedItem?.id ?? 'N/A'] = quantity;
                                  }
                                });
                              }),
                          Text(
                              'RM${updateEstimatedPrice().toStringAsFixed(2)}'),
                          ElevatedButton(
                            onPressed: () {
                              if (selectedItem == null ||
                                  selectedItem?.id == null) {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text(
                                        'No Items Selected.',
                                        // style:
                                        //     CTextTheme.blackTextTheme.headlineLarge,
                                      ),
                                      content: Text(
                                        'Please select some items to proceed.',
                                        // style:
                                        //     CTextTheme.blackTextTheme.headlineMedium,
                                      ),
                                      actions: <Widget>[
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text(
                                            'OK',
                                            // style: CTextTheme
                                            //     .blackTextTheme.headlineMedium,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                                return;
                              }
                              int quantity =
                                  updatedOrderItems[selectedItem?.id] ?? 0;
                              if (quantity > 0) {
                                OrderItem newItem = OrderItem(
                                  id: selectedItem?.id ?? 'N/A',
                                  name: selectedItem?.name ?? 'N/A',
                                  unit: selectedItem?.unit ?? 'N/A',
                                  price: selectedItem?.price ?? 0,
                                  quantity: quantity,
                                  cumPrice:
                                      updateEstimatedPrice(), // Ensure cumPrice is not null
                                );
                                setState(() {
                                  orderItems.add(newItem);
                                  selectedItem = null;
                                });
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text(
                                        'Zero Quantity Selected.',
                                        // style:
                                        //     CTextTheme.blackTextTheme.headlineLarge,
                                      ),
                                      content: Text(
                                        'Please select a non-zero quantity.',
                                        // style:
                                        //     CTextTheme.blackTextTheme.headlineMedium,
                                      ),
                                      actions: <Widget>[
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text(
                                            'OK',
                                            // style: CTextTheme
                                            //     .blackTextTheme.headlineMedium,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            },
                            child: Text("Add Item"),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                orderItems.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  );
                }
              },
            ),
          ),
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

class QuantitySelector extends StatefulWidget {
  final int initialQuantity;
  final Function(int) onChanged;

  const QuantitySelector(
      {super.key, required this.initialQuantity, required this.onChanged});

  @override
  QuantitySelectorState createState() => QuantitySelectorState();
}

class QuantitySelectorState extends State<QuantitySelector> {
  int quantity = 0;

  @override
  void initState() {
    super.initState();
    quantity = widget.initialQuantity;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: () {
            if (quantity > 0) {
              setState(() {
                quantity--;
                widget.onChanged(quantity);
              });
            }
          },
        ),
        Text(
          '$quantity',
          //style: CTextTheme.blackTextTheme.headlineSmall,
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            setState(() {
              quantity++;
              widget.onChanged(quantity);
            });
          },
        ),
      ],
    );
  }
}
