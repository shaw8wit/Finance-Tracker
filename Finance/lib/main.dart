import 'dart:io';
import 'dart:ui';

import 'package:finance_app/widgets/transaction_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

import './models/transaction.dart';
import './widgets/new_transaction.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocDirectory = await path_provider.getApplicationDocumentsDirectory();
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
        primarySwatch: Colors.teal,
        errorColor: Colors.red,
        fontFamily: 'Quicksand',
        textTheme: ThemeData.light().textTheme.copyWith(
              headline6: TextStyle(fontFamily: 'OpenSans', fontWeight: FontWeight.bold, fontSize: 18),
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
            return (snapshot.hasError) ? Text(snapshot.error.toString()) : MyHomePage();
          }
          return CircularProgressIndicator();
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
  void _addNewTransaction(String txTitle, double txAmount, DateTime chosenDate) {
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
            child: TransactionList(),
          )
        : Scaffold(
            appBar: appBar,
            body: TransactionList(),
            floatingActionButton: FloatingActionButton.extended(
              tooltip: "Create new Transaction",
              icon: Icon(Icons.add),
              label: Text("Create"),
              onPressed: () => _startAddNewTransaction(context),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          );
  }
}
