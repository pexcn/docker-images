# qBittorrent

## 前置条件

本容器使用 macvlan 驱动，需要提前开启网卡的混杂模式

## 非通用选项

以下选项需要根据环境适当地进行调整，配置文件位于 `qbittorrent-data/config/qBittorrent/qBittorrent.conf`

```ini
[Application]
MemoryWorkingSetLimit=<内存限制 (MB)>

[BitTorrent]
Session\Port=<端口号>
Session\AsyncIOThreadsCount=<CPU 核心数 * 4>
```
