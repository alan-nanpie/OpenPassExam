import '../models/question.dart';
import '../models/rag_knowledge_chunk.dart';

class MockSeedData {
  MockSeedData._();

  static List<Question> getInitialQuestions() {
    return [
      // CCNA 200-301 考題
      Question(
        id: 'ccna_q001',
        examId: 'cisco-200-301',
        type: 'SINGLE_CHOICE',
        title: '某工程師在路由器 R1 上配置了靜態預設路由，下列何者為正確的 Cisco IOS 語法？',
        options: [
          'ip route 0.0.0.0 0.0.0.0 192.168.1.1',
          'router static 0.0.0.0/0 192.168.1.1',
          'ip default-network 192.168.1.1 0.0.0.0',
          'ip route any any 192.168.1.1',
        ],
        correctAnswer: [0],
        explanation: '在 Cisco IOS 中，標準 IPv4 靜態預設路由（Default Route / Gateway of Last Resort）語法為 `ip route 0.0.0.0 0.0.0.0 <下一跳IP 或 出介面>`。',
        explanationJa: 'Cisco IOSでデフォルトルートを設定する標準コマンドは `ip route 0.0.0.0 0.0.0.0 <next-hop-ip>` です。',
        explanationZhTw: '在 Cisco IOS 中，標準 IPv4 靜態預設路由語法為 `ip route 0.0.0.0 0.0.0.0 <下一跳IP 或 出介面>`。第一個 0.0.0.0 代表目的網路，第二個代表子網路遮罩。',
        topic: '3.0 IP 連線能力 (IP Connectivity)',
        imageUrl: 'https://images.unsplash.com/photo-1544197150-b99a580bb7a8?w=800',
        isApproved: true,
        englishGrammarNotes: '關鍵術語：`Default Route` (預設路由)、`Next-hop IP` (下一跳位址)、`Gateway of Last Resort` (最後手段閘道)。文法解析：`configured ... on ...` 表示在某個設備上配置。',
      ),
      Question(
        id: 'ccna_q002',
        examId: 'cisco-200-301',
        type: 'MULTIPLE_CHOICE',
        title: '依據 Cisco 三層園區網路架構 (Three-Tier Campus Architecture)，下列哪兩項屬於「分發層 (Distribution Layer)」的核心職責？ (選擇兩項)',
        options: [
          '執行存取控制清單 (ACL) 與安全性策略過濾',
          '為終端使用者 PC 與印表機提供實體交換埠連接',
          '在多個 VLAN 間進行第 3 層路由與路由匯總 (Route Summarization)',
          '提供園區各棟大樓間極高速且不經封包過濾的骨幹傳輸',
        ],
        correctAnswer: [0, 2],
        explanation: '分發層 (Distribution Layer) 主要負責：1. VLAN 間路由 (Inter-VLAN Routing)；2. 路由匯總與策略控制 (ACL/QoS)；3. 定義廣播網域邊界。選項 B 為存取層 (Access Layer)，選項 D 為核心層 (Core Layer)。',
        explanationJa: 'ディストリビューション層は、VLAN間ルーティング、ACLポリシー適用、ルート集約を担当します。',
        explanationZhTw: '分發層（Distribution Layer）是存取層與核心層的匯接樞紐，負責：1. 策略控制與 ACL 封包過濾；2. VLAN 間第 3 層路由與路由匯總。',
        topic: '1.0 網路基礎 (Network Fundamentals)',
        imageUrl: null,
        isApproved: true,
        englishGrammarNotes: '關鍵術語：`Distribution Layer` (分發層/匯聚層)、`Access Layer` (存取層)、`Core Layer` (核心層)、`Route Summarization` (路由匯總)。',
      ),
      Question(
        id: 'ccna_q003',
        examId: 'cisco-200-301',
        type: 'DRAG_DROP',
        title: '請將下列 IPv6 位址類型與其對應的字首範圍進行正確配對：',
        options: [
          '全域單播位址 (Global Unicast) ➔ 2000::/3',
          '唯一區域位址 (Unique Local) ➔ FC00::/7',
          '連結本地位址 (Link-Local) ➔ FE80::/10',
          '多播位址 (Multicast) ➔ FF00::/8',
        ],
        correctAnswer: [0, 1, 2, 3],
        explanation: 'IPv6 標準字首分配：Global Unicast 為 2000::/3；Unique Local (私有) 為 FC00::/7；Link-Local (本機鏈路) 為 FE80::/10；Multicast (多播) 為 FF00::/8。',
        explanationJa: 'IPv6プレフィックス：Global Unicast (2000::/3)、Unique Local (FC00::/7)、Link-Local (FE80::/10)、Multicast (FF00::/8)。',
        explanationZhTw: 'IPv6 標準字首定義：全域單播 (2000::/3)、唯一區域 (FC00::/7)、連結本地 (FE80::/10)、多播 (FF00::/8)。',
        topic: '1.0 網路基礎 (Network Fundamentals)',
        imageUrl: null,
        isApproved: true,
        englishGrammarNotes: '術語：`Global Unicast` (全球單播)、`Link-Local` (連結本地)、`Unique Local` (唯一本地)。',
      ),
      Question(
        id: 'ccna_q004',
        examId: 'cisco-200-301',
        type: 'SINGLE_CHOICE',
        title: '下列哪個動態路由協定使用「無類別 (Classless)」、「鏈路狀態演算法 (Link-State)」，且其預設管理距離 (Administrative Distance) 為 110？',
        options: [
          'OSPF (Open Shortest Path First)',
          'EIGRP (Enhanced Interior Gateway Routing Protocol)',
          'RIPv2 (Routing Information Protocol v2)',
          'BGP (Border Gateway Protocol)',
        ],
        correctAnswer: [0],
        explanation: 'OSPF 為基於 Dijkstra 演算法的 Link-State 鏈路狀態路由協定，支援 VLSM/CIDR 無類別定址，在 Cisco IOS 中的預設管理距離 (AD) 恰為 110。EIGRP 的內部 AD 為 90；RIP 為 120；eBGP 為 20。',
        explanationJa: 'OSPFはリンクステート型プロトコルで、CiscoでのデフォルトAD値は110です。',
        explanationZhTw: 'OSPF 採用 Dijkstra 最短路徑優先演算法，屬於 Link-State 協定，Cisco 預設管理距離 AD 值為 110。',
        topic: '3.0 IP 連線能力 (IP Connectivity)',
        imageUrl: null,
        isApproved: true,
        englishGrammarNotes: '術語：`Link-State` (鏈路狀態)、`Administrative Distance (AD)` (管理距離)。',
      ),
      Question(
        id: 'ccna_q005',
        examId: 'cisco-200-301',
        type: 'SIMULATION',
        title: '實作題：工程師欲在交換器 Switch1 上啟用 SSH 連線並停用 Telnet，且需產生 2048 位元的 RSA 密鑰。下列哪組配置步驟最為完整？',
        options: [
          'hostname SW1 ➔ ip domain-name passexam.local ➔ crypto key generate rsa modulus 2048 ➔ line vty 0 4 ➔ transport input ssh ➔ login local',
          'line vty 0 4 ➔ transport input all ➔ password cisco ➔ login',
          'crypto key generate rsa 1024 ➔ enable secret cisco ➔ line vty 0 4 ➔ login',
          'ip ssh version 1 ➔ line vty 0 4 ➔ transport input telnet ssh',
        ],
        correctAnswer: [0],
        explanation: '配置 SSH 必備 6 大要素：1. 設定主機名稱 (`hostname`)；2. 設定域名 (`ip domain-name`)；3. 產生 RSA 密鑰 (`crypto key generate rsa modulus 2048`)；4. 建立本地用戶名密碼；5. 在 VTY 線路上指定 `transport input ssh`；6. 啟用本地驗證 `login local`。',
        explanationJa: 'SSH有効化の標準手順：hostname、ip domain-name、RSAキー生成(2048bit)、line vtyでのtransport input ssh、login local設定。',
        explanationZhTw: 'Cisco 交換器 SSH 安全配置流程：設定 Hostname 與 Domain-name ➔ 生成 2048 位元 RSA 密鑰 ➔ VTY 行配置 `transport input ssh` 與 `login local`。',
        topic: '5.0 資安基礎 (Security Fundamentals)',
        imageUrl: null,
        isApproved: true,
        englishGrammarNotes: '實戰 CLI 指令：`crypto key generate rsa modulus 2048`、`transport input ssh`。',
      ),

      // CCNP 350-401 ENCOR 考題
      Question(
        id: 'encor_q001',
        examId: 'cisco-350-401',
        type: 'SINGLE_CHOICE',
        title: '在 Cisco SD-Access 架構中，LISP (Locator/ID Separation Protocol) 在控制平面扮演什麼角色？',
        options: [
          '將端點識別碼 (EID) 映射至路由定位器 (RLOC)，並追蹤端點在網路拓撲中的移動性',
          '在資料平面封裝包含 VXLAN 標頭的原始乙太網路訊框',
          '在底層網路 (Underlay) 建立 OSPF 鄰居關係',
          '作為網路設備的集中式 Zero-Touch Provisioning (ZTP) 自動化配置伺服器',
        ],
        correctAnswer: [0],
        explanation: '在 Cisco SD-Access Fabric 中，LISP 負責控制平面 (Control Plane) 的位址解析與映射資料庫，將端點標識 (EID) 映射至邊界節點的路由定位器 (RLOC)；VXLAN 則負責資料平面 (Data Plane) 的封裝。',
        explanationJa: 'Cisco SD-Accessにおいて、LISPはコントロールプレーンでEIDからRLOCへのマッピングと追跡を行います。',
        explanationZhTw: '在 Cisco SD-Access 架構中，LISP 作為控制平面協定，維護 EID (端點 ID) 與 RLOC (路由定位器) 的對應資料庫，實現主機移動性追蹤。',
        topic: '1.0 架構 (Architecture)',
        imageUrl: 'https://images.unsplash.com/photo-1558494949-ef010cbdcc31?w=800',
        isApproved: true,
        englishGrammarNotes: '術語：`Locator/ID Separation Protocol (LISP)`、`EID (Endpoint Identifier)`、`RLOC (Routing Locator)`。',
      ),
      Question(
        id: 'encor_q002',
        examId: 'cisco-350-401',
        type: 'MULTIPLE_CHOICE',
        title: '在 BGP 路由選路流程中，當具有多條抵達相同目的地的有效路徑時，下列哪些屬性會被優先評估？ (依順序選擇兩項)',
        options: [
          '最高 Weight (Cisco 專有，僅本地有效)',
          '最高 Local Preference (自治系統內部傳播)',
          '最短 AS_Path 長度',
          '最低 MED (Multi-Exit Discriminator)',
        ],
        correctAnswer: [0, 1],
        explanation: 'BGP 最佳路徑選擇演算法 (Path Selection) 前四步：1. 最高 Weight (預設 0/32768)；2. 最高 Local Preference (預設 100)；3. 本地產生的路由 (Originated)；4. 最短 AS_Path。',
        explanationJa: 'BGPベストパス選択順序：1. Weight (最大)、2. Local Preference (最大)、3. 本地生成、4. AS_Path (最短)。',
        explanationZhTw: 'BGP 選路決策口訣 (W-L-O-A-O-M-N-R-I)：最高 Weight ➔ 最高 Local Preference ➔ 本地生成 ➔ 最短 AS_Path ➔ 最低 Origin ➔ 最低 MED。',
        topic: '3.0 基礎設施 (Infrastructure)',
        imageUrl: null,
        isApproved: true,
        englishGrammarNotes: '記憶口訣：`Weight -> Local Preference -> AS_Path -> MED`。',
      ),

      // CCNP 300-410 ENARSI 考題
      Question(
        id: 'enarsi_q001',
        examId: 'cisco-300-410',
        type: 'SINGLE_CHOICE',
        title: '在 DMVPN (Dynamic Multipoint VPN) Phase 3 架構中，分支機構路由器之間 (Spoke-to-Spoke) 如何動態建立直連通道？',
        options: [
          '透過 NHRP Redirect 觸發與 NHRP Shortcut 機制，動態學習彼此的公網 IP 並建立直接通道',
          '所有流量永遠強制經由 Hub 路由器進行解密與再次加密轉發',
          '必須在所有 Spoke 之間手動靜態配置 Full-Mesh 的 GRE Tunnel 介面',
          '透過 BGP EVPN 控制平面下發 VXLAN 路由',
        ],
        correctAnswer: [0],
        explanation: 'DMVPN Phase 3 引入了 `ip nhrp redirect` (在 Hub 上) 與 `ip nhrp shortcut` (在 Spoke 上)，當 Spoke 間通訊流量經過 Hub 時，Hub 發出 Redirect 指示，促使 Spoke 彼此發送 NHRP 查詢並建立直連 Spoke-to-Spoke 隧道。',
        explanationJa: 'DMVPN Phase 3では、NHRP RedirectとShortcutによりSpoke間で直接トンネルを動的に確立します。',
        explanationZhTw: 'DMVPN Phase 3 核心增強：Hub 啟用 `ip nhrp redirect`，Spoke 啟用 `ip nhrp shortcut`，由 Hub 引導 Spoke 建立 Spoke-to-Spoke 直接加密隧道。',
        topic: '2.0 VPN 服務 (VPN Services)',
        imageUrl: 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=800',
        isApproved: true,
        englishGrammarNotes: '術語：`DMVPN (Dynamic Multipoint VPN)`、`NHRP Redirect`、`NHRP Shortcut`。',
      ),

      // CCNP 300-435 ENAUTO 考題
      Question(
        id: 'enauto_q001',
        examId: 'cisco-300-435',
        type: 'SINGLE_CHOICE',
        title: 'RESTCONF 協定在 HTTP 請求中使用哪種 HTTP 方法來「更新現有資源但僅修改部分欄位」？',
        options: [
          'PATCH',
          'PUT',
          'POST',
          'DELETE',
        ],
        correctAnswer: [0],
        explanation: 'RESTCONF (RFC 8040) HTTP 方法定義：GET (讀取)、POST (新建)、PUT (完整替換/覆蓋)、PATCH (部分更新)、DELETE (刪除)。',
        explanationJa: 'RESTCONFでは、既存リソースの部分更新にPATCHメソッドを使用します。',
        explanationZhTw: 'RESTCONF (RFC 8040) 中，PATCH 用於更新現有資源的特定欄位（部分更新）；PUT 則為全量替換。',
        topic: '2.0 自動化 API (Automate APIs and Protocols)',
        imageUrl: null,
        isApproved: true,
        englishGrammarNotes: 'HTTP Methods in Network Automation: `GET`, `POST`, `PUT`, `PATCH`, `DELETE`.',
      ),

      // CCNP 350-701 SCOR 考題
      Question(
        id: 'scor_q001',
        examId: 'cisco-350-701',
        type: 'SINGLE_CHOICE',
        title: '在 Cisco TrustSec 架構中，安全群組標籤 (Security Group Tag, SGT) 在資料平面封裝於何處？',
        options: [
          '在 Cisco MetaData (CMD) 欄位中，嵌入於第 2 層 802.1Q 乙太網路訊框標頭',
          '在 IP 標頭的 DSCP 欄位中',
          '在 TCP Options 擴充欄位中',
          '在 TLS 握手憑證擴充擴充項目中',
        ],
        correctAnswer: [0],
        explanation: 'Cisco TrustSec 使用 SGT 進行基於角色的微隔離 (Micro-segmentation)，SGT 標籤嵌入於 Layer 2 訊框的 Cisco MetaData (CMD) 欄位中，使交換器能在硬體層級 (ASIC) 執行線速 SGACL 策略。',
        explanationJa: 'Cisco TrustSecでは、SGTはレイヤー2フレームのCisco MetaData (CMD) フィールドに挿入されます。',
        explanationZhTw: 'Cisco TrustSec 的 SGT 標籤被封裝在 Layer 2 訊框的 CMD (Cisco MetaData) 欄位內，交換器藉此執行硬體線速的 SGACL 權限控管。',
        topic: '1.0 安全概念 (Security Concepts)',
        imageUrl: null,
        isApproved: true,
        englishGrammarNotes: '術語：`Security Group Tag (SGT)`、`Cisco TrustSec`、`Micro-segmentation`。',
      ),
    ];
  }

