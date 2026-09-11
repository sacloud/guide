# さくらクラウド構成例 03 - セキュアWebアプリケーション構成

このTerraform構成は、さくらクラウドでセキュアなWebアプリケーション環境を構築します。VPNルーターによるファイアウォール、L2TP/IPSec VPN、WireGuard VPN、データベースアプライアンス、詳細なパケットフィルターによる多層防御を実現し、高度なセキュリティ要件に対応します。

## 主な機能

- **柔軟なスケーリング**: Webサーバーの台数を1〜10台まで指定可能
- **カスタマイズ可能なスペック**: OS・CPU・メモリを自由に設定
- **セキュアなネットワーク**: カスタマイズ可能なプライベートネットワーク
- **VPN接続**: L2TP/IPSec + WireGuard VPNによるセキュアなリモートアクセス
- **データベースサービス**: プライベートネットワーク限定のマネージドMySQL
- **多層セキュリティ**: 詳細なパケットフィルター + ファイアウォール + IPアドレス制限
- **サンドボックス環境**: デフォルトでsandboxリージョンを使用

## インフラストラクチャ構成要素

### Webサーバー
- **台数**: 1〜10台まで指定可能
- **OS**: Ubuntu、Debian、AlmaLinux、Rocky Linux
- **スペック**: 1〜32コア、1〜128GBメモリ（6GB含む）
- **ディスク**: 20〜4000GB、SSD/HDD選択可能
- **ネットワーク**: パブリック + プライベート接続
- **セキュリティ**: HTTP/HTTPS(任意IP) + プライベートネットワーク(全許可)のパケットフィルター

### データベース
- **種別**: マネージドMySQLデータベース
- **プラン**: 10GB〜1TB（10g、30g、90g、240g、500g、1t）
- **バックアップ**: 自動バックアップ（時刻指定可能）
- **接続**: プライベートネットワーク経由のみ（完全分離）
- **セキュリティ**: ネットワークACL + 専用パケットフィルターによる二重保護

### VPNルーター
- **プラン**: standard、premium、highspec
- **ファイアウォール**: IPアドレスリストによる管理アクセス制限
- **VPN**: L2TP/IPSec + WireGuard VPNサーバー機能
- **ルーティング**: プライベートネットワークとの接続
- **アクセス制御**: SSH・WireGuardは許可IPからのみ、HTTP/HTTPSは任意IP

### ネットワーク構成
- **プライベートスイッチ**: Webサーバーとデータベース間の内部通信
- **カスタマイズ可能CIDR**: ネットワークアドレス範囲を自由に設定
- **VPN IPプール**: クライアント用IPアドレス範囲を設定可能
- **セキュアな分離**: パブリックとプライベートの明確な分離

## 前提条件

- Terraform >= 1.0
- さくらクラウド API キーの設定
- 環境変数の設定:

**Linux/macOS:**
```bash
export SAKURA_ACCESS_TOKEN="your-access-token"
export SAKURA_ACCESS_TOKEN_SECRET="your-access-token-secret"
```

**Windows (PowerShell):**
```powershell
$env:SAKURA_ACCESS_TOKEN="your-access-token"
$env:SAKURA_ACCESS_TOKEN_SECRET="your-access-token-secret"
```

`SAKURACLOUD_` プレフィックスの環境変数も互換性のため引き続きサポートされていますが、新しい設定では `SAKURA_` プレフィックスを使用してください。

v3では、サーバー、データベース、VPNルーターのパスワードを内部で `password_wo` と `password_wo_version` により設定します。`server_password`、`db_password`、`vpn_password` の変数名は変更不要です。

## 設定オプション

### 基本設定
- `zone`: 対象ゾーン（デフォルト: "sb" - sandbox）
- `prefix`: リソース名プレフィックス（デフォルト: "example-06"）
- `server_password`: サーバールートユーザーのパスワード

### Webサーバー設定
- `web_server_count`: Webサーバー台数（デフォルト: 1、範囲: 1〜10）
- `web_server_os_type`: OS種別（デフォルト: "ubuntu"）
  - 対応OS: ubuntu, debian, almalinux, rockylinux
- `web_server_core`: CPUコア数（デフォルト: 2）
  - 選択可能: 1, 2, 4, 8, 16, 32
- `web_server_memory`: メモリ容量GB（デフォルト: 6）
  - 選択可能: 1, 2, 4, 6, 8, 16, 32, 64, 128
- `web_server_disk_size`: ディスク容量GB（デフォルト: 100、範囲: 20〜4000）
- `web_server_disk_plan`: ディスクプラン（デフォルト: "ssd"）
  - `ssd`: SSDディスク
  - `hdd`: HDDディスク

