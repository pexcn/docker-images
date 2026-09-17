# VoHive 深度使用攻略：VoHive / 高通 410 / Debian / EC20 / DJI 4G / eSIM / VoWiFi

> **资料来源**：用户提供的 Telegram 群“移远EC20,大疆,高通410折腾群”导出记录。  
> **覆盖时间**：2026-02-07 ～ 2026-07-04。  
> **原始规模**：93,213 条消息，其中约 84,330 条为文字消息。  
> **整理原则**：优先采用 VoHive 官方频道消息；其次采用多名群友重复验证的经验；单人报告、转述、AI 生成内容均明确标为“个例/待验证”。  
> **重要说明**：本文是对群聊经验的深度蒸馏，不等于厂商文档。下面涉及刷机、9008、QCN、USB ID、AT 指令、固件升级等操作，我没有在你的具体硬件上逐条实测；执行前务必确认型号并做好可恢复备份。

---

## 目录

- [1. 先看结论：怎么选硬件和部署方式](#1-先看结论怎么选硬件和部署方式)
- [2. VoHive 到底是什么](#2-vohive-到底是什么)
- [3. 群聊证据等级与“不要照抄”的原则](#3-群聊证据等级与不要照抄的原则)
- [4. VoHive 功能全景](#4-vohive-功能全景)
- [5. 版本演进与已知版本坑](#5-版本演进与已知版本坑)
- [6. 标准 Linux + EC20/EC25：最稳的基线方案](#6-标准-linux--ec20ec25最稳的基线方案)
- [7. Docker / Docker Compose 部署](#7-docker--docker-compose-部署)
- [8. OpenWrt / TR3000 运行 VoHive](#8-openwrt--tr3000-运行-vohive)
- [9. EC20 深度攻略](#9-ec20-深度攻略)
- [10. 高通 410 棒子：从 Android 到 Debian](#10-高通-410-棒子从-android-到-debian)
- [11. 410 各板型/型号差异](#11-410-各板型型号差异)
- [12. 410 Debian 运行 VoHive 的正确思路](#12-410-debian-运行-vohive-的正确思路)
- [13. DJI 4G 一代模块攻略](#13-dji-4g-一代模块攻略)
- [14. eSIM / eUICC 深度攻略](#14-esim--euicc-深度攻略)
- [15. VoWiFi 深度攻略](#15-vowifi-深度攻略)
- [16. SMS / VoLTE / USSD / Bot](#16-sms--volte--ussd--bot)
- [17. 多模组、USB Hub、供电和拓扑](#17-多模组usb-hub供电和拓扑)
- [18. 故障排查总流程](#18-故障排查总流程)
- [19. 升级、回滚与备份策略](#19-升级回滚与备份策略)
- [20. 常用命令速查表](#20-常用命令速查表)
- [21. 群聊中出现的周边工具与资料](#21-群聊中出现的周边工具与资料)
- [22. 关键消息索引](#22-关键消息索引)
- [23. 最后给折腾者的 30 条 Tips](#23-最后给折腾者的-30-条-tips)

---

# 1. 先看结论：怎么选硬件和部署方式

如果只想快速得到一个可工作的 VoHive 环境，群聊中的经验可以压缩成下面这张表。

| 方案 | 推荐程度 | 优点 | 缺点/风险 | 最适合 |
|---|---|---|---|---|
| **EC20/EC25 + Debian/Ubuntu 主机** | **最高，作为基线** | 官方教程最完整；USB/QMI 路径成熟；故障最容易定位；多模组方便 | 需要额外主机、USB 底板和供电 | 想稳定收短信、切 eSIM、跑 VoWiFi、多卡 |
| **EC20/EC25 + NAS/Docker** | 很高 | 与现有 NAS 集成方便；持久运行容易 | Docker 不能替你解决宿主机驱动/ModemManager 抢口 | 已有 Linux NAS/小主机 |
| **OpenWrt/TR3000 + EC20/EC25** | 中高 | 路由器一体化；体积小 | 官方一键脚本常不认 OpenWrt；依赖/内核模块需自己补 | 熟悉 OpenWrt、追求一体化 |
| **高通 410 棒子刷 Debian，使用自身基带** | 中等，适合折腾 | 极低成本、真正一体化，不需额外 EC20 | 板型混乱；刷机、SIM 通路、QCN/基带、aboot 都可能踩坑；恢复难度大 | 想把一根棒子做成完整 VoHive 节点 |
| **410 Debian + 外接 EC20** | 中高 | 410 做小 Linux 主机；可拖多模组 | USB 供电、Hub、系统稳定性仍需处理 | 极低成本多模组主机 |
| **DJI 4G 一代 + Linux 主机** | 中高 | EG25-G 核心，成品外壳好，二手便宜 | 默认 VID/PID 非通用，需先改 USB ID；供电要好 | 想买便宜、完整外壳的 LTE 模组 |

### 推荐路线

**第一次接触 VoHive：**

1. 先用正常 x86_64/arm64 Debian 或 Ubuntu；
2. 接一块确认正常的 EC20CEFAG / EC20CEFHLG；
3. 先让 Linux 独立识别串口、QMI、SIM；
4. 再装 VoHive；
5. 最后再上 eSIM、VoWiFi、代理、Bot；
6. 等整个流程理解后，再折腾 410。

这是群聊里大量问题归纳后最能减少变量的做法。

### 三条最重要的原则

1. **410 先备份，后开机折腾。** 群友反复强调“到手第一件事就是 9008 全盘备份”。[群聊 #24492, 2026-05-29]
2. **不要看外壳判断 410 板型。** 同型号、同外壳甚至同名称，内部基带、SIM 切换方式、设备树都可能不同。
3. **不要把普通 USB EC20 的 ModemManager 规则机械套到 410。** 标准 EC20 主机环境通常应禁用 ModemManager；部分 410 Debian 镜像却依赖 ModemManager 或自己的 `qmi-auto-activate` 类服务维持自身基带。[官方 #12029；群聊 #21809/#21813]

---

# 2. VoHive 到底是什么

从群聊和官方频道历史功能看，VoHive 可以理解成一个面向蜂窝模组的统一管理服务，核心不是“拨号上网”本身，而是把模组能力组织成一个可长期运行的服务层。

它主要围绕以下几类能力工作：

- USB / QMI / AT 模组发现；
- SIM 身份读取：IMEI、ICCID、IMSI、运营商注册状态等；
- SMS 收发；
- USSD；
- eSIM/eUICC Profile 枚举、切换等；
- 蜂窝网络连接和 IP 管理；
- VoWiFi / IMS 相关能力；
- Web 管理界面；
- Telegram / 飞书等通知和机器人命令；
- 多设备管理；
- 某些版本中的代理/流量相关能力。

### 闭源状态应该怎么理解

你说 VoHive 是闭源软件，这与群聊末期的实际讨论基本一致。

2026-06-30 前后群里曾出现 `https://github.com/iniwex5/vohive` 源码仓库，但随后多名群友指出：

- 构建时依赖私有的 `vowifi-go`；[群聊 #85862]
- “群主没完全开源”；[群聊 #91723]
- “核心部分没有开源，后续维护重度依赖作者”。[群聊 #98586]

因此，更实际的使用心态是：

> **把 VoHive 当作一个需要谨慎锁版本、保留二进制和配置备份的闭源/半闭源服务，而不是一个可以随时从源码重建的普通开源项目。**

这会直接影响升级策略，详见后文。

---

# 3. 群聊证据等级与“不要照抄”的原则

本文采用以下等级：

| 等级 | 含义 | 使用方式 |
|---|---|---|
| **A：官方消息** | `VoHive频道` 发布的教程、版本说明、命令 | 优先采用，但仍注意版本时效 |
| **B：多名用户重复验证** | 不同用户在不同时间报告一致行为 | 可以作为高可信经验 |
| **C：单个用户实测** | 有日志/命令，但只出现一次或少量 | 作为排障方向，不能当硬件规格 |
| **D：转述/宣传/AI生成** | 二手描述、商品宣传、AI 输出 | 只作为线索，不当事实 |

### 为什么群聊攻略不能简单“搜关键词复制”

群里有几种特别常见的误导源：

- 不同 EC20 SKU 被混为一谈；
- 410“同一个型号”其实来自不同工厂、不同 PCB revision；
- 命令里的 `/dev/ttyUSB2` 只是某台机器的 AT 口；
- 某个固件适合 UFI003，不代表 UFI001C/QRZL903 可刷；
- 某版本的 VoHive 有回归，最新不一定最好；
- “恢复出厂”“切 MBN”“擦基带”这种命令被当成万能修复；
- eSIM 的失败可能在卡、基带、QMI-UIM、内核、VoHive 五个不同层级。

所以本文所有高风险步骤都会先告诉你“要验证什么”，再给命令。

---

# 4. VoHive 功能全景

## 4.1 Web 管理

官方部署示例默认 Web 端口为：

```text
7575
```

访问：

```text
http://<主机IP>:7575
```

官方不同时期消息里默认密码存在冲突：

- 2026-04-15 示例配置是 `admin / admin123`；[官方 #12029]
- 2026-06-26 DJI 教程写的是 `admin / admin`。[官方 #64152]

因此不要把任何默认密码当成固定事实。

**正确做法：**

- 看你正在使用的 `config.yaml`；
- 看安装脚本完成时的提示；
- 首次登录后立即改密码；
- 若 Web 暴露公网，务必用反代、访问控制或 VPN，而不是直接暴露 7575。

## 4.2 Telegram Bot

官方 2026-04-21 的命令列表：[官方 #12711]

```text
/list                         查看设备列表
/status 设备ID                查看设备状态
/sms 设备ID                   查看最近短信
/send 设备ID 号码 内容         发送短信
/rotate 设备ID                切换 IP
/esim 设备ID                  查看 eSIM profile
/switch 设备ID 序号或 ICCID    切换 eSIM profile
/vocall 设备ID 号码            发起 VoWiFi 模拟呼叫
```

早期列表没有 `/status`，说明 Bot 命令也随版本变化。[官方 #5903]

### Tips

- 设备 ID 比名称可靠；重命名后先 `/list` 确认；
- `/switch` 后不要立刻连续发命令，给 SIM/eUICC、基带和运营商注册留时间；
- `/vocall` 官方明确写的是“模拟呼叫”，不要把它理解成一个完整 SIP 软电话。

## 4.3 VoWiFi

历史版本中，VoHive 自己处理了相当完整的 VoWiFi 链路：

```text
SIM/USIM
  ↓
ePDG 域名发现 / DNS
  ↓
IKEv2 SA_INIT
  ↓
IKE_AUTH + EAP-AKA / AKA'
  ↓
IPsec/XFRM 或 TUN
  ↓
P-CSCF
  ↓
SIP REGISTER
  ↓
IMS keepalive / signaling
```

这也是为什么 VoWiFi 出错时不能只看最后一行日志。

## 4.4 eSIM/eUICC

VoHive 并不是通过 Android LPA，而是借助蜂窝模组的 SIM/UIM/APDU/QMI 能力接触 eUICC。因此：

- 手机能读 eSIM 卡 ≠ VoHive 必定能读；
- iPhone 能切 profile ≠ EC20/410 基带一定能开 logical channel；
- eUICC 被识别 ≠ 所有 profile 都兼容。

群里有真实案例：同一张“实体 eSIM 白卡”在 Android/iPhone 正常，但 VoHive 无法识别 eUICC。[群聊 #16232]

---

# 5. 版本演进与已知版本坑

下面不是完整 changelog，而是对实际使用影响最大的节点。

## 5.1 早期 VoWiFi 阶段

| 版本 | 群聊/官方关键信息 |
|---|---|
| v0.1.7 | USSD 终端、eSIM PKI 文件、重连优化 |
| v0.1.8 | 通知重构、飞书 Bot、VoWiFi 本机号码、eSIM 切换优化 |
| v0.1.9 | ePDG 国家匹配 |
| v0.1.10 | SA_INIT、SIP folded header、更多 DH group |
| v0.1.11 | IKEv2 payload/加密/EAP 类型优化 |
| v0.1.12 | 更多算法、VoWiFi 优化 |
| v0.1.19 | VoWiFi 运行状态；XFRM 失败回落 TUN；AKA' 失败重试；IMS keepalive [官方 #1319] |
| v0.1.23 | USB 探测改进；支持非 QMI 模式；VoWiFi 修复 [官方 #2186] |
| v0.1.24 | VoWiFi ePDG auth、P-CSCF IPv4 等 |
| v0.1.27 | 基于设备模型生成 IMEI/UA；VoWiFi 注册 [官方 #2473] |
| v0.2.2 | VoWiFi 内部重构；移除内置 sing-box，换轻量 HTTP/SOCKS5 [官方 #2613] |

## 5.2 410 支持

官方 2026-05-20 发布 v1.1.0 时明确写了：[官方 #16677]

> 兼容高通410 wifi棒子裸机运行（使用自身的模块能力，需刷 Debian 系统）

这是 410 玩法的关键节点。

## 5.3 群聊中出现的版本回归/个例

这些属于 **C 级证据：单用户或少量用户报告**，但非常值得在升级前留意：

| 版本/平台 | 报告 |
|---|---|
| v1.1.7 → v1.1.10 arm64 | 有用户称 1.1.7 能完整识别，1.1.10 只剩 IMEI |
| v1.2.5 | 有用户报告偶发短信乱码 |
| v1.3.5 | 有用户称短信异常，回退 1.3.4 正常 |
| **v1.3.8 ARMv7** | 有完整日志显示启用 SOCKS5 VoWiFi 后 `panic: unaligned 64-bit atomic operation`，堆栈在 `swu-go/pkg/ipsec` [#48218] |
| v1.5.4 | 有用户报告 Telegram `/list` 不回复 |
| 归档末期 | 群里出现 v1.5.5 以及类似 `v1.5.5-10-gf9eb85d` 的开发构建 |

### 正确升级方式

**不要使用“latest 永远自动追新”的思路。**

建议：

1. 记下当前 VoHive 版本；
2. 备份二进制；
3. 备份完整 `config/`、`data/`；
4. 记下当前设备、eSIM、VoWiFi 的工作状态；
5. 升级后逐项验证：设备发现 → SIM → SMS → eSIM → VoWiFi；
6. 有回归就直接回退，不要先修改几十个系统参数。

---

# 6. 标准 Linux + EC20/EC25：最稳的基线方案

这是官方教程最明确的部署方式。[官方 #12029]

## 6.1 官方推荐硬件

官方点名：

- `EC20CEFHLG`
- `EC20CEFAG`

要求：

- 模组本身/底板能接 SIM；
- Linux 主机有稳定 USB；
- 使用合适的 LTE 天线；
- 多模组时最好使用独立供电 Hub。

## 6.2 第一步不是安装 VoHive，而是确认 Linux 看得到模组

```bash
lsusb
ls /dev/ttyUSB* 2>/dev/null
ls /dev/cdc-wdm* 2>/dev/null
ip link | grep -Ei 'wwan|usb'
```

再看内核：

```bash
dmesg -T | grep -Ei 'qmi|wwan|option|usb|cdc-wdm|Quectel'
```

你至少要弄清：

- USB VID/PID 是什么；
- AT 口是哪一个；
- 是否出现 QMI control device（通常 `/dev/cdc-wdmX`）；
- netdev 是否出现（通常 `wwanX`）。

## 6.3 禁用 ModemManager：标准 EC20 主机上的大坑

官方强调这是重要步骤：ModemManager 会主动探测并抢占 `/dev/ttyUSB*`，可能让 VoHive 的 AT、短信、设备初始化变得随机。[官方 #12029]

```bash
systemctl status ModemManager

sudo systemctl stop ModemManager
sudo systemctl disable ModemManager
sudo systemctl mask ModemManager

systemctl status ModemManager
```

**注意：即便 VoHive 跑在 Docker 中，也要在宿主机处理。**

> 例外：410 自带基带的社区 Debian 镜像，后文另说。不要机械照搬。

## 6.4 确认 AT 口，不要盲信 ttyUSB2

官方教程中的 `/dev/ttyUSB2` 只是例子。

建议扫描：

```bash
for p in /dev/ttyUSB*; do
  echo "==== $p ===="
  timeout 2 socat - "$p",crnl <<< 'ATI' 2>/dev/null
  echo
 done
```

如果 `ATI` 返回 Quectel/型号信息，该口可用于 AT。

## 6.5 切 QMI 模式

官方建议在模式不正确时：

```bash
sudo apt update
sudo apt install -y socat libqmi-utils

echo 'AT+QCFG="usbnet",0;+CFUN=1,1' | sudo socat - /dev/ttyUSB2,crnl
```

其中：

```text
AT+QCFG="usbnet",0   → QMI 模式
AT+CFUN=1,1           → 模组重启
```

重启后再次确认：

```bash
lsusb
ls /dev/cdc-wdm*
ip link
```

## 6.6 官方一键安装

历史官方命令：

```bash
wget -O - https://raw.githubusercontent.com/iniwex5/vohive-release/master/install.sh | sh
```

指定版本：

```bash
wget -O - https://raw.githubusercontent.com/iniwex5/vohive-release/master/install.sh \
  | sh -s -- --version v1.5.3
```

仅二进制、不安装 systemd：

```bash
wget -O - https://raw.githubusercontent.com/iniwex5/vohive-release/master/install.sh \
  | sh -s -- --no-systemd
```

卸载：

```bash
wget -O - https://raw.githubusercontent.com/iniwex5/vohive-release/master/uninstall.sh | sh
```

历史默认路径：

```text
/opt/vohive/bin/vohive
/opt/vohive/config/config.yaml
/opt/vohive/data
/opt/vohive/logs
```

> 上述 GitHub 链接是群聊历史资源，本文没有联网验证当前是否仍然存在。

---

# 7. Docker / Docker Compose 部署

官方示例：[官方 #12029]

## 7.1 目录

```bash
mkdir -p vohive/{config,data,logs}
cd vohive
```

## 7.2 配置

`config/config.yaml`：

```yaml
server:
  port: 7575
  debug: false

web:
  username: admin
  password: admin123
```

建议你马上把密码换掉。

## 7.3 Compose

```yaml
services:
  vohive:
    image: iniwex/vohive:latest
    container_name: vohive
    restart: unless-stopped
    network_mode: host
    privileged: true
    volumes:
      - ./config:/app/config
      - ./data:/app/data
      - ./logs:/app/logs
    environment:
      - TZ=Asia/Shanghai
      - CONFIG_PATH=/app/config/config.yaml
    devices:
      - /dev:/dev
```

启动：

```bash
docker compose up -d
```

日志：

```bash
docker logs -f vohive
```

筛关键字：

```bash
docker logs vohive --tail=300 2>&1 \
  | grep -iE 'qmi|dms|uim|nas|sim|ims|sip|vowifi|epdg|ready|failed|error|timeout|cdc-wdm|wwan|config'
```

## 7.4 为什么需要 privileged / host network / /dev

VoHive 不只是读一个串口，它可能需要：

- 控制 ttyUSB；
- 访问 QMI control device；
- 改/读 netdev；
- 操作 IPsec/XFRM/TUN；
- 访问 USB/sysfs 状态。

因此官方直接用了：

```yaml
privileged: true
network_mode: host
/dev:/dev
```

这是为了降低设备访问阻碍，而不是普通 Web 应用的最小权限范例。

## 7.5 Docker 常见坑

### 坑 1：宿主 ModemManager 还在抢口

Docker `privileged` 也不能让两个进程同时可靠接管同一个 AT/QMI 资源。

### 坑 2：容器里没有 bash

群里有人直接：

```bash
docker exec -it vohive /bin/bash
```

失败，因为镜像可能只有 `sh`。

改用：

```bash
docker exec -it vohive sh
```

### 坑 3：USB 拔插后设备“恢复中”

尤其大疆 + 某些 eSIM 卡有群友报告 Docker 重启或 USB 拔插后需要重新初始化。[#99423]

排查顺序：

1. 宿主 `lsusb` 是否正常；
2. `/dev/ttyUSB*` 是否重新出现；
3. `/dev/cdc-wdm*` 是否存在；
4. `ip link` 是否有 wwan；
5. 再重启 VoHive 容器。

不要一上来就在 Web 页面反复删除/添加设备。

---

# 8. OpenWrt / TR3000 运行 VoHive

## 8.1 一键脚本并不一定支持 OpenWrt

群里多次看到：

```text
[vohive-install] 错误: 不支持的系统: Linlx
```

例如 #86705。

所以 OpenWrt 更可靠的思路是：

- 自己准备对应架构的 VoHive 二进制；
- 自己建目录；
- 自己写 `procd` 服务；
- 把内核模块和用户态工具补齐。

## 8.2 社区常用目录布局

```bash
mkdir -p /vohive/bin /vohive/config /vohive/data /vohive/logs
```

也有人把二进制直接放 `/vohive/vohive`，关键不是路径本身，而是启动脚本保持一致。

示例：

```yaml
server:
  host: 0.0.0.0
  port: 7575

web:
  username: admin
  password: <请改成强密码>

data:
  path: /vohive/data

log:
  level: info
  path: /vohive/logs
```

测试前台运行：

```bash
/vohive/vohive -c /vohive/config/config.yaml
```

## 8.3 procd 示例

`/etc/init.d/vohive`：

```sh
#!/bin/sh /etc/rc.common

START=99
STOP=10
USE_PROCD=1

start_service() {
    mkdir -p /vohive/logs /vohive/data

    procd_open_instance
    procd_set_param command /vohive/vohive -c /vohive/config/config.yaml
    procd_set_param respawn 3600 5 5
    procd_set_param stdout 1
    procd_set_param stderr 1
    procd_close_instance
}
```

然后：

```bash
chmod +x /etc/init.d/vohive
/etc/init.d/vohive enable
/etc/init.d/vohive restart
logread -f | grep -i vohive
```

## 8.4 TR3000 群友整理的依赖

[#62262]

```bash
opkg update
opkg install kmod-ipsec kmod-ipsec4 kmod-ipsec6 kmod-crypto-authenc

opkg install kmod-usb-net-qmi-wwan kmod-usb-wdm \
  kmod-usb-serial-option kmod-usb-serial-qualcomm

opkg update -V2
opkg install socat sudo coreutils-timeout
```

### 社区定制固件

群里分享过 Cudy TR3000 的 ImmortalWrt 定制固件，说明中集成了 QMI/MBIM/NCM/RNDIS/USB serial/WWAN/QRTR/MHI 等：[群聊 #48204]

```text
https://github.com/asrtroh-netizen/immortalwrt-mt7981-cudy-tr3000/releases/tag/ImmortalWrt-20260619-0533
```

这是**群友第三方固件**，不是 VoHive 官方或 Cudy 官方。刷之前按路由器固件的正常风险等级处理。

---

# 9. EC20 深度攻略

## 9.1 EC20 在 VoHive 体系里的角色

从群聊看，EC20 的优势不是“最快”，而是：

- Linux 驱动成熟；
- AT/QMI 文档和经验多；
- USB 底板便宜；
- SIM/eSIM/短信场景成熟；
- 故障容易拆层定位；
- 能多块并行。

所以它非常适合做“标准参考设备”。

## 9.2 型号怎么选

官方直接推荐：

- `EC20CEFAG`
- `EC20CEFHLG`

群聊 #89587 还转发过一份 SKU 差异表。**这份表属于群友整理，不是官方规格书**，但可帮助理解后缀差异：

| 型号 | 群聊描述摘要 |
|---|---|
| EC20CEHC | 三网，纯数据 |
| EC20CEFAG | 三网；语音；短信；GPS/北斗；二次开发；分集 |
| CEFDG | 语音；可外接 Wi-Fi；无 GPS/北斗/分集 |
| CEFDKG | 数据型；无 GPS/语音/Wi-Fi/分集 |
| CEFHKG | 数据型；有分集 |
| CEFILG | GPS + 语音；无 Wi-Fi/分集 |
| CEFDLG | 语音 + Wi-Fi；无 GPS/分集 |
| CEFHLG | 数据/短信方向；分集；群里称“免驱版本” |

另外还有 MiniPCIe 的 `-C`、`-CB`、`-AUD` 等变种。

**选购原则：**

1. 不要只看“EC20”三个字；
2. 拍清完整丝印；
3. 让卖家提供 `ATI` / `AT+QGMR`；
4. 若要语音/VoLTE，确认 SKU 本身具备相关能力；
5. 若只做短信/eSIM，数据型未必不能用，但不要自行假定每个 SKU 都支持相同 QMI-UIM 行为。

## 9.3 USB 底板与 SIM 槽

裸 EC20 本身不是“USB 棒子”。它需要：

- MiniPCIe-to-USB/专用底板；
- SIM 卡槽；
- 稳定电源；
- 天线。

群里也有人买到模块后才发现“模块本身没有 USB”，这是很典型的采购误区。

## 9.4 天线

至少使用适配 LTE 频段的蜂窝天线。

- `MAIN` 是主天线；
- 支持 diversity 的型号可以接 `DIV`；
- 不要因为接口一样，就用 Wi-Fi 2.4/5 GHz 天线当 LTE 天线长期使用。

如果短信/驻网经常不稳定，先排除信号和天线，再改软件。

## 9.5 固件：R06 / R08 / QFlash

群聊 2026-04-01 有人指出 `EC20CEFAGR08A03M4G` 为当时常用的新版本；更重要的是其转述的版本变更规则：[群聊 #4412]

- R06 的 V06xx → R08 的 V08xx：可使用 **QFlash**；
- V06xx ↔ V08xx：**不支持 DFOTA 跨基线升级**。

因此：

> **跨大基线不要把 DFOTA 当万能升级方式。**

升级前至少记录：

```text
ATI
AT+QGMR
AT+QCFG="usbnet"
AT+QCFG="ims"
AT+QMBNCFG="List"
```

群里提到的 `Quectel_QFlash_用户指导_V1.4.pdf` 可以作为工具操作依据，但本文没有从导出包中拿到这份 PDF 本体。

## 9.6 QMI 模式

官方命令：

```text
AT+QCFG="usbnet",0
AT+CFUN=1,1
```

在 Linux：

```bash
echo 'AT+QCFG="usbnet",0;+CFUN=1,1' | socat - /dev/ttyUSB2,crnl
```

重启后看：

```bash
ls /dev/cdc-wdm*
ip link | grep wwan
```

## 9.7 MBN：不要把“手选 profile”当常规步骤

群聊出现过：

```text
AT+QMBNCFG="AutoSel",0
AT+QMBNCFG="select","ROW_Generic_3GPP"
```

[#14637]

也有电信 VoLTE 方向：

```text
AT+QMBNCFG="AutoSel",0
AT+QMBNCFG="Deactivate"
AT+QMBNCFG="select","VoLTE_OPNMKT_CT"
```

[#14676]

**风险：** MBN 决定运营商相关 IMS/网络参数。选错可能导致：

- 注册异常；
- VoLTE 消失；
- 漫游异常；
- SMS 行为改变。

建议顺序：

1. `AT+QMBNCFG="List"` 记录现状；
2. 先用 AutoSel；
3. 只有明确知道运营商需要哪个 MBN 时再手选；
4. 一次只改一个变量；
5. 记录切换前后的注册和 IMS 状态。

## 9.8 强制开启 IMS / VoLTE

官方 2026-06-29 给出的指令：[官方 #78452]

```text
AT+QCFG="ims",1
AT+CFUN=1,1
```

用途描述是：

- CTE UK；
- 中国电信；
- 中国广电；
- 某些依赖 VoLTE 才能收发短信的场景。

不要理解为“所有卡都应该强开”。如果卡本身不需要，没必要增加变量。

## 9.9 USB 软件重置

群里常用两种办法。

### 方式 A：unbind / bind

```bash
# 先确认真实 USB path，例如 1-1

echo -n '1-1' > /sys/bus/usb/drivers/usb/unbind
sleep 2
echo -n '1-1' > /sys/bus/usb/drivers/usb/bind
```

### 方式 B：authorized 0/1

```bash
echo 0 > /sys/bus/usb/devices/1-1/authorized
sleep 2
echo 1 > /sys/bus/usb/devices/1-1/authorized
```

**先确认设备路径，不要照抄 `1-1`。**

## 9.10 raw_ip 警告

群里经常出现：

```text
Kernel driver does not support raw_ip (sysfs entry missing), skipping kernel config
```

或者容器/WSL 中：

```text
/sys/class/net/wwan0/qmi/raw_ip: permission denied
```

这不等于“SIM 坏了”。它更可能说明：

- 当前 qmi_wwan 实现没有那个 sysfs 项；
- 驱动模式不同；
- 容器权限不足；
- WSL/虚拟机对 sysfs/network device 支持不完整。

先看设备是否能真正完成 QMI 请求，再决定是否处理 raw_ip。

---

# 10. 高通 410 棒子：从 Android 到 Debian

这是整份攻略风险最高、也最值得系统化说明的部分。

## 10.1 410 棒子是什么

群里所谓“410 棒子”通常指 Snapdragon 410/相关高通平台的 4G 随身 Wi-Fi/USB 棒子。它本质上不是单纯 USB modem，而是一台：

```text
ARM SoC + RAM/eMMC + Linux/Android + 高通基带 + USB/Wi-Fi
```

因此刷 Debian 后，它自己就能成为：

- Linux 主机；
- 自身蜂窝模组的控制端；
- VoHive 宿主机；
- Wi-Fi 网络节点；
- 甚至还能通过 Hub 外接 EC20。

官方从 VoHive v1.1.0 开始明确支持“410 棒子裸机运行”。[官方 #16677]

## 10.2 410 最重要的一句话：先 9008 全盘备份

群友反复强调：[群聊 #24492]

> 棒子到手第一件事就是 9008 备份，甚至可以不开机直接备份。

另一个长流程同样明确要求：[群聊 #19725]

> 全程别插卡，刷完 Linux 前都别插卡；先在 9008 下用 Miko 备份整个 eMMC。

这不是“强迫症”，而是因为 410 的坑通常不是 Debian 根文件系统，而是：

- bootloader / aboot；
- device tree；
- modem/baseband 分区；
- QCN/NV；
- SIM route；
- 厂家私有配置。

如果你只有别人分享的“同型号备份”，恢复成功率远低于你自己的原厂全盘备份。

## 10.3 收到棒子后正确的资产保存清单

建议建立：

```text
backup/<设备序列或自定义ID>/
├── full-emmc-9008/
├── boot.img
├── system.img
├── modem-related-partitions/
├── qcn/
├── android-build-info.txt
├── usb-info.txt
├── sim-route-info.txt
└── photos/
```

记录：

```bash
adb shell getprop > getprop.txt
adb shell cat /proc/cmdline > cmdline.txt
adb shell cat /proc/partitions > partitions.txt
adb shell ls -l /dev/block/by-name > by-name.txt
```

如果已经有 root，还可以额外保存关键分区表和设备树信息。

## 10.4 不要插卡开始刷机的原因

这主要是降低误操作变量：

- 某些 Android 固件会自动切 SIM/自动写配置；
- 你还没确认内外置 SIM 路由；
- 擦/改基带过程中不希望卡参与初始化；
- eUICC 可能让你误以为是固件问题。

对刷机本身来说 SIM 并不是绝对不能插，但群里形成了“先把系统和基带状态稳定下来，再插卡”的低风险流程。

## 10.5 先判断有没有 ADB / fastboot / root

```bash
adb devices
fastboot devices
```

有些 UZ801 v2.1 群友报告原生就有 ADB/fastboot，甚至获取 root 相对容易。[#21465/#21512]

没有 ADB 时，群友的高级做法包括：

- 9008 提取 system/boot；
- 修改 `build.prop` 强开 ADB；
- 修改 boot 取得 root；
- Magisk 22.1 修补旧 Android boot；
- 重新刷回。

这属于**板型相关的高级救援手段**，不是每根棒子都必须做。

群聊里出现过类似 `build.prop` 设置：

```text
ro.adb.secure=0
persist.sys.usb.config=adb
service.adb.tcp.port=5555
```

[#45996]

不要对不理解的 Android 镜像直接批量写这些项。

## 10.6 刷 Debian 前先处理外置 SIM 通路

这是 410 最容易忽略的步骤之一。

### UZ801 一类

多条群聊经验指出：

1. Android 下先切到外置 SIM 槽；
2. 插实体 SIM；
3. 确认 Android 能正常读卡/驻网；
4. 再拔卡；
5. 保持外置 SIM route 的状态刷 Linux。

群里甚至有某个 UZ801 v2.1 的切卡密码为 `admin8888` 的个例，但**绝对不要把它当所有 UZ801 的通用密码**。

### JZ02 一类

群友则称：

- Debian 设备树通常已经默认外置卡；
- 不一定需要 Android 先切卡；
- 某些 QPST 切换方法只针对 JZ02。

所以：

> **“刷 Debian 前一定要 Android 切外置卡”是 UZ801/部分板子的经验，不是整个 410 生态的铁律。**

## 10.7 QCN / “全网通”流程：高风险，可选，不是默认步骤

群聊 #19725 给出过一套非常激进的流程：

- root/ADB；
- 切外置卡；
- 工具强开 DIAG；
- 备份 QCN；
- 擦某些基带分区；
- 恢复 QCN；
- 再刷 Debian。

其中用户提到 QCN 备份大小约 `556–558 KB`。

### 本文建议

**如果你的棒子 Android 下三网/目标运营商已经正常，不要为了“看起来更完整”主动擦基带。**

只有下面情况才考虑 QCN/DIAG 路线：

- 明确知道该板原厂锁了网络能力；
- 有与该 PCB revision 对应的成熟教程；
- 已经备份自己设备的 QCN；
- 已经有完整 9008 eMMC 备份；
- 明白恢复工具和分区含义。

QCN 是“救命备份”，不应被理解成“刷 Debian 必须先动”。

## 10.8 aboot 坑：社区镜像升级链必须配套

群聊 #22866 有非常明确的一次事件：某版社区 Linux 镜像因为内核变大，触发旧 aboot 的 bug，于是维护者要求：

> **先更新该包对应的非 Android aboot，再刷新镜像，否则可能变砖。**

这条信息非常重要，但它的正确解读是：

- **针对那一代镜像和 boot chain**；
- 不是“所有 410 刷 Debian 都先换 aboot”；
- 不要拿别的教程里的 aboot 混用。

正确原则：

> **boot/rootfs/dtb/aboot 尽量来自同一镜像体系或明确兼容组合。**

## 10.9 Debian 镜像来源

群聊反复分享：

```text
https://blog.iamsjy.com/2023/12/11/snapdragon-410-portable-wifi-hotspot-flash-debian-and-optimize/

https://github.com/OpenStick/OpenStick/releases/tag/v1

https://github.com/markmiller1/Qualcomm-410-Portable-WiFi-for-Debian
```

这些是历史群聊资源，本文没有联网验证当前状态。

## 10.10 设备树选择

某一套社区镜像中，群友提过通过：

```text
/boot/extlinux/extlinux.conf
```

切换 board/device tree，例如：

```text
thwc-uf896
thwc-ufi001c
jz01-45-v33
fy-mf800
```

**这是镜像特定机制。** 如果你使用的是不同 Debian/OpenStick 镜像，请以其 README 和 `/boot` 实际文件为准。

## 10.11 刷完 Debian 后第一轮自检

先不装 VoHive。

### 1. 系统

```bash
uname -a
cat /etc/os-release
uname -m
```

群里 410 通常使用 `arm64/aarch64` VoHive 二进制。

### 2. 基带相关设备

```bash
ls -l /dev/wwan* /dev/cdc-wdm* /dev/ttyUSB* 2>/dev/null
ip link
```

部分 410 原生 QMI 设备不是普通 `/dev/cdc-wdm0`，而会出现类似：

```text
/dev/wwan0qmi0
```

### 3. QMI

```bash
qmicli -d /dev/wwan0qmi0 --dms-get-ids
qmicli -d /dev/wwan0qmi0 --uim-get-card-status
```

实际 device path 按系统为准。

### 4. IMEI/ICCID

如果能拿到：

- IMEI；
- SIM status；
- ICCID；
- 运营商注册；

再进入 VoHive 层。

## 10.12 qmi-auto-activate / 自动激活服务

部分社区 Debian 镜像内置了自己的基带激活/掉卡恢复服务，群里日志显示会自动：

- SIM power cycle；
- refresh；
- QMI UIM 检查；
- 监控 `/dev/wwan0qmi0`。

这也是为什么 410 上不能照搬“看到 ModemManager 就 mask”。

## 10.13 410 上的 ModemManager 特例

标准 EC20 主机：**建议禁用 ModemManager**。

410 自带基带：**先检查你的 Debian 镜像是否依赖它。**

群友 #21809/#21813 明确说 SP970 某套环境中：

> 这个服务主要还支撑 SP970 读卡；群里用 SP970 的这个服务不能停。

### 判断方法

```bash
systemctl status ModemManager
systemctl list-units | grep -Ei 'qmi|modem|wwan|sim'
ps aux | grep -Ei 'ModemManager|qmi'
```

先查：

- 谁在初始化 SIM；
- 谁在做自动激活；
- 停掉后卡是否立刻丢失。

不要因普通 EC20 教程一句 `mask ModemManager` 把 410 自身基带搞离线。

## 10.14 410 散热与网络

群聊经验：

- 410 不开 AP、不主动跑蜂窝数据时温度明显更低；
- 同时做蜂窝上网 + Wi-Fi AP，热量会明显增加；
- 如果只是 VoHive 控制/SMS/VoWiFi，没必要让它同时承担大流量路由器职责。

Wi-Fi 中继还有顺序坑：有群友指出应先连接上游 Wi-Fi，再开热点，否则可能导致 Wi-Fi/AP 状态异常。

## 10.15 默认路由不要被蜂窝口抢走

群聊 #87716 有用户把默认路由改到 `wwan0`：

```text
default via 10.3.200.136 dev wwan0
```

结果容易把：

- apt；
- GitHub 下载；
- VoWiFi 代理；
- 管理 SSH

全部带到蜂窝数据出口。

如果 VoHive 需要一个特定地区代理做 VoWiFi，通常更好的设计是：

```text
管理/系统互联网 → Wi-Fi / Ethernet
蜂窝模组        → 只作为 SIM/基带设备
VoWiFi ePDG     → 按规则走指定代理
```

而不是直接把系统默认路由切到 SIM 数据。

---

# 11. 410 各板型/型号差异

群聊常出现：

- UZ801
- UFI001C
- UFI003
- UFI103S
- SP970
- JZ02
- QRZL903
- W001

## 11.0 群聊型号速查表

下表是对群聊中各型号讨论的压缩。**它描述的是群内出现过的实际现象，不是硬件厂商兼容性承诺。** 同型号不同 PCB revision 仍可能完全不同。

| 型号 | 群内讨论量/成熟度 | Debian/VoHive 观察 | 最需要留意 | 代表消息 |
|---|---|---|---|---|
| **UZ801** | 很高 | 资料多、有人认为操作相对简单 | 先备 QCN；常需 Android 下切外置卡；有不同版本；某些新社区 Debian 曾出现无 Wi-Fi/无基带回归 | #19439、#21512、#23805、#39939 |
| **UFI001C** | 高 | 多套社区镜像支持 | 部分板需硬件改卡槽/接地；混用镜像风险高 | #19129、#19240 |
| **UFI003** | 高 | 有用户 QMI/UIM、ModemManager 日志完整；整体评价较友好 | 不要因为别人刷了 QCN 就跟刷；有 UFI003/003S/板版差异 | #25156、#49189、#49200 |
| **UFI103S** | 中 | 有 V02/V03/V05 等讨论 | revision 差异非常明显；V02 有用户遇到移动/eSTK 问题；V03 可刷 UFI003 包只是个例 | #30146、#31426、#49609 |
| **JZ02** | 很高 | Debian 资料多；有用户实测 SMS | 部分镜像默认外置 SIM；QPST/QCN 流程与其他型号不要混用 | #18718、#20464、#20580 |
| **SP970** | 高但争议大 | 社区专门做过兼容和自动 SIM 激活 | 读卡复杂；某些环境依赖 ModemManager；进入 9008 可能要拆机短接；后期有“刷后短信不可用”的单用户报告 | #21597、#21809、#39996、#86784 |
| **QRZL903** | 低 | 有人尝试刷 UFI001C 包 | 群友称需硬改接地；跨刷后曾出现有 wwan0 但无 ICCID/IMSI/eSIM/SMS | #19240、#26524 |

### 这张表怎么用

例如你手里写着 `UFI103S`，正确问题不是“UFI103S 能不能刷”，而是：

```text
UFI103S 哪个 PCB revision？
原 Android 能不能读 SIM？
9008 全盘备份有没有？
现在用哪套 aboot / boot / DTB / rootfs？
刷后 qmicli 能不能读 UIM？
```

只有这些信息齐，群里的“我这个能用”才有参考价值。

## 11.1 总原则：410 就是“盲盒生态”

群友有一句很形象的总结：买 410 棒子像开盲盒。

原因包括：

- 同壳不同板；
- PCB revision 不同；
- 原厂 Android 不同；
- SIM route 不同；
- 基带 NV/QCN 不同；
- Wi-Fi 芯片/射频设计不同；
- 同名产品卖家刷的系统不同。

### 买到手先拍/记这些

```text
外壳标签
PCB 正反面
SoC/PMIC 丝印
SIM 槽
测试点
Android build number
adb getprop
9008 Sahara/Firehose 信息
完整分区表
```

## 11.2 UZ801

群聊印象：资料较多、相对容易折腾。

常见注意：

- v2.1 有群友报告 ADB/fastboot 较好用；
- 刷 Debian 前常需要在 Android 下切到外置 SIM；
- QCN 不要跨板型乱刷；
- 设备树/镜像匹配比“UZ801 这个名字”更重要。

## 11.3 UFI001C

群里多次提到：

- 某些 UFI001C 需要 SIM 路径的硬件修改/接地；
- 和 QRZL903 一样，不能只靠软件假设外置卡一定通；
- 有用户在混用 OpenStick/社区包后刷成异常状态。

结论：

> 001C 最重要的是确认你手里 PCB revision 对应的硬件改法和 device tree，不要拿“同壳 UFI”教程硬刷。

## 11.4 UFI003

群聊反馈总体比一些老板更友好。

有用户报告自己的 UFI003 不刷 QCN也能识别多运营商，说明：

> **已经正常的设备，不要为了“优化”主动刷 QCN。**

## 11.5 UFI103S

群里出现过：

- V02/V03 等硬件版本；
- 某些版本 SIM 自动激活表现不同；
- 有人称 V03 可以用 UFI003 某套包，但这是个例，不能当通刷规则。

## 11.6 JZ02

群聊普遍认为：

- 外置 SIM 路径相对明确；
- 某套 Debian device tree 已处理外置卡；
- 某些 QPST 方法是 JZ02 特有；
- Wi-Fi 天线/表现有人评价较弱。

## 11.7 SP970

这是群里信息冲突较大的型号。

一方面：

- 社区做过兼容；
- 有专门的自动读卡/ModemManager 相关处理；
- 可能需要拆机/短接进入 9008。

另一方面，2026-07-01 有单用户明确写道：

> “SP970 modem 刷机后不支持短信功能，所以 VoHive 不能收发短信。” [#86784]

这与早期“支持/兼容”讨论存在冲突。

**最合理的解读：**

- 可能是特定 SP970 revision；
- 可能是某套 Debian/baseband 配置；
- 可能是刷 Linux 后 AT/SMS 通道缺失；
- 不能据此下结论说“所有 SP970 都不能短信”。

如果你的核心需求是 SMS，买 SP970 前最好要求卖家/群友提供**同 PCB revision、同 Debian 镜像**的实测。

## 11.8 QRZL903

群里有跨刷后：

- `wwan0` 存在；
- 但 ICCID/IMSI/eSIM/SMS 不正常

的案例。

这正说明：

> `wwan0` 出现，只能证明 Linux 有一个网络/QMI 通路，不等于 SIM route、UIM、NV、短信通路完整。

---

# 12. 410 Debian 运行 VoHive 的正确思路

## 12.1 先做“纯基带验收”

你应该在安装 VoHive 前通过系统工具确认：

```text
[ ] 基带 device 出现
[ ] IMEI 正常，不是 000000...
[ ] SIM status 正常
[ ] ICCID 正常
[ ] IMSI 可读取（若工具支持）
[ ] 网络注册状态合理
[ ] 能收到 SMS（如系统/AT接口支持测试）
[ ] eUICC 能否开 logical channel（如果你要 eSIM）
```

如果这些都失败，装 VoHive 不会魔法修复底层。

## 12.2 安装 VoHive

410 通常用 arm64：

```bash
uname -m
# 常见应为 aarch64
```

使用对应 arm64 binary 或历史安装脚本。

## 12.3 第一轮只开最少功能

建议顺序：

1. 设备发现；
2. SIM 身份；
3. SMS；
4. eSIM；
5. 网络；
6. 代理；
7. VoWiFi。

不要首次启动就：

```text
同时切 eSIM + 改 MBN + 开 IMS + 开 VoWiFi + 改默认路由 + 开热点
```

否则失败时无法知道是哪一层。

---

# 13. DJI 4G 一代模块攻略

## 13.1 它本质是什么

VoHive 官方 2026-06-26 的教程称 DJI 4G 一代模块本质为 **Quectel EG25-G 核心**，只是默认使用 DJI 私有 USB VID/PID，因此通用 Linux 驱动不会按普通 Quectel 设备识别。[官方 #64152]

群聊里常见原 ID：

```text
2ca3:4006
```

改成：

```text
2c7c:0125
```

之后按 EC25 类设备工作。

## 13.2 官方修改方法

先：

```bash
sudo apt-get update
sudo apt-get install socat -y
sudo modprobe option
```

临时告诉 `option` 驱动识别 DJI ID：

```bash
echo '2ca3 4006' | sudo tee /sys/bus/usb-serial/drivers/option1/new_id
```

然后官方示例使用 `/dev/ttyUSB2`：

```bash
echo 'AT+QCFG="usbcfg",0x2C7C,0x0125,1,1,1,1,1,0,0' \
  | sudo socat - /dev/ttyUSB2,crnl

echo 'AT+CFUN=1,1' | sudo socat - /dev/ttyUSB2,crnl
```

重启后：

```bash
lsusb
```

期望看到类似：

```text
2c7c:0125 Quectel Wireless Solutions Co., Ltd. EC25 LTE modem
```

## 13.3 比官方教程更安全的做法：先找 AT 口，再备份 usbcfg

群聊后期有一份更稳妥的操作思路 [#94827]：

### 第一步：不要假定 ttyUSB2

```bash
for p in /dev/ttyUSB*; do
  echo "### $p"
  timeout 2 socat - "$p",crnl <<< 'ATI'
 done
```

### 第二步：先查询当前配置

```text
AT+QCFG="usbcfg"
```

把返回结果保存下来。

### 第三步：再写新 VID/PID

这样如果日后要恢复 DJI 原身份，你至少知道原参数，而不是只记得 `2ca3:4006` 两个数字。

## 13.4 多块 DJI 不要一起改

群聊 #85019 的问题非常典型：同时插两块 DJI，命令只修改其中一块。

原因：

- 两块设备 VID/PID 相同；
- ttyUSB 编号动态；
- 你很难确认 AT 命令发给谁。

**推荐：一次只插一块完成 ID 修改和标签记录。**

完成后给模块物理贴纸：

```text
DJI-01 -> EC25-ID changed
DJI-02 -> original
```

## 13.5 QMI / MBIM 模式

群友 #63215 提到 `usbcfg` 尾部组合可影响 QMI/MBIM，但这是社区解释，不能简单把所有尾参数机械照抄。

最稳做法是：

1. 先查询原 `AT+QCFG="usbcfg"`；
2. 使用已经被 VoHive 官方明确验证的组合；
3. 改完后看 Linux 真实生成的是 `qmi_wwan` 还是 `cdc_mbim`。

## 13.6 供电

群聊反复出现 DJI 模块 USB 反复掉线/重新枚举的问题。

有群友称峰值电流可能超过普通 USB 口舒适范围。具体电流值属于个体经验，但实践结论很稳定：

- 单块：优先用供电好的主板 USB；
- 多块：用**独立供电 USB Hub**；
- 不要用细长劣质延长线；
- 大量掉线先查电压/供电，再查 VoHive。

## 13.7 VoLTE

官方明确给 DJI/EC20/EC25 同一条强开 IMS 指令：[官方 #78452]

```text
AT+QCFG="ims",1
AT+CFUN=1,1
```

## 13.8 虚拟机使用

群聊有 Mac + UTM 指南：

```text
https://github.com/wlzh/dji-4g-vohive-mac
```

虚拟机方案的关键不是 VoHive，而是**USB passthrough**：

```text
宿主机不能同时占用 → USB 整体透传给 Linux VM → VM 内出 ttyUSB/QMI → VoHive
```

如果 VM 里只看得到一个抽象网卡，看不到真实 USB/QMI 设备，VoHive 的完整功能通常无法工作。

---

# 14. eSIM / eUICC 深度攻略

## 14.1 先理解“实体 eSIM 卡”是什么

群里大量讨论的 5ber、9eSIM、eSTK、小白卡、各种 300K/500K 卡，本质上是把 eUICC 做成实体 SIM 形态，让普通 SIM 卡槽设备也能使用可下载/可切换 Profile。

在 VoHive 场景中链路是：

```text
VoHive
  ↓
QMI UIM / AT / APDU
  ↓
Modem/Baseband
  ↓
SIM 接口
  ↓
eUICC
  ↓
Profile
```

其中任何一层不支持，都可能表现成“VoHive 识别不到 eSIM”。

## 14.1.1 群聊里出现过的实体 eSIM/eUICC 兼容性观察

| 类型/标识 | 群聊观察 | 应如何理解 |
|---|---|---|
| **9eSIM** | 讨论很多；既有可正常切换，也有读取失败、DJI 重插后恢复异常的个例 | 品牌名本身不能代表与所有 modem/固件兼容 |
| **eSTK** | 群早期就是重点测试对象，出现大量“加卡/删卡/切卡”讨论 | 属于群内较常见的测试生态，但不同批次/实现仍需实测 |
| **5ber** | 有群友用于解释“实体 eSIM”概念和网页/手机侧切卡 | 手机/App 侧可用不等于 QMI-UIM 路径可用 |
| **Xesim / Switch eSIM 等** | 有零散使用及安全性讨论 | 不足以从群聊得出统一兼容性或安全结论 |
| **约 500K 白卡** | #16232 单用户：Android 写、iPhone 切、VoHive 切均正常 | 是一个成功样本，不代表“500K”本身就是兼容标准 |
| **约 300K 白卡** | 同一用户：Android/iPhone 正常，VoHive 识别不到 eUICC | 很好地证明了“手机正常 ≠ modem logical channel 正常” |
| **EID 89086030** | #50128 在某 410/VoHive 组合遇到 open logical channel QMI error；随后换群内固件恢复 | 更像 kernel/baseband/QMI 路径兼容问题，不能判定该 EID 天生不兼容 |
| **EID 89034011 / EID2** | #98145 用户称实际只有某 Saily profile 出错，而不是传言中的 Vodafone/Saily/O2 全部失败 | Profile 兼容性需要逐个验证，勿传播“一刀切黑名单” |
| **双 EID Plus+ 类卡** | #70513：EID2 正常，EID1 会报错/卡死 | 双 EID 的两个逻辑环境应视为两个独立测试对象 |

### 不要用“容量”判断兼容性

群里常用“300K/500K”描述卡，但这更多是卖家/社区的产品分类。VoHive 是否能管理真正取决于：

```text
eUICC applet/AID
+ modem UIM/APDU 能力
+ QMI logical channel 实现
+ baseband/firmware
+ Linux kernel/driver
+ VoHive LPA 逻辑
```

所以“500K 一定行、300K 一定不行”是从一个样本过度推导，本文不采纳这种结论。

## 14.2 手机能切卡不代表 VoHive 能切

群聊 #16232 有很典型的对比：

- 一张约“500K”的实体 eSIM：Android 写入、iPhone 切换、VoHive 切换都正常；
- 另一张约“300K”的便宜卡：Android/iPhone 正常，VoHive 却识别不到 eUICC。

这说明：

- eUICC 实现细节；
- AID；
- logical channel；
- 证书/应用；
- 模组 UIM 能力

都会影响兼容性。

## 14.3 VoHive 识别 eSIM 的关键步骤

从日志看，VoHive 会尝试：

- AID 遍历；
- open logical channel；
- 创建 LPA client；
- 枚举 eUICC/Profile。

例如 #17175：

```text
首轮 AID 遍历全部失败
AID 遍历重试仍未发现 eUICC
未发现任何 eUICC
```

同时设备 IMEI 还是：

```text
000000000000000
```

这类日志应该首先怀疑**基带/固件/板型/设备初始化**，而不是先怪 eSIM 卡。

## 14.4 常见错误 1：QMI open logical channel error

群聊 #50128：

```text
open logical channel: QMI error:
service=0x0b msg=0x0042 result=0x0001 error=0x0003
```

同一用户随后换了群里的固件包后恢复。[#50419]

因此可能因素包括：

- 410 kernel/baseband 组合；
- QMI-UIM 实现；
- firmware；
- 卡的 AID；
- 端口被别的服务占用。

## 14.5 手工测试 logical channel

群友 #24358 成功使用：

```bash
qmicli -d /dev/cdc-wdm1 \
  --uim-open-logical-channel=1,A0000000871002FF44FFFF8901010100
```

返回：

```text
Open Logical Channel operation successfully completed: 1
```

这是一条非常有价值的分层诊断。

如果手工 qmicli 都打不开 channel，那么先不要反复重装 VoHive。

> AID 不是“通用魔法字符串”；不同 eUICC applet/卡可能不同。这里只是群聊实例。

## 14.6 CatBusy / 6881 等错误

群聊中还出现：

```text
EnableProfile ... 6881
EnableProfile 返回 CatBusy
```

处理思路：

1. 不要连续狂点切换；
2. 给当前 SIM applet 状态释放时间；
3. 等待 modem refresh；
4. 必要时对 SIM 做 power cycle；
5. 再重载 VoHive 设备。

## 14.7 QMI SIM power cycle

部分 410/QMI 环境会用：

```bash
qmicli -d /dev/wwan0qmi0 --uim-sim-power-off=1
sleep 2
qmicli -d /dev/wwan0qmi0 --uim-sim-power-on=1
```

设备路径按实际修改。

**如果你的 410 Debian 有自己的 SIM 自动激活服务，先确认该服务不会与你手工 power-cycle 打架。**

## 14.8 双 EID / 多 EID 卡

群聊有“Plus+”类卡的实测：[群聊 #70513]

- EID2 正常；
- 切 EID1 时 VoHive 直接报错。

另一个 89034011 EID2 的用户则测试：Vodafone/O2 等并非全部失败，实际只有某个 Saily Profile 启用出错。[#98145]

说明：

> **EID 兼容性和 Profile 兼容性是两个维度。**

不要仅凭“这张卡的 EID2 能用”推断所有运营商 Profile 都能用。

## 14.9 最好的 eSIM 测试方法

准备一个“已知好”的组合：

```text
已知能被手机识别的 eUICC
+ 已知能激活的 Profile
+ 已知能开 logical channel 的模组
+ 已知稳定 VoHive 版本
```

然后一次只换一个变量。

例如：

```text
Case A: 同 eUICC + 同模组 + 同 VoHive + 换 Profile
Case B: 同 eUICC + 同 Profile + 换 EC20/410
Case C: 同硬件 + 同卡 + VoHive 升级前后
```

这样才能真正判断兼容性。

## 14.10 eSIM 下载也可能需要特定网络出口

群里有人专门整理过 eSIM 下载/运营商域名的代理规则，例如：

- CMLink / go-esim；
- 3HK/CMHK/CSL；
- Vodafone；
- giffgaff；
- T-Mobile 等。

这说明某些 Profile 下载/激活服务可能存在：

- 地区限制；
- DNS 差异；
- CDN/服务端区域策略。

更推荐**按域名精确分流**，而不是把整个 VoHive 主机默认路由都切到某个代理国家。

## 14.11 eSIM 卡的安全性争议

群聊 #18215 转发过 Reddit 对 5ber/Xesim/eSTK/Switch eSIM/9eSIM 等“可能存在后门”的担忧。

这里必须区分：

- 群聊里确实有这种安全讨论；
- **它不是群聊内已经证实的安全漏洞结论。**

如果是高敏感号码/银行卡/长期主号，更谨慎的做法是：

- 选择来源和固件可审计程度更高的产品；
- 不把关键认证号码交给来源不明的 eUICC；
- 注意配套 Android App 的权限和联网行为；
- 不把卡商宣传等同安全审计。

## 14.12 SimJiang

群聊分享过：

```text
https://github.com/yanglh1/simjiang
```

后期版本据称加入：

- SIM/eSIM 资产管理；
- OMAPI / USB CCID 读写；
- eSIM 下载、切换等。

可作为手机侧/读卡器侧的辅助工具，但它与 VoHive 的 QMI 基带路径不同，不能互相替代。

---

# 15. VoWiFi 深度攻略

VoWiFi 是整个 VoHive 里最“网络协议栈化”的功能，建议按状态机排障。

## 15.1 官方历史已知支持运营商

官方 2026-03-28 列出：[官方 #3012]

### 英国

- CTE UK
- CMLINK UK
- giffgaff UK
- VOXI UK
- 3 UK
- Vodafone UK

### 德国

- Vodafone DE
- Telekom DE
- O2 DE

### 美国

- T-Mobile US

这是**2026-03-28 当时的已知列表**，不是永久兼容保证。

## 15.2 VoWiFi 成功链路

把日志按下面 7 层看：

### 第 1 层：SIM/USIM 能用

必须至少：

```text
ICCID 正常
IMSI/USIM 认证访问正常
IMEI 正常
```

### 第 2 层：ePDG 域名

常见形态：

```text
epdg.epc.mncXXX.mccYYY.pub.3gppnetwork.org
```

如果日志直接：

```text
ePDG DNS 解析失败
```

不要继续看 SIP。

### 第 3 层：IKE SA_INIT

它负责协商：

- cipher；
- integrity；
- PRF；
- DH group。

如果这里 timeout：

优先查：

- UDP 是否通；
- 代理是否支持 UDP；
- 出口 IP；
- 防火墙；
- NAT；
- 算法兼容。

### 第 4 层：IKE_AUTH / EAP-AKA

如果出现：

```text
EAP Failure
AUTHENTICATION_FAILED
```

可能是：

- SIM AKA；
- identity 格式；
- IMEI/device identity；
- 运营商 provisioning；
- 运营商拒绝当前出口/设备身份。

群聊中有日志出现：

```text
"device_identity_present": false
"last_confirmed_eap_stage": "aka_challenge_response_sent"
```

随后被 EAP 拒绝。

这种情况下 DNS 和 UDP 已经不是主要矛盾。

### 第 5 层：IPsec/XFRM/TUN

官方 v0.1.19 就专门加入：

- XFRM 策略优化；
- 失败回落 TUN。[官方 #1319]

如果 auth 成功但隧道后流量不通，查这一层。

### 第 6 层：P-CSCF

v0.1.24 有 P-CSCF IPv4 相关兼容修复。

### 第 7 层：SIP REGISTER / IMS keepalive

到了这里再看：

- 401 challenge；
- 403 reject；
- REGISTER；
- OPTIONS；
- keepalive timeout。

群里 #31225 有 `context deadline exceeded` 一类 IMS heartbeat/OPTIONS 问题，可能触发快速失败重连。

## 15.3 为什么很多人要“对应国家 IP”

群聊里经常说“VoWiFi 基操就是对应 IP”。实际意思通常是：

- 某些运营商只允许特定国家/地区；
- 或不同地区 DNS/ePDG routing 不同；
- 或运营商做了地理策略。

因此 VoHive 后期支持前置 SOCKS5/HTTP 的意义很大。

## 15.4 SOCKS5 前置代理

群聊 v1.3.8 日志清楚显示：

```text
VoWiFi 将使用前置代理连接 ePDG
proxy_addr: 127.0.0.1:7890
remote: epdg....:500
socks5: 代理传输层初始化成功
```

这说明代理不仅是 Web 下载代理，而是在 ePDG/IKE 层使用。

### 关键要求

IKEv2 常见使用：

```text
UDP/500
UDP/4500（NAT-T 场景）
```

所以如果使用 SOCKS5：

> **代理链必须真正支持 UDP relay/UDP associate，而不是只有 TCP。**

否则表现往往是：

```text
DNS 正常
→ ePDG IP 正常
→ SA_INIT 一直超时
```

## 15.5 v1.3.8 ARMv7 原子操作崩溃

群聊 #48218 的日志值得单独记录：

```text
panic: unaligned 64-bit atomic operation
```

发生于：

```text
swu-go/pkg/ipsec.(*Socks5Transport).readLoop
```

平台是：

```text
vohive_v1.3.8_linux_armv7
```

这更像程序/架构实现问题，而不是 SIM/运营商问题。

排障意义：

> 如果出现 runtime panic，不要去改 MBN、APN、EID、ePDG DNS；应先换修复版本或换 arm64 平台。

## 15.6 `ePDG DNS → 127.0.0.1` 之类的异常

群聊早期就出现过 ePDG DNS 结果不正常、直接解析失败。

检查：

```bash
getent hosts epdg.epc.mncXXX.mccYYY.pub.3gppnetwork.org
resolvectl query <domain>        # systemd-resolved 环境
nslookup <domain>
dig <domain>
```

如果你有 Clash/sing-box/AdGuard/hosts 劫持，先确认 DNS 没被代理规则改坏。

## 15.7 VoWiFi 设备模型 / IMEI / UA

官方 v0.1.27 加了基于设备模型生成 IMEI/UA。[官方 #2473]

群聊日志 #27980 甚至可看到类似：

```text
identity_imei_source: carrier_device_model
imsUA: iOS/... iPhone (...)
```

这说明某些运营商对 IMS 客户端身份比较敏感。

但不要手工乱造 IMEI。至少应确保：

- 不与别的设备冲突；
- 符合当地法规/运营商规则；
- 先使用 VoHive 提供的设备模型机制，而不是系统层随意篡改基带 IMEI。

## 15.8 VoWiFi 故障定位模板

复制日志时至少保留：

```text
设备识别开始
SIM/ICCID/IMSI
VoWiFi 启动
目标 ePDG domain
DNS 结果
SA_INIT proposal
SA_INIT response/timeout
EAP-AKA stage
IPsec 建立
P-CSCF
SIP REGISTER
最后错误
```

不要只截图最后一行“连接失败”。

---

# 16. SMS / VoLTE / USSD / Bot

## 16.1 短信不能收时先分层

### A. SIM 是否驻网

看：

```text
CREG/CEREG
运营商
信号
```

### B. 模组能否原生收 SMS

直接 AT 测试比先看 VoHive 更有效。

常见：

```text
AT+CPIN?
AT+CREG?
AT+CEREG?
AT+CMGF=1
AT+CPMS?
AT+CMGL="ALL"
```

具体命令支持按模块固件而定。

### C. 是否依赖 VoLTE/IMS

CTE UK、中国电信/广电等群聊场景中，官方建议：

```text
AT+QCFG="ims",1
AT+CFUN=1,1
```

### D. VoHive 是否收到 URC

成功日志常能看到：

```text
URC: 新短信通知
+CMTI
收到短信 URC 通知
```

如果 AT 层已经有新短信，VoHive 没消费，再查软件版本/AT 口抢占。

## 16.2 USSD

官方 v0.1.7 已提到 USSD terminal。

USSD 是否能用主要取决于：

- 模组/固件；
- 运营商；
- 当前网络制式；
- VoHive 版本。

不要拿 USSD 失败反推 SIM 已坏。

---

# 17. 多模组、USB Hub、供电和拓扑

## 17.1 群里有人用 410 拖多块 EC20

有讨论提到类似“一根 410 再拖 3 个 EC20”的玩法。

技术上可行，但真正限制通常是：

- USB host 能力；
- Hub；
- 供电；
- 温度；
- 设备编号稳定性；
- 多个 QMI/ttyUSB 的映射。

## 17.2 多模组最重要的不是带宽，是供电

每块 LTE 模组在发射时都有瞬态电流。

典型症状：

```text
usb disconnect
new high-speed USB device
ttyUSB 重新编号
cdc-wdm 消失又出现
VoHive 设备循环恢复
```

看到这种日志，**先不要重刷固件**。

### 推荐拓扑

```text
                ┌─ EC20 #1
Linux 主机 ─ USB Hub（独立供电） ─ EC20 #2
                ├─ DJI #1
                └─ DJI #2
```

不要把四五个模组全靠小主机单一 USB 口供电。

## 17.3 固定设备身份

多模组不能只靠：

```text
/dev/ttyUSB2
/dev/cdc-wdm0
```

因为拔插顺序一变就可能换号。

更可靠的思路：

- 用 USB topology；
- `/dev/serial/by-id`（如果设备有唯一序列）；
- udev rule；
- VoHive 自己的设备识别信息；
- 物理端口固定。

---

# 18. 故障排查总流程

## 18.1 “VoHive 找不到设备”

按顺序走：

```text
1. lsusb 有吗？
   ├─ 没有 → 供电/线/Hub/硬件/USB host
   └─ 有
       ↓
2. 内核驱动绑定了吗？
   dmesg / lsmod
       ↓
3. ttyUSB / cdc-wdm / wwan 出现了吗？
   ├─ 没有 → VID/PID、option、qmi_wwan、USB mode
   └─ 有
       ↓
4. AT 能 ATI 吗？
       ↓
5. qmicli 能访问 DMS/UIM 吗？
       ↓
6. ModemManager 是否抢占？
       ↓
7. Docker /dev、privileged、host network 正确吗？
       ↓
8. 才看 VoHive 日志
```

## 18.2 “有 IMEI，但没 ICCID”

说明至少基带 DMS 可能通，但 UIM/SIM 有问题。

优先检查：

- SIM 是否插反；
- SIM slot route；
- 410 外置卡是否真正切通；
- QMI UIM status；
- SIM power；
- ModemManager/自动激活服务冲突；
- 固件/device tree。

## 18.3 “有 wwan0，但完全没 SIM”

**不要被 wwan0 欺骗。**

wwan0 只说明：

```text
Linux 网络/QMI datapath 可能存在
```

不代表：

```text
SIM hardware route 正常
UIM logical channel 正常
NV/QCN 正常
SMS AT port 正常
```

410 跨刷最常出现这种“半活”状态。

## 18.4 “VoHive 找不到 eUICC”

流程：

```text
1. 这张实体 eSIM 在手机上是否正常？
       ↓
2. 普通 SIM 在该模组是否正常？
       ↓
3. qmicli --uim-get-card-status 正常？
       ↓
4. 能否手工 open logical channel？
       ↓
5. AID 是否适配？
       ↓
6. 换已知兼容 eUICC 测试
       ↓
7. 换模组/固件/410 kernel 测试
       ↓
8. 换 VoHive 版本
```

## 18.5 “VoWiFi 不连接”

```text
SIM/USIM OK?
  ↓
ePDG domain 正确？
  ↓
DNS 成功？
  ↓
目标 ePDG IP 合理？
  ↓
UDP 500/4500 路径？
  ↓
SOCKS5 是否真支持 UDP？
  ↓
SA_INIT 成功？
  ↓
EAP-AKA 成功？
  ↓
IPsec tunnel 成功？
  ↓
P-CSCF？
  ↓
SIP REGISTER？
  ↓
IMS keepalive？
```

每失败一层，只解决这一层。

## 18.6 “410 刷后不启动 / 9006 / 奇怪 USB ID”

群里存在刷 aboot/镜像后变成 9006、90B6 等异常状态的案例。

最稳原则：

1. **停止继续尝试随机镜像；**
2. 回到能进 9008 的方式；
3. 用你自己的全盘备份恢复；
4. 恢复后重新确认 PCB revision；
5. 再找对应镜像链。

不要在已经改变 boot chain 的情况下继续“这个也刷一下试试”。

---

# 19. 升级、回滚与备份策略

## 19.1 VoHive 备份

至少：

```bash
tar czf vohive-backup-$(date +%F).tar.gz \
  /opt/vohive/config \
  /opt/vohive/data \
  /opt/vohive/bin/vohive
```

Docker：

```bash
tar czf vohive-docker-$(date +%F).tar.gz \
  ./config ./data ./docker-compose.yml
```

如果镜像 tag 是 `latest`，记录：

```bash
docker inspect iniwex/vohive:latest \
  --format '{{.Id}} {{index .RepoDigests 0}}'
```

这样以后至少知道原来运行的镜像是什么。

## 19.2 EC20 备份“状态”

固件升级前保存：

```text
ATI
AT+QGMR
AT+QCFG="usbnet"
AT+QCFG="ims"
AT+QMBNCFG="List"
AT+QCFG="usbcfg"   # 若型号支持/需要
```

再保存：

```bash
lsusb -v > lsusb-before.txt
ip link > ip-link-before.txt
dmesg -T > dmesg-before.txt
```

## 19.3 410 备份层级

从重要到次要：

```text
1. 9008 full eMMC backup
2. QCN/NV（如果能备份）
3. 分区表
4. boot/system/modem 等分区镜像
5. Android getprop/build 信息
6. SIM route 状态
7. PCB 照片
```

只备份 rootfs 不算真正备份 410。

## 19.4 已经稳定就不要为了“最新版”强更

因为群聊已经出现：

- SMS 回归；
- 设备识别回归；
- ARMv7 panic；
- Bot 命令回归。

对于闭源/半闭源程序，**可回滚性比追最新版更重要。**

---

# 20. 常用命令速查表

## 20.1 Linux USB/QMI 基础

```bash
lsusb
ls -l /dev/ttyUSB* 2>/dev/null
ls -l /dev/cdc-wdm* 2>/dev/null
ls -l /dev/wwan* 2>/dev/null
ip link
lsmod | grep -Ei 'qmi|wwan|option|usbserial|cdc'
dmesg -T | grep -Ei 'usb|qmi|wwan|option|ttyUSB|cdc-wdm'
```

## 20.2 AT 口测试

```bash
echo 'ATI' | socat - /dev/ttyUSB2,crnl
echo 'AT+QGMR' | socat - /dev/ttyUSB2,crnl
```

## 20.3 EC20 切 QMI

```bash
echo 'AT+QCFG="usbnet",0;+CFUN=1,1' | socat - /dev/ttyUSB2,crnl
```

## 20.4 强开 IMS/VoLTE

```bash
echo 'AT+QCFG="ims",1' | socat - /dev/ttyUSB2,crnl
echo 'AT+CFUN=1,1' | socat - /dev/ttyUSB2,crnl
```

## 20.5 MBN 查询

```bash
echo 'AT+QMBNCFG="List"' | socat - /dev/ttyUSB2,crnl
```

不要无理由关闭 AutoSel。

## 20.6 ModemManager

```bash
systemctl status ModemManager
sudo systemctl stop ModemManager
sudo systemctl disable ModemManager
sudo systemctl mask ModemManager
```

**仅普通 Linux + USB 模组作为默认建议；410 请先看后文例外。**

## 20.7 QMI

```bash
qmicli -d /dev/cdc-wdm0 --dms-get-ids
qmicli -d /dev/cdc-wdm0 --uim-get-card-status
qmicli -d /dev/cdc-wdm0 --nas-get-signal-info
qmicli -d /dev/cdc-wdm0 --nas-get-serving-system
```

410 可能是：

```bash
qmicli -d /dev/wwan0qmi0 --dms-get-ids
```

## 20.8 eUICC logical channel 诊断例

```bash
qmicli -d /dev/cdc-wdm1 \
  --uim-open-logical-channel=1,A0000000871002FF44FFFF8901010100
```

只是群聊实例，不保证你的卡使用相同 AID。

## 20.9 SIM power cycle

```bash
qmicli -d /dev/wwan0qmi0 --uim-sim-power-off=1
sleep 2
qmicli -d /dev/wwan0qmi0 --uim-sim-power-on=1
```

## 20.10 Docker

```bash
docker ps
docker logs -f vohive
docker restart vohive
docker exec -it vohive sh
```

## 20.11 USB reset

```bash
echo -n '1-1' > /sys/bus/usb/drivers/usb/unbind
sleep 2
echo -n '1-1' > /sys/bus/usb/drivers/usb/bind
```

或者：

```bash
echo 0 > /sys/bus/usb/devices/1-1/authorized
sleep 2
echo 1 > /sys/bus/usb/devices/1-1/authorized
```

务必先找到真实 USB path。

## 20.12 DJI 临时绑定

```bash
sudo modprobe option
echo '2ca3 4006' | sudo tee /sys/bus/usb-serial/drivers/option1/new_id
```

## 20.13 DJI 修改 ID

```bash
echo 'AT+QCFG="usbcfg",0x2C7C,0x0125,1,1,1,1,1,0,0' \
  | sudo socat - /dev/ttyUSB2,crnl

echo 'AT+CFUN=1,1' | sudo socat - /dev/ttyUSB2,crnl
```

**先查询原 `AT+QCFG="usbcfg"`，再写。**

---

# 21. 群聊中出现的周边工具与资料

> 下列均为群聊历史链接，未联网验证当前是否仍可访问，也不代表本文背书。

## 21.1 VoHive

```text
https://github.com/iniwex5/vohive-release
https://github.com/iniwex5/vohive
```

群里后期还出现过镜像/分叉：

```text
https://github.com/zhangsan-nb/vohive-release
https://github.com/zhangsan-nb/vohive
```

## 21.2 410 / OpenStick / Debian

```text
https://blog.iamsjy.com/2023/12/11/snapdragon-410-portable-wifi-hotspot-flash-debian-and-optimize/
https://github.com/OpenStick/OpenStick/releases/tag/v1
https://github.com/markmiller1/Qualcomm-410-Portable-WiFi-for-Debian
```

## 21.3 DJI 4G + Mac/UTM

```text
https://github.com/wlzh/dji-4g-vohive-mac
```

## 21.4 TR3000

```text
https://github.com/asrtroh-netizen/immortalwrt-mt7981-cudy-tr3000/releases/tag/ImmortalWrt-20260619-0533
```

## 21.5 SimJiang

```text
https://github.com/yanglh1/simjiang
```

---

# 22. 关键消息索引

如果你以后想回原 `result.json` 搜完整上下文，下面这些 ID 最值得保留。

| 消息 ID | 日期 | 内容 |
|---:|---|---|
| #1319 | 2026-03-08 | v0.1.19：VoWiFi 状态、XFRM→TUN、AKA'、IMS keepalive |
| #2186 | 2026-03-14 | v0.1.23：USB 探测、非 QMI 支持 |
| #2473 | 2026-03-16 | v0.1.27：设备模型 IMEI/UA、VoWiFi 注册 |
| #2613 | 2026-03-20 | v0.2.2：VoWiFi 重构、移除 sing-box |
| #3012 | 2026-03-28 | 官方已知 VoWiFi 运营商列表 |
| #5903 | 2026-04-02 | Bot 命令（早期） |
| #12029 | 2026-04-15 | **VoHive 官方完整部署教程** |
| #12711 | 2026-04-21 | Bot 命令 + `/status` |
| #14637 | 2026-05-08 | ROW_Generic_3GPP MBN 个例 |
| #14676 | 2026-05-08 | VoLTE_OPNMKT_CT MBN 个例 |
| #16232 | 2026-05-17 | 两种实体 eSIM 卡 VoHive 兼容性差异 |
| #16677 | 2026-05-20 | **v1.1.0 正式兼容 410 Debian 裸机** |
| #17175 | 2026-05-21 | 410/eSIM AID 遍历失败 + IMEI 000... 日志 |
| #19725 | 2026-05-24 | **410 完整折腾流程长文：9008/ADB/root/QCN/外置卡** |
| #21809/#21813 | 2026-05-25 | **SP970/410 上 ModemManager 不能机械停用** |
| #22866 | 2026-05-26 | **特定 410 镜像必须先升级 aboot，否则可能砖** |
| #24358 | 2026-05-28 | qmicli 手工打开 eUICC logical channel |
| #24492 | 2026-05-29 | **410 到手先 9008 全盘备份** |
| #27980 | 2026-06-08 | VoWiFi IMEI/device model/IMS UA 日志 |
| #31225 | 2026-06-11 | IMS heartbeat/OPTIONS 等 VoWiFi 运行日志 |
| #48204 | 2026-06-19 | TR3000 VoHive 定制 ImmortalWrt |
| #48218 | 2026-06-19 | **v1.3.8 ARMv7 SOCKS5 VoWiFi atomic panic** |
| #50128 | 2026-06-20 | eUICC open logical channel QMI error |
| #50419 | 2026-06-20 | 换 410 固件后 eSIM 识别恢复的个例 |
| #62262 | 2026-06-25 | TR3000 QMI/IPsec 依赖 |
| #64152 | 2026-06-26 | **官方 DJI 4G 一代改 EC25 ID + VoHive 教程** |
| #70513 | 2026-06-28 | 双 EID 卡 EID1/EID2 差异 |
| #78452 | 2026-06-29 | **官方 EC20/EC25/DJI 强开 VoLTE** |
| #83182 | 2026-06-30 | VoHive 频道“江湖再见” |
| #85862 | 2026-07-01 | 源码构建依赖私有 vowifi-go |
| #86784 | 2026-07-01 | SP970 刷 Debian 后短信失效的单用户报告 |
| #87716 | 2026-07-01 | 410 把默认路由切到 wwan0 的实例 |
| #89587 | 2026-07-02 | EC20 SKU 差异的群友整理表 |
| #91723 | 2026-07-02 | “没完全开源”讨论 |
| #98145 | 2026-07-03 | 89034011 EID2/Profile 兼容性实测 |
| #98586 | 2026-07-04 | 核心未开源、维护依赖作者讨论 |
| #99423 | 2026-07-04 | DJI + 9eSIM 重启/拔插后恢复异常个例 |

---

# 23. 最后给折腾者的 30 条 Tips

1. **第一次搭 VoHive，先用 EC20 + Debian/Ubuntu 做标准答案。**
2. **410 到手第一件事是 9008 全盘备份，不是插卡。**
3. **不要用别人同型号的备份替代自己的备份。**
4. **同名 410 棒子不代表同 PCB revision。**
5. **刷 410 前拍 PCB 正反面并保存 Android build/getprop。**
6. **UZ801 一类先在 Android 验证外置 SIM route；JZ02 等板不能机械套用。**
7. **已经三网正常的 410 不要为了“全网通”主动擦基带/QCN。**
8. **自己的 QCN 只做备份/恢复优先，不要跨板乱刷。**
9. **aboot 必须与具体镜像体系兼容，不是越新越好。**
10. **410 刷 Debian 后先 qmicli 验基带，再装 VoHive。**
11. **`wwan0` 存在不等于 SIM/UIM/SMS 正常。**
12. **IMEI 变 `000000...` 时先查底层，不要折腾 VoWiFi。**
13. **普通 EC20 Linux 主机通常要禁用 ModemManager。**
14. **410 自身基带环境先确认是否依赖 ModemManager/auto-activate，再停。**
15. **永远不要假定 `/dev/ttyUSB2` 就是 AT 口；用 `ATI` 找。**
16. **EC20 跨 R06/R08 先确认 QFlash/DFOTA 路径。**
17. **MBN 手选是排障手段，不是安装 VoHive 的必做步骤。**
18. **CTE UK/电信/广电短信异常时再考虑 `AT+QCFG="ims",1`。**
19. **Docker 里的 privileged 不能解决宿主机 ModemManager 抢口。**
20. **Docker 镜像里可能只有 `sh`，不要默认有 `bash`。**
21. **大疆 4G 改 ID 前先查询并保存 `AT+QCFG="usbcfg"` 原值。**
22. **多块 DJI 一块一块改 ID，避免 AT 发错设备。**
23. **多 LTE 模组第一优先是独立供电 Hub，而不是更换 VoHive 版本。**
24. **手机能用实体 eSIM，不代表 QMI-UIM 能 open logical channel。**
25. **eSIM 故障先手工 qmicli 分层，不要一上来删除所有 profile。**
26. **双 EID 卡要分别测试，每个 EID 上不同 Profile 也可能行为不同。**
27. **VoWiFi 按 DNS → SA_INIT → EAP-AKA → IPsec → P-CSCF → SIP 排。**
28. **VoWiFi SOCKS5 代理必须关注 UDP 支持，不只是 TCP 连通。**
29. **闭源软件升级一定保留旧二进制和数据；最新版本可能有回归。**
30. **一次只改一个变量：硬件、固件、MBN、VoHive 版本、eSIM、代理不要一起换。**

---

# 附录 A：建议的一套“标准化实验记录”

每次折腾新设备，建议做一份 Markdown：

```markdown
# Device: UFI003-01

## Hardware
- PCB:
- SoC:
- SIM slot:
- Power:

## Original Android
- Build:
- ADB:
- Root:
- External SIM route verified: yes/no

## Backups
- Full 9008 eMMC: yes/no
- QCN: yes/no
- Partition table: yes/no

## Debian
- Image source:
- Kernel:
- DTB:
- aboot:
- Architecture:

## Modem
- QMI device:
- IMEI:
- ICCID:
- Operator:
- SMS:
- eUICC:

## VoHive
- Version:
- Config checksum:
- SMS: pass/fail
- eSIM: pass/fail
- VoWiFi: pass/fail

## Changes
- 2026-xx-xx: ...
```

这种记录方式会让你在一个月后仍然知道“到底是哪一版能用”。

---

# 附录 B：一套最低变量的验收顺序

拿到任何新模组/棒子，按下面顺序做，成功率最高：

```text
硬件供电
  ↓
USB 枚举
  ↓
驱动/设备节点
  ↓
AT ATI
  ↓
IMEI
  ↓
SIM/ICCID
  ↓
运营商注册
  ↓
SMS
  ↓
QMI data（如果需要）
  ↓
eUICC logical channel
  ↓
eSIM profile
  ↓
VoHive 基础设备管理
  ↓
Bot
  ↓
VoLTE/IMS
  ↓
VoWiFi direct
  ↓
VoWiFi proxy
  ↓
多设备/自动化
```

越靠前的层没过，越不应该去折腾后面的层。

---

# 附录 C：本文最值得记住的“反直觉”结论

### 1. 最新 VoHive 不一定最稳

群聊已有多个回归个例。闭源二进制应把“回滚”设计成默认能力。

### 2. ModemManager 既可能是敌人，也可能是 410 的生命线

普通 EC20 主机上它经常抢 AT 口；某些 410/SP970 社区 Debian 又依赖它或相关服务完成读卡/激活。判断环境再停。

### 3. 有 `wwan0` 不代表 410 刷成功

SIM/UIM、SMS、eUICC、NV/QCN 可以全部坏，而网络接口依然存在。

### 4. 手机能用 eSIM 卡，不代表 VoHive 能用

VoHive 经 QMI-UIM/APDU 走的是另一条访问路径。

### 5. VoWiFi 出错不等于“运营商不支持”

DNS、UDP、代理、IKE 算法、AKA、identity、IPsec、P-CSCF、SIP 任一层都能失败。

### 6. 410 的真正价值不是“便宜 modem”，而是“Linux 主机 + modem 一体化”

也正因此，它比 EC20 多了一整套 bootloader、device tree、Android、eMMC、QCN 的风险面。
