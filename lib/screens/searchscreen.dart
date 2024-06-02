import 'package:flutter/material.dart';
import 'package:jtpi/home.dart';
import 'package:jtpi/screens/bookmarkscreen.dart';
import 'package:jtpi/screens/mainscreen.dart';
import 'package:jtpi/screens/filterscreen.dart';
import 'package:jtpi/screens/passinfoscreen.dart';
import 'package:jtpi/models/passdetailinfo.dart';
import 'package:intl/intl.dart'; // intl 패키지 임포트
import 'package:jtpi/util/my_tab.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jtpi/models/passsearchresult.dart';
import 'package:jtpi/models/searchparameters.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class searchscreen extends StatefulWidget {
  final int screennumber;
  final SearchParameter searchparameter;

  searchscreen({required this.screennumber, required this.searchparameter});

  @override
  _searchscreenState createState() => _searchscreenState();
}

class _searchscreenState extends State<searchscreen> {
  List<Widget> myTabs = [
    MyTab(iconData: Icons.search, text: '검색'),
    MyTab(iconData: Icons.star, text: '즐겨찾기'),
  ];
  String _sortBy = '기본순';
  String? selectedValue;

  late TextEditingController _textEditingController;
  late FocusNode _focusNode;
  bool _isFocused = false;
  String _searchText = '';
  List<PassSearchResult> _filteredPassDetailInfo = [];
  int _selectedIndex = 0;

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List<String> bookmarked = [];

