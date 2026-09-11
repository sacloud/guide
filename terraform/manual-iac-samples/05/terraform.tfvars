# 基本設定
prefix = "example-08"
monitoring_zone = "is1c"  # 監視ゾーンリージョン: is1a, is1b, is1c, tk1a, tk1b, tk1v
business_zone = "tk1b"    # 業務ゾーンリージョン: is1a, is1b, is1c, tk1a, tk1b, tk1v

# セキュリティ設定
server_password = "YourSecurePassword123"

# データベース設定
db_username = "dbuser"
db_password = "DatabasePassword456"

# VPN設定（監視ゾーン）
vpn_pre_shared_secret = "VPNSecret789"
vpn_username = "vpnuser"
vpn_password = "VPNPassword123!"

# リージョン構成例:

# 石狩-東京構成（デフォルト）
# monitoring_zone = "is1a"  # 石狩第1ゾーン
# business_zone = "tk1a"    # 東京第1ゾーン

# 東京-石狩構成
# monitoring_zone = "tk1a"  # 東京第1ゾーン
# business_zone = "is1a"    # 石狩第1ゾーン

# 東京内冗長構成
# monitoring_zone = "tk1a"  # 東京第1ゾーン
# business_zone = "tk1b"    # 東京第2ゾーン

# 石狩内冗長構成
# monitoring_zone = "is1a"  # 石狩第1ゾーン
# business_zone = "is1b"    # 石狩第2ゾーン

# セキュリティ構成の特徴:
# - 監視ゾーン: VPN集約拠点、監視サーバーはプライベートのみ
# - 業務ゾーン: UTMがインターネットゲートウェイ、他サーバーはプライベートのみ
# - ブリッジ接続: リージョン間セキュアプライベート通信
# - データベース: 完全プライベート（インターネットアクセス不可）

# 推奨構成:
# 1. 地理的冗長性: is1a + tk1a （異なるリージョン）
# 2. 東京集約: tk1a + tk1b （東京内冗長）
# 3. 石狩集約: is1a + is1b （石狩内冗長）

# 注意事項:
# - 同一ゾーン構成（monitoring_zone = business_zone）は推奨しません
# - ブリッジ接続により異なるゾーン間での高速プライベート通信が可能
# - VPNは監視ゾーンに集約され、ブリッジ経由で業務ゾーンアクセス可能