#!/bin/bash

echo "🔍 Script de Troubleshooting - CodAtende Chat"
echo "=============================================="

# Verificar se Docker está rodando
echo "1. Verificando Docker..."
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker não está rodando"
    exit 1
else
    echo "✅ Docker está rodando"
fi

# Verificar status dos containers
echo ""
echo "2. Status dos containers:"
docker-compose ps

# Verificar logs do backend
echo ""
echo "3. Últimos logs do backend:"
docker-compose logs --tail=20 backend

# Verificar logs do banco
echo ""
echo "4. Últimos logs do banco:"
docker-compose logs --tail=10 db_postgres

# Verificar conectividade com banco
echo ""
echo "5. Testando conectividade com banco:"
docker-compose exec -T db_postgres pg_isready -U codatende_user -d codatende_db

# Verificar tabelas do banco
echo ""
echo "6. Verificando tabelas do banco:"
docker-compose exec -T db_postgres psql -U codatende_user -d codatende_db -c "SELECT tablename FROM pg_tables WHERE schemaname = 'public';" 2>/dev/null || echo "❌ Erro ao conectar no banco"

# Verificar Redis
echo ""
echo "7. Testando Redis:"
docker-compose exec -T cache redis-cli ping 2>/dev/null || echo "❌ Redis não está respondendo"

# Verificar portas
echo ""
echo "8. Verificando portas em uso:"
echo "- Backend (8080): $(netstat -an | grep :8080 | wc -l) conexões"
echo "- Frontend (3000): $(netstat -an | grep :3000 | wc -l) conexões"
echo "- PostgreSQL (5432): $(netstat -an | grep :5432 | wc -l) conexões"
echo "- Redis (6379): $(netstat -an | grep :6379 | wc -l) conexões"

# Comandos úteis
echo ""
echo "9. Comandos úteis para debug:"
echo "- Ver logs em tempo real: docker-compose logs -f"
echo "- Acessar container backend: docker-compose exec backend sh"
echo "- Acessar banco: docker-compose exec db_postgres psql -U codatende_user -d codatende_db"
echo "- Reiniciar serviços: docker-compose restart"
echo "- Remover tudo: docker-compose down -v"
echo "- Executar migrações: docker-compose exec backend npm run db:migrate"

echo ""
echo "10. Links para testar:"
echo "- Frontend: http://localhost:3000"
echo "- Backend: http://localhost:8080"
echo "- API Health: http://localhost:8080/health (se disponível)"