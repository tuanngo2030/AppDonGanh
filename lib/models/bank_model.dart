class Bank {
  final int id;
  final String name;
  final String code;
  final String bin;
  final String shortName;
  final String logo;
  final bool transferSupported;
  final bool lookupSupported;

  Bank({
    required this.id,
    required this.name,
    required this.code,
    required this.bin,
    required this.shortName,
    required this.logo,
    required this.transferSupported,
    required this.lookupSupported,
  });

  factory Bank.fromJson(Map<String, dynamic> json) {
    return Bank(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      bin: json['bin'],
      shortName: json['shortName'],
      logo: json['logo'],
      transferSupported: json['transferSupported'] == 1,
      lookupSupported: json['lookupSupported'] == 1,
    );
  }
}
