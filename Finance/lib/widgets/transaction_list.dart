import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import './chart.dart';
import './transaction_item.dart';
import '../models/transaction.dart';

class TransactionList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: ValueListenableBuilder(
        valueListenable: Hive.box('expense').listenable(),
        builder: (ctx, box, _) {
          List<Transaction> trans = [];
          for (var i = 0; i < box.length; i++) {
            var temp = box.getAt(i) as Transaction;
            trans.add(temp);
          }
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/one.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: (box.length == 0)
                  ? Center(child: Text("No transactions added!", style: TextStyle(fontSize: 20)))
                  : Column(
                      children: [
                        Expanded(child: Chart(trans)),
                        Container(
                          height: height * 0.65,
                          child: ListView.builder(
                            itemCount: box.length,
                            itemBuilder: (context, index) {
                              final transaction = box.getAt(index) as Transaction;
                              return TransactionItem(
                                transaction: transaction,
                                deleteTx: () => box.deleteAt(index),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }
}
