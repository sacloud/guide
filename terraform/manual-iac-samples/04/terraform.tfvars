# 基本設定
prefix = "example-07"
zone = "tk1b"  # ゾーン: is1a, is1b, is1c, tk1a, tk1b, tk1v
server_password = "YourSecurePassword123!"

# サーバー設定
server_count = 2          # サーバー台数: 1-10
server_os_type = "ubuntu" # OS: ubuntu, debian (cloud-init対応)
server_core = 2           # CPUコア数: 1, 2, 4, 8, 16, 32
server_memory = 4         # メモリ(GB): 1, 2, 4, 8, 16, 32, 64, 128
server_disk_size = 100    # ディスク容量(GB): 20-4000
server_disk_plan = "ssd"  # ディスクプラン: ssd, hdd

# ネットワーク設定
private_network_cidr = "192.168.1.0/24"  # プライベートネットワークCIDR
vpn_ip_range_start = 240  # VPN IPレンジ開始: 100-250
vpn_ip_range_end = 249    # VPN IPレンジ終了: 100-254

# NFS設定
nfs_server_ip = ""                    # 空文字時は自動設定 (192.168.1.21)
nfs_export_path = "/export/shared"    # NFSエクスポートパス
nfs_mount_point = "/mnt/shared"       # ローカルマウントポイント

# Samba設定
samba_workgroup = "WORKGROUP"         # Sambaワークグループ
samba_server_string = "File Server"   # Sambaサーバー説明

# VPN設定
vpn_pre_shared_secret = "YourVPNSecret789"
vpn_username = "vpnuser"
vpn_password = "VPNSecurePassword12!"

# セキュリティ設定
admin_source_networks = ["0.0.0.0/0"]  # 管理アクセス許可ネットワークリスト
vpn_router_plan = "standard"            # VPNルータープラン: standard, premium, highspec

# WireGuard VPN設定
wireguard_enabled = true
wireguard_port = 51820
wireguard_server_private_key = "mBjwUWWzpBRH6JziAHfx36EseAADwP4GlCLdyT2PrHI="
wireguard_server_ip = "192.168.100.1/24"
wireguard_peers = [
  {
    name       = "client1"
    public_key = "vevGBYIkmUnEh6vAZ1LOEGVy5qXxGvB1qLWm5EzEwmg="
    ip_address = "192.168.100.2"
  }
  # {
  #   name       = "client2"
  #   public_key = "CLIENT2_PUBLIC_KEY_HERE"
  #   ip_address = "192.168.100.3/32"
  # }
]

# 設定例:

# 小規模構成
# server_count = 1
# server_core = 2
# server_memory = 4
# vpc_router_plan = "standard"

# 冗長化構成
# server_count = 3
# server_os_type = "ubuntu"
# server_core = 4
# server_memory = 8
# server_disk_size = 200
# private_network_cidr = "10.0.1.0/24"
# vpc_router_plan = "premium"

# 高性能構成
# server_count = 2
# server_os_type = "debian"
# server_core = 8
# server_memory = 16
# server_disk_size = 500
# vpc_router_plan = "highspec"
# private_network_cidr = "172.16.0.0/24"

# セキュリティ強化構成
# admin_source_networks = ["203.0.113.0/24", "198.51.100.100/32"]
# wireguard_port = 443  # HTTPSポートに偽装
# private_network_cidr = "10.10.0.0/24"

# カスタムNFS構成
# nfs_server_ip = "192.168.1.100"        # 外部NFSサーバーを使用
# nfs_export_path = "/data/shared"       # カスタムエクスポートパス
# nfs_mount_point = "/opt/shared"        # カスタムマウントポイント

# カスタムSamba構成
# samba_workgroup = "MYCOMPANY"          # カスタムワークグループ
# samba_server_string = "Company File Server"  # カスタムサーバー説明

# WireGuardキー生成コマンド例:
# サーバー秘密鍵: wg genkey
# サーバー公開鍵: echo "SERVER_PRIVATE_KEY" | wg pubkey
# クライアント秘密鍵: wg genkey
# クライアント公開鍵: echo "CLIENT_PRIVATE_KEY" | wg pubkey

# VPCルータープラン仕様:
# standard: 標準プラン    - 月額  1,100円
# premium:  高性能プラン  - 月額  3,300円
# highspec: 最高性能プラン - 月額 11,000円

# 注意事項:
# - サーバーは直接インターネットアクセス不可（VPCルーター経由のみ）
# - NFSとSambaはcloud-initで自動セットアップ
# - Sambaシェアは //SERVER_IP/shared でアクセス可能
# - VPN接続後、プライベートネットワーク内のリソースにアクセス可能