### 连麦直播-Swift

到[三体官网](http://3ttech.cn)下载最新的SDK，把framework放在TTTLib目录下，使用申请的AppID

1. 该demo使用链接framework的方式，参考other link flags

2. 在framework search path添加framework路径

3. 添加系统库：

> 1. libc++.tbd
> 2. libxml2.tbd
> 3. libz.tbd
> 4. ReplayKit.framework
> 5. CoreTelephony.framework
> 6. SystemConfiguration.framework

4. 设置 bitcode=NO

5. 选择后台音频模式

