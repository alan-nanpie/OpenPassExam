import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../controllers/exam_controller.dart';
import '../../controllers/search_controller.dart';
import '../practice/practice_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final examCtrl = context.read<ExamController>();
      context.read<ExamSearchController>().performSearch('', subjectId: examCtrl.currentSubjectId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchCtrl = context.watch<ExamSearchController>();
    final examCtrl = context.watch<ExamController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('nav_search')),
      ),
      body: Column(
        children: [
          // 搜尋輸入框與篩選列
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (v) => searchCtrl.performSearch(v, subjectId: examCtrl.currentSubjectId),
                  decoration: InputDecoration(
                    hintText: '輸入關鍵字、題號、協定名稱或語意查詢...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              searchCtrl.performSearch('', subjectId: examCtrl.currentSubjectId);
                            },
                          )
                        : null,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    FilterChip(
                      label: const Text('僅看有拓撲圖'),
                      selected: searchCtrl.onlyWithImage,
                      onSelected: (v) => searchCtrl.toggleOnlyWithImage(v),
                    ),
                    const SizedBox(width: 10),
                    DropdownButton<String>(
                      value: searchCtrl.selectedTypeFilter ?? 'ALL',
                      underline: const SizedBox.shrink(),
                      items: const [
                        DropdownMenuItem(value: 'ALL', child: Text('全部題型')),
                        DropdownMenuItem(value: 'SINGLE_CHOICE', child: Text('單選題')),
                        DropdownMenuItem(value: 'MULTIPLE_CHOICE', child: Text('複選題')),
                        DropdownMenuItem(value: 'DRAG_DROP', child: Text('拖曳配對')),
                        DropdownMenuItem(value: 'SIMULATION', child: Text('實作模擬')),
                      ],
                      onChanged: (v) => searchCtrl.setTypeFilter(v),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // 搜尋結果列表
          Expanded(
            child: searchCtrl.isSearching
                ? const Center(child: CircularProgressIndicator())
                : searchCtrl.searchResults.isEmpty
                    ? const Center(child: Text('找不到符合條件的考題'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: searchCtrl.searchResults.length,
                        itemBuilder: (ctx, idx) {
                          final q = searchCtrl.searchResults[idx];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              title: Text(
                                q.title,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                '【${q.topic}】• ${q.type}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                ),
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => PracticeScreen(subjectId: q.examId),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
