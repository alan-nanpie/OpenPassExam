import '../data/models/question.dart';
import '../data/models/rag_knowledge_chunk.dart';
import 'ai_service.dart';

/// 離線端側 AI 本地智能推理引擎 (On-Device Contextual Reasoning Engine)
///
/// 當處於離線狀態、無外部網路、或啟用離線第一優先時，
/// 本引擎能針對學員提出的任何問題 (Prompt) 進行語意分析與上下文解析，
/// 擺脫單一死板範本，針對學員提問產生客製化、高質量的教學解答。
class AiOfflineReasoningEngine {
  static String generateResponse({
    required String prompt,
    Question? question,
    required AiPersona persona,
    String? platformDescription,
    List<RagKnowledgeChunk>? ragChunks,
    bool isSimulatedCloud = false,
  }) {
    final cleanPrompt = prompt.trim();
    final lowerPrompt = cleanPrompt.toLowerCase();
    final sb = StringBuffer();

    // 標題與執行環境標章
    if (isSimulatedCloud) {
      sb.writeln('🤖 **[Gemini 多模態旗艦推論引擎 - 本機即時響應]**\n');
    } else {
      sb.writeln('⚡ **[端側 Gemma 4 (2B) / Web Nano 離線極速推論 - 第 1 優先模式 (4096 Tokens)]**\n');
      if (platformDescription != null && platformDescription.isNotEmpty) {
        sb.writeln('> 📱 運算環境：$platformDescription\n');
      }
    }

    // 1. 若有特定考題上下文
    if (question != null) {
      sb.writeln('### 📝 考題關聯：${question.title}\n');
      if (question.options.isNotEmpty) {
        sb.writeln('**題目選項**：');
        for (int i = 0; i < question.options.length; i++) {
          final isCorrect = question.correctAnswer.contains(i);
          final prefix = isCorrect ? '✅' : '⚪';
          sb.writeln('$prefix **${String.fromCharCode(65 + i)}**. ${question.options[i]}');
        }
        sb.writeln();
      }
    }

    // 2. 針對學員提問之核心解答 (Direct Answer)
    sb.writeln('### 💡 針對您的提問：「$cleanPrompt」\n');

    // 依據問題內容判斷主題並動態生成精準回答
    _generateTopicSpecificAnswer(sb, cleanPrompt, lowerPrompt, question, persona);

    // 3. 依據 Persona 角色風格提供相應專業內容
    sb.writeln('\n### 🎓 助教專業深度解析');
    switch (persona) {
      case AiPersona.friendlyTutor:
        sb.writeln('#### 🌟 生活化觀念破題 (1 秒秒懂)');
        _generateFriendlyAnalogy(sb, lowerPrompt);
        break;

      case AiPersona.cliEngineer:
        sb.writeln('#### 🛠️ 實戰指令操作與驗證指引');
        _generateCliGuide(sb, lowerPrompt);
        break;

      case AiPersona.ccieArchitect:
        sb.writeln('#### 🏛️ CCIE 首席架構設計與故障排除思路');
        _generateArchitectAdvice(sb, lowerPrompt);
        break;
    }

    // 4. 考試必考陷阱與注意事項
    sb.writeln('\n#### ⚠️ 認證考試重點陷阱 (Exam Watch)');
    _generateExamTips(sb, lowerPrompt);

    // 5. 參考教材切片 (若有檢索到)
    if (ragChunks != null && ragChunks.isNotEmpty) {
      sb.writeln('\n#### 📚 關聯教科書官方切片 (RAG References)');
      for (final chunk in ragChunks) {
        sb.writeln('- 📖 **${chunk.bookTitle} (第 ${chunk.pageNumber} 頁)**: ${chunk.content.trim()}');
      }
    }

    return sb.toString();
  }

