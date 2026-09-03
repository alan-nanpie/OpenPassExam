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
  bool _isSemanticVectorMode = false;

  ExamSearchController({required this.repositoryFactory});

  List<Question> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  String get currentQuery => _currentQuery;
  String? get selectedTypeFilter => _selectedTypeFilter;
  bool get onlyWithImage => _onlyWithImage;
  bool get isSemanticVectorMode => _isSemanticVectorMode;

  void setTypeFilter(String? type) {
    _selectedTypeFilter = type;
    performSearch(_currentQuery);
  }

  void toggleOnlyWithImage(bool value) {
    _onlyWithImage = value;
    performSearch(_currentQuery);
  }

  void toggleSemanticVectorMode(bool value) {
    _isSemanticVectorMode = value;
    performSearch(_currentQuery);
  }

  Future<void> performSearch(String query, {String subjectId = 'cisco-200-301'}) async {
    _currentQuery = query;
    _isSearching = true;
    notifyListeners();

    final repo = repositoryFactory.getQuestionRepository(subjectId);
    final all = await repo.getQuestions();

    final q = query.trim().toLowerCase();

    if (_isSemanticVectorMode && q.isNotEmpty) {
      // 模擬 Vertex AI 768 維度語意向量檢索：概念擴展與語意相關度評分
      final queryTokens = q.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();

      final scoredItems = <MapEntry<Question, double>>[];

      for (final item in all) {
        final matchesType = _selectedTypeFilter == null ||
            _selectedTypeFilter == 'ALL' ||
            item.type == _selectedTypeFilter;
        final matchesImage =
            !_onlyWithImage || (item.imageUrl != null && item.imageUrl!.isNotEmpty);

        if (!matchesType || !matchesImage) continue;

        double score = 0.0;
        final titleLower = item.title.toLowerCase();
        final expLower = item.explanation.toLowerCase();
        final topicLower = item.topic.toLowerCase();
        final notesLower = (item.englishGrammarNotes ?? '').toLowerCase();

        // 語意關聯與概念擴展加權 (例如 廣域網 -> wan / dmvpn / sd-wan / bgp)
        final semanticSynonyms = <String, List<String>>{
          '廣域網': ['wan', 'dmvpn', 'sd-wan', 'vpn', 'bgp', 'tunnel'],
          '故障排除': ['troubleshooting', 'debug', 'fail', 'error', 'shortcut', 'redirect'],
          '路由': ['route', 'routing', 'ospf', 'bgp', 'eigrp', 'ad', 'administrative distance'],
          '交換': ['switch', 'stp', 'rstp', 'vlan', 'trunk', 'access'],
          '安全': ['security', 'ssh', 'acl', 'trustsec', 'sgt', 'crypto'],
          '自動化': ['automation', 'restconf', 'api', 'python', 'json', 'yang'],
        };

        for (final token in queryTokens) {
          if (titleLower.contains(token)) score += 5.0;
          if (topicLower.contains(token)) score += 4.0;
          if (expLower.contains(token)) score += 3.0;
          if (notesLower.contains(token)) score += 2.0;

          // 檢查語意關聯同義詞
          for (final entry in semanticSynonyms.entries) {
            if (token.contains(entry.key) || entry.key.contains(token)) {
              for (final syn in entry.value) {
                if (titleLower.contains(syn) || expLower.contains(syn) || topicLower.contains(syn)) {
                  score += 4.0;
                }
              }
            }
          }
        }

        if (score > 0.0) {
          scoredItems.add(MapEntry(item, score));
        }
      }

      scoredItems.sort((a, b) => b.value.compareTo(a.value));
      _searchResults = scoredItems.map((e) => e.key).toList();
    } else {
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
    }

    _isSearching = false;
    notifyListeners();
  }
}
