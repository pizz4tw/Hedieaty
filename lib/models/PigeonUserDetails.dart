class PigeonUserDetails {
  String username;
  String email;
  String? dob;
  String? gender;
  String phoneNumber;

  PigeonUserDetails({
    required this.username,
    required this.email,
    this.dob,
    this.gender,
    required this.phoneNumber,
  });

  // Add a fromMap method to parse the data
  factory PigeonUserDetails.fromMap(Map<String, dynamic>? data) {
    if (data == null) {
      throw ArgumentError("Data cannot be null");
    }

    // Debugging: Log the keys to understand the data structure
    print("Mapping data to PigeonUserDetails: $data");
    print("Data keys: ${data.keys}");

    return PigeonUserDetails(
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      dob: data['dob'],
      gender: data['gender'],
      phoneNumber: data['phoneNumber'] ?? '',
    );
  }

  @override
  String toString() {
    return 'PigeonUserDetails{username: $username, email: $email, dob: $dob, gender: $gender, phoneNumber: $phoneNumber}';
  }
}
