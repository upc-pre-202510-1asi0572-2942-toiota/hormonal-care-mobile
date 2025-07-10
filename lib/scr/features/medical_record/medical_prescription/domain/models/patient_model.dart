class Patient {
  int? id;
  String? fullName;
  String? image;
  String? gender;
  String? phoneNumber;
  String? birthday;
  String? typeOfBlood;
  String? personalHistory;
  String? familyHistory;
  int? doctorId;
  int? profileId;

  Patient({
    this.id,
    this.fullName,
    this.image,
    this.gender,
    this.phoneNumber,
    this.birthday,
    this.typeOfBlood,
    this.personalHistory,
    this.familyHistory,
    this.doctorId,
    this.profileId,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      fullName: json['fullName'],
      image: json['image'],
      gender: json['gender'],
      phoneNumber: json['phoneNumber'],
      birthday: json['birthday'],
      typeOfBlood: json['typeOfBlood'],
      personalHistory: json['personalHistory'],
      familyHistory: json['familyHistory'],
      doctorId: json['doctorId'],
      profileId: json['profileId'],
    );
  }
}