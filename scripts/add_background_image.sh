#!/bin/bash

# Script para adicionar imagem de fundo do login
# Uso: ./add_background_image.sh caminho/para/sua/imagem.png

if [ $# -eq 0 ]; then
    echo "❌ Erro: Forneça o caminho para a imagem"
    echo "Uso: $0 caminho/para/sua/imagem.png"
    exit 1
fi

IMAGE_PATH="$1"
TARGET_PATH="assets/images/parking_background.png"

# Verificar se o arquivo existe
if [ ! -f "$IMAGE_PATH" ]; then
    echo "❌ Erro: Arquivo '$IMAGE_PATH' não encontrado"
    exit 1
fi

# Verificar se a pasta assets/images existe
if [ ! -d "assets/images" ]; then
    echo "📁 Criando pasta assets/images..."
    mkdir -p assets/images
fi

# Copiar a imagem
echo "📥 Copiando imagem para $TARGET_PATH..."
cp "$IMAGE_PATH" "$TARGET_PATH"

# Verificar se a cópia foi bem-sucedida
if [ $? -eq 0 ]; then
    echo "✅ Imagem adicionada com sucesso!"
    echo "🎨 A imagem será usada como fundo nas telas de login e esqueceu senha"
    echo "🔄 Execute 'flutter pub get' e depois 'flutter run' para ver as alterações"
else
    echo "❌ Erro ao copiar a imagem"
    exit 1
fi

# Verificar se o pubspec.yaml está configurado
if grep -q "assets/images/" pubspec.yaml; then
    echo "✅ pubspec.yaml já está configurado"
else
    echo "⚠️  Aviso: Verifique se assets/images/ está listado no pubspec.yaml"
fi