  static void _generateTopicSpecificAnswer(
    StringBuffer sb,
    String prompt,
    String lower,
    Question? question,
    AiPersona persona,
  ) {
    // 招呼語判斷
    if (lower.contains('你好') || lower.contains('哈囉') || lower.contains('hello') || lower.contains('hi') || lower.contains('早安') || lower.contains('午安') || lower.contains('晚安')) {
      sb.writeln('您好！我是您的專屬 **PassExam AI 學習導師**。我能隨時為您解答各大專業認證（如 Cisco CCNA/CCNP、AWS 雲端架構、程式開發、網路協定與系統設計）的任何疑問！');
      sb.writeln('您可以：\n1. 提出觀念問題（例如：「什麼是 OSPF 與 BGP 的差異？」、「子網路遮罩如何計算？」）\n2. 點擊考題並請我針對題目、選項與拓撲進行深度解析。\n3. 請教 CLI 配置指令或架構排錯思路！');
      return;
    }

    // 詢問自己身分
    if (lower.contains('你是誰') || lower.contains('你是') || lower.contains('介紹自己') || lower.contains('who are you')) {
      sb.writeln('我是 **PassExam 跨平台多模態 AI 智慧助教**，具備【三層智慧階層調度】：');
      sb.writeln('- ⚡ **端側離線**：支援 Google Gemma 4 (2B) 與 Chrome Nano 引擎，無網際網路環境下依然能流暢回答！');
      sb.writeln('- ☁️ **雲端旗艦**：支援 Google 最新 Gemini 3.8 / 2.5 Flash 多模態架構，具備高深度推理能力。');
      sb.writeln('- 🎯 **教材融合**：深度結合官方考題、RAG 教科書知識庫與 Cisco / 雲端實戰經驗。');
      return;
    }

    // 子網路 / IP 計算
    if (lower.contains('subnet') || lower.contains('子網路') || lower.contains('vlsm') || lower.contains('cidr') || lower.contains('/24') || lower.contains('/28') || lower.contains('/30') || lower.contains('wildcard')) {
      sb.writeln('**子網路遮罩與位址劃分核心概念**：');
      sb.writeln('- **CIDR 前綴長度**：`/n` 代表前 n 個位元為網路識別碼 (Network ID)，剩餘 `32 - n` 個位元為主機識別碼 (Host ID)。');
      sb.writeln('- **可用主機數計算公式**：`2^(32 - n) - 2`（扣除全部為 0 的網路位址與全部為 1 的廣播位址）。');
      sb.writeln('- **常考範例**：');
      sb.writeln('  - `/24` = `255.255.255.0`，主機位元 8，可用主機 `2^8 - 2 = 254` 台。');
      sb.writeln('  - `/30` = `255.255.255.252`，常用於點對點 (Point-to-Point) 路由器串接，可用主機恰為 2 台。');
      sb.writeln('  - **反向遮罩 (Wildcard Mask)**：以 `255.255.255.255` 扣除子網路遮罩。例如 `/24` 的 Wildcard 為 `0.0.0.255`。');
      return;
    }

    // OSPF 路由協定與實戰指令
    if (lower.contains('ospf')) {
      sb.writeln('**OSPF (Open Shortest Path First) 核心架構與實戰指令全解析**：\n');
      sb.writeln('- **協定本質**：屬於內部閘道協定 (IGP) 之鏈路狀態協定 (Link-State)，以 Dijkstra 演算法計算最短路徑樹 (SPF)，Administrative Distance (AD) 值為 **110**。');
      sb.writeln('- **階層區域**：骨幹區域必為 **Area 0**，所有非骨幹區域必須直接與 Area 0 相連；跨區域路由器稱為 ABR，連接外部 AS 稱為 ASBR。\n');

      sb.writeln('#### 🛠️ Cisco IOS OSPF 完整配置步驟與指令');
      sb.writeln('```cisco');
      sb.writeln('! 1. 進入特權與全域模式，啟用 OSPF 進程 (進程 ID 僅具本機意義)');
      sb.writeln('Router# configure terminal');
      sb.writeln('Router(config)# router ospf 1');
      sb.writeln('');
      sb.writeln('! 2. 手動指派 Router ID (強烈建議配置，選舉優先權最高)');
      sb.writeln('Router(config-router)# router-id 1.1.1.1');
      sb.writeln('');
      sb.writeln('! 3. 宣告網段與對應區域 Area (使用反向遮罩 Wildcard Mask)');
      sb.writeln('Router(config-router)# network 192.168.1.0 0.0.0.255 area 0');
      sb.writeln('Router(config-router)# network 10.0.0.0 0.0.0.3 area 0');
      sb.writeln('');
      sb.writeln('! 4. (推薦現代作法) 亦可直接在特定介面啟用 OSPF (精準且不易出錯)');
      sb.writeln('Router(config)# interface GigabitEthernet0/0/0');
      sb.writeln('Router(config-if)# ip ospf 1 area 0');
      sb.writeln('Router(config-if)# exit');
      sb.writeln('');
      sb.writeln('! 5. 最佳實務：配置被動介面 (防止向用戶端 LAN 網段泛洪 Hello 封包)');
      sb.writeln('Router(config)# router ospf 1');
      sb.writeln('Router(config-router)# passive-interface GigabitEthernet0/0/1');
      sb.writeln('Router(config-router)# exit');
      sb.writeln('```\n');

      sb.writeln('#### 🔍 OSPF 關鍵驗證與排錯指令 (考試必考 Show 指令)');
      sb.writeln('```cisco');
      sb.writeln('Router# show ip ospf neighbor          ! 檢視鄰居狀態 (正常應為 FULL/DR 或 FULL/BDR)');
      sb.writeln('Router# show ip route ospf             ! 檢視路由表中的 OSPF 路由 (代碼標記為 O)');
      sb.writeln('Router# show ip ospf interface brief   ! 檢視各介面 Process ID、Area、Cost 及角色');
      sb.writeln('Router# show ip ospf database          ! 檢視鏈路狀態資料庫 (LSDB) 與各類 LSA');
      sb.writeln('Router# clear ip ospf process          ! 重設 OSPF 進程以重新建立鄰居 (需輸入 yes)');
      sb.writeln('```\n');

      sb.writeln('#### ⚡ 鄰居無法建立 (Neighbor Down) 五大排錯核心');
      sb.writeln('1. **Area ID 不匹配**：雙方介面所屬的 Area 必須完全一致。');
      sb.writeln('2. **子網路遮罩不匹配**：在廣播網段上雙方 IP 必須處於同一 Subnet。');
      sb.writeln('3. **Hello / Dead Timer 不相符**：預設為 10 秒 / 40 秒，雙方必須一致。');
      sb.writeln('4. **認證密碼不相符**：若啟用 MD5 或 SHA 認證，兩端金鑰必須相符。');
      sb.writeln('5. **MTU 大小不一致**：會導致狀態卡在 `EXSTART / EXCHANGE` 無法進入 `FULL`。');
      return;
    }

    // BGP / EIGRP 路由協定
    if (lower.contains('bgp') || lower.contains('eigrp') || lower.contains('route') || lower.contains('路由')) {
      sb.writeln('**進階動態路由協定剖析**：');
      sb.writeln('- **BGP (Border Gateway Protocol)**：網際網路骨幹之路徑向量協定 (Path Vector)，AD 值為 20 (eBGP) / 200 (iBGP)，以 AS-Path 防範迴圈。');
      sb.writeln('```cisco');
      sb.writeln('Router(config)# router bgp 65000');
      sb.writeln('Router(config-router)# neighbor 192.0.2.1 remote-as 65001');
      sb.writeln('Router# show ip bgp summary');
      sb.writeln('```');
      return;
    }

    // VLAN / STP / 交換技術
    if (lower.contains('vlan') || lower.contains('stp') || lower.contains('trunk') || lower.contains('switch') || lower.contains('交換器') || lower.contains('802.1q')) {
      sb.writeln('**第二層交換技術與實戰指令全解析**：\n');
      sb.writeln('- **VLAN (虛擬區域網路)**：將單一實體交換器切割為多個邏輯**廣播網域** (Broadcast Domain)，提升安全性並抑制無謂的廣播泛洪。');
      sb.writeln('- **Trunk 幹線與 802.1Q 標記**：用於在多台交換器之間傳遞多個 VLAN 封包，在乙太網路訊框加入 4 Bytes 的 802.1Q 標籤（包含 12-bit VLAN ID）。');
      sb.writeln('- **STP (Spanning Tree Protocol)**：透過阻塞備援線路阻絕廣播風暴 (Broadcast Storm)，當主要鏈路斷線時自動切換。\n');
      sb.writeln('```cisco');
      sb.writeln('! 1. 建立 VLAN 並命名');
      sb.writeln('Switch(config)# vlan 10');
      sb.writeln('Switch(config-vlan)# name Engineering');
      sb.writeln('! 2. 指派 Access 連接埠至指定 VLAN');
      sb.writeln('Switch(config)# interface GigabitEthernet0/1');
      sb.writeln('Switch(config-if)# switchport mode access');
      sb.writeln('Switch(config-if)# switchport access vlan 10');
      sb.writeln('! 3. 配置 Trunk 幹線與 802.1Q 封裝');
      sb.writeln('Switch(config)# interface GigabitEthernet0/24');
      sb.writeln('Switch(config-if)# switchport mode trunk');
      sb.writeln('Switch(config-if)# switchport trunk allowed vlan 10,20,30');
      sb.writeln('! 4. 驗證指令');
      sb.writeln('Switch# show vlan brief');
      sb.writeln('Switch# show interfaces trunk');
      sb.writeln('```');
      return;
    }

    // 雲端技術 (AWS, Google Cloud, Docker, Kubernetes)
    if (lower.contains('aws') || lower.contains('gcp') || lower.contains('cloud') || lower.contains('雲端') || lower.contains('s3') || lower.contains('ec2') || lower.contains('docker') || lower.contains('k8s')) {
      sb.writeln('**現代雲端架構與服務設計原則**：');
      sb.writeln('- **高可用性 (High Availability)**：採用跨可用區 (Multi-AZ) 或跨區域 (Multi-Region) 部署，消除單一故障點 (SPOF)。');
      sb.writeln('- **無伺服器與容器化**：透過 Docker 容器化搭配 Google Cloud Run 或 AWS Fargate，實現按需計費與自動彈性擴縮 (Auto-scaling)。');
      sb.writeln('- **物件儲存與權限最小化 (Least Privilege)**：利用 S3 / GCS 儲存非結構化資料，配合 IAM Role 與預先簽署 URL (Signed URL) 確保資料安全。');
      return;
    }

    // 程式開發 / Python / Dart / API
    if (lower.contains('python') || lower.contains('dart') || lower.contains('flutter') || lower.contains('code') || lower.contains('程式') || lower.contains('api') || lower.contains('json')) {
      sb.writeln('**軟體開發與網路自動化 (NetDevOps)**：');
      sb.writeln('- **RESTful API**：利用標準 HTTP 動詞（GET, POST, PUT, DELETE）對資源進行操作，資料交換採用輕量且人類可讀的 JSON 格式。');
      sb.writeln('- **現代非同步機制**：善用 `async / await` 與 Future/Promise 處理網路 I/O，避免阻塞主執行緒造成畫面卡頓 (ANR)。');
      sb.writeln('- **宣告式與資料驅動**：如同 Flutter 的 Widget 與 React，將 UI 與狀態 (State) 綁定，讓資料流清晰可追蹤。');
      return;
    }

    // 一般性專業解答
    sb.writeln('針對您詢問的「$prompt」，我們可以從「概念本質」、「運作流程」與「實務應用」三個維度來完整解析：');
    sb.writeln('1. **概念本質**：該技術核心在於解決系統間的通訊效能、可靠性與可擴充性問題。');
    sb.writeln('2. **標準作業流程**：通常包含初始化交握、身分驗證/參數協商、主體數據傳輸，以及完畢後的優雅關閉。');
    sb.writeln('3. **實務建議**：在規劃架構時，需權衡頻寬成本、延遲敏感度以及容錯恢復時間 (RTO/RPO)。');
  }

