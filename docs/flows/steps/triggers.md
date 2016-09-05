# Documentação ZUP-API - Fluxos - Etapas - Gatilhos

## Protocolo

O protocolo usado é REST e recebe como parâmetro um JSON, é necessário executar a chamada de autênticação e utilizar o TOKEN nas chamadas desse Endpoint.
Necessário criação de uma Etapa para utilização correta desse endpoint.

Endpoint Staging: `http://staging.zup.sapience.io/flows/:flow_id/steps/:step_id/triggers`

Exemplo de como realizar um request usando a ferramenta cURL:

```bash
curl -X POST --data-binary @trigger-data.json -H 'Content-Type:application/json' -H 'X-App-Token:TOKEN' http://staging.zup.sapience.io/flows/:flow_id/steps/:step_id/triggers
```
Ou
```bash
curl -X POST --data-binary '{"campo":"valor"}' -H 'Content-Type:application/json' -H 'X-App-Token:TOKEN' http://staging.zup.sapience.io/flows/:flow_id/steps/:step_id/triggers
```

## Serviços

### Índice

* [Listagem](#list)
* [Criação](#create)
* [Edição](#update)
* [Deleção](#delete)
* [Redefinir Ordenação](#order)

___

### Listagem <a name="list"></a>

Endpoint: `/flows/:flow_id/steps/:step_id/triggers`

Method: get

#### Parâmetros de Entrada

#### Status HTTP

| Código | Descrição                          |
|--------|------------------------------------|
| 401    | Acesso não autorizado.             |
| 200    | Exibe listagem (com zero ou mais). |

#### Exemplo

##### Response
```
Status: 200
Content-Type: application/json
```

##### TriggerObject
| Nome          | Tipo     | Descrição                                      |
|---------------|----------|------------------------------------------------|
| id            | Interger | ID do objeto.                                  |
| list_versions | Array    | Array contento todas as versões do objeto.     |
| created_at    | DateTime | Data e horário da criação do objeto.           |
| updated_at    | DateTime | Data e horário da última atualização do objeto.|
| title         | String   | Título do Objeto.                              |
| action_type   | String   | Tipo da ação do Gatilho (enable_steps disable_steps finish_flow transfer_flow) |
| action_values | Array    | Array de ID(s) conforme o tipo da ação do Gatilho (step=ID da Etapa, flow=ID do Fluxo) |
| active        | Boolean  | Se o objeto esta ativo.                        |
| version_id    | Interger | ID da Versão do objeto.                        |
| trigger_conditions    | Array | Array de Condições do Gatilho (vide TriggerConditionObject) |
| my_trigger_conditions | Array | Array de Condições do Gatilho cuja versão é correspondente a Gatilho (vide TriggerConditionObject) |

##### TriggerConditionObject
| Nome          | Tipo     | Descrição                                      |
|---------------|----------|------------------------------------------------|
| id            | Interger | ID do objeto.                                  |
| list_versions | Array    | Array contento todas as versões do objeto.     |
| created_at    | DateTime | Data e horário da criação do objeto.           |
| updated_at    | DateTime | Data e horário da última atualização do objeto.|
| condition_type | String  | Tipo da condição (== != > < inc)               |
| values        | Array    | IDs de valor(es) que devem conferir para a condição ser válida (mais de um valor apenas quando for "inc") |
| active        | Boolean  | Se o objeto esta ativo.                        |
| version_id    | Interger | ID da Versão do objeto.                        |
| my_field      | Object   | Campo utilizado na condição do Gatilho.        |

```json
{
  "triggers": [
    {
      "list_versions": null,
      "created_at": "2015-03-03T11:08:12.193-03:00",
      "updated_at": "2015-03-03T11:08:12.193-03:00",
      "id": 1,
      "title": "Gatilho 1",
      "trigger_conditions": [
        {
          "list_versions": null,
          "id": 1,
          "my_field": null,
          "condition_type": "==",
          "values": [
            1
          ],
          "active": true,
          "version_id": null,
          "updated_at": "2015-03-03T11:08:12.200-03:00",
          "created_at": "2015-03-03T11:08:12.200-03:00"
        }
      ],
      "my_trigger_conditions": [
        {
          "list_versions": null,
          "id": 1,
          "my_field": null,
          "condition_type": "==",
          "values": [
            1
          ],
          "active": true,
          "version_id": null,
          "updated_at": "2015-03-03T11:08:12.200-03:00",
          "created_at": "2015-03-03T11:08:12.200-03:00"
        }
      ],
      "action_type": "disable_steps",
      "action_values": [
        2
      ],
      "active": true,
      "version_id": null
    }
  ]
}
```
___

### Redefinir Ordenação <a name="order"></a>

Endpoint: `/flows/:flow_id/steps/:step_id/triggers`

Method: put

#### Parâmetros de Entrada

| Nome | Tipo  | Obrigatório | Descrição                                     |
|------|-------|-------------|-----------------------------------------------|
| ids  | Array | Sim         | Array com ids dos Gatilhos na ordem desejada. |

#### Status HTTP

| Código | Descrição                  |
|--------|----------------------------|
| 400    | Parâmetros inválidos.      |
| 401    | Acesso não autorizado.     |
| 200    | Exibe mensagem de sucesso. |

#### Exemplo

##### Request

```json
{
  "ids": [3,1,2]
}
```

##### Response
```
Status: 200
Content-Type: application/json
```

```json
{
  "message": "Ordem dos Gatilhos atualizado com sucesso"
}
```
___

### Criação <a name="create"></a>

Endpoint: `/flows/:flow_id/steps/:step_id/triggers`

Method: post

#### Parâmetros de Entrada

| Nome                          | Tipo    | Obrigatório | Descrição                                                            |
|-------------------------------|---------|-------------|----------------------------------------------------------------------|
| title                         | String  | Sim         | Título. (até 100 caracteres)                                         |
| action_type                   | String  | Sim         | Tipo da ação. (enable_steps disable_steps finish_flow transfer_flow) |
| action_values                 | Array   | Sim         | Array com ids variando conforme o action_type                        |
| trigger_conditions_attributes | Array   | Sim         | Condições do Gatilho (vide TriggerConditionsAttributes)              |


##### TriggerConditionsAttributes
| Nome           | Tipo    | Obrigatório | Descrição                                                                     |
|----------------|---------|-------------|-------------------------------------------------------------------------------|
| field_id       | Integer | Sim         | ID do Campo que irá ser utilizado                                             |
| condition_type | String  | Sim         | Tipo da condição (== != > < inc)                                              |
| values         | Array   | Sim         | Array de valor(es) para ser comparado (apenas "inc" utiliza mais de um valor) |

#### Status HTTP

| Código | Descrição                            |
|--------|--------------------------------------|
| 400    | Parâmetros inválidos.                |
| 401    | Acesso não autorizado.               |
| 201    | Se o Gatilho foi criado com sucesso. |

#### Exemplo

##### Request
```json
{
  "title":"Titulo",
  "action_values":[1],
  "action_type":"disable_steps",
  "trigger_conditions_attributes":[
    {"field_id":1, "condition_type":"==", "values":[1]}
  ]
}
```

##### Response

| Nome          | Tipo    | Descrição                                   |
|---------------|---------|---------------------------------------------|
| trigger       | Object  | Vide TriggerObject (get /triggers)          |

```
Status: 201
Content-Type: application/json
```

```json
{
  "trigger": {
    "list_versions": null,
    "created_at": "2015-03-03T11:08:12.193-03:00",
    "updated_at": "2015-03-03T11:08:12.193-03:00",
    "id": 1,
    "title": "Gatilho 1",
    "trigger_conditions": [
      {
        "list_versions": null,
        "id": 1,
        "my_field": null,
        "condition_type": "==",
        "values": [
          1
        ],
        "active": true,
        "version_id": null,
        "updated_at": "2015-03-03T11:08:12.200-03:00",
        "created_at": "2015-03-03T11:08:12.200-03:00"
      }
    ],
    "my_trigger_conditions": [
      {
        "list_versions": null,
        "id": 1,
        "my_field": null,
        "condition_type": "==",
        "values": [
          1
        ],
        "active": true,
        "version_id": null,
        "updated_at": "2015-03-03T11:08:12.200-03:00",
        "created_at": "2015-03-03T11:08:12.200-03:00"
      }
    ],
    "action_type": "disable_steps",
    "action_values": [
      2
    ],
    "active": true,
    "version_id": null
  },
  "message": "Gatilho criado com sucesso"
}
```
___

### Edição <a name="update"></a>

Endpoint: `/flows/:flow_id/steps/:step_id/triggers/:id`

Method: put

#### Parâmetros de Entrada

| Nome                          | Tipo    | Obrigatório | Descrição                                                            |
|-------------------------------|---------|-------------|----------------------------------------------------------------------|
| title                         | String  | Não         | Título. (até 100 caracteres)                                         |
| action_type                   | String  | Não         | Tipo da ação. (enable_steps disable_steps finish_flow transfer_flow) |
| action_values                 | Array   | Não         | Array com ids variando conforme o action_type                        |
| trigger_conditions_attributes | Array   | Não         | Condições do Gatilho (vide TriggerConditionsAttributes)              |


##### TriggerConditionsAttributes
| Nome           | Tipo    | Obrigatório | Descrição                                                                     |
|----------------|---------|-------------|-------------------------------------------------------------------------------|
| id             | Integer | Não         | ID do trigger_condition já existe ou vazio se for novo                        |
| field_id       | Integer | Sim         | ID do Campo que irá ser utilizado                                             |
| condition_type | String  | Sim         | Tipo da condição (== != > < inc)                                              |
| values         | Array   | Sim         | Array de valor(es) para ser comparado (apenas "inc" utiliza mais de um valor) |

#### Status HTTP

| Código | Descrição                                |
|--------|------------------------------------------|
| 400    | Parâmetros inválidos.                    |
| 401    | Acesso não autorizado.                   |
| 404    | Gatilho não existe.                      |
| 200    | Se o Gatilho foi atualizado com sucesso. |

#### Exemplo

##### Request
```json
{
  "title": "Novo Título"
}
```

##### Response
```
Status: 200
Content-Type: application/json
```

```json
{
  "message": "Gatilho atualizado com sucesso"
}
```
___

### Deleção <a name="delete"></a>

Endpoint: `/flows/:flow_id/steps/:id/triggers/:id`

Method: delete

Se houver algum Caso criado para o Fluxo pai (pode ver com a opção GET do Fluxo e o atributo "total_cases")
o Gatilho não poderá ser apagada e será inativada, caso não possua Casos será excluido fisicamente.

#### Parâmetros de Entrada

Nenhum parâmetro de entrada, apenas o **id** na url.

#### Status HTTP

| Código | Descrição                           |
|--------|-------------------------------------|
| 401    | Acesso não autorizado.              |
| 404    | Não existe.                         |
| 200    | Apagado com sucesso.                |

#### Exemplo

##### Response
```
Status: 200
Content-Type: application/json
```

```json
{
  "message": "Gatilho apagado com sucesso"
}
```
