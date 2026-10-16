/// The Association's earlier register of Full Members.
///
/// Source: docs/new/CQAAG_Register_Import_List_for_Mussah.xlsx (98 names)
/// All entries are Full Members. Members whose earlier register payment was marked
/// "Paid" (fee type "existing") have already paid GH₵60 and are billed a discounted
/// Registration Fee of GH₵200 at activation instead of standard GH₵320.
class LegacyMemberEntry {
  const LegacyMemberEntry({
    required this.number,
    required this.name,
    required this.education,
    required this.district,
    required this.region,
    required this.company,
    this.phone,
    required this.cardStatus,
    required this.registerPaymentMark,
    required this.earlierPaid,
    required this.feeType,
  });

  final int number;
  final String name;
  final String education;
  final String district;
  final String region;
  final String company;
  final String? phone;
  final String cardStatus;
  final String registerPaymentMark;
  final bool earlierPaid;
  final String feeType;

  /// Standardized Member ID: CQAAG-FM-001 through CQAAG-FM-098
  String get memberId => 'CQAAG-FM-${number.toString().padLeft(3, '0')}';

  String get firestoreDocId => 'legacy_${number.toString().padLeft(3, '0')}';

  /// First name / given names
  String get firstName {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length <= 1) return name;
    return parts.skip(1).join(' ');
  }

  /// Last name / surname
  String get lastName {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.first;
  }

  /// Location summary string
  String get locationSummary {
    if (district.isNotEmpty && region.isNotEmpty) {
      return '$district, $region';
    }
    return district.isNotEmpty ? district : region;
  }

  /// Full name alias
  String get fullName => name;

  /// Whether membership ID card was marked issued in register
  bool get hasCardIssued => cardStatus.trim().toLowerCase().contains('issued');

  /// Fee due at activation
  double get registrationFeeDue => earlierPaid ? 200.0 : 320.0;
  double get annualDuesDue => 200.0;
  double get totalAtActivation => registrationFeeDue + annualDuesDue;

  Map<String, dynamic> toFirestoreMap({String? userId, String? email}) => {
    'id': firestoreDocId,
    'user_id': userId ?? '',
    'member_id': memberId,
    'legacy_number': number,
    'is_legacy': true,
    'is_claimed': userId != null && userId.isNotEmpty,
    'title': 'mr',
    'first_name': firstName,
    'last_name': lastName,
    'full_name': name,
    'gender': 'male',
    'nationality': 'Ghanaian',
    'phone_number_primary': phone ?? '',
    'email_address': email ?? '',
    'residential_address': locationSummary,
    'region_district': locationSummary,
    'employer_organization': company.isNotEmpty && company != 'N/A' ? company : '',
    'job_title': 'Cashew Quality Analyst',
    'membership_category': 'full',
    'status': 'approved',
    'card_status': cardStatus,
    'earlier_ghc60_paid': earlierPaid,
    'payment_status': earlierPaid ? 'paid' : 'unpaid',
    'payment_registration_fee': registrationFeeDue,
    'payment_annual_dues': annualDuesDue,
    'payment_amount': totalAtActivation,
    'education': {
      'level': education,
      'field_of_study': 'Cashew Quality Control',
    },
    'created_at': DateTime(2025, 1, 1).toIso8601String(),
    'updated_at': DateTime.now().toIso8601String(),
  };
}

class LegacyRegister {
  LegacyRegister._();

  static final Map<String, LegacyMemberEntry> _byPhone = {};
  static final Map<String, LegacyMemberEntry> _byName = {};
  static final Map<String, LegacyMemberEntry> _byMemberId = {};

  static List<LegacyMemberEntry> get allMembers => allEntries;

