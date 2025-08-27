# Implementação da Busca Automática de Dados do Veículo pela Placa

## Visão Geral

Esta funcionalidade foi implementada no app Flutter para replicar o comportamento do app React, onde ao sair do campo da placa, o sistema automaticamente busca os dados do veículo e preenche o campo modelo.

## Arquivos Modificados

### 1. `lib/services/vehicle_service.dart`
- Adicionado método `getModelVehicle(String licensePlate)` que faz uma requisição GET para `/vehicle/{licensePlate}`
- Retorna um objeto `VehicleModelInfo` com os dados do veículo

### 2. `lib/models/vehicle_models.dart`
- Adicionada classe `VehicleModelInfo` para representar os dados retornados pela API
- Campos: `model`, `color`, `manufactureYear`, `modelYear`
- Inclui métodos `fromJson`, `toJson` e `copyWith`

### 3. `lib/screens/vehicles/register_vehicle_screen.dart`
- Modificado método `_getModelByPlate()` para usar a API real em vez de dados mockados
- Adicionado evento `onEditingComplete` no campo de placa para acionar a busca automática
- Implementada lógica para preencher automaticamente o campo modelo
- Adicionadas mensagens informativas para o usuário

## Como Funciona

1. **Entrada da Placa**: O usuário digita a placa do veículo
2. **Validação**: O sistema valida o formato da placa (7 caracteres)
3. **Busca Automática**: Quando o usuário sai do campo (`onEditingComplete`), o sistema:
   - Limpa a placa (remove hífens e caracteres especiais)
   - Faz uma requisição para a API `/vehicle/{licensePlate}`
   - Recebe os dados do veículo (modelo, cor, ano, etc.)
4. **Preenchimento Automático**: O campo modelo é preenchido automaticamente com o valor retornado
5. **Feedback ao Usuário**: Toast informativo é exibido confirmando o preenchimento automático

## API Endpoint

```
GET /vehicle/{licensePlate}
```

### Resposta Esperada
```json
{
  "model": "HONDA CIVIC",
  "color": "PRATA",
  "manufactureYear": "2020",
  "modelYear": "2021"
}
```

## Tratamento de Erros

- **Placa não encontrada**: Mensagem informativa de que nenhum dado foi encontrado
- **Erro de API**: Toast de erro com sugestão para tentar novamente
- **Campos opcionais**: Sistema funciona mesmo se apenas o modelo for retornado

## Benefícios

1. **Experiência do Usuário**: Reduz a necessidade de digitação manual
2. **Consistência**: Dados padronizados vindos da API oficial
3. **Eficiência**: Acelera o processo de cadastro de veículos
4. **Precisão**: Evita erros de digitação no modelo do veículo

## Testes

- Criados testes unitários para a classe `VehicleModelInfo`
- Testes cobrem parsing de JSON, conversão e operações de cópia
- Todos os testes passaram com sucesso

## Compatibilidade

- Funciona com placas no formato antigo (ABC-1234) e Mercosul (ABC-1D23)
- Compatível com a API existente do sistema
- Não interfere com funcionalidades existentes de edição e exclusão

## Próximos Passos

1. **Monitoramento**: Acompanhar logs para identificar possíveis problemas
2. **Cache**: Considerar implementar cache local para placas consultadas frequentemente
3. **Fallback**: Implementar busca em banco de dados local caso a API esteja indisponível
4. **Métricas**: Adicionar tracking de uso da funcionalidade
