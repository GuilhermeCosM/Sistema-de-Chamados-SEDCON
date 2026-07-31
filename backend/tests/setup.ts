import { prisma } from "../src/config/prisma";

beforeEach(async () => {
  await prisma.historicoChamado.deleteMany();
  await prisma.comentario.deleteMany();
  await prisma.chamado.deleteMany();
  await prisma.usuario.deleteMany();
});

afterAll(async () => {
  await prisma.$disconnect();
});