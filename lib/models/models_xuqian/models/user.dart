class User {
  final String? studentId;
  final String? phone;
  final String? password;
  final String? smsCode;
  final String? captcha;
  final DateTime? lastLogin;

  User({
    this.studentId,
    this.phone,
    this.password,
    this.smsCode,
    this.captcha,
    this.lastLogin,
  });
}