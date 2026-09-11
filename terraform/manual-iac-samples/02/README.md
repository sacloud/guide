# さくらクラウド構成例 02 - オートスケール構成

このTerraform構成は、さくらクラウドのオートスケール機能とエンハンスドロードバランサーを使用した自動スケーリングWebアプリケーション環境を構築します。負荷に応じてサーバーの自動増減を行い、高可用性とコスト効率を両立します。

## 主な機能

- **オートスケール**: CPU使用率、ネットワーク使用量、スケジュールに基づく自動スケーリング
- **エンハンスドロードバランサー**: 高性能なL4/L7ロードバランサーによる負荷分散
- **柔軟なサーバー構成**: OS、CPU、メモリ、ディスクの自由な組み合わせ
- **ディスククローン対応**: 既存のディスクやアーカイブからのクローン作成
- **スケジュール運用**: 平日の業務時間に合わせた自動スケーリング

## インフラストラクチャ構成要素

### オートスケール
- **サーバー群**: 最小2台から自動増減（設定可能）
- **スケーリング条件**: CPU閾値、ルーター閾値、スケジュール
- **サーバースペック**: 1〜32コア、1〜128GBメモリ、20〜4000GBディスク

### ロードバランサー
- **エンハンスドLB**: standardまたはhighspecプラン
- **ヘルスチェック**: 設定可能な間隔でのリアルサーバー監視
- **リアルサーバー**: 複数サーバーの重み付け負荷分散

### サーバー仕様
- **初期サーバー**: OSまたはカスタムディスクを選択可能
- **オートスケールサーバー**: 初期サーバーのディスクまたはカスタムディスクからクローン作成
- **ディスク**: SSD/HDD選択可能

## 構成要素

### 初期サーバー
オートスケールのベースとなる初期サーバーを作成します。
- **OS選択**: `initial_server_archive_id`でOSアーカイブを指定
- **カスタムディスク**: `initial_server_disk_id`で既存ディスクを指定
- **注意**: どちらか一方の指定が必須です

### オートスケール
オートスケールで作成される全てのサーバーは**ディスククローン**によって作成されます。
- **初期サーバーからクローン**: デフォルトで初期サーバーのディスクをクローン
- **カスタムクローン元**: `clone_source_disk_id`または`clone_source_archive_id`で別のクローン元を指定可能

### 対応OS
- **Linux系**: Ubuntu、Debian、Rocky Linux、AlmaLinux、MIRACLE LINUX等
- **Windows Server**: Windows Server 2019/2022/2025
- **カスタムイメージ**: 独自に作成したディスク/アーカイブ

## スケーリング方式

### CPU閾値スケーリング
- **スケールアップ**: CPU使用率が設定値（デフォルト80%）を超過時
- **スケールダウン**: CPU使用率が設定値（デフォルト20%）を下回り時
- **監視間隔**: 5分間隔でのCPU使用率監視

### ネットワーク閾値スケーリング
- **スケールアップ**: ルーター通信量が設定値（デフォルト100Mbps）を超過時
- **スケールダウン**: ルーター通信量が設定値（デフォルト10Mbps）を下回り時

### スケジュールスケーリング
- **平日運用**: 月〜金曜日に自動スケーリング実行
- **スケールアップ**: 業務開始時刻（デフォルト8:00）
- **スケールダウン**: 業務終了時刻（デフォルト18:00）

## ディスククローン機能

### クローン元の指定方法
1. **既存ディスクからクローン**: `clone_source_disk_id`にディスクIDを指定
2. **既存アーカイブからクローン**: `clone_source_archive_id`にアーカイブIDを指定
3. **OS自動選択**: クローン元未指定時は`os_type`に基づき最新OSを使用

### 利用シーン
- **環境の統一**: 本番環境と同じ設定のサーバーを自動生成
- **カスタムイメージ**: アプリケーションがプリインストールされたイメージの使用
- **設定済み環境**: セキュリティ設定済みのベースイメージからの展開

## 前提条件

- Terraform >= 1.0
- さくらクラウド API キーの設定
- オートスケール用のAPIキーID
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

v3では、サーバーのパスワードは内部で `password_wo` と `password_wo_version` を使用して設定します。`server_password` 変数名は変更不要です。

## 設定オプション

### 変数

#### 基本設定
- `prefix`: リソース名プレフィックス（デフォルト: "example-03"）
- `zone`: 対象ゾーン（デフォルト: "is1b"）
- `server_password`: サーバールートユーザーのパスワード
- `api_key_id`: オートスケール操作用のAPIキーID

#### オートスケール設定
- `min_size`: 最小サーバー数（デフォルト: 2）
- `change_count`: スケール時の増減数（デフォルト: 1）

#### スケーリング閾値設定
- `cpu_threshold_scaling`: CPU閾値スケーリング有効化（デフォルト: true）
- `cpu_threshold_up`: スケールアップCPU閾値（デフォルト: 80）
- `cpu_threshold_down`: スケールダウンCPU閾値（デフォルト: 20）
- `router_threshold_scaling`: ルーター閾値スケーリング有効化（デフォルト: false）
- `router_threshold_up`: スケールアップルーター閾値（デフォルト: 100）
- `router_threshold_down`: スケールダウンルーター閾値（デフォルト: 10）

