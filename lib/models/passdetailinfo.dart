class PassDetailInfo{
  int passid;
  String transportType;
  String imageURL;
  String title;
  String price;
  String cityNames;
  int period;
  String productDescription;
  String benefit_information;
  String reservation_information;
  String refund_information;

  PassDetailInfo({
    required this.passid,
    required this.transportType,
    required this.imageURL,
    required this.title,
    required this.price,
    required this.cityNames,
    required this.period,
    required this.productDescription,
    required this.benefit_information,
    required this.reservation_information,
    required this.refund_information,
  });

  factory PassDetailInfo.fromJson(Map<String, dynamic> json) {
    return PassDetailInfo(
      passid: json['passId'],
      imageURL: json['imageUrl'],
      transportType: json['transportType'],
      title: json['title'],
      cityNames: json['cityNames'],
      price: json['price'],
      period: json['period'],
      productDescription: json['productDescription'],
      benefit_information: json['benefit_information'],
      reservation_information: json['reservation_information'],
      refund_information: json['refund_information'],
    );
  }
}

List<PassDetailInfo> passdetailinfo = [

];