  List<SearchParameter> SearchParameters = [
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

  Future<List<PassSearchResult>> _search(String searchText) async {
    /*Map<String, dynamic> searchParams = {
      'query': searchText,
      'departureCity': SearchParameters[0].departureCity,
      'arrivalCity': SearchParameters[0].arrivalCity,
      'transportType': SearchParameters[0].transportType,
      'cityNames': SearchParameters[0].cityNames,
      'duration': SearchParameters[0].period,
      'minPrice': 0,
      'maxPrice': 0,
    };*/
    Map<String, dynamic> searchParams = {
      'query': '이와테 홀리데이 패스',
      'departureCity': '0',
      'arrivalCity': '0',
      'transportType': '0',
      'cityNames': '0',
      'duration': '0',
      'minPrice': 0,
      'maxPrice': 0,
    };

    List<PassSearchResult> allResults = [];
    try {
      print(jsonEncode(searchParams));
      final response = await http.post(
        Uri.parse('http://54.180.69.13:8080/passes/search'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(searchParams),
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        List<PassSearchResult> results = body.map((dynamic item) => PassSearchResult.fromJson(item)).toList();
        allResults.addAll(results);
      } else {
        throw Exception('Failed to load hello message: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
    return allResults;
  }

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

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: widget.searchparameter.query);
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
    if (widget.screennumber == 0) _focusNode.requestFocus();
    _textEditingController.addListener(_onSearchTextChanged);
    _searchText = widget.searchparameter.query.toLowerCase(); // 초기 검색어 설정
    if (widget.searchparameter.query == '0') _textEditingController.text = '';

    SearchParameters[0].query = _searchText;
    SearchParameters[0].departureCity = widget.searchparameter.departureCity;
    SearchParameters[0].arrivalCity = widget.searchparameter.arrivalCity;
    SearchParameters[0].transportType = widget.searchparameter.transportType;
    SearchParameters[0].cityNames = widget.searchparameter.cityNames;
    SearchParameters[0].period = widget.searchparameter.period;
    SearchParameters[0].minPrice = widget.searchparameter.minPrice;
    SearchParameters[0].maxPrice = widget.searchparameter.maxPrice;
    SearchParameters[0].quantityAdults = widget.searchparameter.quantityAdults;
    SearchParameters[0].quantityChildren = widget.searchparameter.quantityChildren;

    if (widget.searchparameter.query == '0') _searchText = '';

      _performSearch(); // 초기 검색 수행
    _getbookmark();
    //printing();
  }

  void printing() {
    print('query: ${SearchParameters[0].query}');
    print('departureCity: ${SearchParameters[0].departureCity}');
    print('arrivalCity: ${SearchParameters[0].arrivalCity}');
    print('transportType: ${SearchParameters[0].transportType}');
    print('cityNames: ${SearchParameters[0].cityNames}');
    print('period: ${SearchParameters[0].period}');
    print('minPrice: ${SearchParameters[0].minPrice}');
    print('maxPrice: ${SearchParameters[0].maxPrice}');
    print('quantityAdults: ${SearchParameters[0].quantityAdults}');
    print('quantityChildren: ${SearchParameters[0].quantityChildren}');
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchTextChanged() {
    setState(() {
      _searchText = _textEditingController.text.toLowerCase();
    });
  }

  Future<void> _performSearch() async {
    if (SearchParameters[0].query == '') SearchParameters[0].query = '0';
    printing();
    if (_searchText.isNotEmpty) {
      List<PassSearchResult> results = await _search(_searchText);
      setState(() {
        _filteredPassDetailInfo = results;
      });
    } else {
      setState(() {
        _filteredPassDetailInfo = [];
      });
    }
  }

  List<PassDetailInfo> _filterPassDetailInfo(String searchText) {
    // 검색어에 따라 passdetailinfo 필터링 및 정렬
    return passdetailinfo
        .where((pass) => pass.title.toLowerCase().contains(searchText))
        .toList()
      ..sort((a, b) {
        // 검색어에 따라 passdetailinfo 정렬
        if (a.title.toLowerCase().contains(searchText) &&
            !b.title.toLowerCase().contains(searchText)) {
          return -1;
        } else if (!a.title.toLowerCase().contains(searchText) &&
            b.title.toLowerCase().contains(searchText)) {
          return 1;
        } else {
          return 0;
        }
      });
  }

  void _handleTabSelection(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 0) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(initialTabIndex: 0,)),
        );
      } else if (_selectedIndex == 1) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(initialTabIndex: 1,)),
        );
      }
    });
  }

  void _handleSort(String sortType) {
    print(sortType);
    setState(() {
      _sortBy = sortType; // 정렬 기준 변경
      if (_sortBy == '기본순') {
        // 기본 정렬 (초기 상태 그대로)
        _performSearch();
      } else if (_sortBy == '저가순') {
        // 저가순 정렬
        _filteredPassDetailInfo.sort((a, b) => (double.parse((a.price).split(',')[0])).compareTo(double.parse((b.price).split(',')[0])));
      } else if (_sortBy == '고가순') {
        // 고가순 정렬
        _filteredPassDetailInfo.sort((a, b) => (double.parse((b.price).split(',')[0])).compareTo(double.parse((a.price).split(',')[0])));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: myTabs.length,
      child: Scaffold(
          backgroundColor: Color.fromRGBO(254, 254, 254, 1.0),
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Color.fromRGBO(254, 254, 254, 1.0),
            foregroundColor: Color.fromRGBO(254, 254, 254, 1.0),
            surfaceTintColor: Color.fromRGBO(254, 254, 254, 1.0),
            elevation: 0,
            leadingWidth: 40,
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
                        color: Colors.grey.shade800,
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => HomeScreen(initialTabIndex: 0,)),
                        );
                      },
                    ),
                  ),
                ]
            ),
            title: Column(
              children: [
                SizedBox(height: 20,),
                Container(
                  height: 60,
                  color: Color.fromRGBO(254, 254, 254, 1.0),
                  child: TextField(
                    controller: _textEditingController,
                    focusNode: _focusNode,
                    style: TextStyle(fontSize: 17, color: Colors.black),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(10, 10, 15, 10), // Text 위젯의 위치 조정
                      hintText: _isFocused ? '' : "교통패스를 검색해주세요.",
                      hintStyle: TextStyle(fontSize: 16, color: Colors.grey),
                      suffixIcon: Padding(
                        padding: EdgeInsets.only(left: 8, right: 5), // 아이콘의 왼쪽 여백 설정
                        child: Icon(
                          Icons.search,
                          color: Color.fromRGBO(200, 200, 240, 1.0),
                          size: 32,
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
                    ),
                    onSubmitted: (value) {
                      SearchParameters[0].query = _searchText;
                      SearchParameters[0].departureCity = '0';
                      SearchParameters[0].arrivalCity = '0';
                      SearchParameters[0].transportType = '0';
                      SearchParameters[0].cityNames = '0';
                      SearchParameters[0].period = 0;
                      SearchParameters[0].quantityAdults = 0;
                      SearchParameters[0].quantityChildren = 0;
                      _performSearch(); // 엔터키를 누르면 검색 수행
                      //printing();
                    },
                  ),
                ),
              ],
            ),
            actions: [SizedBox(width: 18,)],
            titleSpacing: 0,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white, // 배경색을 흰색으로 설정
              borderRadius: BorderRadius.circular(0), // 컨테이너의 모서리를 둥글게 만듦
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5), // 그림자 색상과 투명도 설정
                  spreadRadius: 3, // 그림자 퍼짐 정도
                  blurRadius: 2, // 그림자 흐림 정도
                  offset: Offset(0, 3), // 그림자 위치 조정 (수평, 수직)
                ),
              ],
            ),
            child:               TabBar(tabs: myTabs, onTap: _handleTabSelection,),
          ),
          body: Column(
            children: [
              SizedBox(height: 10),
              Container(
                color: Color.fromRGBO(254, 254, 254, 1.0),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      DropdownButtonHideUnderline(
                        child: DropdownButton2<String>(
                          isExpanded: true,
                          hint: const Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '기본순',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    //fontWeight: FontWeight.bold,
                                    color: Color.fromRGBO(100,100,100,1.0),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          items: <String>['기본순', '저가순', '고가순']
                              .map((String item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: const TextStyle(
                                fontSize: 13.5,
                                //fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          )).toList(),
                          value: selectedValue,
                          onChanged: (String? value) {
                            setState(() {
                              selectedValue = value;
                            });
                            if (value != null) {
                              _handleSort(value); // 선택된 정렬 기준으로 정렬
                            }
                          },
                          buttonStyleData: ButtonStyleData(
                            height: 32,
                            width: 88,
                            padding: const EdgeInsets.only(left: 10, right: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(40),
                              border: Border.all(
                                color: Color.fromRGBO(200,200,200,1.0),
                              ),
                              color: Colors.white,
                            ),
                            elevation: 0,
                          ),
                          iconStyleData: const IconStyleData(
                            icon: Icon(
                              Icons.expand_more,
                            ),
                            iconSize: 20,
                            iconEnabledColor: Color.fromRGBO(100,100,100,1.0),
                            iconDisabledColor: Colors.grey,
                          ),
                          dropdownStyleData: DropdownStyleData(
                            //maxHeight: 100,
                            width: 70,
                            elevation: 1,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(0),
                              color: Colors.white,
                            ),
                            offset: const Offset(9, 0),
                            scrollbarTheme: ScrollbarThemeData(
                              radius: const Radius.circular(40),
                              thickness: MaterialStateProperty.all<double>(6),
                              thumbVisibility: MaterialStateProperty.all<bool>(true),
                            ),
                          ),
                          menuItemStyleData: const MenuItemStyleData(
                            height: 20,
                            padding: EdgeInsets.only(left: 10, right: 10),
                          ),
                        ),
                      ),
                      SizedBox(width: 5,),
                      Container(
                          child: Center(
                            child: IconButton(
                              padding: EdgeInsets.zero, // 패딩 설정
                              constraints: BoxConstraints(),
                              icon: Icon(
                                Icons.tune_sharp,
                                color: Color.fromRGBO(100,100,100, 1.0),
                              ),
                              iconSize: 25,
                              onPressed: () {
                                if (_searchText == '') _searchText = '0';
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => filterscreen(searchText: _searchText)),
                                );
                              },
                            ),
                          )
                      ),
                      SizedBox(width: 18,),
                    ]
                ),
              ),
              _filteredPassDetailInfo.isEmpty
                  ? Expanded(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  color: Colors.white60,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, // 수직 방향 중앙 정렬
                    crossAxisAlignment: CrossAxisAlignment.center, // 수평 방향 중앙 정렬
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 48,
                        color: Colors.deepPurple,
                      ),
                      SizedBox(height: 16), // 아이콘과 텍스트 사이의 간격 조절
                      Text(
                        '검색 결과가 없어요',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 42),
                    ],
                  ),
                ),
              )
                  : Expanded(
                child:Container(
                    color: Colors.white60,
                    child:GridView.builder(
                      itemCount: _filteredPassDetailInfo.length,
                      padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1 / 1.5,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        mainAxisExtent: (MediaQuery.of(context).size.width - 48)/2 + 95,
                      ),
                      itemBuilder: (context, index) {
                        int id = _filteredPassDetailInfo[index].passid;
                        String title = _filteredPassDetailInfo[index].title;
                        //String price = NumberFormat('#,###').format(_filteredPassDetailInfo[index].price);
                        String price = (_filteredPassDetailInfo[index].price).split(',')[0];
                        String cityNames = _filteredPassDetailInfo[index].cityNames;
                        String imageURL = _filteredPassDetailInfo[index].imageURL;

                        return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => passinfoscreen(passID: _filteredPassDetailInfo[index].passid),
                                ),
                              ).then((value) {
                                print(selectedValue);
                                //_performSearch();
                                _getbookmark();
                                //_handleSort(selectedValue.toString());
                                //initState();
                              });
                            },
                            child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          height: (MediaQuery.of(context).size.width - 48)/2,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8.0),
                                            image: DecorationImage(
                                              image: NetworkImage(imageURL), // 이미지 파일 경로 지정
                                              fit: BoxFit.cover, // 이미지를 카드에 맞게 채우도록 설정
                                            ),
                                          ),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              IconButton(
                                                icon: Icon(
                                                  bookmarked.contains(id.toString()) ? Icons.star : Icons.star_border,
                                                  color: bookmarked.contains(id.toString()) ? Colors.amber : Colors.white,
                                                ),
                                                iconSize: 40,
                                                onPressed: () {
                                                  setState(() {
                                                    if (bookmarked.contains(id.toString())) {
                                                      _removebookmark(id.toString());
                                                    } else {
                                                      _addbookmark(id.toString());
                                                    }
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(0, 6, 12, 0),
                                          child:
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                title,
                                                softWrap: true,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w800,
                                                  shadows: [
                                                    Shadow(
                                                      color: Colors.grey.shade900,
                                                      offset: Offset(0, 0), // 그림자 위치 (수평, 수직)
                                                      blurRadius: 0.1, // 그림자 흐림 정도
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: 2),
                                              Row( ///////////////////////////////// 지역
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.location_on,
                                                    color: Colors.blue.shade500, size: 14,),
                                                  SizedBox(width: 3,),
                                                  Text(cityNames,
                                                    softWrap: true,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      letterSpacing: -0.8,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  )
                                                ],
                                              ),
                                              SizedBox(height: 2),
                                              Text(
                                                price + ' 원',
                                                softWrap: true,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  letterSpacing: 0,
                                                  color: Color.fromRGBO(0, 51, 120, 1.0),
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  shadows: [
                                                    Shadow(
                                                      color: Colors.grey.shade900,
                                                      offset: Offset(0, 0), // 그림자 위치 (수평, 수직)
                                                      blurRadius: 0.1, // 그림자 흐림 정도
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ]
                                  ),
                                )
                            )
                        );
                      },
                    )
                ),
              ),
              /*Container(
                decoration: BoxDecoration(
                  color: Colors.white, // 배경색을 흰색으로 설정
                  borderRadius: BorderRadius.circular(0), // 컨테이너의 모서리를 둥글게 만듦
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5), // 그림자 색상과 투명도 설정
                      spreadRadius: 3, // 그림자 퍼짐 정도
                      blurRadius: 2, // 그림자 흐림 정도
                      offset: Offset(0, 3), // 그림자 위치 조정 (수평, 수직)
                    ),
                  ],
                ),
                child:               TabBar(tabs: myTabs, onTap: _handleTabSelection,),
              ),*/
            ],
          )
      ),
    );
  }
}
