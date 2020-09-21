import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import './chart.dart';
import './transaction_item.dart';
import '../models/transaction.dart';

class TransactionList extends StatefulWidget {
  @override
  _TransactionListState createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  bool _showChart = false;

  List<Widget> _getLandscape(Box box, List<Transaction> trans) {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Show Chart', style: Theme.of(context).textTheme.headline6),
          Switch.adaptive(
            activeColor: Theme.of(context).accentColor,
            value: _showChart,
            onChanged: (val) {
              setState(() {
                _showChart = val;
              });
            },
          )
        ],
      ),
      Expanded(
        child: _showChart
            ? Chart(trans)
            : Container(
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
      ),
    ];
  }

  List<Widget> _getPortrait(Box box, List<Transaction> trans) {
    return [
      Expanded(flex: 3, child: Chart(trans)),
      Expanded(
        flex: 7,
        child: Container(
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
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return SafeArea(
      child: ValueListenableBuilder(
        valueListenable: Hive.box('expense').listenable(),
        builder: (ctx, box, _) {
          List<Transaction> trans = [];
          for (var i = 0; i < box.length; i++) {
            var temp = box.getAt(i) as Transaction;
            if (temp.date.isAfter(DateTime.now().subtract(Duration(days: 7)))) trans.add(temp);
          }
          return Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
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
                  : Column(children: (isLandscape) ? _getLandscape(box, trans) : _getPortrait(box, trans)),
            ),
          );
        },
      ),
    );
  }
}

// Expanded(child: Chart(trans)),
// Container(
// height: height * 0.65,
// child: ListView.builder(
// itemCount: box.length,
// itemBuilder: (context, index) {
// final transaction = box.getAt(index) as Transaction;
// return TransactionItem(
// transaction: transaction,
// deleteTx: () => box.deleteAt(index),
// );
// },
// ),
// ),
//
// : [
// Row(
// mainAxisAlignment: MainAxisAlignment.center,
// children: <Widget>[
// Text(
// 'Show Chart',
// style: Theme.of(context).textTheme.headline6,
// ),
// Switch.adaptive(
// activeColor: Theme.of(context).accentColor,
// value: _showChart,
// onChanged: (val) {
// setState(() {
// _showChart = val;
// });
// },
// )
// ],
// ),
// (_showChart)?Expanded(child: Chart(trans))?
// Container(
// height: height * 0.65,
// child: ListView.builder(
// itemCount: box.length,
// itemBuilder: (context, index) {
// final transaction = box.getAt(index) as Transaction;
// return TransactionItem(
// transaction: transaction,
// deleteTx: () => box.deleteAt(index),
// );
// },
// ),
// ),
// ],
