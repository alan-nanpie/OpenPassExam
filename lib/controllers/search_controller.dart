import 'package:flutter/foundation.dart';
import '../data/models/question.dart';
import '../data/repositories/repository_factory.dart';

class ExamSearchController extends ChangeNotifier {
  final RepositoryFactory repositoryFactory;

  List<Question> _searchResults = [];
  bool _isSearching = false;
  String _currentQuery = '';
  String? _selectedTypeFilter;
  bool _onlyWithImage = false;

  ExamSearchController({required this.repositoryFactory});

  List<Question> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  String get currentQuery => _currentQuery;
  String? get selectedTypeFilter => _selectedTypeFilter;
  bool get onlyWithImage => _onlyWithImage;

  void setTypeFilter(String? type) {
    _selectedTypeFilter = type;
    performSearch(_currentQuery);
  }

  void toggleOnlyWithImage(bool value) {
    _onlyWithImage = value;
    performSearch(_currentQuery);
  }

  Future<void> performSearch(String query, {String subjectId = 'cisco-200-301'}) async {
    _currentQuery = query;
    _isSearching = true;
    notifyListeners();

    final repo = repositoryFactory.getQuestionRepository(subjectId);
    final all = await repo.getQuestions();

    final q = query.trim().toLowerCase();
    _searchResults = all.where((item) {
      final matchesText = q.isEmpty ||
          item.title.toLowerCase().contains(q) ||
          item.explanation.toLowerCase().contains(q) ||
          item.topic.toLowerCase().contains(q);

      final matchesType =
          _selectedTypeFilter == null || _selectedTypeFilter == 'ALL' || item.type == _selectedTypeFilter;

      final matchesImage = !_onlyWithImage || (item.imageUrl != null && item.imageUrl!.isNotEmpty);

      return matchesText && matchesType && matchesImage;
    }).toList();

    _isSearching = false;
    notifyListeners();
  }
}
