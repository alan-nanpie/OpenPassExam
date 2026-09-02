import 'package:flutter/foundation.dart';
import '../data/datasources/local_persistent_cache.dart';
import '../data/models/wrong_question.dart';

class WrongQuestionsController extends ChangeNotifier {
  final LocalPersistentCache localCache;

  List<WrongQuestion> _wrongQuestions = [];
  String? _selectedDomainFilter;

  WrongQuestionsController({required this.localCache}) {
    loadWrongQuestions();
  }

  List<WrongQuestion> get wrongQuestions => _wrongQuestions;
  String? get selectedDomainFilter => _selectedDomainFilter;

  List<WrongQuestion> get filteredQuestions {
    var list = _wrongQuestions;
    if (_selectedDomainFilter != null && _selectedDomainFilter != 'ALL') {
      list = list.where((w) => w.topic == _selectedDomainFilter).toList();
    }
    return list;
  }

  List<String> get availableDomains {
    final domains = _wrongQuestions.map((w) => w.topic).toSet().toList();
    domains.sort();
    return domains;
  }

  void loadWrongQuestions() {
    _wrongQuestions = localCache.getWrongQuestions();
    notifyListeners();
  }

  void setDomainFilter(String? domain) {
    _selectedDomainFilter = domain;
    notifyListeners();
  }

  Future<void> toggleMastered(String questionId) async {
    final idx = _wrongQuestions.indexWhere((w) => w.questionId == questionId);
    if (idx >= 0) {
      final current = _wrongQuestions[idx];
      _wrongQuestions[idx] = current.copyWith(isMastered: !current.isMastered);
      await localCache.saveWrongQuestions(_wrongQuestions);
      notifyListeners();
    }
  }

  Future<void> removeWrongQuestion(String questionId) async {
    _wrongQuestions.removeWhere((w) => w.questionId == questionId);
    await localCache.saveWrongQuestions(_wrongQuestions);
    notifyListeners();
  }
}
