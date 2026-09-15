# さくらクラウド構成例 04 - VPNゲートウェイ構成（NFS + Sambaファイルサーバー）

このTerraform構成は、さくらクラウドでVPNルーターをインターネットゲートウェイとして使用し、プライベートネットワーク内にNFS・Sambaファイルサーバー環境を構築します。サーバーは直接インターネットにアクセスせず、VPNルーター経由でのみ外部通信を行う、セキュアなファイル共有環境を実現します。

## 主な機能

- **VPNゲートウェイ構成**: VPNルーターをインターネットゲートウェイとして使用
- **プライベートネットワーク**: サーバーは直接インターネットアクセスなし
- **自動ファイルサーバー構築**: Cloud-initによるNFS・Samba自動セットアップ
- **柔軟なサーバー構成**: OS・CPU・メモリ・台数を指定可能
- **カスタマイズ可能ネットワーク**: CIDR範囲を自由に設定
- **VPN接続**: L2TP/IPSec + WireGuard VPNによるリモートアクセス
- **厳格なセキュリティ**: プライベートネットワーク限定通信
- **サンドボックス環境**: デフォルトでsandboxリージョンを使用

## インフラストラクチャ構成要素

### VPNルーター（インターネットゲートウェイ）
- **役割**: プライベートネットワークとインターネット間のゲートウェイ
- **プラン**: standard、premium、highspec
- **ファイアウォール**: IPアドレスリストによる管理アクセス制限
- **VPN**: L2TP/IPSec + WireGuard VPNサーバー機能
- **セキュリティ**: SSH・WireGuardは指定IPからのみアクセス可能

### ファイルサーバー
- **台数**: 1〜10台まで指定可能
- **OS**: Ubuntu、Debian（cloud-init対応）
- **スペック**: 1〜32コア、1〜128GBメモリ
- **ディスク**: 20〜4000GB、SSD/HDD選択可能
- **ネットワーク**: プライベートネットワークのみ（パブリックIP無し）
- **自動セットアップ**: Cloud-initによるNFS・Samba自動構築

### NFSサーバー
- **種別**: さくらクラウドのマネージドNFS
- **容量**: 100GB（標準）
- **アクセス**: プライベートネットワーク内のみ
- **マウント**: 各サーバーに`/mnt/shared`として自動マウント

### Sambaファイル共有
- **共有パス**: `/mnt/shared`（NFSマウントポイント）
- **アクセス**: ゲストアクセス許可（誰でもアクセス可能）
- **プロトコル**: SMB/CIFS
- **セットアップ**: Cloud-initによる自動インストール・設定

### ネットワーク構成
- **プライベートスイッチ**: サーバー間・NFS間の内部通信
- **カスタマイズ可能CIDR**: ネットワークアドレス範囲を自由に設定
- **VPN IPプール**: クライアント用IPアドレス範囲を設定可能
- **完全分離**: サーバーはインターネットに直接アクセス不可

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

v3では、サーバーとVPNルーターのパスワードを内部で `password_wo` と `password_wo_version` により設定します。`server_password` と `vpn_password` の変数名は変更不要です。

## 設定オプション

### 基本設定
- `zone`: 対象ゾーン（デフォルト: "sb" - sandbox）
- `prefix`: リソース名プレフィックス（デフォルト: "example-07"）
- `server_password`: サーバールートユーザーのパスワード

### サーバー設定
- `server_count`: サーバー台数（デフォルト: 2、範囲: 1〜10）
- `server_os_type`: OS種別（デフォルト: "ubuntu"）
  - 対応OS: ubuntu, debian（cloud-init対応のみ）
- `server_core`: CPUコア数（デフォルト: 2）
  - 選択可能: 1, 2, 4, 8, 16, 32
- `server_memory`: メモリ容量GB（デフォルト: 4）
  - 選択可能: 1, 2, 4, 8, 16, 32, 64, 128
- `server_disk_size`: ディスク容量GB（デフォルト: 100、範囲: 20〜4000）
- `server_disk_plan`: ディスクプラン（デフォルト: "ssd"）

### ネットワーク設定
- `private_network_cidr`: プライベートネットワークCIDR（デフォルト: "192.168.1.0/24"）
- `vpn_ip_range_start`: VPN IPレンジ開始（デフォルト: 240）
- `vpn_ip_range_end`: VPN IPレンジ終了（デフォルト: 249）

### NFS・Samba設定
- `nfs_server_ip`: NFSサーバーIP（自動設定時は空文字）
- `nfs_export_path`: NFSエクスポートパス（デフォルト: "/export/shared"）
- `nfs_mount_point`: ローカルマウントポイント（デフォルト: "/mnt/shared"）
- `samba_workgroup`: Sambaワークグループ（デフォルト: "WORKGROUP"）
- `samba_server_string`: Sambaサーバー説明（デフォルト: "Samba Server"）

### VPN設定
- `vpn_pre_shared_secret`: VPN事前共有キー
- `vpn_username`: VPNユーザー名（デフォルト: "vpnuser"）
- `vpn_password`: VPNパスワード

### セキュリティ設定
- `admin_source_networks`: 管理アクセス許可ネットワークリスト（デフォルト: ["0.0.0.0/0"]）
- `vpn_router_plan`: VPNルータープラン（デフォルト: "standard"）

### WireGuard VPN設定
- `wireguard_enabled`: WireGuard有効/無効（デフォルト: true）
- `wireguard_port`: WireGuard UDPポート（デフォルト: 51820）
- `wireguard_server_private_key`: サーバー秘密鍵
- `wireguard_server_ip`: WireGuardサーバーIP（デフォルト: "192.168.100.1/24"）
- `wireguard_peers`: クライアント設定リスト

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

