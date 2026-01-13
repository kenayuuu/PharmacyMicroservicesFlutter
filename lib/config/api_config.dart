class ApiConfig {
  // For Android emulator, use: http://10.0.2.2:PORT
  // For iOS simulator, use: http://localhost:PORT
  // For physical device, use your computer's IP address: http://YOUR_IP:PORT
  
  //static const String baseUrl = 'http://localhost';
  // static const String baseUrl = 'http://10.0.2.2'; // Uncomment for Android emulator
   static const String baseUrl = 'http://192.168.1.39'; // Use your computer's IP for physical device
  
  static const String userServiceUrl = '$baseUrl:4000';
  static const String productServiceUrl = '$baseUrl:8001';
  static const String transactionServiceUrl = '$baseUrl:5001';
  static const String reviewServiceUrl = '$baseUrl:5002';
}
