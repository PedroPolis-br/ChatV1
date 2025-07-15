FROM node:18-alpine

# Instalar dependências do sistema
RUN apk add --no-cache \
    python3 \
    make \
    g++ \
    ffmpeg \
    postgresql-client

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

# Criar diretório público se não existir
RUN mkdir -p public

# Expor porta
EXPOSE 8080

# Comando para iniciar aplicação
CMD ["npm", "start"]