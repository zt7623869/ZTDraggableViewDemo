
###基本功能
基本的左右拖拽选择，同时也可点选按钮实现滑动
###动画效果
各个卡片间的动画联动，拖拽顶层卡片时，卡片组中的其他卡片跟随运动及形变
刷新卡片组时添加类似洗牌效果的动效
###滑动体验优化
检测滑动手势，当满足一定距离或速度时触发事件
手势结束后根据手势速度完成后续动画，效果自然
###数据加载
将数据数组内的源数据依次填充至用于显示的卡片对象中，当数组内数据量少于一定值时继续请求