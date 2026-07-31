enum Role { admin, tecnico, cliente }

Role roleFromString(String value) {
  switch (value) {
    case "ADMIN":
      return Role.admin;
    case "TECNICO":
      return Role.tecnico;
    default:
      return Role.cliente;
  }
}

class Usuario {
  final String id;
  final String nome;
  final String email;
  final Role role;

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.role,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json["id"] as String,
      nome: json["nome"] as String,
      email: json["email"] as String,
      role: roleFromString(json["role"] as String),
    );
  }
}