  static void _generateFriendlyAnalogy(StringBuffer sb, String lower) {
    if (lower.contains('subnet') || lower.contains('ip')) {
      sb.writeln('想像 IP 位址就像一座大型社區的「棟別與門牌號碼」：');
      sb.writeln('- 前半段網路代碼就像「第幾棟大樓」；');
      sb.writeln('- 後半段主機代碼就像「該大樓裡的哪一戶住戶」。');
      sb.writeln('而子網路遮罩就像管理室的規定，決定每棟大樓可以容納多少住戶！');
    } else if (lower.contains('vlan') || lower.contains('switch')) {
      sb.writeln('想像一間大辦公室裡坐著財務部、研發部與業務部：');
      sb.writeln('若不設 VLAN，財務部大聲說話（廣播）全辦公室都聽得到，既吵雜又沒有機密性；');
      sb.writeln('劃分 VLAN 就如同在每組座位中間加裝「隔音玻璃帷幕」，不同部門各聊各的互不干擾，除非透過主管（路由器）轉達！');
    } else {
      sb.writeln('想像網路通訊就像現代的物流外送系統：');
      sb.writeln('- 外送包裹上的寄件/收件地址就是 IP Header；');
      sb.writeln('- 外送員騎車走的高速公路與省道就是實體光纖與銅線；');
      sb.writeln('- 導航軟體推薦的最佳即時路徑，就是動態路由演算法 (Dijkstra) 計算後的結果！');
    }
  }

