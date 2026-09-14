// lib/features/history/providers/history_provider.dart
// Riverpod provider for managing transaction history list and filtering.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/expense_categories.dart';
import '../../../data/models/expense_transaction.dart';
import '../../../data/repositories/transaction_repository.dart';

class HistoryFilter {
  final ExpenseCategory? selectedCategory;
  final DateTime? startDate;
  final DateTime? endDate;
  final String searchQuery;

  const HistoryFilter({
    this.selectedCategory,
    this.startDate,
    this.endDate,
    this.searchQuery = '',
  });

  HistoryFilter copyWith({
    ExpenseCategory? Function()? selectedCategory,
    DateTime? Function()? startDate,
    DateTime? Function()? endDate,
    String? searchQuery,
  }) {
    return HistoryFilter(
      selectedCategory: selectedCategory != null ? selectedCategory() : this.selectedCategory,
      startDate: startDate != null ? startDate() : this.startDate,
      endDate: endDate != null ? endDate() : this.endDate,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class HistoryState {
  final List<ExpenseTransaction> allTransactions;
  final List<ExpenseTransaction> filteredTransactions;
  final HistoryFilter filter;

  const HistoryState({
    required this.allTransactions,
    required this.filteredTransactions,
    required this.filter,
  });

  HistoryState copyWith({
    List<ExpenseTransaction>? allTransactions,
    List<ExpenseTransaction>? filteredTransactions,
    HistoryFilter? filter,
  }) {
    return HistoryState(
      allTransactions: allTransactions ?? this.allTransactions,
      filteredTransactions: filteredTransactions ?? this.filteredTransactions,
      filter: filter ?? this.filter,
    );
  }
}

class HistoryNotifier extends AsyncNotifier<HistoryState> {
  final TransactionRepository _repository = TransactionRepository();

  @override
  Future<HistoryState> build() async {
    return _loadState(const HistoryFilter());
  }

  Future<HistoryState> _loadState(HistoryFilter filter) async {
    final all = await _repository.getAll();
    final filtered = _applyFilter(all, filter);

    return HistoryState(
      allTransactions: all,
      filteredTransactions: filtered,
      filter: filter,
    );
  }

  List<ExpenseTransaction> _applyFilter(
      List<ExpenseTransaction> list, HistoryFilter filter) {
    return list.where((tx) {
      if (filter.selectedCategory != null &&
          tx.category != filter.selectedCategory) {
        return false;
      }
      if (filter.startDate != null && tx.date.isBefore(filter.startDate!)) {
        return false;
      }
      if (filter.endDate != null &&
          tx.date.isAfter(filter.endDate!.add(const Duration(days: 1)))) {
        return false;
      }
      if (filter.searchQuery.isNotEmpty) {
        final query = filter.searchQuery.toLowerCase();
        final matchesMerchant = tx.merchantName.toLowerCase().contains(query);
        final matchesAmount = tx.amount.toInt().toString().contains(query);
        if (!matchesMerchant && !matchesAmount) return false;
      }
      return true;
    }).toList();
  }

  void setCategory(ExpenseCategory? category) {
    final current = state.valueOrNull;
    if (current == null) return;

    final newFilter = current.filter.copyWith(
      selectedCategory: () => category,
    );

    state = AsyncData(current.copyWith(
      filter: newFilter,
      filteredTransactions: _applyFilter(current.allTransactions, newFilter),
    ));
  }

  void setSearchQuery(String query) {
    final current = state.valueOrNull;
    if (current == null) return;

    final newFilter = current.filter.copyWith(searchQuery: query);

    state = AsyncData(current.copyWith(
      filter: newFilter,
      filteredTransactions: _applyFilter(current.allTransactions, newFilter),
    ));
  }

  void setDateRange(DateTime? start, DateTime? end) {
    final current = state.valueOrNull;
    if (current == null) return;

    final newFilter = current.filter.copyWith(
      startDate: () => start,
      endDate: () => end,
    );

    state = AsyncData(current.copyWith(
      filter: newFilter,
      filteredTransactions: _applyFilter(current.allTransactions, newFilter),
    ));
  }

  Future<void> deleteTransaction(String id) async {
    await _repository.delete(id);
    final current = state.valueOrNull;
    if (current == null) return;

    final updatedAll = current.allTransactions.where((tx) => tx.id != id).toList();
    state = AsyncData(current.copyWith(
      allTransactions: updatedAll,
      filteredTransactions: _applyFilter(updatedAll, current.filter),
    ));
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _loadState(state.valueOrNull?.filter ?? const HistoryFilter()));
  }
}

final historyProvider =
    AsyncNotifierProvider<HistoryNotifier, HistoryState>(HistoryNotifier.new);
