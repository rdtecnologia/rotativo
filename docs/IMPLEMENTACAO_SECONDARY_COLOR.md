# Implementação da SecondaryColor

## Objetivo

Implementar um sistema completo para usar duas cores (primaryColor e secondaryColor) no layout do aplicativo, criando uma identidade visual mais rica e consistente.

## Arquivos Modificados

### 1. **DynamicAppConfig** (`lib/config/dynamic_app_config.dart`)
- Adicionado método `secondaryColor` para obter a cor secundária da configuração da cidade
- Mantém fallback para cor padrão `#17428e`

### 2. **ColorUtils** (`lib/utils/color_utils.dart`)
- Adicionado `createCustomColorScheme()` para criar esquemas de cores com duas cores
- Adicionado `createGradientColors()` para criar gradientes entre as duas cores
- Adicionado `createSubtleGradient()` para gradientes sutis de fundo
- Adicionado `createVibrantGradient()` para gradientes vibrantes em botões
- Adicionado `_getContrastColor()` para calcular cor de contraste automática

### 3. **ColorSchemeProvider** (`lib/providers/color_scheme_provider.dart`) - NOVO
- Provider para gerenciar cores dinâmicas em toda a aplicação
- `appColorsProvider`: Provider principal com todas as cores e gradientes
- `AppColors`: Classe de dados com métodos utilitários para cores

### 4. **Main.dart** (`lib/main.dart`)
- Atualizado para carregar e aplicar ambas as cores no tema
- Criado esquema de cores customizado com `createCustomColorScheme()`
- Configurado temas para AppBar, botões e cards

### 5. **ParkingBackground** (`lib/widgets/parking_background.dart`)
- Atualizado para usar gradiente com ambas as cores
- Suporte a cores customizadas via parâmetros
- Gradiente de 3 cores: primary → secondary → primary

### 6. **HomeBottomActions** (`lib/screens/home/widgets/home_bottom_actions.dart`)
- Botões "COMPRAR" e "HISTÓRICO": Cor primária
- Card de saldo: Cor secundária
- Uso do provider para cores dinâmicas

### 7. **BalanceCard** (`lib/widgets/balance_card.dart`)
- Adicionado suporte a `backgroundColor`, `iconColor` e `textColor`
- Cores automáticas baseadas no tema

## Estratégia de Uso das Cores

### **PrimaryColor** (`#b61817` - Vermelho)
- **Uso**: Elementos principais, ações importantes
- **Aplicações**:
  - Botões de ação (COMPRAR, HISTÓRICO)
  - AppBar
  - Ícones principais
  - Elementos de destaque

### **SecondaryColor** (`#17428e` - Azul)
- **Uso**: Elementos secundários, informações, detalhes
- **Aplicações**:
  - Card de saldo
  - Botões outline
  - Textos de informação
  - Bordas e separadores
  - Gradientes sutis

## Como Usar

### 1. **Usando o Provider de Cores**
```dart
Consumer(
  builder: (context, ref, child) {
    return ref.watch(appColorsProvider).when(
      data: (appColors) {
        return Container(
          color: appColors.primary,
          child: Text(
            'Texto com contraste automático',
            style: TextStyle(color: appColors.primaryContrast),
          ),
        );
      },
      loading: () => CircularProgressIndicator(),
      error: (_, __) => Text('Erro'),
    );
  },
)
```

### 2. **Usando Gradientes**
```dart
Container(
  decoration: BoxDecoration(
    gradient: appColors.vibrantGradient, // ou subtleGradient
  ),
  child: Text('Conteúdo'),
)
```

### 3. **Usando Cores com Opacidade**
```dart
Container(
  color: appColors.primaryWithOpacity(0.1),
  child: Text('Fundo sutil'),
)
```

### 4. **Usando o Tema Global**
```dart
// As cores já estão configuradas no tema global
ElevatedButton(
  onPressed: () {},
  child: Text('Botão'), // Usa primaryColor automaticamente
)

OutlinedButton(
  onPressed: () {},
  child: Text('Botão'), // Usa secondaryColor automaticamente
)
```

## Exemplo de Configuração de Cidade

```json
{
  "city": "Ouro Preto",
  "primaryColor": "#b61817",
  "secondaryColor": "#17428e",
  // ... outras configurações
}
```

## Benefícios

1. **Identidade Visual Rica**: Duas cores criam mais profundidade visual
2. **Hierarquia Clara**: Primary para ações importantes, secondary para informações
3. **Consistência**: Provider centralizado garante uso consistente
4. **Flexibilidade**: Fácil mudança de cores por cidade
5. **Acessibilidade**: Contraste automático para melhor legibilidade
6. **Gradientes**: Transições suaves entre as cores

## Widget de Demonstração

Criado `ColorDemoWidget` (`lib/widgets/color_demo_widget.dart`) que demonstra:
- Cards com as duas cores
- Gradientes sutis e vibrantes
- Botões com as cores
- Códigos hex das cores

## Próximos Passos

1. Aplicar as cores em mais componentes UI
2. Criar variações de cores para diferentes estados (hover, disabled, etc.)
3. Implementar modo escuro com as cores
4. Adicionar animações de transição entre cores
