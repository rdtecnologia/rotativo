# Splash Screen

## Descrição

O Splash Screen é a tela inicial do aplicativo Rotativo Digital que exibe a logo da empresa com uma animação de giro de 360 graus no sentido horário.

## Características

- **Logo SVG**: Utiliza o arquivo `assets/images/svg/logo.svg` como imagem principal
- **Animação de Rotação**: Gira 360 graus no sentido horário durante 2.5 segundos
- **Fade In**: A logo aparece com uma animação de fade in suave
- **Escala**: Efeito de escala elástica para dar mais dinamismo
- **Fundo Gradiente**: Utiliza as cores primárias do app em um gradiente vertical
- **Container Decorativo**: A logo é exibida dentro de um container com bordas arredondadas e transparência

## Funcionalidades

### Animações
- **Rotação**: 360 graus no sentido horário usando `Transform.rotate`
- **Fade In**: Opacidade de 0 a 1 com curva `Curves.easeOut`
- **Escala**: De 0.8 a 1.0 com curva `Curves.elasticOut`

### Navegação
- **Duração**: Permanece visível por 3 segundos
- **Destino**: Navega automaticamente para `/auth` (AuthWrapper)
- **Transição**: Usa `pushReplacementNamed` para substituir a tela atual

### Otimizações de Performance
- **Timeout de Token**: 3 segundos para validação de usuário
- **Tempo Mínimo de Loading**: 800ms-1200ms para melhor UX
- **Cache Inteligente**: Dados locais carregados primeiro
- **Fallback Rápido**: Se não há usuário, não valida token

## Estrutura do Código

### Arquivo Principal
- `lib/screens/splash_screen.dart`

### Dependências
- `flutter_svg`: Para renderização de arquivos SVG
- `dart:async`: Para controle de timers

### Classes
- `SplashScreen`: Widget principal
- `_SplashScreenState`: Estado com animações

## Configuração

### Cores
- **Primária**: `Color.fromARGB(255, 90, 123, 151)`
- **Secundária**: `Color.fromARGB(255, 70, 103, 131)`
- **Logo**: Branca com `BlendMode.srcIn`

### Timing
- **Animação**: 2.5 segundos
- **Exibição**: 3 segundos
- **Fade In**: 0-30% da duração
- **Escala**: 0-40% da duração

### Otimizações de Loading
- **Sem Usuário**: 800ms mínimo
- **Com Usuário (Sucesso)**: 1200ms mínimo
- **Com Usuário (Erro)**: 1000ms mínimo
- **Timeout de Token**: 3 segundos máximo

## Testes

### Arquivo de Teste
- `test/splash_screen_test.dart`

### Casos de Teste
1. **Exibição da Logo**: Verifica se a logo SVG é exibida
2. **Navegação**: Verifica se a navegação para `/auth` ocorre após 3 segundos

### Otimizações Implementadas
1. **Timeout Inteligente**: Validação de token com timeout de 3s
2. **Loading Progressivo**: Mostra passos do carregamento
3. **Tempo Mínimo**: Garante UX consistente (800ms-1200ms)
4. **Cache Local**: Carrega dados locais primeiro
5. **Fallback Rápido**: Evita validação desnecessária

## Integração

### Main.dart
- Tela inicial do app (`home: const SplashScreen()`)
- Rota configurada em `/splash`

### Navegação
- Após o splash, navega para `/auth`
- O AuthWrapper gerencia a autenticação do usuário

## Personalização

### Alterar Duração
```dart
// No initState, modificar:
_navigationTimer = Timer(const Duration(seconds: 5), () {
  // Navegação
});
```

### Alterar Cores
```dart
// No BoxDecoration, modificar:
gradient: LinearGradient(
  colors: [
    Colors.blue, // Nova cor primária
    Colors.indigo, // Nova cor secundária
  ],
),
```

### Alterar Tamanho da Logo
```dart
// No SvgPicture.asset, modificar:
width: 150, // Novo tamanho
height: 150,
```

## Configuração do Splash Screen Nativo

### Android
Para evitar que o Flutter mostre o splash screen padrão antes do nosso splash screen personalizado, configuramos:

1. **Temas Transparentes**: 
   - `android/app/src/main/res/values/styles.xml`
   - `android/app/src/main/res/values-night/styles.xml`

2. **Flavor Demo**: 
   - `android/app/src/demo/res/values/styles.xml`
   - `android/app/src/demo/res/values-night/styles.xml`

3. **Configurações do Manifest**: 
   - `android:windowDisablePreview="true"` no AndroidManifest.xml

### Configurações Aplicadas
- **Tema**: `Theme.Translucent.NoTitleBar` (completamente transparente)
- **Background**: Transparente (`@android:color/transparent`)
- **Animações**: Desabilitadas (`@null`)
- **Preview**: Desabilitado (`android:windowDisablePreview="true"`)
- **Overlay**: Removido (`@null`)

### Build com Flavor
```bash
# Build para o flavor demo
flutter build apk --flavor demo --debug

# Build para outros flavors
flutter build apk --flavor patosDeMinas --debug
flutter build apk --flavor janauba --debug
```

## Troubleshooting

### Problemas Comuns
1. **Logo não aparece**: Verificar se o arquivo `logo.svg` existe em `assets/images/svg/`
2. **Animação não funciona**: Verificar se `flutter_svg` está no `pubspec.yaml`
3. **Navegação não ocorre**: Verificar se a rota `/auth` está configurada
4. **Splash nativo ainda aparece**: Verificar se todos os arquivos de estilo foram modificados e fazer `flutter clean` antes do rebuild

### Logs
- Use `flutter analyze` para verificar erros de compilação
- Use `flutter test` para executar os testes
- Use `flutter run` para testar em dispositivo/emulador
- Use `flutter clean` antes de rebuilds para garantir mudanças
