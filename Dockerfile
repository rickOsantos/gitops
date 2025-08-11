FROM nginx:alpine

# Instalar dependências de segurança
RUN apk add --no-cache \
    curl \
    && rm -rf /var/cache/apk/*

# Criar usuário não-root
RUN addgroup -g 1000 appuser && \
    adduser -D -s /bin/sh -u 1000 -G appuser appuser

# Copiar arquivos da aplicação
COPY src/ /usr/share/nginx/html/
COPY *.html /usr/share/nginx/html/ 
COPY *.css /usr/share/nginx/html/ 
COPY *.js /usr/share/nginx/html/

# Copiar configuração personalizada do nginx
COPY k8s/configmap.yml /tmp/
RUN sed -n '/nginx.conf: |/,/^[[:space:]]*$/p' /tmp/configmap.yml | \
    sed '1d;$d' | sed 's/^    //' > /etc/nginx/nginx.conf

# Ajustar permissões
RUN chown -R appuser:appuser /usr/share/nginx/html && \
    chown -R appuser:appuser /var/cache/nginx && \
    chown -R appuser:appuser /var/log/nginx && \
    chown -R appuser:appuser /etc/nginx/conf.d

# Criar diretórios necessários
RUN mkdir -p /var/run/nginx && \
    chown -R appuser:appuser /var/run/nginx

# Criar arquivo de health check
RUN echo '<!DOCTYPE html><html><head><title>Health Check</title></head><body><h1>OK</h1><p>Service is healthy</p></body></html>' > /usr/share/nginx/html/health.html

# Expor porta
EXPOSE 80

# Labels para metadados
LABEL maintainer="ricardo.eletris@gmail.com"
LABEL version="1.0"
LABEL description="GitOps Dashboard Application"

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/health || exit 1

# Usar usuário não-root
USER appuser

# Comando de inicialização
CMD ["nginx", "-g", "daemon off;"]