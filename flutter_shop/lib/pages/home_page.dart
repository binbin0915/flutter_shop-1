import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shop/config/color.dart';
import 'package:flutter_shop/config/font.dart';
import 'package:flutter_shop/config/string.dart';
import 'package:flutter_shop/service/http_service.dart';
import 'dart:convert';
import 'package:flutter_screenutil/screenutil.dart';

//刷新处理模块
import 'package:flutter_easyrefresh/easy_refresh.dart';

//轮播图
import 'package:flutter_swiper/flutter_swiper.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {
  // 防止刷新处理 保持当前状态
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
  GlobalKey<RefreshFooterState> _footerKey =
      new GlobalKey<RefreshFooterState>();

  // diff算法

  @override
  void initState() {
    super.initState();
    print('首页刷新了');
  }

  @override
  Widget build(BuildContext context) {
//    super.build(context);
    return Scaffold(
      backgroundColor: Color.fromRGBO(244, 245, 245, 1.0),
      appBar: AppBar(
        title: Text(
          KString.homeTitle,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: FutureBuilder(
        future: request('homePageContent', formData: null),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var data = json.decode(snapshot.data.toString());
            List<Map> swiperDataList =
                (data['data']['slides'] as List).cast(); //轮播图
            List<Map> navigatorList =
                (data['data']['category'] as List).cast(); // 分类
            List<Map> recommendList =
                (data['data']['recommend'] as List).cast(); // 商品推荐
            List<Map> floor1 =
                (data['data']['floor1'] as List).cast(); // 底部商品推荐
            Map fp1 = data['data']['floor1Pic']; // 广告
//            print(data);
            return EasyRefresh(
              refreshFooter: ClassicsFooter(
                key: _footerKey,
                bgColor: Colors.white,
                textColor: KColor.refreshTextColor,
                moreInfoColor: KColor.refreshTextColor,
                showMore: true,
                noMoreText: '',
                moreInfo: KString.loading,
                //加载中
                loadReadyText: KString.loadReadyText,
              ),
              child: ListView(
                children: <Widget>[
                  SwiperDiy(
                    swiperDataList: swiperDataList,
                  ),
                  TopNavigator(
                    navigatorList: navigatorList,
                  ),
                  RecommendUI(
                    recommendList: recommendList,
                  ),
                  FloorPic(
                    floorPic: fp1,
                  )
                ],
              ),
              loadMore: () async {
                print('开始加载更多');
              },
            );
          } else {
            return Center(
              child: Text('加载中...'),
            );
          }
        },
      ),
    );
  }
}

//首页轮播组件编写
class SwiperDiy extends StatelessWidget {
  final List swiperDataList;

  SwiperDiy({Key key, this.swiperDataList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: ScreenUtil().setHeight(333),
      width: ScreenUtil().setWidth(750),
      child: Swiper(
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
              onTap: () {},
              child: Image.network(
                "${swiperDataList[index]['image']}",
                fit: BoxFit.cover,
              ));
        },
        // 轮播长度
        itemCount: swiperDataList.length,
        // 增加轮播按钮
        pagination: SwiperPagination(),
        // 是否 自动轮播
        autoplay: true,
      ),
    );
  }
}

//首页分类导航组件
class TopNavigator extends StatelessWidget {
  final List navigatorList;

  TopNavigator({Key key, this.navigatorList}) : super(key: key);

  Widget _gridViewItemUi(BuildContext context, item, index) {
    return InkWell(
      onTap: () {
        //跳转到页面
      },
      child: Column(
        children: <Widget>[
          Image.network(item['image'], width: ScreenUtil().setWidth(95)),
          Text(item['firstCategoryName'])
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 判断分类的长度 是否大于10
    if (navigatorList.length > 10) {
      navigatorList.removeRange(10, navigatorList.length);
    }
    var tempIndex = -1;
    return Container(
      color: Colors.white,
      margin: EdgeInsets.only(top: 5.0),
      height: ScreenUtil().setHeight(150 * 2),
      padding: EdgeInsets.all(3.0),
      child: GridView.count(
        // 禁止滚动
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: 5,
        padding: EdgeInsets.all(4.0),
        children: navigatorList.map((e) {
          tempIndex++;
          return _gridViewItemUi(context, e, tempIndex);
        }).toList(),
      ),
    );
  }
}

// 商品推荐
class RecommendUI extends StatelessWidget {
  final List recommendList;

  RecommendUI({Key key, this.recommendList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5.0),
      child: Column(
        children: <Widget>[
          _titleWidget(),
          _recommendList(context),
        ],
      ),
    );
  }

  // 推荐商品标题
  Widget _titleWidget() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.fromLTRB(10.0, 2.0, 0, 5.0),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
              width: 0.5,
              color: KColor.defaultBorderColor,
            ),
          )),
      child: Text(
        KString.recommendText,
        style: TextStyle(
          color: KColor.homeTitleColor,
        ),
      ),
    );
  }

  // 商品推荐列表
  Widget _recommendList(BuildContext context) {
    return Container(
      height: ScreenUtil().setHeight(360),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: recommendList.length,
        itemBuilder: (context, index) {
          return _item(index, context);
        },
      ),
    );
  }

  // 每个商品
  Widget _item(index, context) {
    return InkWell(
      onTap: () {},
      child: Container(
        width: ScreenUtil().setWidth(280),
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            left: BorderSide(
              width: 0.5,
              color: KColor.defaultBorderColor,
            ),
          ),
        ),
        child: Column(
          children: <Widget>[
            // 防止溢出
            Expanded(
              child: Image.network(
                recommendList[index]['image'],
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(
              height: 5.0,
            ),
            Text(
              '￥${recommendList[index]['presentPrice']}',
              style: TextStyle(
                color: KColor.presentPriceTextColor,
              ),
            ),
            Text(
              '￥${recommendList[index]['oriPrice']}',
              style: KFount.oriPriceStyle,
            ),
          ],
        ),
      ),
    );
  }
}

// 商品推荐中间广告
class FloorPic extends StatelessWidget {
  final Map floorPic;

  FloorPic({Key key, this.floorPic}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10.0),
      child: InkWell(
        child: Image.network(
          floorPic['PICTURE_ADDRESS'],
          fit: BoxFit.cover,
        ),
        onTap: () {
          print('你哈');
        },
      ),
    );
  }
// 推荐商品标题
}
