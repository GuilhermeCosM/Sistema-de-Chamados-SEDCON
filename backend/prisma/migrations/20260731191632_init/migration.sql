-- CreateEnum
CREATE TYPE "Role" AS ENUM ('ADMIN', 'TECNICO', 'CLIENTE');

-- CreateEnum
CREATE TYPE "StatusChamado" AS ENUM ('ABERTO', 'EM_ANDAMENTO', 'AGUARDANDO_CLIENTE', 'RESOLVIDO', 'FECHADO');

-- CreateEnum
CREATE TYPE "Prioridade" AS ENUM ('BAIXA', 'MEDIA', 'ALTA', 'URGENTE');

-- CreateTable
CREATE TABLE "usuarios" (
    "id" TEXT NOT NULL,
    "nome" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "senhaHash" TEXT NOT NULL,
    "role" "Role" NOT NULL DEFAULT 'CLIENTE',
    "criadoEm" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "usuarios_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "chamados" (
    "id" TEXT NOT NULL,
    "titulo" TEXT NOT NULL,
    "descricao" TEXT NOT NULL,
    "categoria" TEXT,
    "status" "StatusChamado" NOT NULL DEFAULT 'ABERTO',
    "prioridade" "Prioridade" NOT NULL DEFAULT 'MEDIA',
    "criadoEm" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(3) NOT NULL,
    "solicitanteId" TEXT NOT NULL,
    "tecnicoId" TEXT,

    CONSTRAINT "chamados_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "comentarios" (
    "id" TEXT NOT NULL,
    "texto" TEXT NOT NULL,
    "criadoEm" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "chamadoId" TEXT NOT NULL,
    "autorId" TEXT NOT NULL,

    CONSTRAINT "comentarios_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "historico_chamados" (
    "id" TEXT NOT NULL,
    "campo" TEXT NOT NULL,
    "valorAntigo" TEXT,
    "valorNovo" TEXT NOT NULL,
    "criadoEm" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "chamadoId" TEXT NOT NULL,
    "autorId" TEXT NOT NULL,

    CONSTRAINT "historico_chamados_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "usuarios_email_key" ON "usuarios"("email");

-- AddForeignKey
ALTER TABLE "chamados" ADD CONSTRAINT "chamados_solicitanteId_fkey" FOREIGN KEY ("solicitanteId") REFERENCES "usuarios"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "chamados" ADD CONSTRAINT "chamados_tecnicoId_fkey" FOREIGN KEY ("tecnicoId") REFERENCES "usuarios"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "comentarios" ADD CONSTRAINT "comentarios_chamadoId_fkey" FOREIGN KEY ("chamadoId") REFERENCES "chamados"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "comentarios" ADD CONSTRAINT "comentarios_autorId_fkey" FOREIGN KEY ("autorId") REFERENCES "usuarios"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "historico_chamados" ADD CONSTRAINT "historico_chamados_chamadoId_fkey" FOREIGN KEY ("chamadoId") REFERENCES "chamados"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "historico_chamados" ADD CONSTRAINT "historico_chamados_autorId_fkey" FOREIGN KEY ("autorId") REFERENCES "usuarios"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
