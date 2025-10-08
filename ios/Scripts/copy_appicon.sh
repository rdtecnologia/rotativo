#!/bin/bash

# Script para copiar o AppIcon correto baseado no flavor
# Uso: ./copy_appicon.sh <flavor_name>

set -e

FLAVOR=$1

if [ -z "$FLAVOR" ]; then
    echo "❌ Erro: Flavor não especificado"
    echo "Uso: $0 <flavor_name>"
    exit 1
fi

ASSETS_PATH="${SRCROOT}/Runner/Assets.xcassets"
DEFAULT_APPICON="${ASSETS_PATH}/AppIcon.appiconset"
FLAVOR_APPICON="${ASSETS_PATH}/AppIcon-${FLAVOR}.appiconset"

echo "🎨 Configurando AppIcon para flavor: ${FLAVOR}"

# Verifica se o AppIcon do flavor existe
if [ ! -d "${FLAVOR_APPICON}" ]; then
    echo "⚠️  AppIcon-${FLAVOR}.appiconset não encontrado. Usando AppIcon padrão."
    exit 0
fi

# Remove o AppIcon padrão se existir
if [ -d "${DEFAULT_APPICON}" ]; then
    rm -rf "${DEFAULT_APPICON}"
fi

# Copia o AppIcon do flavor para o local padrão
cp -r "${FLAVOR_APPICON}" "${DEFAULT_APPICON}"

echo "✅ AppIcon configurado com sucesso para ${FLAVOR}"

