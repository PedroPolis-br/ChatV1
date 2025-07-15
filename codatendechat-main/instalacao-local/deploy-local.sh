#!/bin/bash

echo "🏠 Deploy Local - CodAtende Chat"
echo "=================================="

# Verificar se estamos no diretório correto
if [ ! -f "instalacao-local/deploy-local.sh" ]; then
    echo "❌ Execute este script a partir do diretório raiz do projeto"
    echo "   Exemplo: ./instalacao-local/deploy-local.sh"
    exit 1
fi

# Verificar se Docker está rodando
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker não está rodando. Inicie o Docker e tente novamente."
    exit 1
fi

echo "✅ Docker está rodando"

# Copiar arquivos de configuração
echo "📋 Copiando configurações locais..."
cp instalacao-local/.env-backend backend/.env
cp instalacao-local/.env-frontend frontend/.env
cp instalacao-local/docker-compose-local.yml docker-compose.yml

echo "✅ Configurações copiadas"

# Verificar se portas estão livres
echo "🔍 Verificando portas..."

check_port() {
    local port=$1
    if lsof -i :$port >/dev/null 2>&1; then
        echo "⚠️  Porta $port está em uso. Você quer continuar? (y/n)"
        read -r response
        if [ "$response" != "y" ]; then
            echo "❌ Cancelado pelo usuário"
            exit 1
        fi
    fi
}

check_port 3000
check_port 8080
check_port 5432
check_port 6379

# Parar containers existentes
echo "🛑 Parando containers existentes..."
docker-compose down -v

# Limpar cache do Docker
echo "🧹 Limpando cache do Docker..."
docker system prune -f

# Construir e iniciar containers
echo "🔨 Construindo e iniciando containers..."
docker-compose up -d --build

# Aguardar inicialização
echo "⏳ Aguardando containers iniciarem..."
sleep 20

# Verificar status
echo "📊 Verificando status dos containers..."
docker-compose ps

echo ""
echo "🎯 Verificando conectividade..."

# Verificar se backend está respondendo
if curl -s http://localhost:8080 >/dev/null 2>&1; then
    echo "✅ Backend funcionando: http://localhost:8080"
else
    echo "⚠️  Backend ainda não está pronto (normal na primeira execução)"
fi

# Verificar se frontend está respondendo
if curl -s http://localhost:3000 >/dev/null 2>&1; then
    echo "✅ Frontend funcionando: http://localhost:3000"
else
    echo "⚠️  Frontend ainda não está pronto (normal na primeira execução)"
fi

# Executar seeds se necessário
echo "🌱 Executando seeds iniciais..."
docker-compose exec -T backend npm run db:seed || echo "⚠️  Seeds não executados (pode ser normal)"

echo ""
echo "🎉 Deploy Local Concluído!"
echo "=========================="
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
echo ""
echo "📊 Status dos containers:"
docker-compose ps

echo ""
echo "💡 Dica: Se algo não funcionar, aguarde alguns minutos e tente acessar novamente."
echo "   Os containers podem demorar para estar totalmente prontos."