### ネットワーク設定
- `private_network_cidr`: プライベートネットワークCIDR（デフォルト: "192.168.1.0/24"）
- `vpn_ip_range_start`: VPN IPレンジ開始（デフォルト: 240）
- `vpn_ip_range_end`: VPN IPレンジ終了（デフォルト: 249）

### データベース設定
- `db_username`: データベースユーザー名（デフォルト: "dbuser"）
- `db_password`: データベースパスワード
- `db_plan`: データベースプラン（デフォルト: "10g"）
  - 選択可能: 10g, 30g, 90g, 240g, 500g, 1t
- `db_backup_time`: バックアップ時刻（デフォルト: "00:00"）

### VPN設定
- `vpn_pre_shared_secret`: VPN事前共有キー
- `vpn_username`: VPNユーザー名（デフォルト: "vpnuser"）
- `vpn_password`: VPNパスワード

### セキュリティ設定
- `admin_source_networks`: 管理者アクセス許可ネットワークリスト（デフォルト: ["0.0.0.0/0"]）
- `vpn_router_plan`: VPNルータープラン（デフォルト: "standard"）
  - 選択可能: standard, premium, highspec

### WireGuard VPN設定
- `wireguard_enabled`: WireGuard有効/無効（デフォルト: true）
- `wireguard_port`: WireGuard UDPポート（デフォルト: 51820）
- `wireguard_server_private_key`: サーバー秘密鍵
- `wireguard_server_ip`: WireGuardサーバーIP（デフォルト: "192.168.100.1/24"）
- `wireguard_peers`: クライアント設定リスト

## 設定例

### terraform.tfvars.example
```hcl
# 基本設定
prefix = "secure-webapp"
zone = "sb"
server_password = "YourSecurePassword123!"

# Webサーバー設定
web_server_count = 3
web_server_os_type = "ubuntu"
web_server_core = 4
web_server_memory = 8
web_server_disk_size = 200
web_server_disk_plan = "ssd"

# ネットワーク設定
private_network_cidr = "10.0.1.0/24"
vpn_ip_range_start = 200
vpn_ip_range_end = 210

# データベース設定
db_username = "webapp_user"
db_password = "DatabaseSecurePassword456!"
db_plan = "30g"
db_backup_time = "02:00"

# VPN設定
vpn_pre_shared_secret = "YourVPNSecret789"
vpn_username = "admin_user"
vpn_password = "VPNSecurePassword123!"

# セキュリティ設定
admin_source_networks = ["203.0.113.0/24"]
vpn_router_plan = "premium"

# WireGuard VPN設定
wireguard_enabled = true
wireguard_port = 51820
wireguard_server_private_key = "YOUR_SERVER_PRIVATE_KEY"
wireguard_peers = [
  {
    name       = "admin_laptop"
    public_key = "CLIENT_PUBLIC_KEY"
    ip_address = "192.168.100.2/32"
  }
]
```

## 使用方法

1. サンプル変数ファイルをコピー:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. `terraform.tfvars` を編集して設定:
   - パスワード・シークレットの設定
   - サーバー台数・スペックの調整
   - ネットワーク・セキュリティ設定の調整

3. Terraform の初期化:
   ```bash
   terraform init
   ```

4. デプロイメントの計画:
   ```bash
   terraform plan
   ```

5. 設定の適用:
   ```bash
   terraform apply
   ```

## 出力値

- `web_server_global_ips`: WebサーバーのパブリックIPアドレス一覧
- `web_server_private_ips`: WebサーバーのプライベートIPアドレス一覧
- `vpn_router_global_ip`: VPNルーターのパブリックIPアドレス
- `database_fqdn`: データベースのFQDN
- `vpn_l2tp_range`: VPN IPアドレス範囲
- `connection_info`: 接続情報の詳細

## 構成シナリオ

### シナリオ1: 小規模Webアプリケーション
```hcl
web_server_count = 1
web_server_os_type = "ubuntu"
web_server_core = 2
web_server_memory = 4
db_plan = "10g"
vpn_router_plan = "standard"
```

### シナリオ2: 中規模企業サイト
```hcl
web_server_count = 3
web_server_os_type = "rockylinux"
web_server_core = 4
web_server_memory = 8
web_server_disk_size = 200
db_plan = "90g"
vpn_router_plan = "premium"
private_network_cidr = "10.0.1.0/24"
```

### シナリオ3: 高負荷対応構成
```hcl
web_server_count = 5
web_server_os_type = "ubuntu"
web_server_core = 8
web_server_memory = 16
web_server_disk_size = 500
db_plan = "500g"
vpn_router_plan = "highspec"
private_network_cidr = "172.16.0.0/24"
admin_source_networks = ["203.0.113.0/24", "198.51.100.0/24"]
wireguard_enabled = true
wireguard_port = 443  # HTTPSポートに偽装
```

## ネットワーク設計

