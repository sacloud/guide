#cloud-config
package_update: true
package_upgrade: true

packages:
  - nfs-common
  - samba
  - samba-common-bin

write_files:
  - path: /etc/samba/smb.conf
    content: |
      [global]
      workgroup = ${samba_workgroup}
      server string = ${samba_server_string}
      security = user
      map to guest = Bad User
      dns proxy = no

      [shared]
      path = ${nfs_mount_point}
      browsable = yes
      writable = yes
      guest ok = yes
      read only = no
      create mask = 0777
      directory mask = 0777
      force user = nobody
      force group = nogroup
    permissions: '0644'

runcmd:
  - mkdir -p ${nfs_mount_point}
%{ if nfs_server_ip != "" ~}
  - echo "${nfs_server_ip}:${nfs_export_path} ${nfs_mount_point} nfs defaults 0 0" >> /etc/fstab
  - mount -a
%{ else ~}
  - echo "# NFS server IP not specified, skipping NFS mount" >> /etc/fstab
%{ endif ~}
  - systemctl enable smbd
  - systemctl start smbd
  - systemctl enable nmbd
  - systemctl start nmbd
  - ufw allow samba

final_message: "Cloud-init setup completed. NFS and Samba services are ready."