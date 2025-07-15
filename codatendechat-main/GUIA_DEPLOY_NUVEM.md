# Guia Completo para Deploy em Nuvem - CodAtende Chat

## Problema Identificado
O erro de credenciais está acontecendo porque:
1. As variáveis de ambiente não estão sendo carregadas corretamente
2. O `DB_HOST` precisa ser ajustado para funcionar com Docker
3. Falta sincronização entre os containers

## Solução Completa

### 1. Arquivo .env para Backend (Produção)

Crie o arquivo `.env` na pasta `backend/` com as seguintes configurações:

```env
NODE_ENV=production
BACKEND_URL=https://seu-dominio.com
FRONTEND_URL=https://seu-dominio.com
PROXY_PORT=8080
PORT=8080

# Configuração do Banco PostgreSQL
DB_DIALECT=postgres
DB_HOST=db_postgres
DB_PORT=5432
DB_USER=codatende_user
DB_PASS=SuaSenhaSegura123!
DB_NAME=codatende_db
DB_DEBUG=false

# JWT Secrets (gere novos)
JWT_SECRET=kZaOTd+YZpjRUyyuQUpigJaEMk4vcW4YOymKPZX0Ts8=
JWT_REFRESH_SECRET=dBSXqFg9TaNUEDXVp6fhMTRLBysP+j2DSqf7+raxD3A=

# Redis Configuration
REDIS_URI=redis://:123456@cache:6379
REDIS_PORT=6379
REDIS_PASS=123456
REDIS_DBS=16
REDIS_OPT_LIMITER_MAX=1
REDIS_OPT_LIMITER_DURATION=3000

# Limites
USER_LIMIT=10000
CONNECTIONS_LIMIT=100000
CLOSED_SEND_BY_ME=true

# Email Configuration
MAIL_HOST=smtp.gmail.com
MAIL_USER=seu@gmail.com
MAIL_PASS=SuaSenhaDeApp
MAIL_FROM=seu@gmail.com
MAIL_PORT=465

# Gerencianet (se usar)
GERENCIANET_SANDBOX=false
GERENCIANET_CLIENT_ID=seu_client_id
GERENCIANET_CLIENT_SECRET=seu_client_secret
GERENCIANET_PIX_CERT=certificado-gerencianet
GERENCIANET_PIX_KEY=sua_chave_pix
```

### 2. Arquivo .env para Frontend

Crie o arquivo `.env` na pasta `frontend/` com:

```env
REACT_APP_BACKEND_URL=https://seu-dominio.com
REACT_APP_HOURS_CLOSE_TICKETS_AUTO=24
```

### 3. Docker Compose Completo para Produção

Crie o arquivo `docker-compose.yml` na raiz do projeto:

```yaml
version: '3.8'

services:
  # Cache Redis
  cache:
    image: redis:7-alpine
    restart: unless-stopped
    ports:
      - "${REDIS_PORT:-6379}:6379"
    environment:
      - REDIS_PASSWORD=${REDIS_PASS:-123456}
    command: redis-server --requirepass ${REDIS_PASS:-123456}
    volumes:
      - redis_data:/data
    networks:
      - app_network
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

  # Banco PostgreSQL
  db_postgres:
    image: postgres:15-alpine
    restart: unless-stopped
    environment:
      POSTGRES_DB: ${DB_NAME:-codatende_db}
      POSTGRES_USER: ${DB_USER:-codatende_user}
      POSTGRES_PASSWORD: ${DB_PASS:-SuaSenhaSegura123!}
      POSTGRES_INITDB_ARGS: "--auth-host=scram-sha-256"
    ports:
      - "${DB_PORT:-5432}:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - app_network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER:-codatende_user} -d ${DB_NAME:-codatende_db}"]
      interval: 10s
      timeout: 5s
      retries: 5

  # Backend Application
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    restart: unless-stopped
    environment:
      - NODE_ENV=production
      - DB_DIALECT=${DB_DIALECT:-postgres}
      - DB_HOST=db_postgres
      - DB_PORT=${DB_PORT:-5432}
      - DB_NAME=${DB_NAME:-codatende_db}
      - DB_USER=${DB_USER:-codatende_user}
      - DB_PASS=${DB_PASS:-SuaSenhaSegura123!}
      - DB_DEBUG=${DB_DEBUG:-false}
      - REDIS_URI=redis://:${REDIS_PASS:-123456}@cache:6379
      - JWT_SECRET=${JWT_SECRET}
      - JWT_REFRESH_SECRET=${JWT_REFRESH_SECRET}
      - BACKEND_URL=${BACKEND_URL}
      - FRONTEND_URL=${FRONTEND_URL}
      - PORT=${PORT:-8080}
    ports:
      - "${PORT:-8080}:8080"
    depends_on:
      db_postgres:
        condition: service_healthy
      cache:
        condition: service_healthy
    networks:
      - app_network
    volumes:
      - ./backend/public:/app/public

  # Frontend Application
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
      args:
        - REACT_APP_BACKEND_URL=${BACKEND_URL}
    restart: unless-stopped
    ports:
      - "3000:3000"
    depends_on:
      - backend
    networks:
      - app_network

volumes:
  postgres_data:
  redis_data:

networks:
  app_network:
    driver: bridge
```

### 4. Dockerfile para Backend

Crie o arquivo `Dockerfile` na pasta `backend/`:

