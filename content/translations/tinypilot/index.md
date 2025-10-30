---
srcTitle: "TinyPilot: Build a KVM Over IP for Under $100"
srcDate: "2020-07-23"
srcLink: "https://mtlynch.io/tinypilot/"
srcAuthor: "Michael Lynch"

title: "100$以内构建一台KVM Over IP设备"
description: 100$以内构建一台KVM over IP设备
date: "2025-10-27"
images:
  - /translations/tinypilot/opengraph.webp
---

TinyPilot 是一款我自制的远程控制设备，它开源并且构建的价格也很合适。它可以在操作系统启动之前就工作，所以你可以使用它为计算机安装操作系统，或者向我一样为我的[无头服务器](https://mtlynch.io/building-a-vm-homelab/)调试启动失败的问题。

这篇帖子是我创建TinyPilot的过程，并且为你展示我如何使用[树莓派](https://www.raspberrypi.com/)在100$一下构建这台设备。
This post details my experience creating TinyPilot and shows how you can build your own for under $100 using a Raspberry Pi.

{{<img src="win-ubuntu.jpg" alt="使用TinyPilot 连接两台电脑的照片" max-width="600px" caption="通过TinyPilot在Surface上的Chrome控制Ubuntu 笔记本电脑" has-border="false">}}

## 我不想听你的故事，我只是想知道如何构建这个设备

如果你只是被这个设备所吸引，不关心我开发过程中遇到的精彩和挫折，可以跳转到这个部分["怎样构建你自己的TinyPilot"](#Demo)

## Demo

{{<youtube IF-AyHJ8DOI>}}

## 开发TinyPilot的背景

几年之前，为了测试软件，我组装了我自己的家庭服务器（Home Server）。这是非常有价值的投资，今天我还在使用它。
A few years ago, I built my own home server for testing software. It's been a valuable investment, and I use it every day.

{{<img src="homelab-server.jpg" alt="Photo of my homelab VM server" caption="我于2017年搭建的用于托管虚拟机的Home Lab" max-width="650px" has-border="false">}}

我使用ssh或者web界面去访问这台服务器，所以我没有给它配备显示器和键盘。这是一个方便的配置，但是这也常常给我带来很多麻烦。

有时因为我的一些操作失误（频率在几个月一次），会导致服务器无法启动、无法加入网络导致我无法访问它。为了恢复运行，我不得不拔掉所有连接线，将服务器拖到我的桌子旁边，然后连接键盘、显示器以及各种线材到服务器。

## 商业解决方案

朋友们给我安利了iDRAC，对它的使用体验赞不绝口。iDRAC是戴尔服务器中的一种芯片，可在系统启动时提供虚拟控制台。我短暂的考虑过为我的下一台服务器添加iDRAC，但是它昂贵的价格让我很快的打消了这个想法。单单License就需要300$，这还不包含昂贵的定制硬件。

{{<img src="idrac-price.png" alt="Screenshot of $300 price for iDRAC 9 Enterprise license" caption="戴尔iDRAC技术的许可证费用为每台机器300美元，不包括硬件成本" max-width="700px">}}

随后我考察了商用的KVM over IP解决方案。这类设备功能与戴尔iDRAC类似，但属于外接装置，需要连接电脑的键盘(KeyBoard)、显示器(Video)和鼠标(Mouse)端口（KVM即由此得名）。遗憾的是其价格更为高昂，单台设备售价在500至1000美元之间。

{{<img src="raritan-kvm.png" alt="Screenshot of purchsase page for Raritan Dominion KVM over IP" caption="商用的KVM over IP设备的价格在500$~1000$" max-width="800px">}}

虽然我不愿意去来回来的搬服务器，但是为了节省插拔线缆的功夫而去花500$，实在有点说不过去，更何况一年只有几次。

于是，我做了每个不够理性的程序员都会做的事：花了几百个小时打造自己的KVM over IP设备。

## 使用树莓派去构建KVM over IP 设备

[树莓派](https://www.raspberrypi.org/)是小型、廉价的[单板机](https://zh.wikipedia.org/wiki/%E5%8D%95%E6%9D%BF%E6%9C%BA)。它的性能足以运行完整的桌面操作系统，并且售价只需要$30-60，所以它在开发者和业余爱好者群体中很受欢迎。

{{<img src="pi-in-hand.jpg" alt="Raspberry Pi in the palm of my hand" caption="树莓派是一款功能齐全的计算机，所有核心部件都集成在一块小型主板上，价格仅为$30~60" max-width="600px" has-border="false">}}

最新版本的树莓派(作者指的是[树莓派4b](https://www.raspberrypi.com/products/raspberry-pi-4-model-b/))支持[USB on-the-go(USB OTG)](https://www.raspberrypi.org/documentation/hardware/raspberrypi/usb/README.md#overview_pi4), 这允许树莓派可以模拟USB设备，例如键盘、U盘、麦克风。

为了验证 Pi-as-KVM 这个想法，我创建了一个简单的web应用：[Key Mime Pi](https://mtlynch.io/key-mime-pi)

{{<img src="key-mime-pi-interface.png" alt="Screenshot of Key Mime Pi web interface" caption="Key Mime Pi，这是我早期开发的TinyPilot前身，当时仅支持键盘转发功能。" max-width="700px">}}

Key Mime Pi 通过USB连接到目标机器，注册为键盘设备。它也提供了一个web页面通过javascript去监听键盘事件。当用户输入时，Key Mime Pi会捕获这些按键事件，并通过其模拟的USB键盘将其转换为实际键盘动作，从而使目标计算机显示相应字符。关于这一运行机制，[我已经在之前的文章中详细说明](https://mtlynch.io/key-mime-pi#how-it-works)。

## The challenge of capturing video

如果不知道屏幕上显示的是什么，那么键盘指令转发没什么用。所以我的下一步就是采集我服务器的显示，并将它输出到树莓派上，然后渲染视频到浏览器。

关于视频采集的第一个尝试，我使用的是[Lenkeng LKV373A HDMI extender](https://smile.amazon.com/AEMYO-Extender-V3-0-Ethernet-Supports/dp/B01LGUT9HW/)。Daniel Kučera (aka [danman](https://blog.danman.eu/))对这款设备的逆向工程做了很多[贡献](https://blog.danman.eu/new-version-of-lenkeng-hdmi-over-ip-extender-lkv373a/)。可以在eBay上从中国商户那花40$买到，这是我当时能找到的最佳选择。

{{<img src="lkv373a.jpg" alt="Photo of Lenkeng LKV373A HDMI extender" caption="[Lenkeng LKV373A HDMI extender](https://smile.amazon.com/AEMYO-Extender-V3-0-Ethernet-Supports/dp/B01LGUT9HW/)是我尝试的第一款HDMI视频采集器." max-width="600px" has-border="false">}}

因为LKV373A发射器不是专业的视频采集设备，所以采集视频的过程非常棘手。LKV373A发射器预期的使用方式是和LKV373A接收器进行配对，将网络流转换为HDMI输出。在 danman的研究中，他发现一种方式去拦截&捕获视频输出流，但是因为LKV373A使用了非标准的RTP协议，导致绝大多数视频工具无法识别其格式。

幸运的是，danman[为ffmpeg贡献了一个补丁](https://ffmpeg.org/pipermail/ffmpeg-devel/2017-May/211607.html) 使得能够处理LKV377A设备的异常行为，因此我得以通过ffmpeg的视频播放器成功渲染该视频流。

```bash
ffplay -i udp://239.255.42.42:5004
```

{{<img src="ffplay-screenshot.jpg" alt="ffplay 渲染从LKVA373A获取的视频流" caption="使用ffplay渲染从LKVA373A获取的视频流" max-width="800px" has-border="false">}}

这一步，我第一次遇到了贯穿整个项目的难题：延迟。目标计算机和我桌面上播放的回传视频之间有将近一秒的延迟。

{{<img src="lkv373a-latency.jpg" alt="Photo of Lenkeng LKV373A HDMI extender" caption="在视频流还没经过任何处理（比如转码或重新压缩）之前，LKV373A 发射器本身就已经造成了大约 838 毫秒的延迟" max-width="600px" has-border="false">}}

我尝试了很多ffplay的命令去降低延迟，但是始终没有突破800ms大关。这还是在配置比较高的台式机上实现的，如果使用树莓派的话恐怕表现会更差。

幸运的是，我偶然间发现了了一个更好的解决方案。

### HDMI to USB 转换器HDMI to USB dongle

当我浏览推特时，我看到了[Arsenio Dev的一条推文](https://twitter.com/Ascii211/status/1268631069051453448)，关于他刚刚购买的一个低价的HDMI to USB转换器。
While mindlessly scrolling through Twitter, I happened to see [a tweet by Arsenio Dev](https://twitter.com/Ascii211/status/1268631069051453448) about a low-cost HDMI to USB dongle he had just purchased:

{{<img src="arsenio-dev-tweet.jpg" alt="Screenshot of Rufus" caption="A [tweet from Arsenio Dev](https://twitter.com/Ascii211/status/1268631069051453448) tipped me off to a better video capture solution." href="https://twitter.com/Ascii211/status/1268631069051453448" has-border="false">}}

1080p&30帧/s采集视频，有点难以置信，我马上下单了。仅售11$并且包邮。我甚至不知道它的品牌名，所以我就叫他“HDMI转换器”吧。类似的商品有很多，这类商品的关键点在于[MS2109芯片](https://twitter.com/Ascii211/status/1268641527531741186)

{{<img src="hdmi-ebay.png" alt="Screenshot of HDMI for sale on eBay for $11.20" caption="HDMI to USB dongle available on eBay for $11.20 with free shipping" max-width="750px">}}

我收到快递之后，体验出乎意料的好。不需要任何额外的操作，当我把它插入树莓派之后，立即被识别为UVC视频采集设备。
When the device arrived a few days later, it blew me away. Without any tinkering, it showed up as a UVC video capture device as soon as I plugged it in to the Raspberry Pi.

```bash {hl_lines=[7,8,9]}
$ sudo v4l2-ctl --list-devices
bcm2835-codec-decode (platform:bcm2835-codec):
        /dev/video10
        /dev/video11
        /dev/video12

UVC Camera (534d:2109): USB Vid (usb-0000:01:00.0-1.4): <<< HDMI capture dongle
        /dev/video0
        /dev/video1
```

短短几分钟内，我就能捕获并重新推流（/dev/video0 -> ffmpeg -> udp stream）HDMI 视频了。
Within minutes, I was able to capture and restream HDMI video:

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

简直不要太便利！LKV373A接近砖头一样的大小并且需要电源和网线。但是这个HDMI转换器的大小接近U盘，并且只需要一个USB的接口。
It was so darn convenient, too. The LKV373A was nearly brick-sized and required its own power source and Ethernet cable. The HDMI dongle was as small as a thumb drive and required nothing more than a USB port.

{{<img src="lkv373a-vs-dongle.jpg" alt="Comparison of Lenkeng LKV373A with HDMI dongle" caption="The [Lenkeng LKV373A HDMI extender](https://smile.amazon.com/AEMYO-Extender-V3-0-Ethernet-Supports/dp/B01LGUT9HW/) (left) was larger and required more connections than the HDMI dongle (right)." max-width="700px" has-border="false">}}

现在就只有一个问题了，还是延迟。从树莓派获取的视频流是比源计算机慢了7～10秒。
The only problem was, again, latency. The Pi's rebroadcast of the video stream lagged the source computer by 7-10 seconds.

{{<img src="dongle-ffmpeg.jpg" alt="Comparison of Lenkeng LKV373A with HDMI dongle" caption="Using ffmpeg to stream video from my Pi, there was a delay in the video of up to 10 seconds." max-width="700px" has-border="false">}}l

我不确定延迟来自HDMI转换器，树莓派上的ffmpeg，还是我桌面端的ffplay。Arsenio Dev说延迟只有20毫秒，所以似乎可以通过深入研究[ffmpeg那晦涩难懂的命令行参数](https://ffmpeg.org/ffmpeg.html)去降低延迟。
I wasn't sure if this delay came from dongle itself, ffmpeg on the Pi, or ffplay on my desktop. Arsenio Dev reported latency of 20 ms, so it seemed like faster performance was possible if I delved into [ffmpeg's arcane and mysterious command-line flags](https://ffmpeg.org/ffmpeg.html).

又一次的幸运让我免于承担那项令人痛苦的任务。
Another stroke of luck spared me from that miserable task.

### Borrowing from a similar project

当我发布了之前关于Key Mime Pi的帖子之后，我收到了来自Max Davaev的帖子，他鼓励我尝试他的项目--
When I published [my previous blog post](/key-mime-pi/) about Key Mime Pi, I received a comment from Max Devaev, who encouraged me to check out his project, [Pi-KVM](https://github.com/pikvm/pikvm).

{{<img src="maxim-comment.png" alt="Max's comment: Hi:) Take a look at this project: https://github.com/pikvm/pikvm We have already done and debugged many things" caption="Max Devaev pointed me to his existing [Pi-KVM](https://github.com/pikvm/pikvm) project.">}}

{{<img src="melty-breadboard.jpg" align="right" alt="GPIO pins" max-width="500px" caption="My previous experience with breadboards involved [accidentally melting them](/greenpithumb/#why-make-another-raspberry-pi-gardening-bot)." has-border="false">}}

我之前粗略的看过 Pi-KVM，但是这个项目涉及到[面包板](https://zh.wikipedia.org/wiki/%E9%9D%A2%E5%8C%85%E6%9D%BF)和焊接，这让我望而却步。
I had looked at Pi-KVM briefly, but its [requirements of breadboards and soldering](https://github.com/pikvm/pikvm#v2-diagram) scared me off.

在 Max的建议下，我再次看了一下Pi-KVM这个项目，我对Pi-KVM如何解决延迟问题非常感兴趣。我注意到他采集视频使用的工具是[uStreamer](https://github.com/pikvm/ustreamer)
At Max's suggestion, I gave Pi-KVM a second look, particularly interested in how he solved the video latency issue. I noticed that he captured video through a tool called [uStreamer](https://github.com/pikvm/ustreamer).

{{<notice type="info">}}
**Note**: 通过和Max的进一步的交流，我了解到Pi-KVM支持在不需要焊接和面包板的条件下构建。
**Note**: From further discussions with Max, I've learned that Pi-KVM does support builds without soldering or breadboards.
{{</notice>}}

### uStreamer：一款超高速视频流媒体工具 uStreamer: a super-fast video streamer

你是否遇到过一款优秀的工具，它甚至解决了你没有预料到的问题？
Have you ever found a tool that's so good, it solves problems you hadn't even anticipated?

使用uStreamer之后，立马将延迟从8秒降低到500～600ms。并且顺带解决了我很多额外的工作。
Right out of the box, uStreamer reduced my latency from 8 seconds to 500-600 milliseconds. But it also eliminated a whole chain of extra work.

{{<img src="ustreamer-1.jpg" alt="500 ms latency with uStreamer and the HDMI dongle" caption="uStreamer reduced my latency by a factor of 15." max-width="700px" has-border="false">}}

使用uStreamer之前，我不确定怎样把ffmpeg采集的视频呈现在用户的浏览器上，但是我知道这是可以做到的。我测试了这篇教程，它演示了使用HLS协议将ffmpeg视频传输到nginx,但是这引入了更多的延迟。并且遗留了一些问题，如何在HDMI线缆插拔时启停流媒体、如何将视频转码为浏览器友好的格式。
Prior to uStreamer, I wasn't sure how to get video from ffmpeg into the user's browser, but I knew it was possible somehow. I tested this [mostly-accurate tutorial](https://docs.peer5.com/guides/setting-up-hls-live-streaming-server-using-nginx/) for piping video from ffmpeg to nginx using HLS, but it added even more latency. And it still left open problems like how to start and stop streaming on HDMI cable connects and disconnects and how to translate the video to a browser-friendly format.

uStreamer 解决了所有的问题。它本身就运行了一个最小化的HTTP服务器，直接提供浏览器原生支持的[Motion JPEG](https://en.wikipedia.org/wiki/Motion_JPEG)格式。我既无需折腾 HLS 流媒体配置，也不必调试 ffmpeg 与 nginx 的对接问题。
uStreamer solved all of this. It ran its own minimal HTTP server that served video in [Motion JPEG](https://en.wikipedia.org/wiki/Motion_JPEG), a format browsers play natively. I didn't have to bother with HLS streams or getting ffmpeg and nginx to talk to each other.

这么全能的工具，我想是Max fork了一个成熟的项目，然后做的改造。但是我错了，这位大佬使用C语言写了他自己的视频编码器，只为能使树莓派的性能最大化。我立马为这个项目进行[捐献](https://www.paypal.me/mdevaev))，并且也想邀请任何使用这个项目的人捐献。
The tool was so fully-featured that I assumed Max simply forked it from a more mature project, but I was mistaken. This maniac [wrote his own video encoder](https://github.com/pikvm/ustreamer) in C just to squeeze the maximum performance out of Pi hardware. I quickly [donated to Max](https://www.paypal.me/mdevaev) and invite anyone who uses his software to do the same.

## 改进视频传输延迟Improving video latency

uStreamer 将延迟从10秒减少到约600ms。这是一个大的飞跃，但是这个级别的延迟仍是可感知的。我告诉Max我有意进一步的捐赠项目，如何他能找到进一步提升性能的方式，所以我们进行了聊天。
uStreamer reduced my latency from 10 seconds down to ~600 milliseconds. That was a huge leap forward but still a noticeable delay. I told Max I was interested in funding uStreamer further if he could find ways to improve performance, so we got to chatting.

Max 对 HDMI转换器感兴趣，因为他从未见过这种特殊设备。和邀请我使用tmate创建一个共享终端会话，以便他能远程访问我的树莓派。
Max was interested in the HDMI dongle I was using since he'd never seen that particular device. He invited me to create a shared shell session using [tmate](https://tmate.io/) so that he could access my Pi remotely.

{{<img src="maxim-tmate.png" alt="Screenshot of conversation where Max ofers to help me via tmate" caption="Max offered to either help improve latency or frame me for a federal crime. Fortunately, he ended up doing the former." has-border="false">}}

经过几分钟的测试后，Max 跑了一个[`v4l2-ctl` utility]，看到一行输出之后，他非常兴奋，但是我完全摸不着头脑。
After a few minutes of testing how uStreamer ran on my hardware, Max ran the [`v4l2-ctl` utility](https://www.mankier.com/1/v4l2-ctl) and saw a line that fascinated him but totally went over my head:

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

HDMI 转换器已经使用Motion JPEG格式传输视频流！虽然uStreamer's硬件协助编码很快，但是这一步是没有必要的了。Motion JPEG已经可以被浏览器原生识别了。
The HDMI dongle was delivering the video stream in Motion JPEG format! uStreamer's hardware-assisted encoding was fast, but it was totally unnecessary, as modern browsers play Motion JPEG natively.

我配置uStreamer,让它跳过编码直接传输视频流。
We configured uStreamer to skip re-encoding and just pass through the video stream as-is.

{{<img src="tinypilot-latency.jpg" max-width="700px" alt="Photo showing 200ms of latency after eliminating re-encode step" caption="Skipping the extra re-encode step on the Pi reduced latency from 600 ms down to 200 ms." has-border="false">}}

延迟从600ms降低到了200ms。虽然不是即时的，但是在我使用几分钟之后，几乎感觉不到延迟。
Latency went from 600 milliseconds all the way down to 200 ms. It's not instantaneous, but it's low enough to forget the delay after using it for a few minutes.