  static final List<LegacyMemberEntry> allEntries = [
    const LegacyMemberEntry(number: 1, name: 'AMANFO KWABENA EBENEZER', education: 'BSc DEGREE', district: 'JAMAN NORTH', region: 'Bono', company: 'UNICOM', phone: '0553330931', cardStatus: 'Card issued', registerPaymentMark: 'Paid', earlierPaid: true, feeType: 'existing'),
    const LegacyMemberEntry(number: 2, name: 'PIESIE YEBOAH ERIC', education: 'DIPLOMA', district: 'JAMAN SOUTH', region: 'Bono', company: 'AGRICO GHANA LIMITED', phone: '0247593276', cardStatus: 'Card issued', registerPaymentMark: 'Paid', earlierPaid: true, feeType: 'existing'),
    const LegacyMemberEntry(number: 3, name: 'ABDULAI MOHAMMED', education: 'SHS', district: 'JAMAN SOUTH', region: 'Bono', company: 'CLEAN BILL', phone: '0246875200', cardStatus: 'Card issued', registerPaymentMark: 'Paid', earlierPaid: true, feeType: 'existing'),
    const LegacyMemberEntry(number: 4, name: 'MUSAH SEIDU', education: 'SHS', district: 'JAMAN NORTH', region: 'Bono', company: 'UNICOM', phone: '0554968053', cardStatus: 'Card issued', registerPaymentMark: 'Paid', earlierPaid: true, feeType: 'existing'),
    const LegacyMemberEntry(number: 5, name: 'ANDREW SEY', education: 'BSc DEGREE', district: 'SAWLA-TUNAH-KALBA', region: 'Savannah', company: 'SEYLAND TRADING', phone: '0244112709', cardStatus: 'Card issued', registerPaymentMark: 'Paid', earlierPaid: true, feeType: 'existing'),
    const LegacyMemberEntry(number: 6, name: 'ASUMA SIAKA', education: 'SHS', district: 'JAMAN NORTH', region: 'Bono', company: 'NADKANSCO', phone: '0243950331', cardStatus: 'Card issued', registerPaymentMark: 'Paid', earlierPaid: true, feeType: 'existing'),
    const LegacyMemberEntry(number: 7, name: 'APRAKU EUGENE', education: 'SHS', district: 'JAMAN SOUTH', region: 'Bono', company: 'N/A', phone: '0554773401', cardStatus: 'Card issued', registerPaymentMark: 'Paid', earlierPaid: true, feeType: 'existing'),
    const LegacyMemberEntry(number: 8, name: 'NSIAH QUARCCOO SOLOMON', education: 'SHS', district: 'JAMAN SOUTH', region: 'Bono', company: 'N/A', phone: '0543245290', cardStatus: 'Card issued', registerPaymentMark: 'Paid', earlierPaid: true, feeType: 'existing'),
    const LegacyMemberEntry(number: 9, name: 'AGYEIWAA CHRISTIANA', education: 'SHS', district: 'TECHIMAN', region: 'Bono East', company: 'RED RIVER', phone: '0241380999', cardStatus: 'Card issued', registerPaymentMark: 'Paid', earlierPaid: true, feeType: 'existing'),
    const LegacyMemberEntry(number: 10, name: 'OKYERE GIDEON', education: 'SHS', district: 'JAMAN SOUTH', region: 'Bono', company: 'RRF', phone: '0597725461', cardStatus: 'Card issued', registerPaymentMark: 'Paid', earlierPaid: true, feeType: 'existing'),
    const LegacyMemberEntry(number: 11, name: 'ANABI IBRAHIM', education: 'SHS', district: 'NKRANKWANTA', region: 'Bono', company: 'NADKANSCO', phone: '0544806761', cardStatus: 'Card issued', registerPaymentMark: 'Paid', earlierPaid: true, feeType: 'existing'),
    const LegacyMemberEntry(number: 12, name: 'IBRAHIM MOHAMMED', education: 'SHS', district: 'JAMAN SOUTH', region: 'Bono', company: 'N/A', phone: '0554164103', cardStatus: 'Card issued', registerPaymentMark: 'Not paid', earlierPaid: false, feeType: 'new'),
    const LegacyMemberEntry(number: 13, name: 'FREDERICK KWAMENA TANDOH', education: 'SHS', district: 'JAMAN SOUTH', region: 'Bono', company: 'RRF', phone: '0240979753', cardStatus: 'Card issued', registerPaymentMark: 'Not paid', earlierPaid: false, feeType: 'new'),
    const LegacyMemberEntry(number: 14, name: 'DAKURA EMMANUEL', education: 'SHS', district: 'TECHIMAN', region: 'Bono East', company: 'RED RIVER', phone: '0546440718', cardStatus: 'Card issued', registerPaymentMark: 'Paid', earlierPaid: true, feeType: 'existing'),
    const LegacyMemberEntry(number: 15, name: 'ADU BRIGT', education: 'SHS', district: 'JAMAN NORTH', region: 'Bono', company: 'N/A', phone: '0243013732', cardStatus: 'Card issued', registerPaymentMark: 'Paid', earlierPaid: true, feeType: 'existing'),
    const LegacyMemberEntry(number: 16, name: 'AUGUSTINE AHEDOR', education: 'SHS', district: 'PRAMPRAM', region: 'Greater Accra', company: 'JILS LOGISTICS', phone: '0532665988', cardStatus: 'Card issued', registerPaymentMark: 'Paid', earlierPaid: true, feeType: 'existing'),
    const LegacyMemberEntry(number: 17, name: 'TANG RICHARD', education: 'SHS', district: 'DORMAA', region: 'Bono', company: 'EURO AGRO INDEX', phone: '0247703655', cardStatus: 'Card issued', registerPaymentMark: 'Paid', earlierPaid: true, feeType: 'existing'),
    const LegacyMemberEntry(number: 18, name: 'ANOKYE ROCKSON', education: 'SHS', district: 'WENCHI', region: 'Bono', company: 'N/A', phone: '0246505263', cardStatus: 'Card issued', registerPaymentMark: 'Paid', earlierPaid: true, feeType: 'existing'),
    const LegacyMemberEntry(number: 19, name: 'DOMINIC HOMADZI', education: 'SHS', district: 'TEMA', region: 'Greater Accra', company: 'USIBRAS', phone: '0547730920', cardStatus: 'Card issued', registerPaymentMark: 'Paid', earlierPaid: true, feeType: 'existing'),
    const LegacyMemberEntry(number: 20, name: 'TETTEH ISAAC', education: 'SHS', district: 'JAMAN SOUTH', region: 'Bono', company: 'RRF', phone: '0594163027', cardStatus: 'Card issued', registerPaymentMark: 'Paid', earlierPaid: true, feeType: 'existing'),
    const LegacyMemberEntry(number: 21, name: 'MOSES TETTEH KOFFIE', education: 'SHS', district: 'ASHAIMAN', region: 'Greater Accra', company: 'USIBRAS', phone: '0558615837', cardStatus: 'Card issued', registerPaymentMark: 'Paid', earlierPaid: true, feeType: 'existing'),
    const LegacyMemberEntry(number: 22, name: 'ELVIS NUANAH', education: 'SHS', district: 'TECHIMAN', region: 'Bono East', company: 'RRF', phone: '0546638950', cardStatus: 'Card issued', registerPaymentMark: 'Not paid', earlierPaid: false, feeType: 'new'),
    const LegacyMemberEntry(number: 23, name: 'ADAMS OBED', education: 'SHS', district: 'TAIN', region: 'Bono', company: 'FLUDOR GH LTD', phone: '0541417697', cardStatus: 'Card issued', registerPaymentMark: 'Paid', earlierPaid: true, feeType: 'existing'),
    const LegacyMemberEntry(number: 24, name: 'GATIENU CHRISTIAN KWETEY', education: 'SHS', district: 'PRAMPRAM', region: 'Greater Accra', company: 'USIBRAS', phone: '0540801810', cardStatus: 'Card issued', registerPaymentMark: 'Paid', earlierPaid: true, feeType: 'existing'),
    const LegacyMemberEntry(number: 25, name: 'ADJEI RICHARD', education: 'SHS', district: 'DORMAA', region: 'Bono', company: 'N/A', phone: '0242179886', cardStatus: 'Card issued', registerPaymentMark: 'Paid', earlierPaid: true, feeType: 'existing'),
    const LegacyMemberEntry(number: 26, name: 'ABDULAI IBRAHIM', education: 'SHS', district: 'JAMAN NORTH', region: 'Bono', company: 'CLEAN BILL', phone: '0246702290', cardStatus: 'Card issued', registerPaymentMark: 'Paid', earlierPaid: true, feeType: 'existing'),
    const LegacyMemberEntry(number: 27, name: 'ISAAC LOPPOH', education: 'SHS', district: 'JAMAN NORTH', region: 'Bono', company: 'N/A', phone: '0540495614', cardStatus: 'Card issued', registerPaymentMark: 'Paid', earlierPaid: true, feeType: 'existing'),
    const LegacyMemberEntry(number: 28, name: 'ADJEI FRANCIS', education: 'SHS', district: 'NKRANKWANTA', region: 'Bono', company: 'N/A', phone: '0204992398', cardStatus: 'Card issued', registerPaymentMark: 'Paid', earlierPaid: true, feeType: 'existing'),
    const LegacyMemberEntry(number: 29, name: 'HOTOR COLSON ISAAC', education: 'SHS', district: 'TECHIMAN', region: 'Bono East', company: 'RED RIVER', phone: '0242955417', cardStatus: 'Card issued', registerPaymentMark: 'Not paid', earlierPaid: false, feeType: 'new'),
    const LegacyMemberEntry(number: 30, name: 'CHARLES KWAME AMOAH', education: 'SHS', district: 'JAMAN SOUTH', region: 'Bono', company: 'USIBRAS', phone: '0558798778', cardStatus: 'Card issued', registerPaymentMark: 'Paid', earlierPaid: true, feeType: 'existing'),
    const LegacyMemberEntry(number: 31, name: 'SIE KWASI SAMUEL', education: 'SHS', district: 'JAMAN NORTH', region: 'Bono', company: 'N/A', phone: null, cardStatus: 'Card issued', registerPaymentMark: 'Paid', earlierPaid: true, feeType: 'existing'),
    const LegacyMemberEntry(number: 32, name: 'GYAN OVAMARS', education: 'SHS', district: 'JAMAN SOUTH', region: 'Bono', company: 'N/A', phone: null, cardStatus: 'Card issued', registerPaymentMark: 'Paid', earlierPaid: true, feeType: 'existing'),
    const LegacyMemberEntry(number: 33, name: 'DZAHLIE ANOUMOU DE`LALI KOFFIE', education: '', district: 'TECHIMAN', region: 'Bono East', company: 'N/A', phone: '0245925751', cardStatus: 'Card issued', registerPaymentMark: 'Paid', earlierPaid: true, feeType: 'existing'),
    const LegacyMemberEntry(number: 34, name: 'BOAMPONG KWASI', education: 'SHS', district: 'TECHIMAN', region: 'Bono East', company: 'N/A', phone: '0542288360', cardStatus: 'Card issued', registerPaymentMark: 'Paid', earlierPaid: true, feeType: 'existing'),
    const LegacyMemberEntry(number: 35, name: 'ABDUL-RAHMAN ABDUL-SALAM', education: 'SHS', district: 'JAMAN SOUTH', region: 'Bono', company: 'INDAF GHANA LIMITED', phone: '0246135292', cardStatus: 'Card issued', registerPaymentMark: 'Paid', earlierPaid: true, feeType: 'existing'),
    const LegacyMemberEntry(number: 36, name: 'KATABOH KOFI JOHN', education: 'SHS', district: 'TEMA', region: 'Greater Accra', company: 'N/A', phone: '0242242732', cardStatus: 'Card issued', registerPaymentMark: 'Paid', earlierPaid: true, feeType: 'existing'),
    const LegacyMemberEntry(number: 37, name: 'AWUNABERNA MICHEAL YEBOAH', education: 'SHS', district: 'JAMAN NORTH', region: 'Bono', company: 'E. NYAMEKYE ENT', phone: '0531487317', cardStatus: 'Card issued', registerPaymentMark: 'Paid', earlierPaid: true, feeType: 'existing'),
    const LegacyMemberEntry(number: 38, name: 'YEBOAH PRINCE', education: 'SHS', district: 'TECHIMAN', region: 'Bono East', company: 'RED RIVER', phone: '0548855652', cardStatus: 'Card issued', registerPaymentMark: 'Paid', earlierPaid: true, feeType: 'existing'),
    const LegacyMemberEntry(number: 39, name: 'KYEREME AUGUSTINE', education: 'SHS', district: 'TECHIMAN', region: 'Bono East', company: 'RED RIVER', phone: '0240614586', cardStatus: 'Card issued', registerPaymentMark: 'Paid', earlierPaid: true, feeType: 'existing'),
    const LegacyMemberEntry(number: 40, name: 'KONLAN JUSTINA', education: 'SHS', district: 'TECHIMAN', region: 'Bono East', company: 'RED RIVER', phone: '0240013167', cardStatus: 'Card issued', registerPaymentMark: 'Paid', earlierPaid: true, feeType: 'existing'),
    const LegacyMemberEntry(number: 41, name: 'ASAMOAH OPPONG SOLOMON', education: 'SHS', district: 'TECHIMAN', region: 'Bono East', company: 'MH AGRO', phone: '0547416309', cardStatus: 'Card issued', registerPaymentMark: 'Paid', earlierPaid: true, feeType: 'existing'),
    const LegacyMemberEntry(number: 42, name: 'AFFUL EMMANUEL', education: 'SHS/MILLITARY', district: 'JAMAN NORTH', region: 'Bono', company: 'N/A', phone: '0245474497', cardStatus: 'Card issued', registerPaymentMark: 'Not paid', earlierPaid: false, feeType: 'new'),
    const LegacyMemberEntry(number: 43, name: 'KUMI SAMUEL', education: 'SHS', district: 'JAMAN NORTH', region: 'Bono', company: 'N/A', phone: '0245548306', cardStatus: 'Card issued', registerPaymentMark: 'Not paid', earlierPaid: false, feeType: 'new'),
    const LegacyMemberEntry(number: 44, name: 'EDEM KUKUIAH TRUST', education: 'SHS', district: 'JAMAN NORTH', region: 'Bono', company: 'N/A', phone: '0594658984', cardStatus: 'Card issued', registerPaymentMark: 'Paid', earlierPaid: true, feeType: 'existing'),
    const LegacyMemberEntry(number: 45, name: 'ALOSANI DAUDA', education: 'SHS', district: 'JAMAN NORTH', region: 'Bono', company: 'BABAFII VENTURES', phone: '0550837963', cardStatus: 'Card issued', registerPaymentMark: 'Paid', earlierPaid: true, feeType: 'existing'),
    const LegacyMemberEntry(number: 46, name: 'BOAMAH ISAAC', education: 'SHS', district: 'JAMAN SOUTH', region: 'Bono', company: 'KAFAP CASHEWS', phone: '0592363141', cardStatus: 'Card issued', registerPaymentMark: 'Paid', earlierPaid: true, feeType: 'existing'),
    const LegacyMemberEntry(number: 47, name: 'FREEMAN PHILEMON AGAH', education: 'SHS', district: 'WENCHI', region: 'Bono', company: 'N/A', phone: '0543163037', cardStatus: 'Card issued', registerPaymentMark: 'Paid', earlierPaid: true, feeType: 'existing'),
    const LegacyMemberEntry(number: 48, name: 'ISSIFU SALIA', education: 'SHS', district: 'JAMAN NORTH', region: 'Bono', company: 'OFI CASHEW', phone: '0245221748', cardStatus: 'Card issued', registerPaymentMark: 'Not paid', earlierPaid: false, feeType: 'new'),
    const LegacyMemberEntry(number: 49, name: 'ERNEST GYABAAH', education: 'SHS', district: 'JAMAN NORTH', region: 'Bono', company: 'RRF', phone: '0241155506', cardStatus: 'Card issued', registerPaymentMark: 'Paid', earlierPaid: true, feeType: 'existing'),
    const LegacyMemberEntry(number: 50, name: 'KWAKU EBENEZER', education: 'SHS', district: 'JAMAN SOUTH', region: 'Bono', company: 'RRF', phone: '0536768202', cardStatus: 'Card issued', registerPaymentMark: 'Not paid', earlierPaid: false, feeType: 'new'),
    const LegacyMemberEntry(number: 51, name: 'DAPAA RICHARD', education: 'SHS', district: 'JAMAN NORTH', region: 'Bono', company: 'A.S BARUS COMPANY LIMITED', phone: '0244473755', cardStatus: 'Card issued', registerPaymentMark: 'Paid', earlierPaid: true, feeType: 'existing'),
    const LegacyMemberEntry(number: 52, name: 'FREDERICK ADUFU AFFOH', education: 'SHS', district: 'ACCRA', region: 'Greater Accra', company: 'USIBRAS', phone: '0573127700', cardStatus: 'Card issued', registerPaymentMark: 'Paid', earlierPaid: true, feeType: 'existing'),
    const LegacyMemberEntry(number: 53, name: 'ADDA FERDINAND', education: 'SHS', district: 'NAVRONGO', region: 'Upper East', company: 'FARMERLINE LTD', phone: '0240333705', cardStatus: 'Card issued', registerPaymentMark: 'Paid', earlierPaid: true, feeType: 'existing'),
    const LegacyMemberEntry(number: 54, name: 'EMMANUEL MENSAH', education: 'SHS', district: 'JAMAN NORTH', region: 'Bono', company: 'UNICOM', phone: '0532613312', cardStatus: 'Card issued', registerPaymentMark: 'Paid', earlierPaid: true, feeType: 'existing'),
    const LegacyMemberEntry(number: 55, name: 'ERIC ADINKRA', education: 'SHS', district: 'JAMAN NORTH', region: 'Bono', company: 'N/A', phone: '0248204340', cardStatus: 'Card issued', registerPaymentMark: 'Paid', earlierPaid: true, feeType: 'existing'),
    const LegacyMemberEntry(number: 56, name: 'SALIA DAUDA', education: 'SHS', district: 'JAMAN NORTH', region: 'Bono', company: 'OFI CASHEW', phone: '0540495738', cardStatus: 'Card issued', registerPaymentMark: 'Paid', earlierPaid: true, feeType: 'existing'),
    const LegacyMemberEntry(number: 57, name: 'MUSAH SUALIHU', education: 'SHS', district: 'JAMAN NORTH', region: 'Bono', company: 'DUAPA AGRI', phone: '0548548962', cardStatus: 'Card issued', registerPaymentMark: 'Paid', earlierPaid: true, feeType: 'existing'),
    const LegacyMemberEntry(number: 58, name: 'YEBOAH ANTHONY', education: 'SHS', district: 'JAMAN NORTH', region: 'Bono', company: 'DUAPA AGRI', phone: '0247658657', cardStatus: 'Card issued', registerPaymentMark: 'Paid', earlierPaid: true, feeType: 'existing'),
    const LegacyMemberEntry(number: 59, name: 'AGYARE ERIC', education: '', district: 'TEMA', region: 'Greater Accra', company: 'HK CASHEW', phone: '0532516356', cardStatus: 'Card issued', registerPaymentMark: 'Paid', earlierPaid: true, feeType: 'existing'),
    const LegacyMemberEntry(number: 60, name: 'BASOAH EMMANUEL', education: 'SHS', district: 'KUMASI', region: 'Ashante', company: 'N/A', phone: '0599639986', cardStatus: 'Card issued', registerPaymentMark: 'Paid', earlierPaid: true, feeType: 'existing'),
    const LegacyMemberEntry(number: 61, name: 'IBRAHIM SINA', education: 'SHS', district: 'JAMAN NORTH', region: 'Bono', company: 'N/A', phone: '0243029661', cardStatus: 'Card issued', registerPaymentMark: 'Not paid', earlierPaid: false, feeType: 'new'),
    const LegacyMemberEntry(number: 62, name: 'NAGAYE VITALIS', education: 'SHS', district: 'TECHIMAN', region: 'Bono East', company: 'SKY GOBAL GHANA LTD', phone: '0597790793', cardStatus: 'Card issued', registerPaymentMark: 'Paid', earlierPaid: true, feeType: 'existing'),
    const LegacyMemberEntry(number: 63, name: 'PRINCE KONADU YANCHIRA', education: '', district: 'TEMA', region: 'Greater Accra', company: 'N/A', phone: '0275638584', cardStatus: 'Card issued', registerPaymentMark: 'Paid', earlierPaid: true, feeType: 'existing'),
    const LegacyMemberEntry(number: 64, name: 'TAKYI WILLIAMS', education: 'SHS', district: 'JAMAN SOUTH', region: 'Bono', company: 'DUAPA AGRI', phone: '0507929927', cardStatus: 'Card issued', registerPaymentMark: 'Paid', earlierPaid: true, feeType: 'existing'),
    const LegacyMemberEntry(number: 65, name: 'OBAH SAMUEL KWABENA', education: 'BSc DEGREE', district: 'JAMAN NORTH', region: 'Bono', company: 'N/A', phone: '0548639878', cardStatus: 'Card issued', registerPaymentMark: 'Not paid', earlierPaid: false, feeType: 'new'),
    const LegacyMemberEntry(number: 66, name: 'LUKEMAN IDDRISS', education: 'JHS', district: 'WENCHI', region: 'Bono', company: 'UNICOM', phone: '0534076788', cardStatus: 'Card issued', registerPaymentMark: 'Paid', earlierPaid: true, feeType: 'existing'),
    const LegacyMemberEntry(number: 67, name: 'YENNUKON JOHN', education: 'SHS', district: 'JAMAN SOUTH', region: 'Bono', company: 'DUAPA AGRI', phone: '0599606688', cardStatus: 'No', registerPaymentMark: 'Not paid', earlierPaid: false, feeType: 'new'),
    const LegacyMemberEntry(number: 68, name: 'JIBRIL ABDUL-SALAM', education: 'SHS', district: 'BOLE', region: 'Savannah', company: 'N/A', phone: '0247195227', cardStatus: 'Card issued', registerPaymentMark: 'Paid', earlierPaid: true, feeType: 'existing'),
    const LegacyMemberEntry(number: 69, name: 'ALHASSAN SULEMANA', education: 'SHS', district: 'TECHIMAN', region: 'Bono East', company: 'N/A', phone: '0245008995', cardStatus: 'Card issued', registerPaymentMark: 'Paid', earlierPaid: true, feeType: 'existing'),
    const LegacyMemberEntry(number: 70, name: 'ABDULAI SEIDU', education: 'SHS', district: 'JAMAN NORTH', region: 'Bono', company: 'POWER HYDRAULIC', phone: '0542865335', cardStatus: 'In Process', registerPaymentMark: 'Paid', earlierPaid: true, feeType: 'existing'),
    const LegacyMemberEntry(number: 71, name: 'ATOBRAH KWASI BENNARD', education: 'SHS', district: 'AXIM', region: 'Western', company: 'TRUST COMMODITIES CO. LTD.', phone: '0547704695', cardStatus: 'No', registerPaymentMark: 'Not paid', earlierPaid: false, feeType: 'new'),
    const LegacyMemberEntry(number: 72, name: 'KARIM MOHAMMED', education: 'SHS', district: 'JAMAN SOUTH', region: 'Bono', company: 'N/A', phone: '0596758295', cardStatus: 'No', registerPaymentMark: 'Not paid', earlierPaid: false, feeType: 'new'),
    const LegacyMemberEntry(number: 73, name: 'SIAKA AMOAH UMAR', education: 'SHS', district: 'JAMAN SOUTH', region: 'Bono', company: 'TANGHANA', phone: '0249008126', cardStatus: 'No', registerPaymentMark: 'Not paid', earlierPaid: false, feeType: 'new'),
    const LegacyMemberEntry(number: 74, name: 'DAPAA ALEX', education: 'SHS', district: 'JAMAN SOUTH', region: 'Bono', company: 'RRF', phone: '0541909113', cardStatus: 'No', registerPaymentMark: 'Not paid', earlierPaid: false, feeType: 'new'),
    const LegacyMemberEntry(number: 75, name: 'ASANTE KWABENA FRANCIS', education: 'SHS', district: 'JAMAN NORTH', region: 'Bono', company: 'ABEY SHIPING LIMITED', phone: '0241868188', cardStatus: 'No', registerPaymentMark: 'Not paid', earlierPaid: false, feeType: 'new'),
    const LegacyMemberEntry(number: 76, name: 'ANKAMAH FRANCIS', education: 'SHS', district: 'JAMAN SOUTH', region: 'Bono', company: 'N/A', phone: null, cardStatus: 'No', registerPaymentMark: 'Not paid', earlierPaid: false, feeType: 'new'),
    const LegacyMemberEntry(number: 77, name: 'SIAKA SEIKU', education: 'SHS', district: 'JAMAN NORTH', region: 'Bono', company: 'GREENLAND', phone: '0240599570', cardStatus: 'No', registerPaymentMark: 'Not paid', earlierPaid: false, feeType: 'new'),
    const LegacyMemberEntry(number: 78, name: 'ISAAC NKANSAH', education: 'SHS', district: 'JAMAN NORTH', region: 'Bono', company: 'N/A', phone: '0596073828', cardStatus: 'No', registerPaymentMark: 'Not paid', earlierPaid: false, feeType: 'new'),
    const LegacyMemberEntry(number: 79, name: 'OSMAN IBRAHIM', education: 'SHS', district: 'JAMAN NORTH', region: 'Bono', company: 'DEVARAG AGRO INDUSTRIES', phone: '0249800678', cardStatus: 'No', registerPaymentMark: 'Not paid', earlierPaid: false, feeType: 'new'),
    const LegacyMemberEntry(number: 80, name: 'DARTEY BISMARK', education: 'SHS', district: 'JAMAN SOUTH', region: 'Bono', company: 'N/A', phone: null, cardStatus: 'No', registerPaymentMark: 'Not paid', earlierPaid: false, feeType: 'new'),
    const LegacyMemberEntry(number: 81, name: 'IBRAHIM ADAMS', education: 'SHS', district: 'JAMAN SOUTH', region: 'Bono', company: 'N/A', phone: null, cardStatus: 'No', registerPaymentMark: 'Not paid', earlierPaid: false, feeType: 'new'),
    const LegacyMemberEntry(number: 82, name: 'EMMANUEL NARH', education: 'SHS', district: 'PRAMPRAM', region: 'Greater Accra', company: 'USIBRAS', phone: '0554094200', cardStatus: 'Card issued', registerPaymentMark: 'Paid', earlierPaid: true, feeType: 'existing'),
    const LegacyMemberEntry(number: 83, name: 'BERNICE OBENG', education: 'NURSING T', district: 'JAMAN SOUTH', region: 'Bono', company: 'OFI CASHEW', phone: '0551391670', cardStatus: 'No', registerPaymentMark: 'Not paid', earlierPaid: false, feeType: 'new'),
    const LegacyMemberEntry(number: 84, name: 'ABDULLAHI SEIDU', education: 'SHS', district: 'JAMAN NORTH', region: 'Bono', company: 'POWER HYDRAULIC', phone: '0542865335', cardStatus: 'No', registerPaymentMark: 'Not paid', earlierPaid: false, feeType: 'new'),
    const LegacyMemberEntry(number: 85, name: 'TEKYI CLEMENT', education: 'SHS', district: 'JAMAN SOUTH', region: 'Bono', company: 'RRF', phone: '0598150464', cardStatus: 'Card issued', registerPaymentMark: 'Not paid', earlierPaid: false, feeType: 'new'),
    const LegacyMemberEntry(number: 86, name: 'OPOKU DENIS', education: 'SHS', district: 'JAMAN NORTH', region: 'Bono', company: 'UNICOM', phone: '0540601244', cardStatus: 'In Process', registerPaymentMark: 'Not paid', earlierPaid: false, feeType: 'new'),
    const LegacyMemberEntry(number: 87, name: 'OSEI EMMANUEL', education: 'SHS', district: 'WENCHI', region: 'Bono', company: 'N/A', phone: '0244171777', cardStatus: 'No', registerPaymentMark: 'Not paid', earlierPaid: false, feeType: 'new'),
    const LegacyMemberEntry(number: 88, name: 'KAMARA JUNIOR ADIKALIE', education: '', district: 'TEMA', region: 'Greater Accra', company: 'HK CASHEW', phone: '0249217526', cardStatus: 'In Process', registerPaymentMark: 'Paid', earlierPaid: true, feeType: 'existing'),
    const LegacyMemberEntry(number: 89, name: 'ANSOMAH MOHAMMED', education: 'SHS', district: 'TAIN', region: 'Bono', company: 'N/A', phone: '0240895388', cardStatus: 'Card issued', registerPaymentMark: 'Paid', earlierPaid: true, feeType: 'existing'),
    const LegacyMemberEntry(number: 90, name: 'IBRAHIM YAYA', education: 'SHS', district: 'JAMAN NORTH', region: 'Bono', company: 'UNICOM', phone: '0248041156', cardStatus: 'In Process', registerPaymentMark: 'Not paid', earlierPaid: false, feeType: 'new'),
    const LegacyMemberEntry(number: 91, name: 'SOLOMON OBENG', education: 'SHS', district: 'TEMA WEST', region: 'Greater Accra', company: 'SEDACO COM. LMT.', phone: '0249254728', cardStatus: 'In Process', registerPaymentMark: 'Paid', earlierPaid: true, feeType: 'existing'),
    const LegacyMemberEntry(number: 92, name: 'OBENG MALICK', education: 'SHS', district: 'JAMAN SOUTH', region: 'Bono', company: 'POMASS', phone: '0548617865', cardStatus: 'No', registerPaymentMark: 'Not paid', earlierPaid: false, feeType: 'new'),
    const LegacyMemberEntry(number: 93, name: 'OSMAN DRISAH', education: '', district: 'JAMAN NORTH', region: 'Bono', company: '', phone: '0554411182', cardStatus: 'No', registerPaymentMark: 'Not paid', earlierPaid: false, feeType: 'new'),
    const LegacyMemberEntry(number: 94, name: 'OBENG SOLOMON', education: 'SHS', district: '', region: 'Greater Accra', company: '', phone: null, cardStatus: '', registerPaymentMark: '(blank)', earlierPaid: false, feeType: 'new'),
    const LegacyMemberEntry(number: 95, name: 'SULEMAN ADAMS', education: '', district: 'Techiman', region: 'Bono East', company: '', phone: null, cardStatus: '', registerPaymentMark: '(blank)', earlierPaid: false, feeType: 'new'),
    const LegacyMemberEntry(number: 96, name: 'ISAAC BACHINO', education: '', district: 'Tema', region: 'Greater Accra', company: 'Olam', phone: '0553135305', cardStatus: '', registerPaymentMark: '(blank)', earlierPaid: false, feeType: 'new'),
    const LegacyMemberEntry(number: 97, name: 'OWUSU FRANCIS', education: '', district: '', region: 'Greater Accra', company: 'Olam', phone: null, cardStatus: '', registerPaymentMark: '(blank)', earlierPaid: false, feeType: 'new'),
    const LegacyMemberEntry(number: 98, name: 'MASAWUDU SALIFU', education: '', district: '', region: '', company: '', phone: null, cardStatus: '', registerPaymentMark: '(blank)', earlierPaid: false, feeType: 'new'),
  ];