#### スケジュール設定
- `scale_up_hour`: スケールアップ時刻（時）（デフォルト: 8）
- `scale_up_minute`: スケールアップ時刻（分）（デフォルト: 0）
- `scale_down_hour`: スケールダウン時刻（時）（デフォルト: 18）
- `scale_down_minute`: スケールダウン時刻（分）（デフォルト: 0）

#### サーバースペック設定
- `server_core`: CPUコア数（デフォルト: 2）
- `server_memory`: メモリ容量GB（デフォルト: 2）
- `server_disk_size`: ディスク容量GB（デフォルト: 100）
- `server_disk_plan`: ディスクプラン（デフォルト: "ssd"）

#### 初期サーバー設定（必須）
- `initial_server_disk_id`: 初期サーバー用の既存ディスクID
- `initial_server_archive_id`: 初期サーバー用のOSアーカイブID
- **注意**: いずれか一方の指定が必須です

#### オートスケールクローン設定（オプション）
- `clone_source_disk_id`: オートスケール用の元ディスクID（未指定時は初期サーバーのディスクを使用）
- `clone_source_archive_id`: オートスケール用の元アーカイブID

#### エンハンスドロードバランサー設定
- `elb_plan`: ELBプラン（デフォルト: "standard"）
- `elb_vip_port`: 仮想IPポート（デフォルト: 80）
- `elb_delay_loop`: ヘルスチェック間隔（デフォルト: 10）
- `elb_sorry_server`: ソーリーサーバーIP（オプション）
- `elb_real_servers`: リアルサーバー設定リスト

## 設定シナリオ

### シナリオ1: 標準的なWebアプリケーション構成
```hcl
prefix = "web-app"
zone = "tk1a"
min_size = 2
cpu_threshold_up = 70
cpu_threshold_down = 30
```

### シナリオ2: 高性能サーバー構成
```hcl
prefix = "high-perf"
zone = "tk1a"
server_core = 8
server_memory = 16
server_disk_size = 500
elb_plan = "highspec"
```

### シナリオ3: Ubuntuクローン構成
```hcl
prefix = "ubuntu-app"
zone = "is1a"
clone_source_archive_id = "archive-ubuntu-xxxxxxxx"
server_core = 4
server_memory = 8
server_disk_size = 200
```

### シナリオ4: カスタムイメージ利用構成
```hcl
prefix = "custom-app"
zone = "tk1a"
clone_source_archive_id = "archive-xxxxxxxx"
server_core = 4
server_memory = 8
min_size = 3
change_count = 2
```

### シナリオ5: ネットワーク閾値スケーリング構成
```hcl
prefix = "network-scale"
zone = "tk1v"
cpu_threshold_scaling = false
router_threshold_scaling = true
router_threshold_up = 200
router_threshold_down = 50
```

## 使用方法

1. サンプル変数ファイルをコピー:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. `terraform.tfvars` を編集して設定:
   - APIキーIDの設定
   - サーバーパスワードの設定
   - スケーリング設定の調整
   - サーバースペックの設定
   - ロードバランサー設定の調整

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

## オートスケール運用

### 監視とスケーリング
1. **監視開始**: デプロイ完了後、自動的に監視開始
2. **スケールアップ**: 閾値超過時に自動でサーバー追加
3. **ロードバランサー連携**: 新サーバーの自動登録
4. **スケールダウン**: 閾値下回り時に自動でサーバー削除

### 運用のベストプラクティス
1. **段階的スケーリング**: change_countを小さく設定して急激な変化を避ける
2. **閾値の調整**: 実際の負荷パターンに合わせた閾値設定
3. **スケジュール活用**: 予測可能な負荷パターンでのコスト最適化
4. **監視強化**: CloudWatchやZabbix等での詳細監視

## 出力値

- `initial_server_ip`: 初期サーバーのIPアドレス
- `initial_server_disk_id`: 初期サーバーのディスクID（オートスケールクローン用）
- `autoscale_group_id`: オートスケールグループのID
- `load_balancer_ip`: エンハンスドロードバランサーのIPアドレス


## 重要な注意事項

- **APIキー管理**: オートスケール用APIキーは適切なアクセス権限に制限してください
- **スケーリング頻度**: 頻繁なスケーリングによるコスト増加に注意してください
- **ディスククローン**: クローン元のディスク/アーカイブは削除しないでください
- **ネットワーク設計**: shared接続のため、プライベートネットワークは使用できません
- **Windows License**: Windows Serverには別途ライセンス費用が発生します
- **監視設定**: アプリケーションレベルでの詳細監視を別途設定してください

## トラブルシューティング

### スケーリングが動作しない
1. APIキーIDの確認
2. 閾値設定の確認
3. サーバーリソース制限の確認

### ロードバランサーエラー
1. リアルサーバーIPアドレスの確認
2. ヘルスチェック設定の確認
3. サーバーのポート開放状況確認

### ディスククローンエラー
1. クローン元ディスク/アーカイブの存在確認
2. ディスク容量の確認
3. アクセス権限の確認

この構成により、負荷に応じて自動的にスケールするWebアプリケーション環境を構築できます。コスト効率と可用性を両立した運用が可能です。