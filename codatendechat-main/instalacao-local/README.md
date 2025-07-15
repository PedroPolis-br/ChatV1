# 🏠 Instalação Local - CodAtende Chat

## 🎯 Configuração para Desenvolvimento Local

Esta pasta contém todas as configurações otimizadas para rodar o projeto **localmente** no seu computador.

---

## 📋 Pré-requisitos

1. **Docker** e **Docker Compose** instalados
2. **Node.js** (opcional, para desenvolvimento)
3. **Git** instalado
4. **8GB RAM** recomendado
5. **Portas livres**: 3000, 8080, 5432, 6379

---

## 🚀 Instalação Super Simples

### 1️⃣ Copiar arquivos de configuração
```bash
# Copiar configurações locais
cp instalacao-local/.env-backend ../backend/.env
cp instalacao-local/.env-frontend ../frontend/.env
cp instalacao-local/docker-compose-local.yml ../docker-compose.yml
```

### 2️⃣ Executar o projeto
```bash
# Voltar para pasta principal
cd ..

# Executar deploy local
./instalacao-local/deploy-local.sh
```

### 3️⃣ Acessar a aplicação
- **Frontend**: http://localhost:3000
- **Backend**: http://localhost:8080
- **Admin**: http://localhost:3000/admin (se disponível)

---

## 🔧 Configurações Locais

### Banco de dados:
- **Host**: localhost
- **Porta**: 5432
- **Usuário**: local_user
- **Senha**: local123
- **Database**: codatende_local

### Redis:
- **Host**: localhost
- **Porta**: 6379
- **Senha**: redis123

### URLs:
- **Backend**: http://localhost:8080
- **Frontend**: http://localhost:3000

---

## 🛠️ Comandos Úteis

### Gerenciar containers:
```bash
# Iniciar projeto
./instalacao-local/deploy-local.sh

# Parar projeto
docker-compose down

# Reiniciar projeto
docker-compose restart

# Ver logs
docker-compose logs -f

# Limpar tudo e recomeçar
docker-compose down -v
./instalacao-local/deploy-local.sh
```

### Desenvolvimento:
```bash
# Executar só o backend (se quiser frontend separado)
docker-compose up backend db_postgres cache

# Executar migrações
docker-compose exec backend npm run db:migrate

# Acessar container do backend
docker-compose exec backend sh

# Backup do banco
docker-compose exec db_postgres pg_dump -U local_user codatende_local > backup.sql
```

---

## 🔍 Resolução de Problemas

### Se algo der errado:
```bash
# Diagnóstico completo
./instalacao-local/diagnostico.sh

# Verificar logs específicos
docker-compose logs backend
docker-compose logs db_postgres

# Limpar cache do Docker
docker system prune -f
```

### Problemas comuns:
- **Porta ocupada**: Use o comando `sudo lsof -i :3000` para ver o que está usando
- **Banco não conecta**: Verifique se o PostgreSQL está rodando
- **Frontend não carrega**: Verifique se o backend está funcionando

---

## 📁 Estrutura dos Arquivos

```
instalacao-local/
├── README.md                  # Este arquivo
├── .env-backend              # Configurações do backend
├── .env-frontend             # Configurações do frontend
├── docker-compose-local.yml  # Docker compose para local
├── deploy-local.sh           # Script de deploy local
├── diagnostico.sh            # Script de diagnóstico
├── primeiro-uso.sh           # Script para primeira instalação
└── DICAS.md                  # Dicas e truques
```

---

## 🎉 Primeiro Uso

Se é sua primeira vez rodando o projeto:

```bash
# Execute este comando
./instalacao-local/primeiro-uso.sh
```

Este script vai:
1. Verificar se tudo está instalado
2. Configurar os arquivos necessários
3. Fazer o primeiro deploy
4. Criar um usuário admin
5. Mostrar como acessar o sistema

---

## 💡 Dicas para Desenvolvimento Local

- Use **http://localhost:3000** para acessar o frontend
- Use **http://localhost:8080** para acessar a API
- O banco persiste os dados mesmo quando você para os containers
- Para limpar tudo: `docker-compose down -v`
- Para ver logs em tempo real: `docker-compose logs -f`

---

## 🔗 Links Úteis

- **Interface Principal**: http://localhost:3000
- **API Backend**: http://localhost:8080
- **Documentação API**: http://localhost:8080/docs (se disponível)
- **Banco de Dados**: localhost:5432

---

**🎯 Agora é só seguir os passos e o projeto vai funcionar perfeitamente no seu computador local!**