```dockerfile
FROM node:18-alpine

# Instalar dependências do sistema
RUN apk add --no-cache \
    python3 \
    make \
    g++ \
    ffmpeg

# Criar diretório de trabalho
WORKDIR /app

# Copiar arquivos de dependências
COPY package*.json ./

# Instalar dependências
RUN npm ci --only=production

# Copiar código fonte
COPY . .

# Compilar TypeScript
RUN npm run build

# Expor porta
EXPOSE 8080

# Comando para iniciar aplicação
CMD ["npm", "start"]
```

### 5. Dockerfile para Frontend

Crie o arquivo `Dockerfile` na pasta `frontend/`:

```dockerfile
FROM node:18-alpine as builder

WORKDIR /app

# Copiar arquivos de dependências
COPY package*.json ./

# Instalar dependências
RUN npm ci

# Copiar código fonte
COPY . .

# Compilar aplicação
RUN npm run build

# Imagem de produção
FROM nginx:alpine

# Copiar arquivos compilados
COPY --from=builder /app/build /usr/share/nginx/html

# Copiar configuração do nginx
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 3000

CMD ["nginx", "-g", "daemon off;"]
```

### 6. Configuração Nginx para Frontend

Crie o arquivo `nginx.conf` na pasta `frontend/`:

```nginx
events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    server {
        listen 3000;
        server_name localhost;
        root /usr/share/nginx/html;
        index index.html;

        # Configuração para SPA (Single Page Application)
        location / {
            try_files $uri $uri/ /index.html;
        }

        # Cache para arquivos estáticos
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }

        # Configuração para API
        location /api {
            proxy_pass http://backend:8080;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
```

### 7. Script de Deploy

Crie o arquivo `deploy.sh` na raiz do projeto:

```bash
#!/bin/bash

echo "🚀 Iniciando deploy do CodAtende Chat..."

# Verificar se Docker está rodando
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker não está rodando. Inicie o Docker e tente novamente."
    exit 1
fi

# Parar containers existentes
echo "🛑 Parando containers existentes..."
docker-compose down

# Remover imagens antigas
echo "🧹 Limpando imagens antigas..."
docker image prune -f

# Construir e iniciar containers
echo "🔨 Construindo e iniciando containers..."
docker-compose up -d --build

# Aguardar containers iniciarem
echo "⏳ Aguardando containers iniciarem..."
sleep 30

# Verificar status
echo "📊 Verificando status dos containers..."
docker-compose ps

# Executar migrações do banco
echo "🗄️ Executando migrações do banco..."
docker-compose exec backend npm run db:migrate

# Executar seeds (se necessário)
echo "🌱 Executando seeds..."
docker-compose exec backend npm run db:seed

echo "✅ Deploy concluído!"
echo "🌐 Frontend: http://localhost:3000"
echo "🔧 Backend: http://localhost:8080"
echo "📊 Logs: docker-compose logs -f"
```

### 8. Comandos para Deploy

1. **Preparar ambiente:**
```bash
# Dar permissão de execução
chmod +x deploy.sh

# Criar arquivos .env
cp backend/.env.example backend/.env
cp frontend/.env.exemple frontend/.env

# Editar os arquivos .env com suas configurações
```

2. **Executar deploy:**
```bash
./deploy.sh
```

3. **Verificar logs:**
```bash
# Logs de todos os containers
docker-compose logs -f

# Logs específicos
docker-compose logs -f backend
docker-compose logs -f db_postgres
```

### 9. Resolução de Problemas Comuns

#### Erro de Conexão com Banco:
```bash
# Verificar se o banco está rodando
docker-compose ps

# Verificar logs do banco
docker-compose logs db_postgres

# Reiniciar apenas o banco
docker-compose restart db_postgres
```

#### Problema com Migrações:
```bash
# Entrar no container do backend
docker-compose exec backend sh

# Executar migrações manualmente
npm run db:migrate

# Verificar tabelas criadas
docker-compose exec db_postgres psql -U codatende_user -d codatende_db -c "\\dt"
```

#### Limpar tudo e recomeçar:
```bash
# Parar e remover tudo
docker-compose down -v

# Remover imagens
docker image prune -f

# Executar deploy novamente
./deploy.sh
```

### 10. Configuração para Produção em Nuvem

Para deploy em serviços como AWS, Google Cloud, etc:

1. **Ajustar variáveis de ambiente:**
   - Alterar `DB_HOST` para o endereço do banco gerenciado
   - Usar Redis gerenciado
   - Configurar domínio real

2. **Usar Docker Swarm ou Kubernetes:**
   - Configurar secrets para senhas
   - Usar load balancers
   - Configurar SSL/TLS

3. **Monitoramento:**
   - Logs centralizados
   - Métricas de performance
   - Alertas

### 11. Checklist Final

- [ ] Arquivo `.env` criado no backend
- [ ] Arquivo `.env` criado no frontend
- [ ] Docker e Docker Compose instalados
- [ ] Ports liberados no firewall (3000, 8080, 5432, 6379)
- [ ] Domínio configurado (se aplicável)
- [ ] SSL/TLS configurado (se aplicável)
- [ ] Backup do banco configurado
- [ ] Monitoramento configurado

---

**Dica importante:** O erro de credenciais geralmente acontece porque o `DB_HOST` está configurado como `localhost` em vez de `db_postgres` (nome do container). Sempre use o nome do serviço Docker como host quando os containers estão na mesma rede.

Se ainda tiver problemas, execute: `docker-compose logs -f backend` para ver os logs detalhados do erro.