#!/bin/bash

echo "🚀 Configurando projeto GitOps..."

# Verificar se kubectl está instalado
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl não encontrado. Instale kubectl primeiro."
    exit 1
fi

# Verificar se docker está instalado
if ! command -v docker &> /dev/null; then
    echo "❌ Docker não encontrado. Instale Docker primeiro."
    exit 1
fi

echo "✅ Dependências verificadas"

# Criar namespace
echo "📁 Criando namespace..."
kubectl apply -f k8s/namespace.yml

# Aplicar configurações
echo "⚙️ Aplicando configurações Kubernetes..."
kubectl apply -f k8s/

# Verificar status
echo "📊 Verificando status do deployment..."
kubectl get all -n gitops

echo "🎉 Setup concluído!"
echo "🌐 Para acessar localmente: docker-compose up"
echo "⚓ Para deploy K8s: kubectl apply -f k8s/"