- `vpn_router_global_ip`: VPNルーターのパブリックIPアドレス
- `server_private_ips`: ファイルサーバーのプライベートIPアドレス一覧
- `nfs_server_ip`: NFSサーバーのIPアドレス
- `samba_share_path`: Sambaシェアパス（例: `//192.168.1.11/shared`）
- `vpn_l2tp_range`: VPN IPアドレス範囲
- `connection_info`: 詳細な接続情報

## 構成シナリオ

### シナリオ1: 小規模ファイルサーバー
```hcl
server_count = 1
server_os_type = "ubuntu"
server_core = 2
server_memory = 4
private_network_cidr = "192.168.1.0/24"
vpn_router_plan = "standard"
```

### シナリオ2: 冗長化ファイルサーバー
```hcl
server_count = 3
server_os_type = "ubuntu"
server_core = 4
server_memory = 8
server_disk_size = 200
private_network_cidr = "10.0.1.0/24"
vpn_router_plan = "premium"
```

### シナリオ3: 高性能ファイルサーバー
```hcl
server_count = 2
server_os_type = "debian"
server_core = 8
server_memory = 16
server_disk_size = 500
server_disk_plan = "ssd"
private_network_cidr = "172.16.0.0/24"
vpn_router_plan = "highspec"
```

## ネットワーク設計

### IPアドレス割り当て
- **VPNルーター**: ネットワークの .1（例: 192.168.1.1）
- **ファイルサーバー**: ネットワークの .11〜（例: 192.168.1.11〜）
- **NFSサーバー**: ネットワークの .21（例: 192.168.1.21）
- **VPN クライアント**: 指定範囲内（例: 192.168.1.240〜249）

### セキュリティ設計

#### パケットフィルタールール
- **ファイルサーバー**:
  - プライベートネットワーク: 全通信許可
  - その他: 全て拒否
- **VPNルーター**:
  - SSH(22): 指定IPリストからのみ
  - WireGuard(UDP): 指定IPリストからのみ
  - ICMP: 任意のIPから許可

#### アクセス制御
1. **インターネットアクセス**: VPNルーター経由のみ
2. **管理アクセス**: SSH・WireGuardは指定IPからのみ
3. **ファイルアクセス**: プライベートネットワーク内のみ
4. **VPN接続**: L2TP/IPSec + WireGuardの二重オプション

## Cloud-init自動セットアップ

### 自動インストールパッケージ
- nfs-common（NFSクライアント）
- samba（Sambaサーバー）
- samba-common-bin（Samba共通ツール）

### 自動設定内容
1. **NFSマウント**:
   - `/mnt/shared` ディレクトリ作成
   - `/etc/fstab` にNFSマウント設定追加
   - 自動マウント実行

2. **Samba設定**:
   - `/etc/samba/smb.conf` 自動生成
   - ゲストアクセス許可設定
   - `/mnt/shared` を `shared` として共有

3. **サービス起動**:
   - Sambaサービス（smbd、nmbd）の有効化・起動
   - ファイアウォール設定（ufw allow samba）

## ファイルアクセス方法

### NFS経由
```bash
# 各サーバーで自動マウント済み
ls -la /mnt/shared/
```

### Samba（SMB）経由
- **Windows**: `\\192.168.1.11\shared`
- **macOS**: `smb://192.168.1.11/shared`
- **Linux**: `smbclient //192.168.1.11/shared -N`

### VPN経由でのアクセス
VPN接続後、各サーバーのプライベートIPアドレスを使用してSambaシェアにアクセス可能。

## VPN接続設定

### L2TP/IPSec VPN
標準的なVPN接続方式。Windows・macOS・iOS・Androidで標準サポート。

### WireGuard VPN
現代的で高性能なVPN。専用クライアントアプリが必要。

## 運用・トラブルシューティング

### 日常運用
1. **ファイル共有監視**: NFS・Sambaサービスの稼働状況確認
2. **ストレージ監視**: NFSの容量使用率確認
3. **ネットワーク監視**: VPNルーター経由の通信状況確認
4. **バックアップ**: 共有ファイルの定期バックアップ

### よくある問題
1. **NFSマウントエラー**: NFSサーバーIPとエクスポート設定の確認
2. **Sambaアクセス不可**: サービス起動状況とファイアウォール設定の確認
3. **インターネット接続不可**: VPNルーターのNAT設定とルーティングの確認
4. **VPN接続不可**: 事前共有キー・認証情報・ファイアウォール設定の確認

### トラブルシューティングコマンド
```bash
# NFSマウント状況確認
df -h | grep nfs
mount | grep nfs

# Sambaサービス状況確認
systemctl status smbd nmbd
smbclient -L localhost -N

# ネットワーク接続確認（プライベートネットワーク内から）
ping 8.8.8.8  # VPNルーター経由でインターネット接続確認
```

## セキュリティのベストプラクティス

1. **ネットワーク分離**: サーバーは直接インターネットアクセス不可
2. **アクセス制限**: admin_source_networksを特定IPに限定
3. **VPN使用**: リモートアクセスは必ずVPN経由
4. **定期更新**: Cloud-initで自動パッケージ更新設定
5. **監視強化**: ファイルアクセスログの監視
6. **バックアップ**: 重要データの定期バックアップ

この構成により、セキュアで管理しやすいファイル共有環境を構築できます。VPNゲートウェイ構成により、サーバーのインターネットアクセスを制御しながら、柔軟なファイル共有機能を提供します。