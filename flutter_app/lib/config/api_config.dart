class ApiConfig {
  // Android emulator usa 10.0.2.2 para acessar o localhost da máquina host.
  // iOS simulator e web podem usar localhost diretamente.
  // Em dispositivo físico, use o IP da máquina na rede local.
  static const String baseUrl = "http://localhost:3334";
}
