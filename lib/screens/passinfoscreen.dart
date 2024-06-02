import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jtpi/models/passdetailinfo.dart';
import 'package:jtpi/models/passpreview.dart';
import 'package:intl/intl.dart'; // intl 패키지 임포트
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jtpi/models/bookmark.dart';
import 'package:shared_preferences/shared_preferences.dart';

class passinfoscreen extends StatefulWidget {
  final int passID;

  passinfoscreen({required this.passID});

  @override
  _passinfoscreenState createState() => _passinfoscreenState();
}

class _passinfoscreenState extends State<passinfoscreen> with SingleTickerProviderStateMixin {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List<String> bookmarked = [];

  List<PassDetailInfo> passDetailInfo = [
    PassDetailInfo(
      passid: 0,
      transportType: '0',
      imageURL: '0',
      title: '0',
      price: '0',
      cityNames: '0',
      productDescription: '0',
      period: 0,
      benefit_information: '0',
      reservation_information: '0',
      refund_information: '0',
    ),
  ];
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  bool _showTabBar = false;
  Color _titleColor = Colors.white;

  final GlobalKey _rootKey = GlobalKey();
  final GlobalKey _descriptionKey = GlobalKey();
  final GlobalKey _benefitKey = GlobalKey();
  final GlobalKey _reservationKey = GlobalKey();
  final GlobalKey _refundKey = GlobalKey();

  ////
  Future<List<PassDetailInfo>> passdetailinfo(String id) async {

    final response = await http.get(Uri.parse('http://54.180.69.13:8080/passes/'+'${id}'));

    try {
      if (response.statusCode == 200) {
        print('Hello Message: ${response.body}'); // 로그 출력
        Map<String, dynamic> jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        PassDetailInfo passDetail = PassDetailInfo.fromJson(jsonResponse);
        return [passDetail];
      } else {
        print('Failed to load hello message: ${response.statusCode}');
        return passDetailInfo;
      }
    } catch (e) {
      print('Error fetching hello message: $e');
      return passDetailInfo;
    }

  }

  void _passdetailinfo() async {
    String _passid = widget.passID.toString();
    //String _passid = '1';

    try {
      List<PassDetailInfo> results = await passdetailinfo(_passid);

      setState(() {
        passDetailInfo = results;
      });
    } catch (e) {
      print('Error: $e');
    }
  }
////

