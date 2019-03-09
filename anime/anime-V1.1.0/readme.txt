名称：动画
文件：anime


相对上一个版本：
【V1.0.0】

--对于动画对象闭包（getAnime()）增加了更多的操作函数


当前版本：

【V1.1.0】

--播放顺序，速度，绘制坐标设置

--播放开始和结束位置的设置

--播放，暂停，结束

--顺序帧数据处理

====================
--初始化动画系统

initAnime()

初始化动画系统

====================
--添加动画

addAnime(string,string,number,string)

添加动画对象

====================
--绘制动画

drawAnime(string)

绘制一个指定动画

====================
--开始动画

staAnime(string)

开始播放一个指定动画

====================
-暂停动画

stopAnime(string)

暂停播放一个指定动画

====================
--结束动画

endAnime(string)

结束播放一个指定动画

====================
--破坏动画

desAnime(string)

释放一个指定动画在系统中的引用，交给GC处理

====================
--指定动画播放位置

setAnimePos(string)

返回一个指定动画的闭包，用于操作位置
	--afterPos()
	播放上一帧
	--nextPos()
	播放下一帧
	--setPos()
	设置播放位置

====================
--设置动画数据

setAnimeData(string)

返回一个指定动画的闭包，用于操作帧数据
	--addAnime(number,table)
	添加一组动画帧
	--desAnime(number)
	破坏指定动画帧
	--altAnime(number,number)
	替换指定动画帧
	--moveAnime(number,number)
	移动指定动画帧

====================
--设置动画播放顺序

setAnimeOrder(string,order)

设置动画播放顺序

====================
--设置动画坐标

setAnimeAxis(string,table)

设置动画绘制坐标

====================
--设置动画速度

setAnimeSpeed(string,number)

设置动画帧的切换速度

====================
--获得动画对象

getAnime(string)

获得动画对象闭包，用于操作
	--getW()
	获得图像宽
	--getH()
	获得图像高
	--getPos()
	获得当前帧位置
	--setAxis(table)
	设置坐标
	--setNowPos(number)
	设置当前播放帧位置
	--setStaPos(number)
	--设置开始播放帧位置
	--setEndPos(number)
	设置结束播放帧位置
	--staAnime()
	开始播放
	--stopAnime()
	暂停播放
	--endAnime()
	结束播放

====================
--获得动画当前播放位置

getAnimePos(string)

获得动画的当前帧，返回number（整数）

====================
--保留函数，设置动画层

setAnimeLayer(...)

无


额外注释：
====================
无