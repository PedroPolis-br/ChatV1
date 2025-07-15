#!/bin/bash

echo "🎉 Primeiro Uso - CodAtende Chat Local"
echo "======================================"

# Verificar se estamos no diretório correto
if [ ! -f "instalacao-local/primeiro-uso.sh" ]; then
    echo "❌ Execute este script a partir do diretório raiz do projeto"
    echo "   Exemplo: ./instalacao-local/primeiro-uso.sh"
    exit 1
fi

echo "🔍 Verificando pré-requisitos..."

# Verificar Docker
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker não está rodando ou não está instalado"
    echo "   Instale o Docker e tente novamente"
    echo "   https://docs.docker.com/get-docker/"
    exit 1
fi
echo "✅ Docker está funcionando"

# Verificar Docker Compose
if ! docker-compose --version > /dev/null 2>&1; then
    echo "❌ Docker Compose não está instalado"
    echo "   Instale o Docker Compose e tente novamente"
    exit 1
fi
echo "✅ Docker Compose está funcionando"

# Verificar Node.js (opcional)
if command -v node > /dev/null 2>&1; then
    echo "✅ Node.js está instalado (versão: $(node --version))"
else
    echo "⚠️  Node.js não está instalado (opcional para Docker)"
fi

# Verificar portas
echo ""
echo "🔌 Verificando portas necessárias..."
check_port() {
    local port=$1
    local service=$2
    if lsof -i :$port >/dev/null 2>&1; then
        echo "⚠️  Porta $port ($service) está em uso"
        echo "   Deseja continuar mesmo assim? (y/n)"
        read -r response
        if [ "$response" != "y" ]; then
            echo "❌ Cancelado pelo usuário"
            exit 1
        fi
    else
        echo "✅ Porta $port ($service) está livre"
    fi
}

check_port 3000 "Frontend"
check_port 8080 "Backend"
check_port 5432 "PostgreSQL"
check_port 6379 "Redis"

# Configurar arquivos
echo ""
echo "📁 Configurando arquivos..."
cp instalacao-local/.env-backend backend/.env
cp instalacao-local/.env-frontend frontend/.env
cp instalacao-local/docker-compose-local.yml docker-compose.yml
echo "✅ Arquivos de configuração copiados"

# Limpar ambiente anterior
echo ""
echo "🧹 Limpando ambiente anterior..."
docker-compose down -v 2>/dev/null || true
docker system prune -f

# Primeira construção
echo ""
echo "🔨 Construindo containers (primeira vez pode demorar)..."
docker-compose build --no-cache

# Iniciar serviços
echo ""
echo "🚀 Iniciando serviços..."
docker-compose up -d

# Aguardar inicialização
echo ""
echo "⏳ Aguardando serviços iniciarem..."
sleep 30

# Verificar se tudo está funcionando
echo ""
echo "🔍 Verificando se tudo está funcionando..."

# Verificar PostgreSQL
max_attempts=10
attempt=0
while [ $attempt -lt $max_attempts ]; do
    if docker-compose exec -T db_postgres pg_isready -U local_user -d codatende_local >/dev/null 2>&1; then
        echo "✅ PostgreSQL está funcionando"
        break
    else
        echo "⏳ Aguardando PostgreSQL... (tentativa $((attempt+1))/$max_attempts)"
        sleep 3
        attempt=$((attempt+1))
    fi
done

if [ $attempt -eq $max_attempts ]; then
    echo "❌ PostgreSQL não iniciou corretamente"
    echo "   Verifique os logs: docker-compose logs db_postgres"
fi

# Verificar Redis
if docker-compose exec -T cache redis-cli -a redis123 ping >/dev/null 2>&1; then
    echo "✅ Redis está funcionando"
else
    echo "❌ Redis não está funcionando"
fi

# Executar migrações
echo ""
echo "🗄️ Executando migrações do banco..."
docker-compose exec -T backend npm run db:migrate

# Executar seeds
echo ""
echo "🌱 Executando seeds iniciais..."
docker-compose exec -T backend npm run db:seed || echo "⚠️  Seeds não executados (pode ser normal)"

# Verificar conectividade
echo ""
echo "🌐 Verificando conectividade..."

# Aguardar backend
attempt=0
while [ $attempt -lt $max_attempts ]; do
    if curl -s http://localhost:8080 >/dev/null 2>&1; then
        echo "✅ Backend está respondendo"
        break
    else
        echo "⏳ Aguardando backend... (tentativa $((attempt+1))/$max_attempts)"
        sleep 5
        attempt=$((attempt+1))
    fi
done

# Aguardar frontend
attempt=0
while [ $attempt -lt $max_attempts ]; do
    if curl -s http://localhost:3000 >/dev/null 2>&1; then
        echo "✅ Frontend está respondendo"
        break
    else
        echo "⏳ Aguardando frontend... (tentativa $((attempt+1))/$max_attempts)"
        sleep 5
        attempt=$((attempt+1))
    fi
done

# Status final
echo ""
echo "📊 Status final dos containers:"
docker-compose ps

echo ""
echo "🎉 INSTALAÇÃO CONCLUÍDA!"
echo "========================"
echo ""
echo "🌐 Acesse a aplicação:"
echo "   Frontend: http://localhost:3000"
echo "   Backend:  http://localhost:8080"
echo ""
echo "🔧 Comandos úteis:"
echo "   Ver logs:        docker-compose logs -f"
echo "   Parar projeto:   docker-compose down"
echo "   Reiniciar:       docker-compose restart"
echo "   Diagnóstico:     ./instalacao-local/diagnostico.sh"
echo "   Deploy:          ./instalacao-local/deploy-local.sh"
echo ""
echo "📝 Credenciais do banco (se precisar):"
echo "   Host: localhost"
echo "   Porta: 5432"
echo "   Usuário: local_user"
echo "   Senha: local123"
echo "   Database: codatende_local"
echo ""
echo "💡 Dicas:"
echo "   - Os dados ficam salvos mesmo se você parar os containers"
echo "   - Para limpar tudo: docker-compose down -v"
echo "   - Para ver logs em tempo real: docker-compose logs -f"
echo ""
echo "🚀 Agora você pode começar a usar o CodAtende Chat!"

# Tentar abrir no navegador (opcional)
if command -v xdg-open > /dev/null 2>&1; then
    echo ""
    echo "🌐 Abrindo no navegador..."
    xdg-open http://localhost:3000 &
elif command -v open > /dev/null 2>&1; then
    echo ""
    echo "🌐 Abrindo no navegador..."
    open http://localhost:3000 &
fi