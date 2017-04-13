---
title: Mac，让工作更加高效
date: 2017-04-06 12:21:33
categories: work
---

> 有幸跟秋哥工作了一段时间，下面分享下我们团队为了更加高效地工作与配合对 mac 做的一系列配置

# 改键

这里我们需要把 fn 键与 control 键对调同时将 caps lock 键映射成 escape 键。首先将 fn 键与 control 键对调是因为 mac 默认 fn 处于键盘最左下角位置而使用相对频繁的 control 键处于 fn 右边，由于我们是用小拇指摁 control 键，按照 mac 的默认布局，每次小拇指摁 control 键小拇指是弯曲的，对小拇指有一定的压迫，长此以往容易造成小拇指弯曲定型，而若 control 键处于 fn 的位置，小拇指摁 control 键时是笔直的，避免对小拇指的伤害；其次将 caps lock 键映射成 escape 键是因为我们后面会讲到并在实际开发中会大量用到 vim 快捷键，将 caps lock 键映射成 escape 键可以方便我们退出 vim 模式，更何况使用带 toolbar 的 mac 摁 escape 简直是反人类。

我们将使用 Karabiner-Elements 改建，点击进入该[项目](https://github.com/tekezo/Karabiner-Elements)或者直接[下载](https://pqrs.org/latest/karabiner-elements-latest.dmg)，安装后就可以配置了，下面是示范下配置 fn 键映射 control 键的过程。

* 当我们安装 Karabiner-Elements 并打开后即可看到这个界面![](https://okwmjvg92.qnssl.com/Screen%20Shot%202017-04-06%20at%2012.55.32%20PM.png)
* 点击左下方的 Add item 后会可以添加一行映射![](https://okwmjvg92.qnssl.com/Screen%20Shot%202017-04-06%20at%201.00.12%20PM.png)
* 还没有映射关系，首先点击 From key 这边的下拉框并选择 fn 然后点击 To key 那边的下拉框选择 left_control，操作完后即可建立 fn 对 left control 键的映射，现在摁 fn 键就相当于摁 control 键啦![](https://okwmjvg92.qnssl.com/Screen%20Shot%202017-04-06%20at%201.03.46%20PM.png)
* 接着我们添加 left control 对 fn 以及 caps lock 对 escape 的映射，完成后即可看到![](https://okwmjvg92.qnssl.com/Screen%20Shot%202017-04-06%20at%201.08.27%20PM.png)

现在你可以验证下了，同时这里有个需要注意的地方是我们不需要将 escape 键映射成 caps lock 键，需要大写的话直接摁住 shift 键输入即可大写。同时虽然现在实际上 fn 已经跟 control 对调了，但视觉上键盘的 fn 依然是处于最左下角位置，容易造成误解。不怕不怕，因为 mac 采用巧克力键盘，所以我们可以把 fn 和 control 键扣下来并对调啦，我的是 2015 年版的 mac，貌似 2016 年版的 mac 有点难弄，实在扣不下来也不要太暴力哈。

<!-- more -->

# 改快捷键

这个步骤主要是为了统一团队的关键快捷键，方便协作时候无缝转换，如果不需要的话可以看下一节哈。

* 到 System Preferences - Trackpad 将 Swipe between full-sreen apps 的手势换成 Swipe left or right with four fingers![](https://okwmjvg92.qnssl.com/Screen%20Shot%202017-04-06%20at%201.24.59%20PM.png)
* 到 System Preferences - Accessibility - Mouse & Trackpad - Trackpad Options 中选中 Enable dragging 并将行为选择为 three finger drag![](https://okwmjvg92.qnssl.com/Screen%20Shot%202017-04-06%20at%201.29.45%20PM.png)
*  到 System Preferences - Keyboard - Keyboard 中选中 Use F1, F2, etc. keys as standard function keys，设置这个后调节亮度等等需要先摁住 fn 键![](https://okwmjvg92.qnssl.com/Screen%20Shot%202017-04-06%20at%201.33.28%20PM.png)
* 到 System Preferences - Keyboard - Shortcuts - Spotlight 将 Show Spotlight search 快捷键换成 option + r![](https://okwmjvg92.qnssl.com/Screen%20Shot%202017-04-06%20at%201.37.47%20PM.png)
* 到 System Preferences - Keyboard - Shortcuts - Input Sources 将 Select the previous input source 快捷键换成是 control + space![](https://okwmjvg92.qnssl.com/Screen%20Shot%202017-04-06%20at%201.40.22%20PM.png)

# 全局 Vim 快捷键

使用过 vim 的同学都应该知道 vim 的强大之处吧，特别是在 vim 模式中我们可以直接键入 k、j、h、l 控制光标上下左右，这样我们就不用移动光标时笨拙地需要使用鼠标或者使用右下角的方向键啦！！所以我们接下来将把全局的 option + k/j/h/l 映射成是上下左右方向键。

我们需要使用到 Keyboard Maestro，点击进入[官网](https://www.keyboardmaestro.com/main/)，然后下载最新版本并安装，安装后需要到 System Preferences - Security & Privacy - Accessibility 授予 Keyboard Maestro 权限。

安装完成后默认有些快捷方式，为了防止误会我们先清空全部默认的快捷方式![](https://okwmjvg92.qnssl.com/Screen%20Shot%202017-04-06%20at%202.05.01%20PM.png)

首先我们注意到在每个标签页下面分别有 `+`、`-`、`√`，点击 `+` 和 `-` 分别是添加和删除一项，而点击 `√` 则是启用或者停用该项。这里需要注意！！！变成浅色调说明其处于停用状态，即上图中 mine2 处于停用状态,同时设置好一项后不用再点击右上角那个大 `√` 了，点击后就会变成 `X` 和浅色调，即停用了，一定要注意这个__变态交互__（敲黑板）！！！

清空默认后，喜欢探索不想清空可以先停用，然后再逐个启用试试效果![](https://okwmjvg92.qnssl.com/Screen%20Shot%202017-04-06%20at%202.21.36%20PM.png)

接下来就是配置过程，后面也给出了导入文件，下载后直接双击即可导入。

* 方便教程，这里新建一个文件夹 ![](https://okwmjvg92.qnssl.com/vim-mode-img1.png)
* 新建一个宏![](https://okwmjvg92.qnssl.com/vim-mode-img2.png)
* 点击 `New Trigger` 建立一个触发器，接着点击 `Hot Key Trigger`![](https://okwmjvg92.qnssl.com/vim-mode-img3.png)
* 点击 `This hot key` 下面的方框让其底色变成蓝色，然后键入我们想要的的快捷键 `option + j`，同时将方框旁边默认的 `is pressed`  改成 `is down`  ![](https://okwmjvg92.qnssl.com/vim-mode-img4.png)
* 点击下方的 `New Action`，在左边的弹出框的搜索栏中键入 `type`，选择 `Type a Keystroke`  ![](https://okwmjvg92.qnssl.com/vim-mode-img5.png)
* 接着同理，点击 `Simulate keystroke` 右边的方框使其背景色变成蓝色，键入 `方向键下`  ![](https://okwmjvg92.qnssl.com/vim-mode-img6.png)
* 这时候已经成功了，但我们希望快捷键按住时能持续触发。单击 `Type the Down Arrow Keystroke` 右侧 的齿轮按钮，在弹出的选项中选择 `Press and Hold`。注意：只有配合刚刚按照上面说的将触发器从 `is pressed` 改成 `is down` 后才会持续触发有效果  ![](https://okwmjvg92.qnssl.com/vim-mode-img7.png)
* 同理我们接着把剩下的快捷键 option + h\k\l 都改了![](https://okwmjvg92.qnssl.com/Screen%20Shot%202017-04-06%20at%202.33.39%20PM.png)
* 当然，你可以直接[下载](https://okwmjvg92.qnssl.com/Vim.kmmacros?attname=)并双击即可导入

现在你可以验证下 option + k/j/h/l 是不是分别映射成上下左右方向键了呀。对了，Keyboard Maestro 是有免费试用期的，过了的话需要注册码，想支持作者的话推荐购买，囊中羞涩的就要考验你们的搜索能力了（微笑脸）。

# 福利时刻

在使用 windows 时我比较喜欢通过 win + l 直接锁屏，通过 Keyboard Maestro 我们在 mac 上也可以很方便实现啦，因为 command + l 有默认行为，所以我们的锁屏快捷键是 command + option + l，直接[下载](https://okwmjvg92.qnssl.com/Login%20Window.kmmacros?attname=)双击导入即可
