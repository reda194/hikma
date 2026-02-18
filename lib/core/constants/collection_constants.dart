/// Hadith collection constants and metadata
class CollectionConstants {
  CollectionConstants._();

  // Collection names for API
  static const String bukhari = 'bukhari';
  static const String muslim = 'muslim';
  static const String abuDawud = 'abudawud';
  static const String tirmidhi = 'tirmidhi';
  static const String ibnMajah = 'ibnmajah';
  static const String nasai = 'nasai';
  static const String all = 'all';

  // Arabic names
  static const Map<String, String> arabicNames = {
    bukhari: 'صحيح البخاري',
    muslim: 'صحيح مسلم',
    abuDawud: 'سنن أبي داود',
    tirmidhi: 'جامع الترمذي',
    ibnMajah: 'سنن ابن ماجه',
    nasai: 'سنن النسائي',
    all: 'جميع الكتب',
  };

  // Display names (English)
  static const Map<String, String> displayNames = {
    bukhari: 'Sahih Al-Bukhari',
    muslim: 'Sahih Muslim',
    abuDawud: 'Sunan Abu Dawud',
    tirmidhi: "Jami' Al-Tirmidhi",
    ibnMajah: 'Sunan Ibn Majah',
    nasai: 'Sunan Al-Nasa\'i',
    all: 'All Collections',
  };

  // All available collections
  static const List<String> allCollections = [
    bukhari,
    muslim,
    abuDawud,
    tirmidhi,
    ibnMajah,
    nasai,
  ];
}
