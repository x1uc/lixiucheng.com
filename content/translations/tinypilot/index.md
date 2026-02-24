---
srcTitle: "TinyPilot: Build a KVM Over IP for Under $100"
srcDate: "2020-07-23"
srcLink: "https://mtlynch.io/tinypilot/"
srcAuthor: "Michael Lynch"

title: "$100 以内构建一台 KVM over IP 设备"
description: $100 以内构建一台 KVM over IP 设备
date: "2025-10-27"
images:
  - /translations/tinypilot/opengraph.webp
---

{{<notice type="info">}}
**Note**: KVM over IP 指通过网络远程控制键盘、视频和鼠标
{{</notice>}}
TinyPilot 是一款我自制的远程控制设备，它开源并且构建的价格也很合适。它可以在操作系统启动之前就工作，所以你可以使用它为计算机安装操作系统，或者像我一样为我的 [无头服务器](https://mtlynch.io/building-a-vm-homelab/) 调试启动失败的问题。

这篇帖子是我创建 TinyPilot 的过程，并且为你展示我如何使用 [树莓派](https://www.raspberrypi.com/) 在 $100 以下构建这台设备。

{{<img src="win-ubuntu.jpg" alt="使用 TinyPilot 连接两台电脑的照片" max-width="600px" caption="在 Surface 上通过 TinyPilot 控制 Ubuntu 笔记本电脑" has-border="false">}}

## 我不想听你的故事，我只是想知道如何构建这个设备

如果你只是被这个设备所吸引，不关心我开发过程中遇到的精彩和挫折，可以跳转到这个部分 [如何去构建你自己的 TinyPilot](#如何去构建你自己的-tinypilot)

{{<youtube IF-AyHJ8DOI>}}

## 开发 TinyPilot 的背景

几年之前，为了测试软件，我组装了我自己的家庭服务器（Home Server）。这是非常有价值的投资，直到今天我还在使用它。

{{<img src="homelab-server.jpg" alt="我的 homelab VM server 照片" caption="我于 2017 年搭建的用于托管虚拟机的 homelab" max-width="650px" has-border="false">}}

我使用 SSH 或者 Web 界面去访问这台服务器，所以我没有给它配备显示器和键盘。这是一个方便的配置，但这也常常给我带来很多麻烦。

有时因为我的一些操作失误（频率在几个月一次），会导致服务器无法启动、无法加入网络，导致我无法访问它。为了恢复运行，我不得不拔掉所有连接线，将服务器拖到我的桌子旁边，然后连接键盘、显示器以及各种线材到服务器。

## 商业解决方案

朋友们给我安利了 iDRAC，对它的使用体验赞不绝口。iDRAC 是戴尔服务器中的一种芯片，可以在系统启动时提供虚拟控制台。我短暂地考虑过为我的下一台服务器添加 iDRAC，但是它昂贵的价格让我很快打消了这个想法。单单 License 就需要 $300，这还不包含昂贵的定制硬件。

{{<img src="idrac-price.png" alt="iDRAC 9 Enterprise 许可证价格为 300 美元的截图" caption="戴尔 iDRAC 技术的许可证费用为每台机器 300 美元，不包括硬件成本" max-width="700px">}}

随后我考察了商用的 KVM over IP 解决方案。这类设备功能与戴尔 iDRAC 类似，但属于外接装置，需要连接电脑的键盘（Keyboard）、显示器（Video）和鼠标（Mouse）端口（KVM 即由此得名）。遗憾的是其价格更为高昂，单台设备售价在 500 至 1000 美元之间。

{{<img src="raritan-kvm.png" alt="Raritan Dominion KVM over IP 购买页面截图" caption="商用的 KVM over IP 设备价格在 $500~$1000" max-width="800px">}}

虽然我不愿意来回来去地搬服务器，但是为了节省插拔线缆的功夫而花 $500，实在有点说不过去，更何况一年只有几次。

于是，我做了每个不够理性的程序员都会做的事：花了几百个小时打造自己的 KVM over IP 设备。

## 使用树莓派构建 KVM over IP 设备

[树莓派](https://www.raspberrypi.org/) 是小型、廉价的 [单板机](https://zh.wikipedia.org/wiki/%E5%8D%95%E6%9D%BF%E6%9C%BA)。它的性能足以运行完整的桌面操作系统，并且售价只需要 $30-60，所以它在开发者和业余爱好者群体中很受欢迎。

{{<img src="pi-in-hand.jpg" alt="手掌中的树莓派" caption="树莓派是一款功能齐全的计算机，所有核心部件都集成在一块小型主板上，价格仅为 $30~60" max-width="600px" has-border="false">}}

最新版本的树莓派（作者指的是 [树莓派 4B](https://www.raspberrypi.com/products/raspberry-pi-4-model-b/)）支持 [USB on-the-go（USB OTG）](https://www.raspberrypi.org/documentation/hardware/raspberrypi/usb/README.md#overview_pi4)，这允许树莓派模拟 USB 设备，例如键盘、U 盘、麦克风。

为了验证 Pi-as-KVM 这个想法，我创建了一个简单的 Web 应用：[Key Mime Pi](https://mtlynch.io/key-mime-pi)

{{<img src="key-mime-pi-interface.png" alt="Key Mime Pi网页界面截图" caption="Key Mime Pi，这是我早期开发的TinyPilot前身，当时仅支持键盘转发功能。" max-width="700px">}}

Key Mime Pi 通过 USB 连接到目标机器，注册为键盘设备。它也提供了一个 Web 页面，通过 JavaScript 监听键盘事件。当用户输入时，Key Mime Pi 会捕获这些按键事件，并通过其模拟的 USB 键盘将其转换为实际键盘动作，从而使目标计算机显示相应字符。关于这一运行机制，[我已经在之前的文章中详细说明](https://mtlynch.io/key-mime-pi#how-it-works)。

## 关于采集视频的挑战

如果不知道屏幕上显示的是什么，那么键盘指令转发基本没什么用。所以我的下一步就是采集我服务器的显示，并将它输出到树莓派上，然后渲染视频到浏览器。

关于视频采集的第一个尝试，我使用的是 [Lenkeng LKV373A HDMI extender](https://smile.amazon.com/AEMYO-Extender-V3-0-Ethernet-Supports/dp/B01LGUT9HW/)。Daniel Kučera（aka [danman](https://blog.danman.eu/)）对这款设备的逆向工程做了很多 [贡献](https://blog.danman.eu/new-version-of-lenkeng-hdmi-over-ip-extender-lkv373a/)。这款设备可以在 eBay 上从中国商户那花 $40 买到，这是我当时能找到的最佳选择。

{{<img src="lkv373a.jpg" alt="Lenkeng LKV373A HDMI延长器照片" caption="[Lenkeng LKV373A HDMI extender](https://smile.amazon.com/AEMYO-Extender-V3-0-Ethernet-Supports/dp/B01LGUT9HW/)是我尝试的第一款HDMI视频采集器" max-width="600px" has-border="false">}}

因为 LKV373A 发射器不是专业的视频采集设备，所以采集视频的过程非常棘手。LKV373A 发射器预期的使用方式是和 LKV373A 接收器进行配对，将网络流转换为 HDMI 输出。在 danman 的研究中，他发现一种方式去拦截 & 捕获视频输出流，但是因为 LKV373A 使用了非标准的 RTP 协议，导致绝大多数视频工具无法识别其格式。

幸运的是，danman [为 ffmpeg 贡献了一个补丁](https://ffmpeg.org/pipermail/ffmpeg-devel/2017-May/211607.html)，使得能够处理 LKV377A 设备的异常行为，因此我得以通过 ffmpeg 的视频播放器成功渲染该视频流。

```bash
ffplay -i udp://239.255.42.42:5004
```

{{<img src="ffplay-screenshot.jpg" alt="ffplay 渲染从LKVA373A获取的视频流" caption="使用ffplay渲染从LKVA373A获取的视频流" max-width="800px" has-border="false">}}

这一步，我第一次遇到了贯穿整个项目的难题：延迟。目标计算机和我桌面上播放的回传视频之间有将近一秒的延迟。

{{<img src="lkv373a-latency.jpg" alt="Lenkeng LKV373A HDMI延长器延迟测试照片" caption="在视频流还没经过任何处理（比如转码或重新压缩）之前，LKV373A 发射器本身就已经造成了大约 838 毫秒的延迟" max-width="600px" has-border="false">}}

我尝试了很多 ffplay 命令去降低延迟，但是始终没有突破 800 ms 大关。这还是在配置比较高的台式机上实现的，如果使用树莓派的话恐怕表现会更差。

幸运的是，我偶然间发现了一个更好的解决方案。

### HDMI to USB 转换器

当我浏览推特时，我看到了 [Arsenio Dev 的一条推文](https://twitter.com/Ascii211/status/1268631069051453448)，关于他刚刚购买的一个低价 HDMI to USB 转换器。

{{<img src="arsenio-dev-tweet.jpg" alt="Arsenio Dev的推文截图" caption="一篇[来自Arsenio Dev的推特](https://twitter.com/Ascii211/status/1268631069051453448) 启发我找到了更好的视频采集方式" href="https://twitter.com/Ascii211/status/1268631069051453448" has-border="false">}}

1080p & 30 帧/s 采集视频，这个描述有点难以置信，我马上下单了。仅售 $11 并且包邮。我甚至不知道它的品牌名，所以之后我就叫它“HDMI 转换器”吧。类似的商品有很多，这类商品的关键点在于 [MS2109 芯片](https://twitter.com/Ascii211/status/1268641527531741186)

{{<img src="hdmi-ebay.png" alt="eBay 上售价 11.20 美元的 HDMI 转换器截图" caption="在 eBay 上 $11.20 就可以买到这款 HDMI to USB 转换器，并且包邮" max-width="750px">}}

我收到快递之后，体验出乎意料地好。不需要任何额外的操作，当我把它插入树莓派之后，立即被识别为 UVC 视频采集设备。

```bash {hl_lines=[7,8,9]}
$ sudo v4l2-ctl --list-devices
bcm2835-codec-decode (platform:bcm2835-codec):
        /dev/video10
        /dev/video11
        /dev/video12

UVC Camera (534d:2109): USB Vid (usb-0000:01:00.0-1.4): <<< 这个是 HDMI 转换器
        /dev/video0
        /dev/video1
```

短短几分钟内，我就能捕获并重新推流（/dev/video0 -> ffmpeg -> udp stream）HDMI 视频了。

```bash
# On the Pi
ffmpeg \
  -re \
  -f v4l2 \
  -i /dev/video0 \
  -vcodec libx264 \
  -f mpegts udp://10.0.0.100:1234/stream

# On my Windows desktop
ffplay.exe -i udp://@10.0.0.100:1234/stream
```

简直不要太便利！LKV373A 接近砖头一样的大小并且需要电源和网线。但是这个 HDMI 转换器的大小接近 U 盘，并且只需要一个 USB 接口。
{{<img src="lkv373a-vs-dongle.jpg" alt="Lenkeng LKV373A与HDMI转换器对比" caption="[Lenkeng LKV373A HDMI延长器](https://smile.amazon.com/AEMYO-Extender-V3-0-Ethernet-Supports/dp/B01LGUT9HW/)（左）比HDMI转换器（右）更大，需要更多连接线" max-width="700px" has-border="false">}}

现在就只有一个问题了，还是延迟。从树莓派获取的视频流比源计算机慢了 7～10 秒。

{{<img src="dongle-ffmpeg.jpg" alt="使用ffmpeg从树莓派流式传输视频的延迟对比" caption="使用ffmpeg从树莓派流化视频时，视频延迟最高达到了10秒" max-width="700px" has-border="false">}}

我不确定延迟来自 HDMI 转换器、树莓派上的 ffmpeg，还是我桌面端的 ffplay。Arsenio Dev 说延迟只有 20 毫秒，所以似乎可以通过深入研究 [ffmpeg 那晦涩难懂的命令行参数](https://ffmpeg.org/ffmpeg.html) 去降低延迟。

又一次的幸运让我免于承担那项令人痛苦的任务。

### 浏览一个相似的项目

当我发布了之前关于 Key Mime Pi 的帖子之后，我收到了来自 Max Davaev 的帖子，他鼓励我尝试他的项目 [Pi-KVM](https://github.com/pikvm/pikvm)。

{{<img src="maxim-comment.png" alt="Max的评论截图：你好:) 看看这个项目：https://github.com/pikvm/pikvm 我们已经完成和调试了很多功能" caption="Max Devaev 指出它已经存在的 [Pi-KVM](https://github.com/pikvm/pikvm) 项目。">}}

{{<img src="melty-breadboard.jpg" align="right" alt="GPIO引脚照片" max-width="500px" caption="我之前使用面包板的经历包括[不小心把它们熔化了](https://mtlynch.io/greenpithumb/#why-make-another-raspberry-pi-gardening-bot)" has-border="false">}}

我之前粗略地看过 Pi-KVM，但是这个项目涉及到 [面包板](https://zh.wikipedia.org/wiki/%E9%9D%A2%E5%8C%85%E6%9D%BF) 和焊接，这让我望而却步。

在 Max 的建议下，我再次看了一下 Pi-KVM 这个项目，我对 Pi-KVM 如何解决延迟问题非常感兴趣。我注意到他采集视频使用的工具是 [uStreamer](https://github.com/pikvm/ustreamer)

{{<notice type="info">}}
**Note**: 通过和 Max 的进一步交流，我了解到 Pi-KVM 支持在不需要焊接和面包板的条件下构建。
{{</notice>}}

### uStreamer：一款超高速视频流媒体工具

你是否遇到过一款优秀的工具，它甚至解决了你没有预料到的问题？

使用 uStreamer 之后，立马将延迟从 8 秒降低到 500～600 ms。并且顺带解决了我很多额外的工作。

{{<img src="ustreamer-1.jpg" alt="使用uStreamer和HDMI转换器实现500毫秒延迟" caption="uStreamer将我的延迟降低了15倍" max-width="700px" has-border="false">}}

使用 uStreamer 之前，我不确定怎样把 ffmpeg 采集的视频呈现在用户的浏览器上，但是我知道这是可以做到的。我测试了这篇 [教程](https://docs.peer5.com/guides/setting-up-hls-live-streaming-server-using-nginx/)，它演示了使用 HLS 协议将 ffmpeg 视频传输到 nginx，但是这引入了更多的延迟。并且遗留了一些问题，如何在 HDMI 线缆插拔时启停流媒体、如何将视频转码为浏览器友好的格式。

uStreamer 解决了所有的问题。它本身就运行了一个最小化的HTTP服务器，直接提供浏览器原生支持的[Motion JPEG](https://en.wikipedia.org/wiki/Motion_JPEG)格式。我既无需折腾 HLS 流媒体配置，也不必调试 ffmpeg 与 nginx 的对接问题。

这么全能的工具，我想是 Max fork 了一个成熟的项目，然后做了改造。但是我错了，这位大佬使用 C 语言写了他自己的 [视频编码器](https://github.com/pikvm/ustreamer)，只为能使树莓派的性能最大化。我立马为这个项目进行 [捐献](https://www.paypal.me/mdevaev)，并且也想邀请任何使用这个项目的人捐献。

## 改进视频传输延迟

uStreamer 将延迟从 10 秒减少到约 600 ms。这是一个大的飞跃，但是这个级别的延迟仍是可感知的。我告诉 Max 我有意进一步捐赠项目，如果他能找到进一步提升性能的方式，所以我们进行了聊天。

Max 对 HDMI 转换器感兴趣，因为他从未见过这种特殊设备。他邀请我使用 [tmate](https://tmate.io/) 创建一个共享终端会话，以便他能远程访问我的树莓派。
Max was interested in the HDMI dongle I was using since he'd never seen that particular device. He invited me to create a shared shell session using [tmate](https://tmate.io/) so that he could access my Pi remotely.

{{<img src="maxim-tmate.png" alt="Max通过tmate提供帮助的对话截图" caption="Max 主动提出要么帮助我改善延迟，要么陷害我犯下联邦罪行。幸运的是，他最终选择了前者。" max-width="800px" has-border="false">}}

{{<img src="maxim-tmate-zh.png" max-width="800px" has-border="false">}}

经过几分钟的测试后，Max 跑了一个 [`v4l2-ctl` utility]，看到一行输出之后，他非常兴奋，但是我完全摸不着头脑：

```bash {hl_lines=[8]}
$ sudo v4l2-ctl --all
Driver Info:
        Driver name      : uvcvideo
        Card type        : UVC Camera (534d:2109): USB Vid
...
Format Video Capture:
        Width/Height      : 1280/720
        Pixel Format      : 'MJPG' (Motion-JPEG)
...
Streaming Parameters Video Capture:
        Capabilities     : timeperframe
        Frames per second: 30.000 (30/1)
```

HDMI 转换器已经使用 Motion JPEG 格式传输视频流！虽然 uStreamer 的硬件协助编码很快，但是这一步是没有必要的了。Motion JPEG 已经可以被浏览器原生识别了。

我配置 uStreamer，让它跳过编码直接传输视频流。

{{<img src="tinypilot-latency.jpg" max-width="700px" alt="消除重新编码步骤后200毫秒延迟的照片" caption="跳过树莓派上的额外重新编码步骤，延迟从600毫秒降低到200毫秒" has-border="false">}}

延迟从 600 ms 降低到了 200 ms。虽然算不上即时，但是在我使用几分钟之后，几乎感觉不到延迟。

## TinyPilot 实机演示

还记得我在文章开头对这个项目的愿景么？我想在我的无头虚拟机服务器在系统启动之前就可以访问它，是的我做到了。

我迭代了 Key Mime Pi 项目，开发了一个集成视频采集功能的新 Web 界面。

<img src="tinypilot-bios.gif">

今年我搭建了一台新的无头虚拟机服务器，并使用 TinyPilot 安装了 [Proxmox](https://www.proxmox.com/en/)——这是一款用于管理虚拟机的开源虚拟化平台，并且提供了 Web 页面去管理虚拟机。

TinyPilot 允许我去通过浏览器管理整个系统的安装过程。这比起以往来回搬动电脑、不断插拔线缆的旧方式，体验确实愉悦得多。

## 如何去构建你自己的 TinyPilot

### 零件清单

- [树莓派4](https://smile.amazon.com/Raspberry-Model-2019-Quad-Bluetooth/dp/B07TD42S27/)
- [USB-C to USB-A 数据线](https://www.amazon.com/Anker-2-Pack-Premium-Charging-Samsung/dp/B07DC5PPFV/)
- [HDMI to USB 转换器](https://www.ebay.com/itm/284886683842)
  - 奇怪的是，这个商品竟然没有品牌名，但是你可以通过[外观](hdmi-dongle.jpg)
  - 它在 eBay 上的价格普遍为 $11～15
- [microSD 卡](https://smile.amazon.com/Sandisk-Ultra-Micro-UHS-I-Adapter/dp/B073K14CVB/)（最低持续写入速度不低于 10 MB/秒，空间为 8 GB 以上）
- [HDMI to HDMI 线](https://smile.amazon.com/Cable-DisplayPort-marca-AmazonBasics-longitud/dp/B015OW3M1W/)
  - 或者是 \[other\] 到 HDMI，取决于你目标机器的显示输出接口。
- (可选的) [USB-C OTG分线转接头](https://tinypilotkvm.com/product/tinypilot-power-connector)
  - 需要额外两根 USB-A 转 microUSB 连接线和一个 3 A 电源适配器。
- (可选的) 散热外壳、散热鳍片、风扇
  - 选择一个能够接入树莓派 GPIO 引脚的外壳。
  - 我选择了[这款机箱采用极简设计，被动散热的外壳](https://shop.pimoroni.com/products/aluminium-heatsink-case-for-raspberry-pi-4?variant=29430673178707).

### 安装 Raspberry Pi OS Lite 操作系统

开始之前，需要在 microSD 卡上安装 [Raspberry Pi OS Lite](https://www.raspberrypi.org/downloads/raspberry-pi-os/)（之前被称为 Raspbian）。
{{<notice type="warning">}}
**Warning**: TinyPilot 不支持最新的 Raspberry Pi 操作系统。系统版本需要为 [Raspberry Pi OS Bullseye (32-bit)](https://github.com/tiny-pilot/tinypilot#pre-requisites)
{{</notice>}}

{{<img src="rufus-install.png" alt="Rufus软件截图" caption="我使用 [Rufus](https://rufus.ie) 来写入树莓派的 micro SD 卡，但任何磁盘映像工具都可以" has-border="false">}}

通过在 microSD 卡的 boot 分区创建一个 `ssh` 文件，以启动 SSH 访问功能。如果你想通过无线网连接，还需要一个 [`wpa_supplicant.conf` 文件](https://www.raspberrypi.org/documentation/configuration/wireless/headless.md)。

当你准备好 microSD 卡之后，将它插入树莓派中。

### 安装一个机壳 (可选的)

树莓派 4 是出了名的发热量大。你可以在没有散热的条件下运行，但是长时间运行可能遇到稳定性问题。

我选择了最小化的机壳，它的价格低，并且有被动散热，而且它没有风扇，这降低了硬件的复杂性：

{{<img src="minimal-case.jpg" alt="树莓派极简铝制外壳" caption="这款[极简铝制外壳](https://shop.pimoroni.com/products/aluminium-heatsink-case-for-raspberry-pi-4?variant=29430673178707)能很好地为树莓派散热，且没有风扇的复杂性" max-width="600px" has-border="false">}}

### 通过USB连接到目标机器

为了让 TinyPilot 可以模拟键盘，需要将树莓派的 USB-C 接口与目标机的 USB-A 接口相连：

{{<gallery caption="使用 USB-C 转 USB-A 数据线，将 USB-C 端连接到树莓派的 USB-C 端口，将 USB-A 端连接到目标计算机">}}
{{<img src="usb-cable.jpg" alt="USB连接到树莓派" max-width="500px" has-border="false">}}
{{<img src="usb-server.jpg" alt="USB连接到目标计算机" max-width="500px" has-border="false">}}
{{</gallery>}}

{{<notice type="info">}}
**Note**: 最好使用 USB 3.0 接口，因为它们可以为 Pi 提供更多的电力。
{{</notice>}}

### 连接HDMI转换器

请将 HDMI 转换器插入树莓派的任一 USB 端口。随后用 HDMI 线连接 HDMI 转换器，并将另一端接入目标电脑的显示输出接口。

{{<gallery caption="将目标计算机的显示输出连接到 HDMI 转换器，然后将其插入树莓派的 USB 端口。">}}
{{<img src="hdmi-insert.jpg" alt="HDMI输入连接到树莓派" max-width="500px" has-border="false">}}
{{<img src="hdmi-server.jpg" alt="来自目标计算机的HDMI输出连接" max-width="500px" has-border="false">}}
{{</gallery>}}

{{<notice type="info">}}
**Note**: 如果你的目标机器没有 HDMI 输出接口，你可以使用 DP 转 HDMI 线或者 DVI 转 HDMI 线，尽管我没有测试这些。
{{</notice>}}

### 连接网口

如果你通过有线局域网连接树莓派，请将网线插入树莓派的以太网端口：
{{<img src="ethernet-cable.jpg" alt="网线连接到树莓派设备的照片" max-width="700px" caption="将网线连接到你的树莓派" has-border="false">}}

{{<notice type="info">}}
**Note**: 如果你在 [之前](#安装-raspberry-pi-os-lite-操作系统) 通过添加 `wpa_supplicant.conf` 文件配置了无线网络，那么你可以跳过这一步。
{{</notice>}}

### 安装 TinyPilot 软件

通过 SSH 连接到树莓派设备（树莓派操作系统的默认登录凭证是 `pi` / `raspberry`），然后执行下面这段命令：

```bash
curl -sS https://raw.githubusercontent.com/tiny-pilot/tinypilot/master/quick-install \
  | bash -
sudo reboot
```

如果你对一个随便从网上下载的脚本有怀疑，我鼓励你去检查这个脚本的 [源代码](https://github.com/tiny-pilot/tinypilot/blob/master/quick-install)。

该脚本引导一个自包含的 Ansible 环境，其中集成了我的 TinyPilot Ansible 角色。它会安装四项在每次启动时自动运行的服务：

- [nginx](https://nginx.org/): 一个受欢迎的开源 Web 服务器
- [ustreamer](https://github.com/pikvm/ustreamer): 一个轻量级的HTTP 视频流服务器
- [usb-gadget](https://github.com/tiny-pilot/tinypilot/blob/4587f989b6d479034a64b2411c1c9964cdad7261/scripts/usb-gadget/init-usb-gadget): 一个启动树莓派 `USB gadget mode` 的脚本，开启后允许树莓派模拟 USB 设备
- [tinypilot](https://github.com/tiny-pilot/tinypilot): 我为 TinyPilot 创建的 Web 界面

{{<notice type="info">}}
**译者注**: 现在的 TinyPilot 项目已经抛弃了 Ansible
{{</notice>}}

## 使用 TinyPilot

在运行完脚本之后，TinyPilot 就可以使用了，你可以通过这个地址访问：

- [http://raspberrypi/](http://raspberrypi/)

{{<img src="tinypilot-hello-world.png" alt="TinyPilot网页界面截图" max-width="700px" caption="设置完成后，你可以在本地网络中通过 [http://raspberrypi/](http://raspberrypi/) 访问 TinyPilot 的网页界面" has-border="false">}}

## 电源问题

这套设备最大的限制就是电源。依赖目标机器的电源意味着当目标机器关机时，树莓派会遭遇意外断电。

更进一步，树莓派需要 3 A 的稳定电流，但是它也可以在低供电下运行。USB 3.0 接口只能提供 0.9 A 的供电，USB 2.0 仅仅能提供 0.5 A 的供电，这就是为什么我们可以在树莓派的系统日志中看到这些警告：

```bash
 $ sudo journalctl -xe | grep "Under-voltage"
Jun 28 06:23:15 tinypilot kernel: Under-voltage detected! (0x00050005)
```

为了解决这个问题，我与一家工程公司合作制作了一款定制的电路板，将树莓派的 USB-C 端口分为两个。一个端口用来接收 USB 供电，让树莓派可以获得稳定的 3 A 电流。另一个端口用来接收 USB 数据输出，让树莓派可以模拟 USB 键盘。

{{<gallery caption="[TinyPilot 电源连接器](https://tinypilotkvm.com/product/tinypilot-power-connector) 允许树莓派通过其 USB-C 端口接收 3 安培的电力，同时不失去 USB OTG 功能">}}
{{<img src="power-connector.jpg" alt="电源连接器特写" max-width="500px" has-border="false">}}
{{<img src="power-connector-cables.jpg" alt="电源连接器连接到树莓派和microUSB线缆" max-width="500px" has-border="false">}}
{{</gallery>}}

重要的是，电源连接器的数据端口不包括 USB 电源线。这确保了计算机电源与树莓派电源之间的电压差不会引发有害的电力回流。

{{<notice type="warning">}}
**Note**: 没有合适的连接器，在树莓派连接至电脑时使用外部电源供电可能导致硬件损坏。更多详情请 [参阅 TinyPilot 维基页面](https://github.com/tiny-pilot/tinypilot/wiki/Powering-your-TinyPilot-safely)。
{{</notice>}}

## 源代码

TinyPilot 的软件是开源的，开源协议是 [MIT license](https://opensource.org/licenses/MIT)：

- [tinypilot](https://github.com/tiny-pilot/tinypilot.git)： TinyPilot 的 Web 界面和后端
- [ansible-role-tinypilot](https://github.com/tiny-pilot/ansible-role-tinypilot)： 用于安装 TinyPilot 及其依赖项作为 systemd 服务的 Ansible 角色。

## 成品 TinyPilot 设备

[TinyPilot 官网](https://tinypilotkvm.com/)上可直接购买成品设备。我虽是 TinyPilot 公司的初创创始人，[但已于 2024 年 4 月将业务转让](https://mtlynch.io/i-sold-tinypilot/)，如今除作为热心用户外与该公司再无关联。

---

特别感谢 Max Devaev 在 uStreamer 项目上的卓越贡献，以及他为 TinyPilot 所付出的努力。
