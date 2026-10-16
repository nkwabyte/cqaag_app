import zipfile, xml.etree.ElementTree as ET

with zipfile.ZipFile('docs/new/CQAAG_Register_Import_List_for_Mussah.xlsx') as z:
    shared_strings = []
    if 'xl/sharedStrings.xml' in z.namelist():
        tree = ET.fromstring(z.read('xl/sharedStrings.xml'))
        for elem in tree.findall('{http://schemas.openxmlformats.org/spreadsheetml/2006/main}si'):
            text = ''.join(t.text for t in elem.iter('{http://schemas.openxmlformats.org/spreadsheetml/2006/main}t') if t.text)
            shared_strings.append(text)
    
    sheet_tree = ET.fromstring(z.read('xl/worksheets/sheet1.xml'))
    rows = []
    for row in sheet_tree.findall('{http://schemas.openxmlformats.org/spreadsheetml/2006/main}sheetData/{http://schemas.openxmlformats.org/spreadsheetml/2006/main}row'):
        row_vals = []
        for c in row.findall('{http://schemas.openxmlformats.org/spreadsheetml/2006/main}c'):
            t = c.get('t')
            v = c.find('{http://schemas.openxmlformats.org/spreadsheetml/2006/main}v')
            val = v.text if v is not None else ''
            if t == 's' and val.isdigit():
                val = shared_strings[int(val)]
            row_vals.append(val)
        rows.append(row_vals)

entries = []
for r in rows[3:]:
    if len(r) >= 2 and r[0].isdigit():
        num = int(r[0])
        name = r[1].strip()
        edu = r[2].strip() if len(r) > 2 else ''
        district = r[3].strip() if len(r) > 3 else ''
        region = r[4].strip() if len(r) > 4 else ''
        company = r[5].strip() if len(r) > 5 else ''
        tel = r[6].strip() if len(r) > 6 else ''
        card_status = r[7].strip() if len(r) > 7 else ''
        pay_mark = r[8].strip() if len(r) > 8 else ''
        paid_60 = r[9].strip().lower() == 'yes' if len(r) > 9 else False
        fee_type = r[11].strip() if len(r) > 11 else ('existing' if paid_60 else 'new')
        entries.append((num, name, edu, district, region, company, tel, card_status, pay_mark, paid_60, fee_type))

out = []
for num, name, edu, district, region, company, tel, card_status, pay_mark, paid_60, fee_type in entries:
    clean_tel = f"'{tel}'" if tel else 'null'
    clean_name = name.replace("'", "\\'")
    clean_edu = edu.replace("'", "\\'")
    clean_dist = district.replace("'", "\\'")
    clean_reg = region.replace("'", "\\'")
    clean_comp = company.replace("'", "\\'")
    clean_card = card_status.replace("'", "\\'")
    clean_pay = pay_mark.replace("'", "\\'")
    line = f"    const LegacyMemberEntry(number: {num}, name: '{clean_name}', education: '{clean_edu}', district: '{clean_dist}', region: '{clean_reg}', company: '{clean_comp}', phone: {clean_tel}, cardStatus: '{clean_card}', registerPaymentMark: '{clean_pay}', earlierPaid: {str(paid_60).lower()}, feeType: '{fee_type}'),"
    out.append(line)

entries_str = '\n'.join(out)

content = """/// The Association's earlier register of Full Members.
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
    final parts = name.trim().split(RegExp(r'\\s+'));
    if (parts.length <= 1) return name;
    return parts.skip(1).join(' ');
  }

  /// Last name / surname
  String get lastName {
    final parts = name.trim().split(RegExp(r'\\s+'));
    return parts.first;
  }

  /// Location summary string
  String get locationSummary {
    if (district.isNotEmpty && region.isNotEmpty) {
      return '$district, $region';
    }
    return district.isNotEmpty ? district : region;
  }

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

  static final List<LegacyMemberEntry> allEntries = [
""" + entries_str + """
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
    return name.trim().toUpperCase().replaceAll(RegExp(r'\\s+'), ' ');
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
"""

with open('lib/services/membership/legacy_register.dart', 'w') as f:
    f.write(content)

print('Updated lib/services/membership/legacy_register.dart with all 98 members.')
