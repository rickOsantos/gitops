#!/bin/bash

set -e

echo "🚀 Iniciando deploy..."

# Build da imagem
echo "🏗️ Construindo imagem Docker..."
docker build -t gitops-app:latest .

# Tag para registry
REGISTRY="ghcr.io"
REPO_NAME=$(git config --get remote.origin.url | sed 's/.*\///' | sed 's/\.git//')
USER_NAME=$(git config --get remote.origin.url | sed 's/.*github.com[:/]//' | sed 's/\/.*//')

echo "📦 Taggeando imagem..."
docker tag gitops-app:latest $REGISTRY/$USER_NAME/$REPO_NAME:latest
docker tag gitops-app:latest $REGISTRY/$USER_NAME/$REPO_NAME:$(git rev-parse --short HEAD)

# Push para registry (requer login)
echo "📤 Fazendo push da imagem..."
# docker push $REGISTRY/$USER_NAME/$REPO_NAME:latest
# docker push $REGISTRY/$USER_NAME/$REPO_NAME:$(git rev-parse --short HEAD)

# Atualizar manifests K8s
echo "🔄 Atualizando manifests Kubernetes..."
sed -i.bak "s|IMAGE_TAG|$(git rev-parse --short HEAD)|g" k8s/deployment.yml

# Aplicar no K8s
echo "⚓ Aplicando no Kubernetes..."
kubectl apply -f k8s/

# Aguardar rollout
echo "⏳ Aguardando rollout..."
kubectl rollout status deployment/gitops-app -n gitops

echo "✅ Deploy concluído!"