import '../models/expense_model.dart';

class ExpenseService {
  List<Expense> getExpenses() {
    return [
      Expense(description: "Hotel", amount: 200),
      Expense(description: "Food", amount: 50),
      Expense(description: "Transport", amount: 100),
    ];
  }
}
