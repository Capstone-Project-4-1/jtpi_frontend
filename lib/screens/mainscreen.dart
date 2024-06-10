import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jtpi/models/searchparameters.dart';
import 'package:jtpi/home.dart';
import 'dart:convert';
import 'package:jtpi/screens/searchscreen.dart';
import 'package:jtpi/screens/filterscreen.dart';
import 'package:jtpi/screens/passinfoscreen.dart';
import 'package:jtpi/models/passdetailinfo.dart';
import 'package:jtpi/models/passpreview.dart';
import 'package:jtpi/models/bookmark.dart';
import 'package:shared_preferences/shared_preferences.dart';



class mainscreen extends StatefulWidget {
  const mainscreen({super.key});

  @override
  State<mainscreen> createState() => _mainscreenState();
}

class _mainscreenState extends State<mainscreen> {
  final FocusNode _focusNode = FocusNode();

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List<String> bookmarked = [];
  List<SearchParameter> _searchparameter = [
    SearchParameter(
        query: '0',
        departureCity: '0',
        arrivalCity: '0',
        transportType: '0',
        cityNames: '0',
        period: 0,
        minPrice: 0,
        maxPrice: 0,
        quantityAdults: 0,
        quantityChildren: 0
    )
  ];

  Future<void> _getbookmark() async {
    final SharedPreferences prefs = await _prefs;
    bookmarked = prefs.getStringList('bookmarked') ?? [];
    setState(() {
      //bookmarked = ['1','2','3','4'];
      prefs.setStringList('bookmarked', bookmarked);
    });
  }

  List<PassDetailInfo> searchPass = [];
  List<PassPreview> newpasslist = [];
  List<PassPreview> recommendpasslist = [];

  late String searchT;
  late TextEditingController _textEditingController;

