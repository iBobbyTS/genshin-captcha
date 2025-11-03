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
- 如果画师说明了不可以使用，请不要使用（[示例](https://www.pixiv.net/en/artworks/136264010)）。

## 贡献说明：
1. 在src/images/char下添加文件夹，文件夹名称为全小写的角色英文名（如furina）。
2. 检查角色对应的小蛋糕是否存在于src/images/cake，不存在则添加（一个角色可以存在多个小蛋糕）。
3. (可选)添加角色语音，语音文件放在src/images/char/{角色英文名}/voice/{success/fail}目录下。
4. 添加图片：把正方形的图片放在src/images/char/{角色英文名}目录下，按顺序命名。网上找的图片必须记录来源。
5. 在src/char.json中添加角色信息：
  1. 在char数组中添加角色英文名。
  2. 在char_detail对象中添加一组key-value，key是角色英文名，value如下：
    1. name：角色中文名。
    2. cake_name：角色对应的小蛋糕名称（如“可爱的蓝莓小蛋糕”）。
    3. cake_list：角色对应的小蛋糕英文名（如妮露对应草莓和帕蒂莎兰，则写["strawberry", "padisarah"]）。
    4. 在char_src对象中添加角色图片来源：
      1. key：图片名称（如1.png）；value：图片来源，如果图片是CG，写null，自己拍的写自己的GitHub地址，尽量不要写unknown。
  3. 在cake_detail对象中添加小蛋糕信息：
    1. key：小蛋糕英文名；value：一组key-value：
      1. key：图片名称（如1.png）；value：图片来源。

## TODO
- 随机选择1-3个cake和6-8个角色

## 演化说明：
灵感来自[请选择最萌小蛋糕！省流（纳西妲）](https://www.bilibili.com/video/BV1VAsczqEfc/)
由[VanillaNahida/nahida-captcha](https://github.com/VanillaNahida/nahida-captcha)复刻为网页版，视频：[【开源】纳西妲 Na CAPTCHA，请选择世界上最萌小蛋糕！
](https://www.bilibili.com/video/BV1cq1jBwER1)
转载使用本仓库请标明原作者，谢谢配合！