  Future<void> _getbookmark() async {
    final SharedPreferences prefs = await _prefs;
    bookmarked = prefs.getStringList('bookmarked') ?? [];
    prefs.setStringList('bookmarked', bookmarked);
  }
  Future<void> _addbookmark(String _passid) async {
    final SharedPreferences prefs = await _prefs;
    bookmarked = prefs.getStringList('bookmarked') ?? [];
    bookmarked.add(_passid);
    prefs.setStringList('bookmarked', bookmarked);
    _getbookmark();
  }
  Future<void> _removebookmark(String _passid) async {
    final SharedPreferences prefs = await _prefs;
    bookmarked = prefs.getStringList('bookmarked') ?? [];
    bookmarked.removeWhere((item) => item == _passid);
    prefs.setStringList('bookmarked', bookmarked);
    _getbookmark();
  }
  ///

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _scrollController.addListener(() {
      final scrollPosition = _scrollController.position.pixels;
      if (scrollPosition > 200 && !_showTabBar) {
        setState(() {
          _showTabBar = true;
        });
      } else if (scrollPosition <= 200 && _showTabBar) {
        setState(() {
          _showTabBar = false;
        });
      }

      final newColorValue = (scrollPosition / 200).clamp(0.0, 1.0);
      setState(() {
        _titleColor = Color.lerp(Colors.white, Colors.black, newColorValue)!;
      });

    });
    _passdetailinfo();
    _getbookmark();
  }

  void _checkTabPosition() {
    final benefitBox = _benefitKey.currentContext?.findRenderObject() as RenderBox?;
    final reservationBox = _reservationKey.currentContext?.findRenderObject() as RenderBox?;
    final refundBox = _refundKey.currentContext?.findRenderObject() as RenderBox?;
    double pk = refundBox?.localToGlobal(Offset.zero, ancestor: _rootKey.currentContext!.findRenderObject())?.dy ?? double.infinity;


    final benefitPosition = benefitBox?.localToGlobal(Offset.zero, ancestor: _rootKey.currentContext!.findRenderObject())?.dy ?? double.infinity;
    final reservationPosition = reservationBox?.localToGlobal(Offset.zero, ancestor: _rootKey.currentContext!.findRenderObject())?.dy ?? double.infinity;
    final refundPosition = refundBox?.localToGlobal(Offset.zero, ancestor: _rootKey.currentContext!.findRenderObject())?.dy ?? double.infinity;

    final scrollPosition = _scrollController.position.pixels;

    if (scrollPosition >= pk) {
      _tabController.animateTo(2);
    }else if (scrollPosition >= refundPosition) {
      _tabController.animateTo(1);
    } else if (scrollPosition >= reservationPosition) {
      _tabController.animateTo(0);
    } else if (scrollPosition >= benefitPosition ) {
      _tabController.animateTo(0);
    }
  }

  void _scrollToIndex(int index) {
    RenderBox renderBox;
    Offset position;
    switch (index) {
      case 0:
        renderBox = _descriptionKey.currentContext!.findRenderObject() as RenderBox;
        position = renderBox.localToGlobal(
            Offset.zero, ancestor: _rootKey.currentContext!.findRenderObject());
        _scrollController.animateTo(
          _scrollController.offset + position.dy -
              AppBar().preferredSize.height -
              (_showTabBar ? kTextTabBarHeight : 0),
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        break;
      case 1:
        renderBox = _benefitKey.currentContext!.findRenderObject() as RenderBox;
        position = renderBox.localToGlobal(
            Offset.zero, ancestor: _rootKey.currentContext!.findRenderObject());
        _scrollController.animateTo(
          _scrollController.offset + position.dy -
              AppBar().preferredSize.height -
              (_showTabBar ? kTextTabBarHeight : 0),
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        break;
      case 2:
        renderBox = _reservationKey.currentContext!.findRenderObject() as RenderBox;
        position = renderBox.localToGlobal(
            Offset.zero, ancestor: _rootKey.currentContext!.findRenderObject());
        _scrollController.animateTo(
          _scrollController.offset + position.dy -
              AppBar().preferredSize.height -
              (_showTabBar ? kTextTabBarHeight : 0),
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        break;
      case 3:
        renderBox = _refundKey.currentContext!.findRenderObject() as RenderBox;
        position = renderBox.localToGlobal(
            Offset.zero, ancestor: _rootKey.currentContext!.findRenderObject());
        _scrollController.animateTo(
          _scrollController.offset + position.dy -
              AppBar().preferredSize.height -
              (_showTabBar ? kTextTabBarHeight : 0),
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        break;
      default:
        _scrollController.animateTo(
          0,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    //String price = NumberFormat('#,###').format(passDetailInfo[0].price);
    String price = (passDetailInfo[0].price);

    return Scaffold(
      body: Container(
        key: _rootKey,
        color: Color.fromRGBO(254, 254, 254, 1.0), // 배경색 설정
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              backgroundColor: Color.fromRGBO(254, 254, 254, 1.0),
              foregroundColor: Color.fromRGBO(254, 254, 254, 1.0),
              surfaceTintColor: Color.fromRGBO(254, 254, 254, 1.0),
              leading: Column(
                  children: [
                    SizedBox(height: 10,),
                    Container(
                      height: 45,
                      child: IconButton(
                        padding: EdgeInsets.zero, // 패딩 설정
                        constraints: BoxConstraints(),
                        icon: Icon(
                          Icons.arrow_back_ios_new,
                          color: _titleColor,
                          shadows: <Shadow>[Shadow(color: Color.fromRGBO(0, 0, 0, 0.6), blurRadius: 5.0)],
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ]
              ),
              pinned: true,
              expandedHeight: 200.0,
              flexibleSpace: FlexibleSpaceBar(
                background: Image.network(
                  passDetailInfo[0].imageURL,
                  fit: BoxFit.cover,
                  errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                    return Image.asset(
                      'assets/logo3.png',
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
              bottom: _showTabBar
                  ? TabBar(
                controller: _tabController,
                unselectedLabelColor: Colors.grey, // 선택되지 않은 탭의 글자색
                labelStyle: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold), // 선택된 탭의 스타일
                unselectedLabelStyle: TextStyle(fontSize: 16.0), // 선택되지 않은 탭의 스타일
                indicatorSize: TabBarIndicatorSize.label, // 탭바 인디케이터 크기
                tabs: [
                  Tab(
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      height: 20, // 탭 높이 설정
                      child: Text('상품 설명'),
                    ),
                  ),
                  Tab(
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      height: 20, // 탭 높이 설정
                      child: Text('혜택'),
                    ),
                  ),
                  Tab(
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      height: 20, // 탭 높이 설정
                      child: Text('예매'),
                    ),
                  ),
                  Tab(
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      height: 20, // 탭 높이 설정
                      child: Text('환불'),
                    ),
                  ),
                ],
                onTap: _scrollToIndex,
              )
                  : null,
              actions: [
                Column(
                  children: [
                    SizedBox(height: 10,),
                    Container(
                  height: 45,
                  child: IconButton(
                    icon: Icon(
                      bookmarked.contains(widget.passID.toString()) ? Icons.star : Icons.star_border,
                      color: bookmarked.contains(widget.passID.toString()) ? Colors.amber : Colors.white,
                    ),
                    iconSize: 40,
                    onPressed: () {
                      setState(() {
                        if (bookmarked.contains(widget.passID.toString())) {
                          _removebookmark(widget.passID.toString());
                        } else {
                          _addbookmark(widget.passID.toString());
                        }
                      });
                    },
                  ),
                )
                    ]
                )
              ],
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(17, 20, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SizedBox(width: 4),
                            Container(
                              padding: EdgeInsets.fromLTRB(0, 2, 0, 2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: Color.fromRGBO(243, 243, 243, 0.95),
                              ),
                              width: 120,
                              height: 30,
                              child: Center(
                                child: Text(
                                  ' ' + passDetailInfo[0].transportType,
                                  style: TextStyle(
                                    color: Color.fromRGBO(0, 0, 0, 0.4),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            SizedBox(width: 3),
                            Text(
                              passDetailInfo[0].title,
                              style: TextStyle(
                                letterSpacing: -1,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                shadows: [
                                  Shadow(
                                    color: Colors.black,
                                    offset: Offset(0, 0), // 그림자 위치 (수평, 수직)
                                    blurRadius: 0.05, // 그림자 흐림 정도
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Colors.blue.shade500,
                              size: 22,
                            ),
                            SizedBox(width: 5),
                            Text(
                              passDetailInfo[0].cityNames,
                              style: TextStyle(
                                letterSpacing: -0.8,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            SizedBox(width: 2),
                            Text(
                              price.split(',')[0] + ' 원',
                              style: TextStyle(
                                letterSpacing: 0,
                                fontSize: 18, // 텍스트 크기 조정
                                fontWeight: FontWeight.bold, // 굵은 글꼴로 설정
                                color: Color.fromRGBO(0, 51, 120, 1.0), // 텍스트 색상 설정
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 2,
                          width: double.infinity,
                          color: Colors.grey.shade300,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 50),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10, key: _descriptionKey,),
                        SizedBox(height: 19),
                        Container(
                          child: Text('상품 설명',
                            style: TextStyle(
                              letterSpacing: 0,
                              fontSize: 18, // 텍스트 크기 조정
                              fontWeight: FontWeight.bold, // 굵은 글꼴로 설정
                              color: Color.fromRGBO(0, 51, 120, 1.0), // 텍스트 색상 설정
                            ),),
                        ),
                        Container(
                          height: 400,
                          child: Text('${passDetailInfo[0].benefit_information}'),
                        ),

                        SizedBox(height: 10, key: _benefitKey,),
                        SizedBox(height: 19),
                        Container(
                          child: Text('혜택',
                            style: TextStyle(
                              letterSpacing: 0,
                              fontSize: 18, // 텍스트 크기 조정
                              fontWeight: FontWeight.bold, // 굵은 글꼴로 설정
                              color: Color.fromRGBO(0, 51, 120, 1.0), // 텍스트 색상 설정
                            ),),
                        ),
                        Container(
                          height: 400,
                          child: Text('${passDetailInfo[0].benefit_information}'),
                        ),

                        SizedBox(height: 10, key: _reservationKey,),
                        SizedBox(height: 19),
                        Container(
                          child: Text('예매',
                            style: TextStyle(
                              letterSpacing: 0,
                              fontSize: 18, // 텍스트 크기 조정
                              fontWeight: FontWeight.bold, // 굵은 글꼴로 설정
                              color: Color.fromRGBO(0, 51, 120, 1.0), // 텍스트 색상 설정
                            ),),
                        ),
                        Container(
                          height: 400,
                          child: Text('${passDetailInfo[0].reservation_information}'),
                        ),

                        SizedBox(height: 10, key: _refundKey,),
                        SizedBox(height: 19),
                        Container(
                          child: Text('환불',
                            style: TextStyle(
                              letterSpacing: 0,
                              fontSize: 18, // 텍스트 크기 조정
                              fontWeight: FontWeight.bold, // 굵은 글꼴로 설정
                              color: Color.fromRGBO(0, 51, 120, 1.0), // 텍스트 색상 설정
                            ),),
                        ),
                        Container(
                          height: 400,
                          child: Text('${passDetailInfo[0].refund_information}'),
                        ),

                        SizedBox(height: 20),
                        Text('ID: ${passDetailInfo[0].passid}'),
                        Text('Description: ${passDetailInfo[0].benefit_information}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
