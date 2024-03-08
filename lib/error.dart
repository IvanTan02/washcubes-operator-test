// ignore_for_file: use_build_context_synchronously, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:washcubes_operator_test/models/order.dart';

class OrderError extends StatefulWidget {
  final Order? order;
  final String serviceName;

  const OrderError({
    super.key,
    required this.order,
    required this.serviceName,
  });

  @override
  OrderErrorState createState() => OrderErrorState();
}

class OrderErrorState extends State<OrderError> {
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
                  Text('Processing Status: ${widget.order?.orderStage?.getInProgressStatus()}'),
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
                  Text('Status: Pending for Customer Top Up')
                ],
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Colors.blue[100]!)),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return ImageDisplayDialog(
                        imageUrls: widget.order?.orderStage?.orderError.proofPicUrl,
                      );
                    },
                  );
                },
                child: Text(
                  'Proof',
                  //style: CTextTheme.blackTextTheme.headlineSmall,
                ),
              )
            ],),
          const SizedBox(height: 20.0),
          orderItems != null
              ? SizedBox(
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

class ImageDisplayDialog extends StatefulWidget {
  final List<String>? imageUrls;

  const ImageDisplayDialog({Key? key, this.imageUrls}) : super(key: key);

  @override
  _ImageDisplayDialogState createState() => _ImageDisplayDialogState();
}

class _ImageDisplayDialogState extends State<ImageDisplayDialog> {
  int currentIndex = 0;

  void nextImage() {
    setState(() {
      if (currentIndex < (widget.imageUrls?.length ?? 0) - 1) {
        currentIndex++;
      }
    });
  }

  void previousImage() {
    setState(() {
      if (currentIndex > 0) {
        currentIndex--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Proof Image ${currentIndex + 1} of ${widget.imageUrls?.length}',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.0),
            if (widget.imageUrls != null && widget.imageUrls!.isNotEmpty)
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 650,
                    width: 500,
                    child: Image.network(
                      widget.imageUrls![currentIndex],
                      fit: BoxFit.cover,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: previousImage,
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_forward),
                        onPressed: nextImage,
                      ),
                    ],
                  ),
                ],
              ),
            SizedBox(height: 10.0),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.blue[100]!)),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}