  static List<RagKnowledgeChunk> getInitialRagChunks() {
    return [
      RagKnowledgeChunk(
        id: 'chunk_ccna_001',
        bookTitle: 'CCNA 200-301 Official Cert Guide Vol 1',
        chapter: 'Chapter 14: IP Routing Concepts & Static Routes',
        pageNumber: 342,
        topic: 'IPv4 Default Routing and Administrative Distance',
        content: '''
靜態預設路由 (Static Default Route) 亦被稱為最後手段閘道 (Gateway of Last Resort)。
在 Cisco IOS 中，語法為：
`Router(config)# ip route 0.0.0.0 0.0.0.0 {next-hop-ip | exit-interface} [distance]`

管理距離 (Administrative Distance, AD) 是 Cisco 路由器評估路由來源可信度的指標：
- 直接連線 (Connected): 0
- 靜態路由 (Static Route): 1
- eBGP: 20
- EIGRP 內部: 90
- OSPF: 110
- IS-IS: 115
- RIP: 120
- iBGP: 200
AD 數值越小，代表該路由來源的優先權越高。
''',
        qualityScore: 0.98,
        keywords: ['ip route', 'default route', 'administrative distance', 'gateway of last resort'],
      ),
      RagKnowledgeChunk(
        id: 'chunk_ccna_002',
        bookTitle: 'CCNA 200-301 Official Cert Guide Vol 1',
        chapter: 'Chapter 10: RSTP and EtherChannel',
        pageNumber: 215,
        topic: 'Rapid Spanning Tree Protocol (IEEE 802.1w)',
        content: '''
802.1w RSTP (Rapid STP) 大幅縮短了傳統 802.1D STP 的收斂時間（從 30-50 秒降至毫秒級）。
RSTP 埠角色 (Port Roles)：
1. Root Port (RP): 抵達 Root Bridge 最佳路徑。
2. Designated Port (DP): 每個網段轉發封包的代表埠。
3. Alternate Port (AP): Root Port 的即時備份路徑 (接收到其他交換器的更優 BPDU)。
4. Backup Port (BP): 同一交換器上 Designated Port 的備用埠。

RSTP 埠狀態 (Port States)：
- Discarding (結合 802.1D 的 Disabled, Blocking, Listening)
- Learning
- Forwarding
''',
        qualityScore: 0.96,
        keywords: ['RSTP', '802.1w', 'Alternate Port', 'Root Port', 'Discarding'],
      ),
      RagKnowledgeChunk(
        id: 'chunk_encor_001',
        bookTitle: 'CCNP Enterprise ENCOR 350-401 Official Cert Guide',
        chapter: 'Chapter 24: Cisco SD-Access Solution',
        pageNumber: 580,
        topic: 'LISP Control Plane & VXLAN Data Plane Integration',
        content: '''
Cisco Software-Defined Access (SD-Access) 採用控制器為核心 (Cisco DNA Center) 的校園網路架構。
Fabric 架構元件：
1. Control Plane (LISP):
   - 解決路由表膨脹與移動性問題。
   - Map Server (MS) 與 Map Resolver (MR) 維護 EID 到 RLOC 的映射。
2. Data Plane (VXLAN):
   - 使用 UDP Port 4789 封裝完整 Layer 2 訊框。
   - VXLAN 標頭內建 16 位元 SGT (Security Group Tag) 與 24 位元 VNI。
3. Policy Plane (TrustSec & Cisco ISE):
   - 依據 SGT 實施組間存取控制 (SGACL)。
''',
        qualityScore: 0.99,
        keywords: ['SD-Access', 'LISP', 'VXLAN', 'TrustSec', 'DNA Center', 'EID', 'RLOC'],
      ),
    ];
  }
}
