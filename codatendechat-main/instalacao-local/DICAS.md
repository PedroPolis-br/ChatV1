# 💡 Dicas e Truques - Desenvolvimento Local

## 🚀 Comandos Essenciais

### Iniciar/Parar Projeto
```bash
# Iniciar projeto
./instalacao-local/deploy-local.sh

# Parar projeto
docker-compose down

# Parar e remover volumes (limpar tudo)
docker-compose down -v

# Reiniciar apenas um serviço
docker-compose restart backend
docker-compose restart frontend
```

### Ver Logs
```bash
# Logs de todos os serviços
docker-compose logs -f

# Logs de um serviço específico
docker-compose logs -f backend
docker-compose logs -f db_postgres
docker-compose logs -f cache

# Últimas 50 linhas de logs
docker-compose logs --tail=50 backend
```

### Acessar Containers
```bash
# Acessar backend
docker-compose exec backend sh

# Acessar banco PostgreSQL
docker-compose exec db_postgres psql -U local_user -d codatende_local

# Acessar Redis
docker-compose exec cache redis-cli -a redis123
```

## 🗄️ Banco de Dados

### Comandos Úteis
```bash
# Executar migrações
docker-compose exec backend npm run db:migrate

# Executar seeds
docker-compose exec backend npm run db:seed

# Reverter última migração
docker-compose exec backend npm run db:migrate:undo

# Ver tabelas
docker-compose exec db_postgres psql -U local_user -d codatende_local -c "\\dt"

# Backup do banco
docker-compose exec db_postgres pg_dump -U local_user codatende_local > backup.sql

# Restaurar backup
docker-compose exec -T db_postgres psql -U local_user -d codatende_local < backup.sql
```

### Conectar com Cliente Externo
```
Host: localhost
Port: 5432
Database: codatende_local
Username: local_user
Password: local123
```

## 🔧 Desenvolvimento

### Hot Reload
- O backend já está configurado para hot reload
- Mudanças no código são refletidas automaticamente
- Frontend precisa ser reconstruído se alterar configurações

### Modificar Código
```bash
# Backend: edite arquivos em backend/src/
# As mudanças são refletidas automaticamente

# Frontend: edite arquivos em frontend/src/
# Pode precisar reconstruir: docker-compose build frontend
```

### Debugging
```bash
# Backend com debug
docker-compose exec backend npm run dev:server

# Ver variáveis de ambiente
docker-compose exec backend printenv

# Verificar conectividade
docker-compose exec backend wget -qO- http://localhost:8080
```

## 🔍 Troubleshooting

### Problemas Comuns

#### 1. Porta já em uso
```bash
# Ver o que está usando a porta
sudo lsof -i :3000
sudo lsof -i :8080

# Matar processo
sudo kill -9 PID_DO_PROCESSO
```

#### 2. Containers não sobem
```bash
# Verificar logs
docker-compose logs

# Limpar cache do Docker
docker system prune -f

# Reconstruir sem cache
docker-compose build --no-cache
```

#### 3. Banco não conecta
```bash
# Verificar se PostgreSQL está rodando
docker-compose ps

# Verificar logs do banco
docker-compose logs db_postgres

# Testar conexão
docker-compose exec db_postgres pg_isready -U local_user -d codatende_local
```

#### 4. Frontend não carrega
```bash
# Verificar se backend está funcionando
curl http://localhost:8080

# Verificar logs do frontend
docker-compose logs frontend

# Reconstruir frontend
docker-compose build frontend
```

## 📊 Monitoramento

### Verificar Status
```bash
# Status dos containers
docker-compose ps

# Uso de recursos
docker stats

# Espaço em disco
docker system df
```

### Health Checks
```bash
# Backend
curl http://localhost:8080

# Frontend
curl http://localhost:3000

# PostgreSQL
docker-compose exec db_postgres pg_isready -U local_user -d codatende_local

# Redis
docker-compose exec cache redis-cli -a redis123 ping
```

## 🔄 Atualizações

### Atualizar Código
```bash
# Puxar código mais recente
git pull origin main

# Reconstruir containers
docker-compose build --no-cache

# Executar migrações
docker-compose exec backend npm run db:migrate
```

### Atualizar Dependências
```bash
# Backend
docker-compose exec backend npm update

# Frontend
docker-compose exec frontend npm update
```

## 🛠️ Customizações

### Alterar Portas
Edite o arquivo `instalacao-local/docker-compose-local.yml`:
```yaml
ports:
  - "3001:3000"  # Frontend na porta 3001
  - "8081:8080"  # Backend na porta 8081
```

### Alterar Configurações
Edite os arquivos `.env`:
- `instalacao-local/.env-backend`
- `instalacao-local/.env-frontend`

### Usar Banco Externo
No arquivo `.env-backend`:
```env
DB_HOST=seu-servidor-postgres.com
DB_PORT=5432
DB_USER=seu_usuario
DB_PASS=sua_senha
DB_NAME=sua_database
```

## 🔐 Segurança

### Para Produção
- Altere todas as senhas padrão
- Use HTTPS
- Configure firewall
- Use secrets do Docker

### Senhas Padrão (APENAS PARA DESENVOLVIMENTO)
```
PostgreSQL: local_user / local123
Redis: redis123
JWT: LOCAL_JWT_SECRET_123456789
```

## 📱 Testes

### Testar API
```bash
# Ping básico
curl http://localhost:8080

# Testar endpoint específico
curl http://localhost:8080/api/users

# Com autenticação
curl -H "Authorization: Bearer SEU_TOKEN" http://localhost:8080/api/protected
```

### Testar WhatsApp
- Configure um número de teste
- Use a interface web para conectar
- Teste envio/recebimento de mensagens

## 🎯 Performance

### Otimizar Containers
```bash
# Limpar imagens não utilizadas
docker image prune -f

# Limpar volumes órfãos
docker volume prune -f

# Limpar tudo
docker system prune -a -f
```

### Monitorar Recursos
```bash
# Ver uso de CPU/RAM
docker stats

# Ver logs de performance
docker-compose logs backend | grep -i "slow\|timeout\|error"
```

## 🔗 Links Úteis

- **Frontend**: http://localhost:3000
- **Backend**: http://localhost:8080
- **PostgreSQL**: localhost:5432
- **Redis**: localhost:6379
- **Logs**: `docker-compose logs -f`

## 🆘 Última Opção

Se nada funcionar:
```bash
# Parar tudo
docker-compose down -v

# Limpar tudo
docker system prune -a -f

# Recomeçar
./instalacao-local/primeiro-uso.sh
```

---

**💡 Lembre-se**: Desenvolvimento local é para testar e desenvolver. Para produção, use configurações diferentes!