# 🚀 Deploy Simplificado - CodAtende Chat

## ⚡ Solução Rápida para o Problema de Credenciais

### 🔧 O que foi corrigido:
- **DB_HOST** alterado de `localhost` para `db_postgres` (nome do container)
- **Docker Compose** otimizado com health checks
- **Arquivos .env** configurados corretamente
- **Scripts automatizados** para deploy e troubleshooting

---

## 📋 Pré-requisitos

1. **Docker** e **Docker Compose** instalados
2. **Git** instalado
3. **Portas livres**: 3000, 8080, 5432, 6379

---

## 🎯 Deploy em 3 Passos

### 1. Executar o Deploy
```bash
./deploy.sh
```

### 2. Aguardar a inicialização (2-3 minutos)
```bash
# Acompanhar logs
docker-compose logs -f
```

### 3. Acessar a aplicação
- **Frontend**: http://localhost:3000
- **Backend**: http://localhost:8080

---

## 🔍 Se algo der errado

### Executar diagnóstico:
```bash
./troubleshoot.sh
```

### Comandos úteis:
```bash
# Ver logs específicos
docker-compose logs -f backend
docker-compose logs -f db_postgres

# Reiniciar um serviço
docker-compose restart backend

# Recomeçar do zero
docker-compose down -v
./deploy.sh

# Acessar container do backend
docker-compose exec backend sh

# Acessar banco PostgreSQL
docker-compose exec db_postgres psql -U codatende_user -d codatende_db
```

---

## ⚙️ Configurações Personalizadas

### Para usar em produção:

1. **Editar backend/.env**:
```env
# Altere estas configurações
BACKEND_URL=https://seu-dominio.com
FRONTEND_URL=https://seu-dominio.com
DB_PASS=SuaSenhaSegura123!
JWT_SECRET=NovoSecretAqui
```

2. **Editar frontend/.env**:
```env
REACT_APP_BACKEND_URL=https://seu-dominio.com
```

---

## 🌐 Deploy em Nuvem

### AWS/Google Cloud/Azure:

1. **Subir os arquivos** para o servidor
2. **Instalar Docker** no servidor
3. **Configurar firewall** (portas 3000, 8080, 5432, 6379)
4. **Alterar URLs** nos arquivos .env
5. **Executar**: `./deploy.sh`

### Para HTTPS:
- Configure um proxy reverso (nginx)
- Obtenha certificado SSL (Let's Encrypt)
- Altere as URLs para https://

---

## 🔐 Segurança

### Para produção, altere:
- `DB_PASS` - senha do banco
- `JWT_SECRET` - chave JWT
- `JWT_REFRESH_SECRET` - chave refresh token
- `REDIS_PASS` - senha do Redis

### Gerar novos secrets:
```bash
# JWT Secret
openssl rand -base64 32

# Refresh Secret
openssl rand -base64 32
```

---

## 📊 Monitoramento

### Ver status dos serviços:
```bash
docker-compose ps
```

### Verificar recursos:
```bash
docker stats
```

### Backup do banco:
```bash
docker-compose exec db_postgres pg_dump -U codatende_user codatende_db > backup.sql
```

---

## 🚨 Problemas Comuns

### ❌ "Connection refused" ou "Host not found"
**Solução**: Verifique se `DB_HOST=db_postgres` no arquivo `.env`

### ❌ "Authentication failed"
**Solução**: Verifique se as credenciais no `.env` estão corretas

### ❌ "Port already in use"
**Solução**: 
```bash
# Matar processos na porta
sudo lsof -ti:8080 | xargs kill -9
sudo lsof -ti:3000 | xargs kill -9
```

### ❌ "Cannot connect to Docker daemon"
**Solução**: Inicie o Docker
```bash
sudo systemctl start docker
sudo systemctl enable docker
```

---

## 📞 Suporte

### Logs detalhados:
```bash
# Backend
docker-compose logs -f backend

# Banco
docker-compose logs -f db_postgres

# Todos os serviços
docker-compose logs -f
```

### Limpar tudo e recomeçar:
```bash
docker-compose down -v
docker image prune -f
./deploy.sh
```

---

## ✅ Checklist Final

- [ ] Docker instalado e rodando
- [ ] Arquivos .env configurados
- [ ] Portas 3000, 8080, 5432, 6379 livres
- [ ] Deploy executado com sucesso
- [ ] Frontend acessível em http://localhost:3000
- [ ] Backend acessível em http://localhost:8080
- [ ] Banco de dados funcionando
- [ ] Redis funcionando

---

**💡 Dica**: Se você está migrando de MySQL para PostgreSQL, apenas altere `DB_DIALECT=postgres` no arquivo `.env`. O resto da configuração já está correta!

**🎉 Agora seu CodAtende Chat está rodando perfeitamente!**