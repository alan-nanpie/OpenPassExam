import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:passexam/data/datasources/local_persistent_cache.dart';
import 'package:passexam/data/datasources/rtdb_approved_keys_datasource.dart';
import 'package:passexam/data/models/app_user.dart';
import 'package:passexam/data/models/exam_subject.dart';
import 'package:passexam/data/models/question.dart';
import 'package:passexam/data/repositories/user_repository.dart';
import 'package:passexam/data/repositories/subject_repository.dart';
import 'package:passexam/data/repositories/question_repository.dart';
import 'package:passexam/controllers/auth_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Google 帳號登入與 RBAC 角色權限矩陣測試', () {
    late SharedPreferences prefs;
    late UserRepository userRepo;
    late AuthController authController;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      userRepo = UserRepository(prefs);
      authController = AuthController(userRepository: userRepo);
      await authController.initialize();
    });

    test('預設未登入時應為訪客角色，且具備訪客限制權限', () {
      final user = authController.currentUser;
      expect(user != null, true);
      expect(user!.isGuest, true);
      expect(user.isLoggedIn, false);
      expect(user.canCreateSubject, false);
      expect(user.canCreateQuestion, false);
      expect(user.canManageSystem, false);
    });

    test('Google 帳號登入後自動取得 Google 識別碼與創作者出題權限', () async {
      await authController.loginWithGoogle(
        email: 'developer.alan@gmail.com',
        displayName: 'Alan Chen',
        role: UserRole.creator,
      );

      final user = authController.currentUser;
      expect(user != null, true);
      expect(user!.isLoggedIn, true);
      expect(user.isGoogleUser, true);
      expect(user.email, 'developer.alan@gmail.com');
      expect(user.displayName, 'Alan Chen');
      expect(user.uid.startsWith('google_'), true);
      expect(user.role, UserRole.creator);

      // 檢查 RBAC 權限
      expect(user.canCreateSubject, true); // 可自建考試科目
      expect(user.canCreateQuestion, true); // 可自建考題
      expect(user.canAccessAiTutor, true); // 可使用 AI 導師
      expect(user.canAccessMockExam, true); // 可模擬考
      expect(user.canComment, true); // 可討論
      expect(user.canManageSystem, false); // 非管理員不可全站配置
    });

    test('系統管理員角色 (admin) 應享有全站最高管控權限', () async {
      await authController.loginWithGoogle(
        email: 'admin.super@gmail.com',
        displayName: 'Super Admin',
        role: UserRole.admin,
      );

      final user = authController.currentUser;
      expect(user!.isAdmin, true);
      expect(user.canManageSystem, true);
      expect(user.canCreateSubject, true);
      expect(user.canCreateQuestion, true);
    });

    test('登出後應清除 Google 憑證並重設為訪客身分', () async {
      await authController.loginWithGoogle(
        email: 'temp.user@gmail.com',
        displayName: 'Temp User',
      );
      expect(authController.currentUser!.isLoggedIn, true);

      await authController.logout();
      expect(authController.currentUser!.isGuest, true);
      expect(authController.currentUser!.isLoggedIn, false);
    });
  });

  group('UGC 社群自建考試科目與考題所有權 CRUD 測試', () {
    late SharedPreferences prefs;
    late LocalPersistentCache localCache;
    late SubjectRepository subjectRepo;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      localCache = LocalPersistentCache(prefs);
      subjectRepo = SubjectRepository(localCache: localCache);
    });

    test('可以載入官方科目，且官方科目不可被非管理員修改或刪除', () async {
      final officials = await subjectRepo.getOfficialSubjects();
      expect(officials.isNotEmpty, true);
      expect(officials.any((s) => s.code == '200-301'), true);

      // 非管理員企圖刪除官方科目 -> 應拋出異常
      expect(
        () async => await subjectRepo.deleteSubject('cisco-200-301', currentUserId: 'user_other'),
        throwsA(isA<Exception>()),
      );
    });

    test('Google 學員建立自訂考試科目 (如 AWS 考科) 並進行 CRUD 管控', () async {
      const creatorUid = 'google_alan_nanpie';
      const strangerUid = 'google_bob_viewer';

      final awsSubject = ExamSubject(
        id: 'subject_aws_saa_c03_custom',
        code: 'AWS-SAA-C03',
        title: 'AWS Certified Solutions Architect',
        category: 'Cloud',
        description: '涵蓋 AWS 雲端架構設計考題',
        totalQuestions: 50,
        domains: ['1.0 彈性設計', '2.0 安全架構'],
        iconName: 'cloud',
        creatorId: creatorUid,
        creatorName: 'Alan',
      );

      // 1. 建立者新增自訂科目 (Create)
      await subjectRepo.saveSubject(awsSubject, currentUserId: creatorUid);

      final allSubjects = await subjectRepo.getAllSubjects();
      final savedAws = allSubjects.firstWhere((s) => s.id == 'subject_aws_saa_c03_custom');
      expect(savedAws.code, 'AWS-SAA-C03');
      expect(savedAws.isOfficial, false);
      expect(savedAws.isOwner(creatorUid), true);
      expect(savedAws.isOwner(strangerUid), false);

      // 2. 陌生學員嘗試修改該科目資訊 -> 應遭拒絕
      expect(
        () async => await subjectRepo.saveSubject(
          savedAws,
          currentUserId: strangerUid,
        ),
        throwsA(isA<Exception>()),
      );

      // 3. 陌生學員嘗試刪除該科目 -> 應遭拒絕
      expect(
        () async => await subjectRepo.deleteSubject(
          'subject_aws_saa_c03_custom',
          currentUserId: strangerUid,
        ),
        throwsA(isA<Exception>()),
      );

      // 4. 建立者本人修改與刪除 -> 成功
      final updatedAws = ExamSubject(
        id: awsSubject.id,
        code: 'AWS-SAA-C03',
        title: 'AWS Certified Solutions Architect (Updated)',
        category: 'Cloud',
        description: awsSubject.description,
        totalQuestions: 60,
        domains: awsSubject.domains,
        iconName: awsSubject.iconName,
        creatorId: creatorUid,
        creatorName: 'Alan',
      );
      await subjectRepo.saveSubject(updatedAws, currentUserId: creatorUid);

      final afterUpdate = await subjectRepo.getSubjectById(awsSubject.id);
      expect(afterUpdate!.title.contains('Updated'), true);

      // 建立者本人刪除
      await subjectRepo.deleteSubject(awsSubject.id, currentUserId: creatorUid);
      final afterDelete = await subjectRepo.getSubjectById(awsSubject.id);
      expect(afterDelete, null);
    });

    test('自建科目下建立專屬考題，所有權限完整貫通隔離', () async {
      const creatorUid = 'google_teacher_lee';
      const strangerUid = 'google_student_wang';

      final questionRepo = FirestoreQuestionRepository(
        subjectId: 'subject_aws_saa_c03_custom',
        localCache: localCache,
        rtdbDatasource: RtdbApprovedKeysDatasource(),
      );

      final newQuestion = Question(
        id: 'q_aws_001',
        examId: 'subject_aws_saa_c03_custom',
        type: 'SINGLE_CHOICE',
        title: '何種服務提供 S3 跨區域非同步複製？',
        options: ['S3 Cross-Region Replication', 'EFS Sync', 'Direct Connect'],
        correctAnswer: [0],
        explanation: 'CRR 提供跨區域儲存桶非同步備份複製。',
        topic: '1.0 彈性設計',
        isApproved: true,
        creatorId: creatorUid,
        creatorName: 'Teacher Lee',
      );

      // 建立者儲存自創題
      await questionRepo.saveQuestion(newQuestion, currentUserId: creatorUid);

      // 學生刷題讀取
      final loaded = await questionRepo.getQuestionById('q_aws_001');
      expect(loaded != null, true);
      expect(loaded!.title.contains('S3 跨區域'), true);

      // 學生嘗試修改題目 -> 拒絕
      expect(
        () async => await questionRepo.saveQuestion(loaded.copyWith(title: '惡意修改'), currentUserId: strangerUid),
        throwsA(isA<Exception>()),
      );
    });
  });
}
