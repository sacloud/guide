# さくらクラウド構成例 01 - マルチリージョン災害復旧構成

このTerraform構成は、さくらクラウドの複数リージョンにまたがる高可用性のWebアプリケーション環境を構築します。プライマリ・セカンダリリージョンを自由に選択でき、マネージドデータベースのマスター・スレーブ構成により、災害復旧機能を提供します。

## 主な機能

- **柔軟なリージョン選択**: プライマリ・セカンダリリージョンを自由に選択可能
- **マルチリージョン構成**: 選択した2つのリージョンでの冗長化
- **グローバルロードバランシング**: GSLBによる自動フェイルオーバー
- **マネージドデータベース**: マスター・スレーブ構成による高可用性
- **柔軟なネットワーク設定**: サブネットマスクを設定可能
- **多様なOS対応**: Linux各種ディストリビューション、Windows Serverに対応
- **ブリッジ接続**: リージョン間のプライベート通信

## インフラストラクチャ構成要素

### ネットワーク
- **プライベートスイッチ**: 各リージョンに1つずつ（設定可能なサブネット）
- **ブリッジ接続**: リージョン間プライベート通信
- **GSLB**: グローバルサーバーロードバランシング

### コンピュート
- **Webサーバー**: 各リージョンに1台ずつ（スペック設定可能）
- **CPU**: 1〜32コア（1, 2, 4, 8, 16, 32）
- **メモリ**: 1〜128GB（1, 2, 4, 8, 16, 32, 64, 128）
- **ディスク**: 20〜4000GB（SSD/HDD選択可能）
- **OS選択**: Ubuntu、Debian、Rocky Linux、AlmaLinux、MIRACLE LINUX、Windows Server

### データベース
- **マスターDB**: プライマリリージョン（スペック設定可能、レプリケーション：マスター）
- **スレーブDB**: セカンダリリージョン（同一スペック、レプリケーション：スレーブ）
- **容量**: 10GB〜1TB（10g, 30g, 90g, 240g, 500g, 1t）
- **自動バックアップ**: 毎日実行（時刻設定可能）

## 対応OS一覧

### Linuxディストリビューション
- **Rocky Linux**: `os_type = "rockylinux"` (デフォルト)
- **Ubuntu**: `os_type = "ubuntu"`
- **Debian**: `os_type = "debian"`
- **AlmaLinux**: `os_type = "almalinux"`
- **MIRACLE LINUX**: `os_type = "miraclelinux"`

### Windows Server
- **Windows Server 2019**: `os_type = "windows2019"`
- **Windows Server 2022**: `os_type = "windows2022"`
- **Windows Server 2025**: `os_type = "windows2025"`

## ネットワーク構成

### デフォルトIPアドレス割り当て

#### プライマリリージョン（192.168.0.0/24）
- ゲートウェイ: 192.168.0.1
- Webサーバー: 192.168.0.11
- マスターDB: 192.168.0.50

#### セカンダリリージョン（192.168.1.0/24）
- ゲートウェイ: 192.168.1.1
- Webサーバー: 192.168.1.11
- スレーブDB: 192.168.1.50

### リージョン選択

以下の全てのさくらクラウドゾーンから自由に組み合わせ可能：

#### 石狩リージョン
- **is1a**: 石狩第1ゾーン
- **is1b**: 石狩第2ゾーン
- **is1c**: 石狩第3ゾーン

#### 東京リージョン
- **tk1a**: 東京第1ゾーン
- **tk1b**: 東京第2ゾーン
- **tk1v**: 東京第3ゾーン

### 推奨リージョン組み合わせ

#### 地理的分散（高可用性・災害復旧）
- **石狩 ⇔ 東京**: 地理的に最も離れており、災害復旧に最適

#### 同一リージョン内冗長化（高可用性）
- **東京内**: tk1a ⇔ tk1b ⇔ tk1v
- **石狩内**: is1a ⇔ is1b ⇔ is1c

### カスタムサブネット設定例
```hcl
# 10.0.x.x系での設定
primary_subnet_cidr   = "10.0.1.0/24"
secondary_subnet_cidr = "10.0.2.0/24"

# 172.16.x.x系での設定
primary_subnet_cidr   = "172.16.1.0/24"
secondary_subnet_cidr = "172.16.2.0/24"

# /25での設定（より小さなサブネット）
primary_subnet_cidr   = "192.168.0.0/25"
secondary_subnet_cidr = "192.168.0.128/25"
```

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

v3では、サーバーとデータベースのパスワードは内部で `password_wo` と `password_wo_version` を使用して設定します。`server_password` と `db_password` の変数名は変更不要です。

## 設定オプション

### 変数

#### 基本設定
- `prefix`: リソース名プレフィックス（デフォルト: "example-02"）
- `server_password`: サーバールートユーザーのパスワード
- `domain_name`: GSLB ヘルスチェック用ドメイン名

#### リージョン設定
- `primary_region`: プライマリリージョン（デフォルト: "is1a"）
- `secondary_region`: セカンダリリージョン（デフォルト: "tk1a"）

#### サーバースペック設定
- `server_core`: CPUコア数（デフォルト: 2）
- `server_memory`: メモリ容量GB（デフォルト: 2）
- `server_disk_size`: ディスク容量GB（デフォルト: 100）
- `server_disk_plan`: ディスクプラン（デフォルト: "ssd"）

