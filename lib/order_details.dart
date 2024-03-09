// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:washcubes_operator_test/confirm_return.dart';
import 'package:washcubes_operator_test/error.dart';
import './models/order.dart';
import './approve_order_details.dart';
import './confirm_processing_completion.dart';
import './ready_order_details.dart';

class OrderDetails extends StatefulWidget {
  final Order? order;
  final String serviceName;

  const OrderDetails({
    super.key,
    required this.order,
    required this.serviceName,
  });

  @override
  State<OrderDetails> createState() => OrderDetailsState();
}

class OrderDetailsState extends State<OrderDetails> {
  @override
  Widget build(BuildContext context) {
    final inProgressStatus = widget.order?.orderStage?.getInProgressStatus();

    switch (inProgressStatus) {
      case 'Pending Verification':
        return ApproveOrderDetails(
          order: widget.order,
          serviceName: widget.serviceName,
        );
      case 'Processing':
        return ProcessingComplete(
          order: widget.order,
          serviceName: widget.serviceName,
        );
      case 'Ready':
        return ReadyOrderDetails(
          order: widget.order,
          serviceName: widget.serviceName,
        );
      case 'Order Error':
        return OrderError(
          order: widget.order,
          serviceName: widget.serviceName,
        );
      case 'Pending Return Approval':
        return ReturnConfirmation(
          order: widget.order,
          serviceName: widget.serviceName,
        );
      default:
        return CircularProgressIndicator();
    }
  }
}
