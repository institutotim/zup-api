# Documentação ZUP-API - Fluxos - Etapas - Gatilhos

## Protocolo

O protocolo usado é REST e recebe como parâmetro um JSON, é necessário executar a chamada de autênticação e utilizar o TOKEN nas chamadas desse Endpoint.
Necessário criação de um Gatilho com ao menos uma Condição para utilização correta desse endpoint.

*Para criação e atualização é utilizado no próprio PUT do Gatilho.

Endpoint Staging: `http://staging.zup.sapience.io/flows/:flow_id/steps/:step_id/triggers/:trigger_id/trigger_conditions`

Exemplo de como realizar um request usando a ferramenta cURL:

```bash
curl -X DELETE -H 'Content-Type:application/json' -H 'X-App-Token:TOKEN' http://staging.zup.sapience.io/flows/:flow_id/steps/:step_id/triggers/:trigger_id/trigger_conditions/:trigger_condition_id
```

## Serviços

### Índice

* [Deleção](#delete)

___

### Deleção <a name="delete"></a>

Endpoint: `/flows/:flow_id/steps/:step_id/triggers/:trigger_id/trigger_conditions/:id`

Method: delete

Se houver algum Caso criado para o Fluxo pai da Etapa do Gatilho (pode ver com a opção GET do Fluxo e o atributo "total_cases")
a Condição do Gatilho não poderá ser apagada e será inativada, caso não possua Casos será excluido fisicamente.

#### Parâmetros de Entrada

Nenhum parâmetro de entrada, apenas o **id** na url.

#### Status HTTP

| Código | Descrição                   |
|--------|-----------------------------|
| 401    | Acesso não autorizado.      |
| 404    | Não existe.                 |
| 200    | Se foi apagada com sucesso. |

#### Exemplo

##### Response
```
Status: 200
Content-Type: application/json
```

```json
{
  "message": "Condição do Gatilho apagado com sucesso"
}
```
