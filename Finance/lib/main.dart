import 'dart:io';
import 'dart:ui';

import 'package:finance_app/widgets/transaction_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

import './models/transaction.dart';
import './widgets/new_transaction.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocDirectory =
      await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocDirectory.path);
  Hive.registerAdapter(TransactionAdapter());
  return runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void dispose() {
    Hive.box('contacts').compact();
    Hive.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Track Expense',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        errorColor: Colors.red,
        fontFamily: 'Quicksand',
        textTheme: ThemeData.light().textTheme.copyWith(
              headline6: TextStyle(
                  fontFamily: 'OpenSans',
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
              button: TextStyle(color: Colors.white),
            ),
        appBarTheme: AppBarTheme(
          textTheme: ThemeData.light().textTheme.copyWith(
                headline6: TextStyle(fontFamily: 'OpenSans', fontSize: 20),
              ),
        ),
      ),
      home: FutureBuilder(
        future: Hive.openBox(
          'expense',
          compactionStrategy: (_, deleted) {
            return deleted > 20;
          },
        ),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError)
              return Text(snapshot.error.toString());
            else
              return MyHomePage();
          } else
            return Scaffold();
        },
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  /*
  to update use:
  boxVariable.putAt(index, Transaction(..., ..., ..., ...));
  */

  // save inserted details to hive box [expense]
  void _addNewTransaction(
      String txTitle, double txAmount, DateTime chosenDate) {
    final newTx = Transaction(
      title: txTitle,
      amount: txAmount,
      date: chosenDate,
      id: DateTime.now().toString(),
    );

    final expenseBox = Hive.box('expense');
    expenseBox.add(newTx);
  }

  // add new area to fill expense details
  void _startAddNewTransaction(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (_) => NewTransaction(_addNewTransaction),
    );
  }

  // list view to see all the expenses
  Widget _buildListView(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('expense').listenable(),
      builder: (ctx, box, _) {
        return (box.length == 0)
            ? Container(
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
                  child: Center(child: Text("No transactions added!")),
                ),
              )
            : ListView.builder(
                itemCount: box.length,
                itemBuilder: (context, index) {
                  final transaction = box.getAt(index) as Transaction;
                  return TransactionItem(
                      transaction: transaction,
                      deleteTx: () => box.deleteAt(index));
                },
              );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final PreferredSizeWidget appBar = Platform.isIOS
        ? CupertinoNavigationBar(
            middle: Text('Expense Tracker'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                GestureDetector(
                  child: Icon(CupertinoIcons.add),
                  onTap: () => _startAddNewTransaction(context),
                ),
              ],
            ),
          )
        : AppBar(
            title: Text('Expense Tracker'),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () => _startAddNewTransaction(context),
              )
            ],
          );
    return Platform.isIOS
        ? CupertinoPageScaffold(
            navigationBar: appBar,
            child: _buildListView(context),
          )
        : Scaffold(
            appBar: appBar,
            body: _buildListView(context),
            floatingActionButton: FloatingActionButton.extended(
              icon: Icon(Icons.add),
              label: Text("Create"),
              onPressed: () => _startAddNewTransaction(context),
            ),
          );
  }
}

//
// // bool _showChart = false;
//
// // List<Transaction> get _recentTransactions {
// //   return _userTransactions
// //       .where(
// //         (tx) => tx.date.isAfter(DateTime.now().subtract(Duration(days: 7))),
// //       )
// //       .toList();
// // }
//
// // adding new transactions
// void _addNewTransaction(String txTitle, double txAmount, DateTime chosenDate) {
//   final newTx = Transaction(
//     title: txTitle,
//     amount: txAmount,
//     date: chosenDate,
//     id: DateTime.now().toString(),
//   );
//
//   final expenseBox = Hive.box('expense');
//   expenseBox.add(newTx);
// }
//
// // delete transaction
// void _deleteTransaction(String id) {
//   print("deleting");
// }
//
// void _startAddNewTransaction(BuildContext ctx) {
//   showModalBottomSheet(
//     context: ctx,
//     builder: (_) {
//       return NewTransaction(_addNewTransaction);
//     },
//   );
// }
//
// // List<Widget> _buildLandscapeContent(MediaQueryData mediaQuery, AppBar appBar, Widget txListWidget) {
// //   return [
// //     Row(
// //       mainAxisAlignment: MainAxisAlignment.center,
// //       children: <Widget>[
// //         Text(
// //           'Show Chart',
// //           style: Theme.of(context).textTheme.headline6,
// //         ),
// //         Switch.adaptive(
// //           activeColor: Theme.of(context).accentColor,
// //           value: _showChart,
// //           onChanged: (val) {
// //             setState(() {
// //               _showChart = val;
// //             });
// //           },
// //         )
// //       ],
// //     ),
// //     _showChart
// //         ? Container(
// //             height: (mediaQuery.size.height - appBar.preferredSize.height - mediaQuery.padding.top) * 0.86,
// //             child: Chart(_recentTransactions),
// //           )
// //         : txListWidget,
// //   ];
// // }
// //
// // List<Widget> _buildPortraitContent(
// //   MediaQueryData mediaQuery,
// //   AppBar appBar,
// //   Widget txListWidget,
// // ) {
// //   return [
// //     Container(
// //       height: (mediaQuery.size.height - appBar.preferredSize.height - mediaQuery.padding.top) * 0.32,
// //       child: Chart(_recentTransactions),
// //     ),
// //     txListWidget
// //   ];
// // }
//
// @override
// Widget build(BuildContext context) {
//   final mediaQuery = MediaQuery.of(context);
//   final isLandscape = mediaQuery.orientation == Orientation.landscape;
//   final PreferredSizeWidget appBar = Platform.isIOS
//       ? CupertinoNavigationBar(
//     middle: Text('Expense Tracker'),
//     trailing: Row(
//       mainAxisSize: MainAxisSize.min,
//       children: <Widget>[
//         GestureDetector(
//           child: Icon(CupertinoIcons.add),
//           onTap: () => _startAddNewTransaction(context),
//         ),
//       ],
//     ),
//   )
//       : AppBar(
//     title: Text('Expense Tracker'),
//     actions: <Widget>[
//       IconButton(
//         icon: Icon(Icons.add),
//         onPressed: () => _startAddNewTransaction(context),
//       )
//     ],
//   );
//   final txListWidget = Container(
//     height: (mediaQuery.size.height - appBar.preferredSize.height - mediaQuery.padding.top) *
//         ((isLandscape) ? 0.86 : 0.68),
//     child: TransactionList(
//       _userTransactions,
//       _deleteTransaction,
//     ),
//   );
//   final pageBody = SafeArea(
//     child: SingleChildScrollView(
//       child: Column(
//         // mainAxisAlignment: MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: (isLandscape)
//             ? _buildLandscapeContent(mediaQuery, appBar, txListWidget)
//             : _buildPortraitContent(mediaQuery, appBar, txListWidget),
//       ),
//     ),
//   );
//   return Platform.isIOS
//       ? CupertinoPageScaffold(
//     child: pageBody,
//     navigationBar: appBar,
//   )
//       : Scaffold(
//     appBar: appBar,
//     body: pageBody,
//     // floatingActionButtonLocation:
//     //     FloatingActionButtonLocation.centerFloat,
//     floatingActionButton: Platform.isIOS
//         ? Container()
//         : FloatingActionButton.extended(
//       icon: Icon(Icons.add),
//       label: Text("Create"),
//       onPressed: () => _startAddNewTransaction(context),
//     ),
//   );
// }
