enum StatusChamado { aberto, emAndamento, aguardandoCliente, resolvido, fechado }

enum Prioridade { baixa, media, alta, urgente }

StatusChamado statusFromString(String value) {
  switch (value) {
    case "ABERTO":
      return StatusChamado.aberto;
    case "EM_ANDAMENTO":
      return StatusChamado.emAndamento;
    case "AGUARDANDO_CLIENTE":
      return StatusChamado.aguardandoCliente;
    case "RESOLVIDO":
      return StatusChamado.resolvido;
    default:
      return StatusChamado.fechado;
  }
}

String statusToApiString(StatusChamado status) {
  switch (status) {
    case StatusChamado.aberto:
      return "ABERTO";
    case StatusChamado.emAndamento:
      return "EM_ANDAMENTO";
    case StatusChamado.aguardandoCliente:
      return "AGUARDANDO_CLIENTE";
    case StatusChamado.resolvido:
      return "RESOLVIDO";
    case StatusChamado.fechado:
      return "FECHADO";
  }
}

String statusLabel(StatusChamado status) {
  switch (status) {
    case StatusChamado.aberto:
      return "Aberto";
    case StatusChamado.emAndamento:
      return "Em andamento";
    case StatusChamado.aguardandoCliente:
      return "Aguardando cliente";
    case StatusChamado.resolvido:
      return "Resolvido";
    case StatusChamado.fechado:
      return "Fechado";
  }
}

Prioridade prioridadeFromString(String value) {
  switch (value) {
    case "BAIXA":
      return Prioridade.baixa;
    case "MEDIA":
      return Prioridade.media;
    case "ALTA":
      return Prioridade.alta;
    default:
      return Prioridade.urgente;
  }
}

String prioridadeToApiString(Prioridade prioridade) {
  switch (prioridade) {
    case Prioridade.baixa:
      return "BAIXA";
    case Prioridade.media:
      return "MEDIA";
    case Prioridade.alta:
      return "ALTA";
    case Prioridade.urgente:
      return "URGENTE";
  }
}

String prioridadeLabel(Prioridade prioridade) {
  switch (prioridade) {
    case Prioridade.baixa:
      return "Baixa";
    case Prioridade.media:
      return "Média";
    case Prioridade.alta:
      return "Alta";
    case Prioridade.urgente:
      return "Urgente";
  }
}

class UsuarioResumo {
  final String id;
  final String nome;
  final String? email;

  UsuarioResumo({required this.id, required this.nome, this.email});

  factory UsuarioResumo.fromJson(Map<String, dynamic> json) {
    return UsuarioResumo(
      id: json["id"] as String,
      nome: json["nome"] as String,
      email: json["email"] as String?,
    );
  }
}

class Chamado {
  final String id;
  final String titulo;
  final String descricao;
  final String? categoria;
  final StatusChamado status;
  final Prioridade prioridade;
  final DateTime criadoEm;
  final UsuarioResumo solicitante;
  final UsuarioResumo? tecnico;

  Chamado({
    required this.id,
    required this.titulo,
    required this.descricao,
    this.categoria,
    required this.status,
    required this.prioridade,
    required this.criadoEm,
    required this.solicitante,
    this.tecnico,
  });

  factory Chamado.fromJson(Map<String, dynamic> json) {
    return Chamado(
      id: json["id"] as String,
      titulo: json["titulo"] as String,
      descricao: json["descricao"] as String,
      categoria: json["categoria"] as String?,
      status: statusFromString(json["status"] as String),
      prioridade: prioridadeFromString(json["prioridade"] as String),
      criadoEm: DateTime.parse(json["criadoEm"] as String),
      solicitante: UsuarioResumo.fromJson(json["solicitante"] as Map<String, dynamic>),
      tecnico: json["tecnico"] != null
          ? UsuarioResumo.fromJson(json["tecnico"] as Map<String, dynamic>)
          : null,
    );
  }
}