#### データベース設定
- `db_username`: データベースユーザー名（デフォルト: "dbuser"）
- `db_password`: データベースパスワード
- `db_plan`: データベース容量プラン（デフォルト: "90g"）
- `db_backup_time`: バックアップ時刻（デフォルト: "02:00"）

#### オペレーティングシステム選択
- `os_type`: サーバーのOS種別
- `archive_ostype`: 特定のOSバージョン指定（オプション）
- `archive_name_filter`: アーカイブ名フィルタ（オプション）

#### ネットワーク設定
- `primary_subnet_cidr`: プライマリリージョンのサブネットCIDR（デフォルト: "192.168.0.0/24"）
- `secondary_subnet_cidr`: セカンダリリージョンのサブネットCIDR（デフォルト: "192.168.1.0/24"）

## 設定シナリオ

### シナリオ1: 標準的なマルチリージョン構成（Rocky Linux）
```hcl
prefix = "prod-web"
primary_region = "is1a"
secondary_region = "tk1a"
os_type = "rockylinux"
```

### シナリオ2: Ubuntu + 石狩リージョン冗長化
```hcl
prefix = "ubuntu-cluster"
primary_region = "is1a"
secondary_region = "is1b"
os_type = "ubuntu"
primary_subnet_cidr = "10.0.1.0/24"
secondary_subnet_cidr = "10.0.2.0/24"
```

### シナリオ3: Windows Server + 東京リージョン冗長化
```hcl
prefix = "win-web"
primary_region = "tk1a"
secondary_region = "tk1b"
os_type = "windows2022"
primary_subnet_cidr = "172.16.1.0/24"
secondary_subnet_cidr = "172.16.2.0/24"
```

### シナリオ4: 東京→石狩DR構成
```hcl
prefix = "tokyo-ishikari-dr"
primary_region = "tk1a"
secondary_region = "is1a"
os_type = "rockylinux"
```

### シナリオ5: 東京リージョン内高可用性
```hcl
prefix = "tokyo-ha"
primary_region = "tk1a"
secondary_region = "tk1v"
os_type = "ubuntu"
```

### シナリオ6: 高性能サーバー + 大容量DB構成
```hcl
prefix = "high-performance"
primary_region = "tk1a"
secondary_region = "is1a"
os_type = "rockylinux"
server_core = 16
server_memory = 64
server_disk_size = 1000
server_disk_plan = "ssd"
db_plan = "1t"
db_backup_time = "01:00"
```

## 使用方法

1. サンプル変数ファイルをコピー:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. `terraform.tfvars` を編集して設定:
   - リージョン選択（プライマリ・セカンダリ）
   - サーバースペック（CPU/メモリ/ディスク）
   - データベーススペック（容量/バックアップ時刻）
   - パスワードとドメイン名
   - OS種別の選択
   - ネットワーク設定

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

## 災害復旧ワークフロー

### 通常運用
1. **トラフィック分散**: GSLBが両リージョンに負荷分散
2. **データ同期**: マスターDBからスレーブDBへ自動レプリケーション
3. **ヘルスチェック**: GSLBが各サーバーの死活監視

### 障害発生時
1. **自動フェイルオーバー**: GSLBが正常なリージョンにトラフィック誘導
2. **手動切り替え**: 必要に応じてスレーブDBをマスターに昇格
3. **復旧作業**: 障害リージョンの復旧とデータ同期再開

## 出力値

- `web_server_primary_global_ip`: プライマリリージョンWebサーバーのグローバルIP
- `web_server_secondary_global_ip`: セカンダリリージョンWebサーバーのグローバルIP
- `web_server_primary_private_ip`: プライマリリージョンWebサーバーのプライベートIP
- `web_server_secondary_private_ip`: セカンダリリージョンWebサーバーのプライベートIP
- `master_database_ip`: マスターデータベースのプライベートIP
- `slave_database_ip`: スレーブデータベースのプライベートIP
- `gslb_fqdn`: GSLBのFQDN
- `primary_region`: 選択されたプライマリリージョン
- `secondary_region`: 選択されたセカンダリリージョン
- `primary_subnet_cidr`: プライマリリージョンのサブネットCIDR
- `secondary_subnet_cidr`: セカンダリリージョンのサブネットCIDR
- `selected_os_type`: 選択されたOS種別


## 重要な注意事項

- **リージョン選択**: プライマリとセカンダリで同じリージョンを選択しないでください
- **データベースフェイルオーバー**: 手動での切り替え作業が必要です
- **ネットワーク設計**: サブネット範囲の重複に注意してください
- **OS選択の影響**: Windows Serverには別途ライセンス費用が発生します
- **バックアップ**: 定期的なバックアップの確認と復旧テストを実施してください
- **監視**: アプリケーションレベルでの監視設定を追加してください

## トラブルシューティング

### データベース接続エラー
1. ネットワーク設定（allow_networks）の確認
2. プライベートネットワーク疎通確認
3. データベースサービス状態確認

### リージョン間通信エラー
1. ブリッジ接続状態の確認
2. セキュリティグループ設定の確認
3. ルーティング設定の確認

### GSLB動作不良
1. ヘルスチェック設定の確認
2. ドメイン名設定の確認
3. Webサーバーの応答状況確認

この構成により、高可用性と災害復旧機能を備えたマルチリージョンWebアプリケーション環境を構築できます。