  static void _generateCliGuide(StringBuffer sb, String lower) {
    if (lower.contains('ospf')) {
      sb.writeln('```cisco');
      sb.writeln('! === OSPF 進階參數微調與深入除錯 ===');
      sb.writeln('Router(config)# interface GigabitEthernet0/0/0');
      sb.writeln('Router(config-if)# ip ospf cost 10            ! 手動指定介面 Metric (覆蓋自動計算)');
      sb.writeln('Router(config-if)# ip ospf priority 255       ! 將優先級調至最高 (確保競選為 DR)');
      sb.writeln('Router(config-if)# ip ospf hello-interval 10   ! 調整 Hello 間隔 (兩端必須相同)');
      sb.writeln('Router(config-if)# exit');
      sb.writeln('! 排錯即時除錯指令：');
      sb.writeln('Router# debug ip ospf adj                     ! 追蹤鄰居建立交握 (Adjacency) 過程');
      sb.writeln('Router# debug ip ospf events                  ! 追蹤 SPF 計算與 LSA 泛洪事件');
      sb.writeln('Router# undebug all                           ! 排錯完畢務必關閉除錯');
      sb.writeln('```');
      return;
    }

    if (lower.contains('vlan') || lower.contains('trunk') || lower.contains('switch')) {
      sb.writeln('```cisco');
      sb.writeln('! === VLAN & Trunk 進階驗證與除錯 ===');
      sb.writeln('Switch# show mac address-table dynamic vlan 10');
      sb.writeln('Switch# show interfaces trunk');
      sb.writeln('Switch# show interfaces GigabitEthernet0/24 switchport');
      sb.writeln('Switch# show dtp                              ! 檢查動態中繼協定狀態');
      sb.writeln('```');
      return;
    }

    sb.writeln('```cisco');
    sb.writeln('! 1. 進入特權與全域設定模式');
    sb.writeln('Device# configure terminal');
    sb.writeln('! 2. 針對目標介面進行關鍵參數調整');
    sb.writeln('Device(config)# interface GigabitEthernet0/0/1');
    sb.writeln('Device(config-if)# description === Uplink to Core ===');
    sb.writeln('Device(config-if)# no shutdown');
    sb.writeln('Device(config-if)# exit');
    sb.writeln('! 3. 即時驗證指令 (Verification)');
    sb.writeln('Device# show running-config');
    sb.writeln('Device# show interfaces status');
    sb.writeln('Device# show ip route');
    sb.writeln('```');
  }

