class CertificationEntity {
  final String id;
  final String title;
  final String issuer;
  final String issuerLogo;
  final String date;
  final String credentialUrl;
  final String pdfUrl;
  final String color;
  final String badge;

  const CertificationEntity({
    required this.id,
    required this.title,
    required this.issuer,
    required this.issuerLogo,
    required this.date,
    required this.credentialUrl,
    required this.pdfUrl,
    required this.color,
    required this.badge,
  });
}
