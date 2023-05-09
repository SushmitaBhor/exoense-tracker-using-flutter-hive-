import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trackexpense/component/expense_summary.dart';
import 'package:trackexpense/data/expense_data.dart';
import 'package:trackexpense/models/expense_item.dart';

import '../component/expense_tile.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // text controllers
  final newExpenseNameController = TextEditingController();
  final newExpenseDollarController = TextEditingController();
  final newExpenseCentsController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  RegExp numberRegex = RegExp(r"^\d+$");
  @override
  void initState() {
    super.initState();

    // prepare data on startup
    Provider.of<ExpenseData>(context, listen: false).prepareData();
  }

  // add new expense
  void addNewExpense() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Add new expense'),
              content: Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  // expense name
                  TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Expense name cannot be empty";
                        }
                        return null;
                      },
                      controller: newExpenseNameController,
                      decoration:
                          const InputDecoration(hintText: 'Expense name')),

                  // expense amount
                  Row(
                    children: [
                      //dollars
                      Expanded(
                          child: TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Dollars cannot be empty";
                          } else if (numberRegex.hasMatch(value) == false) {
                            return "please numbers format";
                          }

                          return null;
                        },
                        controller: newExpenseDollarController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: 'Dollars'),
                      )),

                      //cents
                      Expanded(
                          child: TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Cents cannot be empty";
                          } else if (numberRegex.hasMatch(value) == false) {
                            return "please numbers format";
                          }
                          return null;
                        },
                        controller: newExpenseCentsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: 'Cents'),
                      ))
                    ],
                  )
                ]),
              ),
              actions: [
                // save button
                MaterialButton(onPressed: save, child: const Text('Save')),
                // cancel button
                MaterialButton(onPressed: cancel, child: const Text('Cancel'))
              ],
            ));
  }

  // delete expense
  void deleteExpense(ExpenseItem expense) {
    Provider.of<ExpenseData>(context, listen: false).deleteExpense(expense);
  }

  // save
  void save() {
    if (formKey.currentState?.validate() == true) {
      // put dollars and cents together
      String amount =
          '${newExpenseDollarController.text}.${newExpenseCentsController.text}';
      // create expense item

      ExpenseItem newExpense = ExpenseItem(
          name: newExpenseNameController.text,
          amount: newExpenseDollarController.text,
          dateTime: DateTime.now());
      // add the new expense

      Provider.of<ExpenseData>(context, listen: false)
          .addNewExpense(newExpense);

      Navigator.pop(context);
      clear();
    }
  }

  // cancel
  void cancel() {
    Navigator.pop(context);
    clear();
  }

  void clear() {
    newExpenseNameController.clear();
    newExpenseDollarController.clear();
    newExpenseCentsController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseData>(
        builder: (context, value, child) => Scaffold(
            backgroundColor: Colors.grey[300],
            body: ListView(children: [
              ExpenseSummary(
                startOfWeek: value.startOfWeekDate(),
              ),
              const SizedBox(height: 20),
              ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: value.getAllExpenseList().length,
                  itemBuilder: (context, index) => ExpenseTile(
                        name: value.getAllExpenseList()[index].name,
                        dateTime: value.getAllExpenseList()[index].dateTime,
                        amount: value.getAllExpenseList()[index].amount,
                        deleteTapped: (p0) =>
                            deleteExpense(value.getAllExpenseList()[index]),
                      ))
            ]),
            floatingActionButton: FloatingActionButton(
              tooltip: 'Increment',
              onPressed: addNewExpense,
              backgroundColor: Colors.black,
              child: const Icon(Icons.add),
            ) // This trailing comma makes auto-formatting nicer for build methods.
            ));
  }
}
