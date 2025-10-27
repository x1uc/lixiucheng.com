---
srcTitle: "TinyPilot: Build a KVM Over IP for Under $100"
srcDate: "2020-07-23"
srcLink: "https://mtlynch.io/tinypilot/"
srcAuthor: "Michael Lynch"

title: "100$以内构建一台KVM Over IP设备"
description: 100$以内构建一台KVM Over IP设备
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

因为我的一些操作失误（频率在几个月一次），会导致服务器无法启动、无法加入网络导致我无法访问它。为了恢复运行，我不得不拔掉所有连接线，将服务器拖到我的桌子旁边，然后连接键盘、显示器以及各种线材到服务器。

## 商业解决方案

朋友们给我安利了iDRAC，对它的使用体验赞不绝口。iDRAC是戴尔服务器中的一种芯片，可在系统启动时提供虚拟控制台。我短暂的考虑过为我的下一台服务器添加iDRAC，但是它昂贵的价格让我很快的打消了这个想法。单单License就需要300$，这还不包含昂贵的定制硬件。

{{<img src="idrac-price.png" alt="Screenshot of $300 price for iDRAC 9 Enterprise license" caption="戴尔iDRAC技术的许可证费用为每台机器300美元，不包括硬件成本" max-width="700px">}}

随后我考察了商用的KVM Over IP解决方案。这类设备功能与戴尔iDRAC类似，但属于外接装置，需要连接电脑的键盘(KeyBoardKeyBoard)、显示器(Video)和鼠标(Mouse)端口（KVM即由此得名）。遗憾的是其价格更为高昂，单台设备售价在500至1000美元之间。

{{<img src="raritan-kvm.png" alt="Screenshot of purchsase page for Raritan Dominion KVM over IP" caption="商用的KVM Over IP设备的价格在500$~1000$" max-width="800px">}}

虽然我不愿意去来回来的搬服务器，但是为了节省插拔设备的功夫而去花500$，实在有点说不过去，更何况一年只有几次。

于是，我做了任何不够理性的程序员都会做的事：花了几百个小时打造自己的KVM Over IP设备。