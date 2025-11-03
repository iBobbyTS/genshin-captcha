# Genshin CAPTCHA
把原始项目的抹茶小蛋糕，换成原神中各位可爱小蛋糕。
如果图片侵犯到了您的权益，请提交issue或者发邮件到[ibobbyts@gmail.com](mailto:ibobbyts@gmail.com)通知删除。

## 运行项目：
本项目使用Vue框架编写而成
```bash
npm install
npm run dev
```
然后根据终端提示访问 http://localhost:5173/ 即可

## 图片资源：
- 未知
  - 纳西妲
- 画师未说明不可以使用，但也未获得授权
  - 芙宁娜
  - 妮露
- 如果画师说明了不可以使用，请不要使用。

## 贡献说明：
1. 检查src/images/char目录下是否存在该角色英文名的文件夹（全小写）；小蛋糕放在src/images/cake目录下。
2. 检查该文件夹里是否存在该图片。
3. 转换格式：分辨率最大256*256，格式jpeg或png。
3. 按照序号增加图片，图片名称为序号.png/jpeg。
4. 提交PR增加图片时，请在src/char.json[char_detail][角色英文名][char_src]里添加来源。CG写null，自己拍的写自己的GitHub地址，尽量不要写unknown。小蛋糕放在src/char.json[cake_detail][小蛋糕英文名]里。

## TODO
- 把图片移动到角色文件夹里（代码也要改）
- 增加角色选择功能
- 底部显示所有图片的来源
- 处理非正方形的图片
- 随机选择1-3个cake和6-8个角色
- 成功和失败语音

## 演化说明：
灵感来自[请选择最萌小蛋糕！省流（纳西妲）](https://www.bilibili.com/video/BV1VAsczqEfc/)
由[VanillaNahida/nahida-captcha](https://github.com/VanillaNahida/nahida-captcha)复刻为网页版，视频：[【开源】纳西妲 Na CAPTCHA，请选择世界上最萌小蛋糕！
](https://www.bilibili.com/video/BV1cq1jBwER1)
转载使用本仓库请标明原作者，谢谢配合！