  static void _ensureInitialized() {
    if (_byPhone.isNotEmpty) return;
    for (final entry in allEntries) {
      if (entry.phone != null && entry.phone!.isNotEmpty) {
        _byPhone[normalizePhone(entry.phone!)] = entry;
      }
      _byName[normalizeName(entry.name)] = entry;
      _byMemberId[entry.memberId.toUpperCase()] = entry;
      _byMemberId[entry.number.toString()] = entry;
    }
  }

  static String normalizePhone(String phone) {
    var digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('233') && digits.length >= 12) {
      digits = '0${digits.substring(3)}';
    }
    return digits;
  }

  static String normalizeName(String name) {
    return name.trim().toUpperCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Find legacy member by phone number
  static LegacyMemberEntry? findByPhone(String? phone) {
    if (phone == null || phone.trim().isEmpty) return null;
    _ensureInitialized();
    return _byPhone[normalizePhone(phone)];
  }

  /// Find legacy member by name
  static LegacyMemberEntry? findByName(String? name) {
    if (name == null || name.trim().isEmpty) return null;
    _ensureInitialized();
    final normalized = normalizeName(name);
    if (_byName.containsKey(normalized)) return _byName[normalized];

    // Fuzzy check for partial name match if query has multiple words
    final queryTokens = normalized.split(' ');
    if (queryTokens.length >= 2) {
      for (final entry in allEntries) {
        final entryNorm = normalizeName(entry.name);
        if (queryTokens.every((t) => entryNorm.contains(t))) {
          return entry;
        }
      }
    }
    return null;
  }

  /// Find by Member ID (e.g. 'CQAAG-FM-001' or '1')
  static LegacyMemberEntry? findByMemberId(String? id) {
    if (id == null || id.trim().isEmpty) return null;
    _ensureInitialized();
    final clean = id.trim().toUpperCase();
    return _byMemberId[clean];
  }

  /// Matches against member ID, phone, or name
  static LegacyMemberEntry? match(String? query) {
    if (query == null || query.trim().isEmpty) return null;
    return findByMemberId(query) ?? findByPhone(query) ?? findByName(query);
  }

  /// Check whether phone or name belongs to an existing member who already paid earlier GH₵60
  static bool isExistingMember({String? phone, String? name, String? memberId}) {
    final entry = findByMemberId(memberId) ?? findByPhone(phone) ?? findByName(name);
    return entry != null && entry.earlierPaid;
  }

  /// Searches members by keyword across name, ID, phone, company, district, or region
  static List<LegacyMemberEntry> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return allEntries;

    return allEntries.where((entry) {
      if (entry.memberId.toLowerCase().contains(q)) return true;
      if (entry.name.toLowerCase().contains(q)) return true;
      if (entry.phone != null && entry.phone!.contains(q)) return true;
      if (entry.company.toLowerCase().contains(q)) return true;
      if (entry.district.toLowerCase().contains(q)) return true;
      if (entry.region.toLowerCase().contains(q)) return true;
      return false;
    }).toList();
  }
}