### IPアドレス割り当て
- **VPNルーター**: ネットワークの .1（例: 192.168.1.1）
- **Webサーバー**: ネットワークの .11〜（例: 192.168.1.11〜）
- **データベース**: ネットワークの .21（例: 192.168.1.21）
- **VPN クライアント**: 指定範囲内（例: 192.168.1.240〜249）

### セキュリティ設計

#### パケットフィルタールール
- **Webサーバー**:
  - HTTP(80)/HTTPS(443): 任意のIPから接続許可
  - プライベートネットワーク: 全通信許可
  - その他: 全て拒否
- **データベース**:
  - プライベートネットワーク: 全通信許可
  - その他: 全て拒否
- **VPNルーター**:
  - SSH(22): 指定IPリストからのみ
  - WireGuard(UDP): 指定IPリストからのみ
  - HTTP(80)/HTTPS(443): 任意のIPから許可
  - ICMP: 任意のIPから許可

## VPN接続設定

### L2TP/IPSec VPN

#### クライアント設定例
1. **Windows:**
   - コントロールパネル → ネットワークとインターネット → VPN接続を追加
   - サーバー名: VPNルーターのパブリックIP
   - VPNの種類: L2TP/IPsec
   - 事前共有キー: 設定した値

2. **iOS/Android:**
   - 設定 → VPN → VPN構成を追加
   - タイプ: L2TP
   - サーバー: VPNルーターのパブリックIP
   - アカウント・パスワード・シークレット: 設定した値

### WireGuard VPN

#### キー生成
```bash
# サーバーキーペア生成
wg genkey | tee server_private.key | wg pubkey > server_public.key

# クライアントキーペア生成
wg genkey | tee client_private.key | wg pubkey > client_public.key
```

#### クライアント設定例 (wg0.conf)
```ini
[Interface]
PrivateKey = CLIENT_PRIVATE_KEY
Address = 192.168.100.2/24
DNS = 8.8.8.8

[Peer]
PublicKey = SERVER_PUBLIC_KEY
Endpoint = VPN_ROUTER_PUBLIC_IP:51820
AllowedIPs = 192.168.1.0/24, 192.168.100.0/24
PersistentKeepalive = 25
```

#### クライアントアプリ
- **Windows**: WireGuard for Windows
- **macOS**: WireGuard for macOS
- **iOS**: WireGuard (App Store)
- **Android**: WireGuard (Google Play)


## セキュリティのベストプラクティス

1. **強力なパスワード**: 各種パスワードは十分に複雑にする
2. **ネットワーク制限**: admin_source_networksを特定IPリストに限定
3. **定期更新**: OS・アプリケーションの定期的なセキュリティ更新
4. **監視強化**: ログ監視とアラート設定
5. **バックアップ**: データベースとファイルの定期バックアップ

## 運用・監視

### 日常運用
1. **サーバー監視**: CPU・メモリ・ディスク使用率の監視
2. **ログ監視**: アクセスログ・エラーログの定期確認
3. **セキュリティ監視**: 不正アクセス試行の検出
4. **バックアップ確認**: データベースバックアップの動作確認

### トラブルシューティング
1. **接続エラー**: ファイアウォール・パケットフィルター設定確認
2. **VPN接続不可**: 事前共有キー・認証情報の確認
3. **データベース接続エラー**: ネットワークACLとクレデンシャル確認
4. **パフォーマンス問題**: リソース使用率とボトルネック分析
5. **WireGuard接続不可**: キーペア、ポート設定、ファイアウォール設定の確認

## セキュリティ機能の詳細

### パケットフィルターの実装
この構成では、以下の3つのパケットフィルターを実装しています：

1. **Webサーバー用フィルター**
   - HTTP/HTTPSポートは任意のIPからアクセス可能
   - プライベートネットワークからは全ポートアクセス可能
   - その他は全てブロック

2. **データベース用フィルター**
   - プライベートネットワークからのみアクセス可能
   - パブリックアクセスは完全にブロック

3. **VPNルーター用ファイアウォール**
   - 管理アクセス（SSH、WireGuard）は指定したIPリストからのみ
   - Webアクセス（HTTP/HTTPS）は任意のIPから許可

### 多層防御アーキテクチャ
1. **ネットワーク分離**: パブリックとプライベートの完全分離
2. **アクセス制御**: IPアドレスリストによる管理アクセス制限
3. **パケットフィルタリング**: 各リソースに専用フィルターを適用
4. **VPN暗号化**: L2TP/IPSec + WireGuardによる二重のVPNオプション
5. **データベース分離**: プライベートネットワーク内のみでアクセス可能

この構成により、高度なセキュリティ要件を満たすWebアプリケーション環境を構築できます。柔軟な設定と詳細なセキュリティ制御により、様々な用途とセキュリティレベルに対応可能です。