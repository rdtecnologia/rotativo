# Correção: Link "Avalie o app" no iOS

## Problema

Ao clicar no item de menu "Avalie o app", o Android abria corretamente a tela do app no Google Play, mas no iOS não abria corretamente a tela da App Store. O erro exibido era:

> "O Safari não pode abrir a página porque o endereço é inválido."

## Causa

O problema estava na forma como a URL da App Store era construída. O código estava usando o campo `iosPackage` (que contém o **bundle identifier**, como `com.rotativodigitalouropretord`) para construir a URL da App Store:

```dart
final appId = await DynamicAppConfig.iosPackage;
storeUrl = 'https://apps.apple.com/app/id$appId';
```

Isso resultava em uma URL inválida como:
```
https://apps.apple.com/app/idcom.rotativodigitalouropretord
```

A App Store do iOS requer o **App Store ID** (um número numérico), não o bundle identifier.

## Solução

Foi adicionado um novo campo `iosAppStoreId` nos arquivos de configuração das cidades para armazenar o ID numérico correto da App Store.

### Arquivos Modificados

1. **Arquivos de configuração JSON das cidades:**
   - `assets/config/cities/OuroPreto/OuroPreto.json`
   - `assets/config/cities/Vicosa/Vicosa.json`
   - `assets/config/cities/Main/Main.json`

   Adicionado o campo:
   ```json
   "iosAppStoreId": "6734653300"
   ```

2. **DynamicAppConfig** (`lib/config/dynamic_app_config.dart`):
   - Adicionado getter para o novo campo:
   ```dart
   static Future<String> get iosAppStoreId async {
     final config = await _loadConfig();
     return config['iosAppStoreId'] ?? '';
   }
   ```

3. **CustomDrawer** (`lib/widgets/custom_drawer.dart`):
   - Atualizado para usar o novo campo:
   ```dart
   } else if (Platform.isIOS) {
     final appStoreId = await DynamicAppConfig.iosAppStoreId;
     storeUrl = 'https://apps.apple.com/app/id$appStoreId';
   }
   ```

4. **Schema JSON** (`assets/config/cities/schema.json`):
   - Adicionado o campo ao schema de validação:
   ```json
   "iosAppStoreId": {
     "type": "string"
   }
   ```

5. **TypeScript Definitions** (`assets/config/cities/cities.d.ts`):
   - Adicionado o campo ao tipo `CityConfig`:
   ```typescript
   iosAppStoreId: string;
   ```

## Como Obter o App Store ID

O App Store ID é um número numérico único para cada app na App Store. Você pode encontrá-lo:

1. Acesse a página do seu app na App Store no navegador
2. O ID está na URL: `https://apps.apple.com/app/id[ID_AQUI]`
3. Ou acesse [App Store Connect](https://appstoreconnect.apple.com) e procure na seção de informações do app

## Resultado

Agora, ao clicar em "Avalie o app" no iOS, o app abre corretamente a página na App Store usando a URL válida:
```
https://apps.apple.com/app/id6734653300
```

## Notas

- O campo `iosPackage` continua sendo usado para outros propósitos (como identificação do bundle)
- O campo `iosAppStoreId` é específico para links diretos para a App Store
- O mesmo App Store ID pode ser usado para múltiplos flavors se eles compartilharem o mesmo app na App Store

