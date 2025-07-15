#!/bin/bash

echo "🔍 Diagnóstico Local - CodAtende Chat"
echo "====================================="

# Verificar se estamos no diretório correto
if [ ! -f "instalacao-local/diagnostico.sh" ]; then
    echo "❌ Execute este script a partir do diretório raiz do projeto"
    echo "   Exemplo: ./instalacao-local/diagnostico.sh"
    exit 1
fi

# Verificar Docker
echo "1. 🐳 Verificando Docker..."
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker não está rodando"
    exit 1
else
    echo "✅ Docker está funcionando"
fi

# Verificar Docker Compose
echo ""
echo "2. 📋 Verificando Docker Compose..."
if ! docker-compose --version > /dev/null 2>&1; then
    echo "❌ Docker Compose não está instalado"
    exit 1
else
    echo "✅ Docker Compose está funcionando"
fi

# Status dos containers
echo ""
echo "3. 📊 Status dos containers:"
docker-compose ps

# Verificar portas
echo ""
echo "4. 🔌 Verificando portas:"
check_port() {
    local port=$1
    local service=$2
    if lsof -i :$port >/dev/null 2>&1; then
        echo "✅ Porta $port ($service) está em uso"
    else
        echo "⚠️  Porta $port ($service) está livre"
    fi
}

check_port 3000 "Frontend"
check_port 8080 "Backend"
check_port 5432 "PostgreSQL"
check_port 6379 "Redis"

# Verificar conectividade
echo ""
echo "5. 🌐 Testando conectividade:"

# Backend
if curl -s http://localhost:8080 >/dev/null 2>&1; then
    echo "✅ Backend respondendo em http://localhost:8080"
else
    echo "❌ Backend NÃO está respondendo em http://localhost:8080"
fi

# Frontend
if curl -s http://localhost:3000 >/dev/null 2>&1; then
    echo "✅ Frontend respondendo em http://localhost:3000"
else
    echo "❌ Frontend NÃO está respondendo em http://localhost:3000"
fi

# Verificar banco
echo ""
echo "6. 🗄️ Testando banco PostgreSQL:"
if docker-compose exec -T db_postgres pg_isready -U local_user -d codatende_local >/dev/null 2>&1; then
    echo "✅ PostgreSQL está funcionando"
    
    # Verificar tabelas
    echo "📋 Verificando tabelas:"
    docker-compose exec -T db_postgres psql -U local_user -d codatende_local -c "SELECT COUNT(*) as total_tables FROM information_schema.tables WHERE table_schema = 'public';" 2>/dev/null | grep -E "[0-9]+" | tail -1 | while read count; do
        if [ "$count" -gt 0 ]; then
            echo "✅ Banco tem $count tabelas"
        else
            echo "⚠️  Banco não tem tabelas (pode precisar executar migrações)"
        fi
    done
else
    echo "❌ PostgreSQL NÃO está funcionando"
fi

# Verificar Redis
echo ""
echo "7. 🔴 Testando Redis:"
if docker-compose exec -T cache redis-cli -a redis123 ping >/dev/null 2>&1; then
    echo "✅ Redis está funcionando"
else
    echo "❌ Redis NÃO está funcionando"
fi

# Logs recentes
echo ""
echo "8. 📋 Últimos logs dos serviços:"
echo ""
echo "🔧 Backend:"
docker-compose logs --tail=5 backend

echo ""
echo "🗄️ PostgreSQL:"
docker-compose logs --tail=5 db_postgres

echo ""
echo "🔴 Redis:"
docker-compose logs --tail=5 cache

# Verificar recursos
echo ""
echo "9. 💾 Uso de recursos:"
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}" | head -10

# Comandos úteis
echo ""
echo "10. 🛠️ Comandos úteis para resolver problemas:"
echo ""
echo "# Ver logs em tempo real:"
echo "docker-compose logs -f"
echo ""
echo "# Reiniciar um serviço específico:"
echo "docker-compose restart backend"
echo "docker-compose restart db_postgres"
echo ""
echo "# Executar migrações manualmente:"
echo "docker-compose exec backend npm run db:migrate"
echo ""
echo "# Acessar container do backend:"
echo "docker-compose exec backend sh"
echo ""
echo "# Acessar banco PostgreSQL:"
echo "docker-compose exec db_postgres psql -U local_user -d codatende_local"
echo ""
echo "# Limpar tudo e recomeçar:"
echo "docker-compose down -v"
echo "./instalacao-local/deploy-local.sh"
echo ""
echo "# Matar processos nas portas (se necessário):"
echo "sudo lsof -ti:3000 | xargs kill -9"
echo "sudo lsof -ti:8080 | xargs kill -9"

echo ""
echo "✅ Diagnóstico concluído!"