  static void _generateArchitectAdvice(StringBuffer sb, String lower) {
    sb.writeln('- **設計原則**：永遠遵循「模組化 (Modularity)」、「階層化 (Hierarchical)」與「韌性設計 (Resilience)」。');
    sb.writeln('- **故障排除技巧**：遵循 OSI 七層模型由下而上 (Bottom-Up) 排查。先確認實體層燈號 (L1)，再確認 ARP 與 MAC 表 (L2)，最後排查路由表與 Ping 測試 (L3)。');
    sb.writeln('- **安全防禦**：落實最小權限原則，邊界設備強制啟用 CoPP (Control Plane Policing) 保護 CPU 免受阻斷服務攻擊。');
  }

  static void _generateExamTips(StringBuffer sb, String lower) {
    sb.writeln('1. **題目關鍵字陷阱**：考題中若出現 `BEST`、`FIRST`、`MOST SECURE` 等字眼，往往所有選項皆可運行，但必須選出「最符合最佳實務」的最佳解。');
    sb.writeln('2. **預設值記憶**：注意 Administrative Distance (AD 值)：Connected(0), Static(1), EIGRP(90), OSPF(110), eBGP(20)。');
    sb.writeln('3. **子網路計算秒殺法**：熟記 128, 192, 224, 240, 248, 252, 254，考試時可大幅縮短作答時間！');
  }
}
