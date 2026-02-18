import 'package:equatable/equatable.dart';

/// HadithCollection enum representing the six authentic collections (Kutub al-Sittah)
enum HadithCollection {
  bukhari,
  muslim,
  abuDawud,
  tirmidhi,
  ibnMajah,
  nasai,
  all;

  String get displayName {
    switch (this) {
      case HadithCollection.bukhari:
        return 'Sahih Al-Bukhari';
      case HadithCollection.muslim:
        return 'Sahih Muslim';
      case HadithCollection.abuDawud:
        return 'Sunan Abu Dawud';
      case HadithCollection.tirmidhi:
        return "Jami' Al-Tirmidhi";
      case HadithCollection.ibnMajah:
        return 'Sunan Ibn Majah';
      case HadithCollection.nasai:
        return 'Sunan Al-Nasa\'i';
      case HadithCollection.all:
        return 'All Collections';
    }
  }

  String get arabicName {
    switch (this) {
      case HadithCollection.bukhari:
        return 'صحيح البخاري';
      case HadithCollection.muslim:
        return 'صحيح مسلم';
      case HadithCollection.abuDawud:
        return 'سنن أبي داود';
      case HadithCollection.tirmidhi:
        return 'جامع الترمذي';
      case HadithCollection.ibnMajah:
        return 'سنن ابن ماجه';
      case HadithCollection.nasai:
        return 'سنن النسائي';
      case HadithCollection.all:
        return 'جميع الكتب';
    }
  }

  String get apiValue {
    switch (this) {
      case HadithCollection.bukhari:
        return 'bukhari';
      case HadithCollection.muslim:
        return 'muslim';
      case HadithCollection.abuDawud:
        return 'abudawud';
      case HadithCollection.tirmidhi:
        return 'tirmidhi';
      case HadithCollection.ibnMajah:
        return 'ibnmajah';
      case HadithCollection.nasai:
        return 'nasai';
      case HadithCollection.all:
        return 'all';
    }
  }

  static HadithCollection fromApiValue(String value) {
    return HadithCollection.values.firstWhere(
      (collection) => collection.apiValue == value,
      orElse: () => HadithCollection.all,
    );
  }

  static HadithCollection fromIndex(int index) {
    if (index >= 0 && index < values.length) {
      return values[index];
    }
    return all;
  }
}
