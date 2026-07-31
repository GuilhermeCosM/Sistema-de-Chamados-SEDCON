import { PrismaClient } from "@prisma/client";
import bcrypt from "bcryptjs";

const prisma = new PrismaClient();

async function main() {
  const senhaHash = await bcrypt.hash("123456", 10);

  const admin = await prisma.usuario.upsert({
    where: { email: "admin@chamados.com" },
    update: {},
    create: { nome: "Admin", email: "admin@chamados.com", senhaHash, role: "ADMIN" },
  });

  const tecnico = await prisma.usuario.upsert({
    where: { email: "tecnico@chamados.com" },
    update: {},
    create: { nome: "João Técnico", email: "tecnico@chamados.com", senhaHash, role: "TECNICO" },
  });

  const cliente = await prisma.usuario.upsert({
    where: { email: "cliente@chamados.com" },
    update: {},
    create: { nome: "Maria Cliente", email: "cliente@chamados.com", senhaHash, role: "CLIENTE" },
  });

  await prisma.chamado.createMany({
    data: [
      {
        titulo: "Impressora não liga",
        descricao: "A impressora do setor financeiro não liga desde ontem à tarde.",
        prioridade: "ALTA",
        status: "ABERTO",
        categoria: "Hardware",
        solicitanteId: cliente.id,
      },
      {
        titulo: "Sistema lento ao abrir relatórios",
        descricao: "O sistema de relatórios está demorando mais de 1 minuto para carregar.",
        prioridade: "MEDIA",
        status: "EM_ANDAMENTO",
        categoria: "Software",
        solicitanteId: cliente.id,
        tecnicoId: tecnico.id,
      },
    ],
    skipDuplicates: true,
  });

  console.log("✅ Seed concluído:", { admin: admin.email, tecnico: tecnico.email, cliente: cliente.email });
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