  ////
  Future<List<PassPreview>> _getpasses(String passtype) async {
    final response = await http.get(Uri.parse('http://54.180.69.13:8080/passes/slideshow/' + passtype));

    try {
      if (response.statusCode == 200) {
        print('Hello Message: ${response.body}'); // 로그 출력
        List<dynamic> jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        List<PassPreview> passDetails = jsonResponse.map((item) => PassPreview.fromJson(item)).toList();
        return passDetails;
      } else {
        print('Failed to load hello message: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching hello message: $e');
      return [];
    }
  }

  void getPasses() async {
    try {
      List<PassPreview> newresults = await _getpasses('new');
      List<PassPreview> recommendedresults = await _getpasses('recommended');
      setState(() {
        newpasslist = newresults;
        recommendpasslist = recommendedresults;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        searchT = '';
        goToSearchScreen();
      }
    });
    getPasses();
    _getbookmark();
  }

  @override
  void onSearchTextChanged(String searchText) {
    setState(() {
      searchT = searchText;
      searchPass = passdetailinfo
          .where((pass) =>
          pass.title.contains(searchText)
      ).toList();
    });
  }

  void goToSearchScreen() {
    _searchparameter[0].query = searchT;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => searchscreen(searchparameter: _searchparameter[0], screennumber: 0,)),
    );
    /*Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => searchscreen(searchparameter: _searchparameter[0])),
    ).then((value) {
      // FilterScreen에서 돌아온 후 실행할 작업
      // FilterScreen에서 전달된 값(value)을 확인하고 필요한 로직을 수행
      setState(() {
        _textEditingController.clear();
      });
    });*/
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Color.fromRGBO(253, 253, 254, 1.0),
            foregroundColor: Color.fromRGBO(253, 253, 254, 1.0),
            surfaceTintColor: Color.fromRGBO(253, 253, 254, 1.0),
            elevation: 0,
            toolbarHeight: 115.0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(height: 55,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 60,
                      height: 56,
                      child: Image.asset('assets/logo1.png'),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 48,
                      child: Image.asset('assets/logo2.png'),
                    ),
                    const SizedBox(width: 6),
                  ],
                ),
              ],
            )
        ),
        body: Container(
            color: Color.fromRGBO(253, 253, 254, 1.0), // 배경색 설정
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15.0, 25.0, 15.0, 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    SizedBox(height: 10),
                    Column(
                      children: [
                        Container(
                          //height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            //color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromRGBO(0, 51, 120, 0.04),
                                spreadRadius: 0,
                                blurRadius: 5.0,
                                offset: Offset(0, 6),
                              ),
                              BoxShadow(
                                color: Color.fromRGBO(0, 51, 120, 0.02),
                                spreadRadius: 0,
                                blurRadius: 5.0,
                                offset: Offset(0, -2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(0),
                                  child: TextField(
                                    focusNode: _focusNode,
                                    controller: _textEditingController,
                                    onChanged: onSearchTextChanged,
                                    onSubmitted: (text) {
                                      onSearchTextChanged(text);
                                      goToSearchScreen();
                                    },
                                    style: TextStyle(fontSize: 16, color: Colors.black),
                                    decoration: InputDecoration(
                                      hintText: "교통패스를 검색해주세요.",
                                      hintStyle: TextStyle(fontSize: 15, color: Colors.grey[700]),
                                      prefixIcon: Padding(
                                        padding: EdgeInsets.only(left: 18, right: 8, top: 2), // 아이콘의 왼쪽 여백 설정
                                        child: Icon(
                                          Icons.search,
                                          color: Color.fromRGBO(50,50,70, 0.8),
                                          size: 25,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25),
                                        borderSide: BorderSide(width: 1.7, color: Color.fromRGBO(20, 71, 140, 0.9)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25),
                                        borderSide: BorderSide(width: 1.7, color: Color.fromRGBO(20, 71, 140, 0.9)),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(vertical: 10), // Text 위젯의 위치 조정
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ),
                        SizedBox(height: 15),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0.0, 25.0, 0.0, 25.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '" 교통패스 이름을 모르시나요? "',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height : 5),
                              TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => filterscreen(searchText: '', screennumber: 0,)),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size(50, 30),
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        '조건으로 검색하기',
                                        style: TextStyle(
                                          //decoration: TextDecoration.underline,
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      Container(height: 1.5, width: 111, color: Colors.grey.shade600),
                                    ],
                                  )
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 0),


                    /*Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 100, 0.08),
                            spreadRadius: 2,
                            blurRadius: 7,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Container(
                            color: Colors.white,
                            height: 60,
                            child: Align(
                              alignment: Alignment.center,
                              child: TextField(
                                focusNode: _focusNode,
                                controller: _textEditingController,
                                onChanged: onSearchTextChanged,
                                onSubmitted: (text) {
                                  onSearchTextChanged(text);
                                  goToSearchScreen();
                                },
                                style: TextStyle(fontSize: 17, color: Colors.black),
                                decoration: InputDecoration(
                                  hintText: "교통패스를 검색해주세요.",
                                  hintStyle: TextStyle(fontSize: 16, color: Colors.grey[600]),
                                  prefixIcon: Padding(
                                    padding: EdgeInsets.only(left: 8, right: 5), // 아이콘의 왼쪽 여백 설정
                                    child: Icon(
                                      Icons.search,
                                      color: Color.fromRGBO(200, 200, 240, 1.0),
                                      size: 35,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(width: 2.2, color: Color.fromRGBO(0, 51, 120, 1.0)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(width: 2.2, color: Color.fromRGBO(0, 51, 120, 1.0)),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(vertical: 10), // Text 위젯의 위치 조정
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 15),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 25.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '교통패스 이름을 모르시나요?',
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height : 5),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => filterscreen(searchText: '')),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size(50, 30),
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        '조건으로 검색하기',
                                        style: TextStyle(
                                          //decoration: TextDecoration.underline,
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      Container(height: 1, width: 120, color: Colors.grey.shade500),
                                    ],
                                  )
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),*/
                    SizedBox(height: 80),
                    Padding(
                        padding: const EdgeInsets.fromLTRB(5.0, 16.0, 5.0, 0.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  //Icon(Icons.thumb_up_outlined, size: 19,),
                                  SizedBox(width: 3),
                                  Text(' 신규 패스', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              SizedBox(height: 8),
                              Container(
                                height: 120,
                                child: PageView.builder(
                                  itemCount: newpasslist.length,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () {
                                        // 해당 항목을 눌렀을 때 passinfoscreen으로 이동
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => passinfoscreen(passID: newpasslist[index].passid),
                                          ),
                                        );
                                      },
                                      child: Stack(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(0),
                                              color: Colors.grey,
                                              image: DecorationImage(
                                                image: NetworkImage(newpasslist[index].imageURL),
                                                fit: BoxFit.cover,
                                                colorFilter: ColorFilter.mode(
                                                  Colors.black.withOpacity(0.1), // 어둡게 만들기 위한 색상 및 투명도 설정
                                                  BlendMode.darken, // 어둡게 만들기 위해 BlendMode.darken 사용
                                                ),
                                              ),
                                            ),
                                            width: double.infinity,
                                            child: Align(
                                              alignment: Alignment.bottomLeft, // 왼쪽 하단으로 정렬
                                              child: Padding(
                                                padding: EdgeInsets.all(10.0),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min, // 최소 크기로 설정
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'NEW !!',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 19,
                                                        fontWeight: FontWeight.w600,
                                                        shadows: [
                                                          Shadow(
                                                            color: Colors.grey.shade900,
                                                            offset: Offset(0, 0), // 그림자 위치 (수평, 수직)
                                                            blurRadius: 5,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 230,
                                                      child: Text(
                                                        newpasslist[index].title,
                                                        softWrap: true,
                                                        maxLines: 2,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 19,
                                                          fontWeight: FontWeight.w800,
                                                          shadows: [
                                                            Shadow(
                                                              color: Colors.grey.shade400,
                                                              offset: Offset(0, 0), // 그림자 위치 (수평, 수직)
                                                              blurRadius: 5, // 그림자 흐림 정도
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 10,
                                            right: 10,
                                            child: Container(
                                                width: 40,
                                                padding: EdgeInsets.fromLTRB(8,3,8,3),
                                                decoration: BoxDecoration(
                                                  color: Colors.black54,
                                                  borderRadius: BorderRadius.circular(30),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    '${index + 1}/${newpasslist.length}', // 현재 페이지 / 전체 페이지 수
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 11.5,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                )
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 10,
                                            right: 10,
                                            child: Container(
                                                width: 90,
                                                padding: EdgeInsets.all(5),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(40),
                                                ),
                                                child: Padding(
                                                    padding: EdgeInsets.fromLTRB(5,0,2,0),
                                                    child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        children: [
                                                          Text(
                                                            '보러가기 ', // 현재 페이지 / 전체 페이지 수
                                                            style: TextStyle(
                                                              color: Colors.black,
                                                              fontSize: 11.5,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                          Icon(
                                                            Icons.arrow_forward,
                                                            color: Colors.black,
                                                            size: 13,
                                                          ),
                                                        ]
                                                    )
                                                )
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(height: 25),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  //Icon(Icons.thumb_up_outlined, size: 20,),
                                  SizedBox(width: 3),
                                  Text(' JTPI 추천 패스', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              SizedBox(height: 8),
                              Container(
                                height: 120,
                                child: PageView.builder(
                                  itemCount: recommendpasslist.length,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () {
                                        // 해당 항목을 눌렀을 때 passinfoscreen으로 이동
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => passinfoscreen(passID: recommendpasslist[index].passid),
                                          ),
                                        );
                                      },
                                      child: Stack(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(0),
                                              color: Colors.grey,
                                              image: DecorationImage(
                                                image: NetworkImage(recommendpasslist[index].imageURL),
                                                fit: BoxFit.cover,
                                                colorFilter: ColorFilter.mode(
                                                  Colors.black.withOpacity(0.1), // 어둡게 만들기 위한 색상 및 투명도 설정
                                                  BlendMode.darken, // 어둡게 만들기 위해 BlendMode.darken 사용
                                                ),
                                              ),
                                            ),
                                            width: double.infinity,
                                            child: Align(
                                              alignment: Alignment.bottomLeft, // 왼쪽 하단으로 정렬
                                              child: Padding(
                                                padding: EdgeInsets.all(10.0),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min, // 최소 크기로 설정
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      width: 230,
                                                      child: Text(
                                                        recommendpasslist[index].title,
                                                        softWrap: true,
                                                        maxLines: 2,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 19,
                                                          fontWeight: FontWeight.w800,
                                                          shadows: [
                                                            Shadow(
                                                              color: Colors.grey.shade400,
                                                              offset: Offset(0, 0), // 그림자 위치 (수평, 수직)
                                                              blurRadius: 5, // 그림자 흐림 정도
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 10,
                                            right: 10,
                                            child: Container(
                                                width: 40,
                                                padding: EdgeInsets.fromLTRB(8,3,8,3),
                                                decoration: BoxDecoration(
                                                  color: Colors.black54,
                                                  borderRadius: BorderRadius.circular(30),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    '${index + 1}/${recommendpasslist.length}', // 현재 페이지 / 전체 페이지 수
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 11.5,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                )
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 10,
                                            right: 10,
                                            child: Container(
                                                width: 90,
                                                padding: EdgeInsets.all(5),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(40),
                                                ),
                                                child: Padding(
                                                    padding: EdgeInsets.fromLTRB(5,0,2,0),
                                                    child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        children: [
                                                          Text(
                                                            '보러가기 ', // 현재 페이지 / 전체 페이지 수
                                                            style: TextStyle(
                                                              color: Colors.black,
                                                              fontSize: 11.5,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                          Icon(
                                                            Icons.arrow_forward,
                                                            color: Colors.black,
                                                            size: 13,
                                                          ),
                                                        ]
                                                    )
                                                )
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              )
                            ]
                        )
                    ),
                  ],
                ),
              ),
            )
        ),
    );
  }
}
