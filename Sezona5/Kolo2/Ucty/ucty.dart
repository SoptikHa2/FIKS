import 'dart:io';

void main(List<String> args) {
  /* INPUT */
  var line = stdin.readLineSync().split(' ').map((p) => int.parse(p)).toList();
  // Number of accounts
  int n = line[0];
  // Budget
  int budget = line[1];

  var accountBalances =
      stdin.readLineSync().split(' ').map((p) => int.parse(p)).toList();
  var accountFeeOut =
      stdin.readLineSync().split(' ').map((p) => int.parse(p)).toList();
  var accountFeeIn =
      stdin.readLineSync().split(' ').map((p) => int.parse(p)).toList();

  var accounts =
      Account.loadAccounts(accountBalances, accountFeeOut, accountFeeIn)
          .toList();
  accounts.sort((a, b) => a.currentMoney.compareTo(b.currentMoney));

  int optimalResult =
      (accountBalances.reduce((a, b) => a + b) / accountBalances.length).ceil();

  /* SOLVE */
  while (budget > 0) {
    // Try to solve this just by moving money to the account with cheapest transactions, do not go
    // over optimal result
    budget = moveMoneyCheaply(accounts, budget, optimalResult);
    if (accounts.last.currentMoney <= optimalResult) {
      print(optimalResult);
      return;
    }
    if (budget == -1) {
      print(accounts.last.currentMoney);
      return;
    }
    // Hm, it might've been better if we actually transfered more money
    // to the cheapest account than just to fill it's balance up to optimalResult
    budget = revertSomeTransactions(accounts, budget, optimalResult);
    if (accounts.last.currentMoney <= optimalResult) {
      print(optimalResult);
      return;
    }
    if (budget == -1) {
      print(accounts.last.currentMoney);
      return;
    }
  }
  print(accounts.last.currentMoney);
}

/// Move money between accounts.
/// Return remaining budget.
/// Return -1 if it is done.
int moveMoneyCheaply(
    List<Account> accounts, int remainingBudget, int optimalResult) {
  if (accounts.length < 2 ||
      accounts.last.currentMoney == optimalResult ||
      remainingBudget == -1 ||
      accounts.reversed
              .skip(1)
              .where((a) =>
                  a.feeIncoming + accounts.last.feeOutcoming > remainingBudget)
              .length ==
          accounts.length) return -1;

  var accountsToMoveMoneyFrom =
      accounts.where((a) => a.currentMoney > optimalResult);

  if (accountsToMoveMoneyFrom.length > 1) {
    // We need to reduce amount of accounts
    // How?
    // Take account with highest balance > A
    // Take account with second highest balance > B
    // call this method recursively, but omit all
    // accounts with balance > optimalResult, except A
    // instead of optimalResult as a stop, pass there
    // balance of B
    // After this runs, we can merge accounts A and B -
    // we simply add together their fees, nothing else
    // changes
    var accountWithHighestBalance = accounts.last;
    var accountWithSecondHighestBalance = accounts.reversed.skip(1).first;
    int newBudget = moveMoneyCheaply(
        accounts.where((a) => a.currentMoney <= optimalResult).toList()
          ..add(accountWithHighestBalance),
        remainingBudget,
        accountWithSecondHighestBalance.currentMoney);
    // Now, we have everything done, there is only one source account left
    accountWithHighestBalance.feeIncoming +=
        accountWithSecondHighestBalance.feeIncoming;
    accountWithHighestBalance.feeOutcoming +=
        accountWithSecondHighestBalance.feeOutcoming;
    return moveMoneyCheaply(
        accounts.where((a) => a != accountWithSecondHighestBalance),
        newBudget,
        optimalResult);
  } else {
    // We can move money
    while (remainingBudget >= 0) {
      var cheapestAccountToMoveMoneyTo =
          accounts.where((a) => a.currentMoney < optimalResult).first;
      int cost =
          accounts.last.feeOutcoming + cheapestAccountToMoveMoneyTo.feeIncoming;
      if (remainingBudget - cost < 0) break;
      // We can trasnfer at most maximum of these values:
      // - money in the source account over optimal result
      // - money in the target account below optimal result
      // - maximum amount of money we can transfer depending on the cost
      int maximumMoneyTransferAmount = min(
          accounts.last.currentMoney - optimalResult,
          min(remainingBudget ~/ cost,
              optimalResult - cheapestAccountToMoveMoneyTo.currentMoney));

      if (maximumMoneyTransferAmount == 0) break;

      stderr.writeln(
          "Moving ${maximumMoneyTransferAmount} from ${accounts.length - 1} to ${accounts.indexOf(cheapestAccountToMoveMoneyTo)}.");

      accounts.last.currentMoney -= maximumMoneyTransferAmount;
      cheapestAccountToMoveMoneyTo.currentMoney += maximumMoneyTransferAmount;
      remainingBudget -= cost * maximumMoneyTransferAmount;
    }
  }
  return remainingBudget;
}

/// Cancel some transactions to accounts
/// with high fees if it allows me to
/// move more money into low-fee accounts
int revertSomeTransactions(
    List<Account> accounts, int remainingBudget, int optimalResult) {
      var accountsThatWereImportedTo = accounts.where((a) => a.currentMoney > a.startingMoney).toList();
      accountsThatWereImportedTo.sort((a, b) => a.feeIncoming.compareTo(b.feeIncoming));
      
    }

class Account {
  int currentMoney;
  int feeIncoming;
  int feeOutcoming;
  int startingMoney;

  Account(this.currentMoney, this.feeIncoming, this.feeOutcoming) {
    this.startingMoney = this.currentMoney;
  }

  static Iterable<Account> loadAccounts(List<int> startBalances,
      List<int> accountFeesOut, List<int> accountFeesIn) sync* {
    for (var i = 0; i < startBalances.length; i++) {
      var balance = startBalances[i];
      var feeIn = accountFeesIn[i];
      var feeOut = accountFeesOut[i];
      yield Account(balance, feeIn, feeOut);
    }
  }

  @override
  String toString() {
    return currentMoney.toString();
  }
}

num min(num a, num b) => a <= b ? a : b;
