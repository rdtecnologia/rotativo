# Configuração da Imagem de Fundo do Login

## ✅ Alterações Realizadas

1. **Criada pasta de assets de imagens**: `assets/images/`
2. **Atualizado pubspec.yaml**: Adicionado caminho `assets/images/` aos assets
3. **Modificado ParkingBackground widget**: Agora usa imagem ao invés de desenho customizado
4. **Aplicado à tela de login**: A tela principal já usa o novo fundo
5. **Aplicado à tela de esqueceu senha**: Agora também usa o fundo com imagem

## 🖼️ Como Adicionar a Imagem

1. Salve a imagem fornecida como `parking_background.png` na pasta:
   ```
   /Volumes/SSD2/TIMOB/rotativo/assets/images/parking_background.png
   ```

2. A imagem será automaticamente carregada como fundo das telas de autenticação

## 🎨 Como Funciona

- A imagem é aplicada como `background-image` com `fit: BoxFit.cover`
- Uma sobreposição de gradiente azul com transparência é aplicada sobre a imagem
- Isso mantém a legibilidade do texto e botões sobre a imagem
- A cor da sobreposição é baseada na `primaryColor` do tema

## 📱 Telas Afetadas

- ✅ Login Screen (`/lib/screens/auth/login_screen.dart`)
- ✅ Forgot Password Screen (`/lib/screens/auth/forgot_password_screen.dart`)
- ⚠️ Register Screen mantém AppBar (não alterado)

## 🛠️ Customização Adicional

Para ajustar a transparência da sobreposição, modifique o parâmetro `opacity` no `ParkingBackground`:

```dart
ParkingBackground(
  primaryColor: Theme.of(context).primaryColor,
  opacity: 0.25, // Ajuste este valor (0.0 a 1.0)
  child: SafeArea(
    // ...
  ),
)
```

## 🔄 Para Reverter

Se quiser voltar ao padrão anterior, apenas substitua `AssetImage('assets/images/parking_background.png')` por um `CustomPaint` com o `ParkingBackgroundPainter` no arquivo `parking_background.dart`.
