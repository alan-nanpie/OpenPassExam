import '../datasources/local_persistent_cache.dart';
import '../models/exam_subject.dart';
import '../../core/constants/exam_subjects_data.dart';

abstract class ISubjectRepository {
  Future<List<ExamSubject>> getAllSubjects();
  Future<List<ExamSubject>> getOfficialSubjects();
  Future<List<ExamSubject>> getCustomSubjects();
  Future<ExamSubject?> getSubjectById(String id);
  Future<void> saveSubject(
    ExamSubject subject, {
    required String currentUserId,
    bool isAdmin = false,
  });
  Future<void> deleteSubject(
    String subjectId, {
    required String currentUserId,
    bool isAdmin = false,
  });
}

class SubjectRepository implements ISubjectRepository {
  final LocalPersistentCache localCache;

  SubjectRepository({required this.localCache});

  @override
  Future<List<ExamSubject>> getOfficialSubjects() async {
    return List.unmodifiable(ExamSubjectsData.allSubjects);
  }

  @override
  Future<List<ExamSubject>> getCustomSubjects() async {
    return localCache.getCachedCustomSubjects();
  }

  @override
  Future<List<ExamSubject>> getAllSubjects() async {
    final official = await getOfficialSubjects();
    final custom = await getCustomSubjects();
    return [...official, ...custom];
  }

  @override
  Future<ExamSubject?> getSubjectById(String id) async {
    final all = await getAllSubjects();
    try {
      return all.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveSubject(
    ExamSubject subject, {
    required String currentUserId,
    bool isAdmin = false,
  }) async {
    // 檢查是否企圖覆寫官方科目
    final official = await getOfficialSubjects();
    if (official.any((s) => s.id == subject.id) && !isAdmin) {
      throw Exception('【權限不足】：官方認證科目受保護，僅系統管理員可進行維護！');
    }

    final customList = (await getCustomSubjects()).toList();
    final existingIndex = customList.indexWhere((s) => s.id == subject.id);

    if (existingIndex >= 0) {
      final existing = customList[existingIndex];
      if (!existing.canEdit(currentUid: currentUserId, isAdmin: isAdmin)) {
        throw Exception('【權限不足】：您不是此自訂考試科目的建立者，無權進行修改！');
      }
      customList[existingIndex] = subject;
    } else {
      // 新增科目
      customList.add(subject);
    }

    await localCache.saveCustomSubjects(customList);
  }

  @override
  Future<void> deleteSubject(
    String subjectId, {
    required String currentUserId,
    bool isAdmin = false,
  }) async {
    final official = await getOfficialSubjects();
    if (official.any((s) => s.id == subjectId)) {
      throw Exception('【操作無效】：系統內建官方認證考科不可刪除！');
    }

    final customList = (await getCustomSubjects()).toList();
    final existingIndex = customList.indexWhere((s) => s.id == subjectId);

    if (existingIndex < 0) {
      throw Exception('【科目不存在】：找不到指定的自訂考試科目。');
    }

    final target = customList[existingIndex];
    if (!target.canEdit(currentUid: currentUserId, isAdmin: isAdmin)) {
      throw Exception('【權限不足】：您不是此自訂考試科目的建立者，無權刪除！');
    }

    customList.removeAt(existingIndex);
    await localCache.saveCustomSubjects(customList);
  }
}
