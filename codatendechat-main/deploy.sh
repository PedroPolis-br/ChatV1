#!/bin/bash

echo "🚀 Iniciando deploy do CodAtende Chat..."

# Verificar se Docker está rodando
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker não está rodando. Inicie o Docker e tente novamente."
    exit 1
fi

# Verificar se arquivos .env existem
if [ ! -f "backend/.env" ]; then
    echo "❌ Arquivo backend/.env não encontrado. Copiando do exemplo..."
    cp backend/.env.example backend/.env
    echo "✅ Edite o arquivo backend/.env com suas configurações antes de continuar."
fi

if [ ! -f "frontend/.env" ]; then
    echo "❌ Arquivo frontend/.env não encontrado. Copiando do exemplo..."
    cp frontend/.env.exemple frontend/.env
    echo "✅ Edite o arquivo frontend/.env com suas configurações antes de continuar."
fi

# Carregar variáveis de ambiente
set -a
source backend/.env
set +a

# Parar containers existentes
echo "🛑 Parando containers existentes..."
docker-compose down -v

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

# Executar seeds (se necessário)
echo "🌱 Executando seeds..."
docker-compose exec -T backend npm run db:seed || echo "⚠️ Seeds não executados (pode ser normal)"

echo "✅ Deploy concluído!"
echo "🌐 Frontend: http://localhost:3000"
echo "🔧 Backend: http://localhost:8080"
echo "🗄️ PostgreSQL: localhost:5432"
echo "🔴 Redis: localhost:6379"
echo ""
echo "📊 Para ver logs: docker-compose logs -f"
echo "🔍 Para debug: docker-compose logs -f backend"
echo "🛠️ Para acessar backend: docker-compose exec backend sh"
echo "🗄️ Para acessar banco: docker-compose exec db_postgres psql -U codatende_user -d codatende_db"