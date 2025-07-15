-- Configurações iniciais do banco para desenvolvimento local
-- Este arquivo é executado apenas na primeira criação do banco

-- Criar extensões úteis (se necessário)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Configurar timezone para desenvolvimento
SET timezone = 'America/Sao_Paulo';

-- Configurações de performance para desenvolvimento
ALTER SYSTEM SET shared_buffers = '128MB';
ALTER SYSTEM SET effective_cache_size = '512MB';
ALTER SYSTEM SET checkpoint_segments = '32';
ALTER SYSTEM SET checkpoint_completion_target = '0.9';
ALTER SYSTEM SET wal_buffers = '16MB';
ALTER SYSTEM SET default_statistics_target = '100';

-- Recarregar configurações
SELECT pg_reload_conf();

-- Comentário para debug
INSERT INTO pg_stat_statements_info (dealloc) VALUES (0) ON CONFLICT DO NOTHING;

-- Log de inicialização
DO $$
BEGIN
    RAISE NOTICE 'Banco de dados inicializado para desenvolvimento local';
    RAISE NOTICE 'Timezone configurado para: %', current_setting('timezone');
END $$;