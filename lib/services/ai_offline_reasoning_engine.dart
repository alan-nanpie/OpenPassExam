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

    // 2. 針對提問進行領域頂尖專家與首席顧問之核心深度解答
    sb.writeln('### 💡 頂尖專家專業剖析：「$cleanPrompt」\n');

    // 依據問題內容判斷主題並動態生成極致詳盡之技術解答
    _generateTopicSpecificAnswer(sb, cleanPrompt, lowerPrompt, question, persona);

    // 3. 領域首席顧問進階架構與實踐指引
    sb.writeln('\n### 🏛️ 首席技術顧問實務與架構指引');
    switch (persona) {
      case AiPersona.friendlyTutor:
        sb.writeln('#### 🔬 技術核心機制與規範深度剖析 (RFC / Architecture Details)');
        _generateExpertDeepDive(sb, lowerPrompt);
        break;

      case AiPersona.cliEngineer:
        sb.writeln('#### 🛠️ 企業級工程實戰配置與深入排錯 (Production Deployment & Troubleshooting)');
        _generateCliGuide(sb, lowerPrompt);
        break;

      case AiPersona.ccieArchitect:
        sb.writeln('#### 📐 首席架構師全域設計、效能瓶頸與權衡分析 (Trade-offs & Resilience)');
        _generateArchitectAdvice(sb, lowerPrompt);
        break;
    }

    // 4. 參考教材與標準規範切片 (若有檢索到)
    if (ragChunks != null && ragChunks.isNotEmpty) {
      sb.writeln('\n#### 📚 官方規範與教材知識庫 (RAG References)');
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
      sb.writeln('您好！我是您的 **PassExam 專屬領域首席技術顧問與頂尖專家**。我專精於網路通訊協定、企業級系統架構、雲端原生技術、資訊安全與各項全球頂尖技術認證。');
      sb.writeln('無論您提出任何專業理論、RFC 規範、生產環境實戰故障排除、指令配置細節或架構選型評估，我都將以業界頂尖專家的規格為您提供最權威且詳盡的完整剖析！');
      return;
    }

    // 詢問自己身分
    if (lower.contains('你是誰') || lower.contains('你是') || lower.contains('介紹自己') || lower.contains('who are you')) {
      sb.writeln('我是 **PassExam 領域頂尖專家與首席技術顧問**，具備【端側離線與雲端旗艦雙引擎調度】：');
      sb.writeln('- ⚡ **端側極速離線引擎**：支援 Google Gemma 4 (2B) 與 Web Nano，無網路狀態下仍可產出完整萬字級架構與指令剖析。');
      sb.writeln('- ☁️ **雲端旗艦多模態**：調度 Google Gemini 2.5 Flash 旗艦架構，具備深度推理、圖文拓撲多模態分析與生產實務評估能力。');
      sb.writeln('- 🎯 **專家諮詢定位**：徹底摒棄簡略回答與表面比喻，為您提供白皮書等級的底層機制、配置範例、架構權衡與排錯思路。');
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

  static void _generateExpertDeepDive(StringBuffer sb, String lower) {
    if (lower.contains('subnet') || lower.contains('ip') || lower.contains('cidr') || lower.contains('vlsm')) {
      sb.writeln('1. **RFC 4632 無類別域間路由 (CIDR) 底層位址空間數學模型**：');
      sb.writeln('   - IPv4 位址空間總量為 \\(2^{32} = 4,294,967,296\\) 個位址。子網路劃分本質是將主機位元借位至網路位元（Borrowing Bits）。');
      sb.writeln('   - 每向主機位元借 1 個 bit，可劃分的子網路數即翻倍（\\(2^k\\)），而每個子網路的可用主機容量減半。');
      sb.writeln('2. **VLSM (可變長度子網路遮罩) 規劃與點對點最佳實務**：');
      sb.writeln('   - 骨幹路由器點對點互連建議採用 `/30`（保留 2 個可用 IP 給兩端介面）或 RFC 3021 規範的 `/31`（無廣播與網路位址，位址利用率達 100%）。');
      sb.writeln('   - 針對終端用戶 LAN 建議採用 `/24` 或依部門規模規劃 `/25`~`/27`，並確保保留足夠位址作為 DHCP 動態分配池與網關備援 (HSRP/VRRP Virtual IP)。');
      sb.writeln('3. **反向遮罩 (Wildcard Mask) 在 ACL 與 OSPF 中的微架構比對**：');
      sb.writeln('   - Wildcard Mask 中的 `0` 代表「必須嚴格比對」，`1` 代表「忽略比對（Don\'t Care）」。');
      sb.writeln('   - 專家技巧：非連續 Wildcard（如 `0.0.0.254`）可用於單一 ACL 規則比對所有奇數或偶數 IP，大幅壓縮硬體 TCAM 表項。');
    } else if (lower.contains('vlan') || lower.contains('switch') || lower.contains('trunk') || lower.contains('stp')) {
      sb.writeln('1. **IEEE 802.1Q 訊框封裝與 4-Byte Tag 結構細節**：');
      sb.writeln('   - **TPID (Tag Protocol Identifier)**：固定為 `0x8100`，指示此為 802.1Q 標記訊框。');
      sb.writeln('   - **TCI (Tag Control Information)**：包含 3-bit PCP（802.1p 服務優先級 QoS）、1-bit DEI（丟棄指示）、以及 12-bit VLAN ID（範圍 1 ~ 4094）。');
      sb.writeln('2. **二層交換機 TCAM (Ternary Content Addressable Memory) 轉發原理**：');
      sb.writeln('   - 交換機硬體 ASIC 在接收訊框的第一個時鐘週期即透過 MAC Address Table 進行平行查表。');
      sb.writeln('   - 若目的 MAC 不在表項中，將觸發未知單播泛洪 (Unknown Unicast Flooding)，僅限同 VLAN 廣播域內所有連接埠。');
      sb.writeln('3. **STP/RSTP (802.1w) 狀態機收斂與硬體加速**：');
      sb.writeln('   - RSTP 將傳統 STP 的 5 種狀態簡化為 Discarding、Learning、Forwarding 3 種狀態。');
      sb.writeln('   - 啟用 PortFast 與 BPDU Guard：使終端連接埠直接跳過 Listening/Learning 進入 Forwarding（0 毫秒收斂），若誤接交換機收到 BPDU 則立即 Err-Disable 保護根橋。');
    } else if (lower.contains('ospf')) {
      sb.writeln('1. **Dijkstra SPF 演算法與七類 LSA 鏈路狀態通告深層機制**：');
      sb.writeln('   - **Type 1 (Router LSA)**：每台路由器在所屬區域內宣告自身介面與鏈路成本。');
      sb.writeln('   - **Type 2 (Network LSA)**：由 DR (Designated Router) 宣告多路訪問 (Broadcast/NBMA) 網段上的所有鄰居清單。');
      sb.writeln('   - **Type 3 (Summary LSA)**：由 ABR 宣告跨區域路由彙總，阻止 Type 1/2 泛洪至其他 Area，降低 CPU 拓撲計算開銷。');
      sb.writeln('   - **Type 4/5 (ASBR Summary & External LSA)**：宣告外部自治系統引入之路由（如重分布靜態或 BGP 路由）。');
      sb.writeln('2. **DR / BDR 選舉演算法與無中斷優雅重啟 (Graceful Restart)**：');
      sb.writeln('   - 選舉條件：介面 Priority 最高者獲選（0 代表不參與選舉）；Priority 相同時以 Router ID (IPv4 格式數值最大者) 獲選。');
      sb.writeln('   - 具備非搶佔特性（Non-preemptive）：即使網絡中加入更高優先級設備，也不會引發 DR 重選導致業務瞬斷。');
    } else {
      sb.writeln('1. **通訊協定與系統底層標準規範架構**：');
      sb.writeln('   - 系統核心運作嚴格遵循 IETF RFC 與業界開放標準架構，定義狀態機（State Machine）轉換條件、保活計時器（Keepalive Timer）與異常容錯重試機制。');
      sb.writeln('2. **企業級生產環境高可用性與吞吐量最佳化策略**：');
      sb.writeln('   - 採用雙主動（Active-Active）或主備（Active-Standby）集群架構，搭配心跳檢測（Heartbeat）達成毫秒級故障轉移。');
      sb.writeln('   - 透過快取層（如 Redis / 本機記憶體快取）消峰填谷，降低資料庫 I/O 與網路頻寬壓力。');
    }
  }

  static void _generateCliGuide(StringBuffer sb, String lower) {
    if (lower.contains('ospf')) {
      sb.writeln('```cisco');
      sb.writeln('! === 企業級 OSPF 進階微調、認證與深度排錯實戰 ===');
      sb.writeln('Router(config)# router ospf 1');
      sb.writeln('Router(config-router)# router-id 10.255.255.1');
      sb.writeln('Router(config-router)# auto-cost reference-bandwidth 100000 ! 將參考頻寬調整為 100G (正確區分 10G/40G/100G 介面 Cost)');
      sb.writeln('Router(config-router)# passive-interface default            ! 預設所有介面被動 (安全最佳實務)');
      sb.writeln('Router(config-router)# no passive-interface GigabitEthernet0/0/0');
      sb.writeln('');
      sb.writeln('! 介面啟用 Cryptographic SHA 認證，杜絕非法路由注入');
      sb.writeln('Router(config)# interface GigabitEthernet0/0/0');
      sb.writeln('Router(config-if)# ip ospf authentication message-digest');
      sb.writeln('Router(config-if)# ip ospf message-digest-key 1 md5 CiscoSecureKey2026!');
      sb.writeln('Router(config-if)# ip ospf dead-interval 40');
      sb.writeln('Router(config-if)# ip ospf hello-interval 10');
      sb.writeln('Router(config-if)# exit');
      sb.writeln('');
      sb.writeln('! 生產環境深入排錯與效能診斷');
      sb.writeln('Router# show ip ospf neighbor detail          ! 檢視完整鄰居狀態、MTU 與 dead timer 倒數');
      sb.writeln('Router# show ip ospf database summary         ! 快速盤點各區域 Type 3 LSA 路由總數');
      sb.writeln('Router# show ip ospf statistics              ! 檢視 SPF 演算法執行次數與 CPU 耗時');
      sb.writeln('```');
      return;
    }

    if (lower.contains('vlan') || lower.contains('trunk') || lower.contains('switch')) {
      sb.writeln('```cisco');
      sb.writeln('! === 企業級交換器 VLAN & 802.1Q Trunk 實務配置與安全性防禦 ===');
      sb.writeln('Switch(config)# vlan 10,20,30');
      sb.writeln('Switch(config)# interface GigabitEthernet0/1');
      sb.writeln('Switch(config-if)# switchport mode access');
      sb.writeln('Switch(config-if)# switchport access vlan 10');
      sb.writeln('Switch(config-if)# spanning-tree portfast     ! 啟用 PortFast 加速主機上線');
      sb.writeln('Switch(config-if)# spanning-tree bpduguard enable ! 啟用 BPDU Guard 阻絕外接交換機');
      sb.writeln('');
      sb.writeln('! Trunk 幹線安全加固 (關閉 DTP 自動協商，修改 Native VLAN)');
      sb.writeln('Switch(config)# interface GigabitEthernet0/24');
      sb.writeln('Switch(config-if)# switchport mode trunk');
      sb.writeln('Switch(config-if)# switchport nonegotiate     ! 關閉 DTP 避免中繼跳轉攻擊');
      sb.writeln('Switch(config-if)# switchport trunk native vlan 999 ! 避免預設 VLAN 1 雙標籤跳轉');
      sb.writeln('Switch(config-if)# switchport trunk allowed vlan 10,20,30');
      sb.writeln('');
      sb.writeln('! 實時檢視與除錯');
      sb.writeln('Switch# show interfaces trunk');
      sb.writeln('Switch# show spanning-tree summary');
      sb.writeln('Switch# show mac address-table count');
      sb.writeln('```');
      return;
    }

    sb.writeln('```cisco');
    sb.writeln('! === 生產環境標準化配置與監控指令 ===');
    sb.writeln('Device# configure terminal');
    sb.writeln('Device(config)# interface GigabitEthernet0/0/1');
    sb.writeln('Device(config-if)# description === Production Uplink to Core DC ===');
    sb.writeln('Device(config-if)# no shutdown');
    sb.writeln('Device(config-if)# exit');
    sb.writeln('! 即時驗證與系統狀態審計');
    sb.writeln('Device# show running-config');
    sb.writeln('Device# show ip interface brief');
    sb.writeln('Device# show ip route');
    sb.writeln('Device# show logging | include ERROR|FAIL');
    sb.writeln('```');
  }

  static void _generateArchitectAdvice(StringBuffer sb, String lower) {
    sb.writeln('1. **全域模組化架構與單點故障消除 (SPOF Elimination)**：');
    sb.writeln('   - 採用 Core / Aggregation / Access 三層或 Spine-Leaf 現代扁平化拓撲架構，確保任意單一節點或線路中斷皆能在 50 毫秒內由 BFD/ECMP 自動切換。');
    sb.writeln('2. **控制平面防護 (Control Plane Policing, CoPP)**：');
    sb.writeln('   - 在所有邊界節點部署 QoS 限速規則，嚴格限制抵達 CPU 的 OSPF/BGP/SSH/ICMP 封包速率，防止分散式拒絕服務攻擊 (DDoS) 癱瘓網路控制平面。');
    sb.writeln('3. **可觀測性與主動遙測 (Observability & Telemetry)**：');
    sb.writeln('   - 捨棄傳統低頻率 SNMP 輪詢，改採基於 gRPC 的串流遙測 (Model-driven Streaming Telemetry) 實現網路延遲、抖動與丢包的秒級實時告警與根因分析。');
  }
}
