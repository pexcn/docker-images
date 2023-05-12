# RustDesk Server

### 内核优化

```sh
echo "net.core.rmem_max=8388608" > /etc/sysctl.d/90-rustdesk_server.conf
sysctl -p /etc/sysctl.d/90-rustdesk_server.conf
```
