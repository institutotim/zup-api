# Documentação ZUP-API - Casos

## Protocolo

O protocolo usado é REST e recebe como parâmetro um JSON, é necessário executar a chamada de autênticação e utilizar o TOKEN nas chamadas desse Endpoint.
Necessário criação de um Fluxo completo (com Etapas e Campos) para utilização correta desse endpoint.

Endpoint Staging: `http://staging.zup.sapience.io/cases`

Exemplo de como realizar um request usando a ferramenta cURL:

```bash
curl -X POST --data-binary @case-data.json -H 'Content-Type:application/json' -H 'X-App-Token:TOKEN' http://staging.zup.sapience.io/cases
```
Ou
```bash
curl -X POST --data-binary '{"campo":"valor"}' -H 'Content-Type:application/json' -H 'X-App-Token:TOKEN' http://staging.zup.sapience.io/cases
```

## Serviços

### Índice

* [Criação](#create)
* [Lista](#list)
* [Exibir](#show)
* [Atualizar / Avançar Etapa](#update)
* [Finalizar](#finish)
* [Transferir para outro Fluxo](#transfer)
* [Inativar](#inactive)
* [Restaurar](#restore)
* [Atualizar Etapa do Caso](#update_case_step)
* [Permissões](#permissions)

___

### Criação <a name="create"></a>

Criação de Caso é feito no envio dos dados da primeira Etapa.
Se não for enviado o "fields" a primeira Etapa será apenas iniciada e não estará como executada

Endpoint: `/cases`

Method: post

#### Parâmetros de Entrada

| Nome                 | Tipo    | Obrigatório | Descrição                                                   |
|----------------------|---------|-------------|-------------------------------------------------------------|
| initial_flow_id      | Integer | Sim         | ID do Fluxo Inicial utilizando a versão corrente (pai de todos fluxos).                  |
| fields               | Array   | Não         | Array de Hash com ID do Campo e Value com o Valor do campo (a value será convertida no valor correto do campo para verificar as validações do campo). |
| responsible_user_id  | Integer | Não         | ID do Grupo que será responsável pela Etapa do Caso. |
| responsible_group_id | Integer | Não         | ID do Grupo que será responsável pela Etapa do Caso. |

#### Status HTTP

| Código | Descrição                  |
|--------|----------------------------|
| 400    | Parâmetros inválidos.      |
| 400    | Etapa está disabilitada    |
| 400    | Etapa não pertence ao Caso |
| 400    | Etapa atual não foi preenchida |
| 401    | Acesso não autorizado.     |
| 201    | Se foi criado com sucesso. |

#### Exemplo

##### Request
```json
{
  "initial_flow_id": 2,
  "fields": [
    {"id": 1, "value": "10"}
  ]
}
```

##### Response

###### Failure
```
Status: 400
Content-Type: application/json
```

```json
{
  "error": {
    "case_steps.fields": [
      "new_age não pode ficar em branco",
      "new_age deve ser maior que 10"
    ]
  }
}
```

###### Success

É criado uma entrado no CasesLogEntries com a ação de 'create_case'.

No retorno de criação do Caso, o retorno é trazido com display_type='full'.

Quando houver um Gatilho que foi executado no final do Caso no retorno vai ter dois valores preenchidos **trigger_values** e **trigger_type**.

**trigger_values** terá o ID do item

**trigger_type** terá um dos valroes: "enable_steps", "disable_steps", "finish_flow", "transfer_flow"

```
Status: 201
Content-Type: application/json
```

| Nome     | Tipo    | Descrição                             |
|----------|---------|---------------------------------------|
| case     | Object  | Vide CaseObject get /cases/1          |

```json
{
  "trigger_description": null,
  "trigger_values": null,
  "trigger_type": null,
  "case": {
    "steps": [
      {
        "steps": [],
        "flow": {
          "steps_versions": {},
          "resolution_states_versions": {},
          "draft": false,
          "current_version": null,
          "step_id": null,
          "status": "pending",
          "id": 4,
          "title": "Fluxo Filho",
          "description": null,
          "created_by_id": 1,
          "updated_by_id": 1,
          "initial": false,
          "created_at": "2015-03-04T00:30:40.425-03:00",
          "updated_at": "2015-03-04T00:31:03.225-03:00"
        },
        "step": {
          "triggers_versions": {},
          "fields_versions": {},
          "user_id": 1,
          "draft": false,
          "conduction_mode_open": true,
          "child_flow_version": null,
          "child_flow_id": 4,
          "id": 6,
          "title": "Etapa 3",
          "description": null,
          "step_type": "flow",
          "flow_id": 3,
          "created_at": "2015-03-04T00:31:37.531-03:00",
          "updated_at": "2015-03-04T00:51:47.252-03:00",
          "active": true
        }
      },
      {
        "steps": [],
        "flow": null,
        "step": {
          "triggers_versions": {},
          "fields_versions": {
            "3": 5
          },
          "user_id": 1,
          "draft": false,
          "conduction_mode_open": true,
          "child_flow_version": null,
          "child_flow_id": null,
          "id": 5,
          "title": "Etapa 2",
          "description": null,
          "step_type": "form",
          "flow_id": 3,
          "created_at": "2015-03-04T00:30:06.214-03:00",
          "updated_at": "2015-03-04T00:51:47.232-03:00",
          "active": true
        }
      },
      {
        "steps": [],
        "flow": null,
        "step": {
          "triggers_versions": {},
          "fields_versions": {
            "2": 3
          },
          "user_id": 1,
          "draft": false,
          "conduction_mode_open": true,
          "child_flow_version": null,
          "child_flow_id": null,
          "id": 4,
          "title": "Etapa 1",
          "description": null,
          "step_type": "form",
          "flow_id": 3,
          "created_at": "2015-03-04T00:24:26.529-03:00",
          "updated_at": "2015-03-04T00:51:47.210-03:00",
          "active": true
        }
      }
    ],
    "current_step": {
      "updated_by": null,
      "created_by": {
        "google_plus_user_id": null,
        "twitter_user_id": null,
        "document": "67392343700",
        "phone": "11912231545",
        "email": "euricovidal@gmail.com",
        "groups_names": [
          "Administradores"
        ],
        "permissions": "<permission object>",
        "groups": [
          {
            "permissions": "<permission object>",
            "name": "Administradores",
            "id": 2
          }
        ],
        "name": "Hellen Armstrong Sr.",
        "id": 1,
        "address": "430 Danika Parkways",
        "address_additional": "Suite 386",
        "postal_code": "04005000",
        "district": "Lake Elsafort",
        "device_token": "445dcfb912fade983885d17f9aa42448",
        "device_type": "ios",
        "created_at": "2015-03-03T10:45:08.037-03:00",
        "facebook_user_id": null
      },
      "case_step_data_fields": [],
      "created_at": "2015-03-04T11:11:46.894-03:00",
      "updated_at": "2015-03-04T11:11:46.894-03:00",
      "id": 1,
      "step_id": 5,
      "step_version": 6,
      "my_step": {
        "list_versions": [
          {
            "created_at": "2015-03-04T00:30:06.214-03:00",
            "updated_at": "2015-03-04T00:51:47.232-03:00",
            "permissions": "<permission object>",
            "version_id": 6,
            "active": true,
            "id": 5,
            "title": "Etapa 2",
            "conduction_mode_open": true,
            "step_type": "form",
            "child_flow": null,
            "my_child_flow": null,
            "fields": [
              {
                "draft": false,
                "step_id": 5,
                "active": true,
                "origin_field_id": null,
                "category_report_id": null,
                "category_inventory_id": null,
                "field_type": "text",
                "title": "Campo 1",
                "id": 3,
                "created_at": "2015-03-04T00:30:27.297-03:00",
                "updated_at": "2015-03-04T00:51:47.224-03:00",
                "multiple": false,
                "filter": null,
                "requirements": null,
                "values": null,
                "user_id": 1,
                "origin_field_version": null
              }
            ],
            "my_fields": [
              {
                "draft": false,
                "step_id": 5,
                "active": true,
                "origin_field_id": null,
                "category_report_id": null,
                "category_inventory_id": null,
                "field_type": "text",
                "title": "Campo 1",
                "id": 3,
                "created_at": "2015-03-04T00:30:27.297-03:00",
                "updated_at": "2015-03-04T00:51:47.224-03:00",
                "multiple": false,
                "filter": null,
                "requirements": null,
                "values": null,
                "user_id": 1,
                "origin_field_version": null
              }
            ]
          }
        ],
        "created_at": "2015-03-04T00:30:06.214-03:00",
        "updated_at": "2015-03-04T00:51:47.232-03:00",
        "permissions": "<permission object>",
        "version_id": 6,
        "active": true,
        "id": 5,
        "title": "Etapa 2",
        "conduction_mode_open": true,
        "step_type": "form",
        "child_flow": null,
        "my_child_flow": null,
        "fields": [
          {
            "draft": false,
            "step_id": 5,
            "active": true,
            "origin_field_id": null,
            "category_report_id": null,
            "category_inventory_id": null,
            "field_type": "text",
            "title": "Campo 1",
            "id": 3,
            "created_at": "2015-03-04T00:30:27.297-03:00",
            "updated_at": "2015-03-04T00:51:47.224-03:00",
            "multiple": false,
            "filter": null,
            "requirements": null,
            "values": null,
            "user_id": 1,
            "origin_field_version": null
          }
        ],
        "my_fields": [
          {
            "draft": false,
            "step_id": 5,
            "active": true,
            "origin_field_id": null,
            "category_report_id": null,
            "category_inventory_id": null,
            "field_type": "text",
            "title": "Campo 1",
            "id": 3,
            "created_at": "2015-03-04T00:30:27.297-03:00",
            "updated_at": "2015-03-04T00:51:47.224-03:00",
            "multiple": false,
            "filter": null,
            "requirements": null,
            "values": null,
            "user_id": 1,
            "origin_field_version": null
          }
        ]
      },
      "trigger_ids": [],
      "responsible_user_id": 1,
      "responsible_group_id": null,
      "executed": true
    },
    "case_steps": [
      {
        "updated_by": null,
        "created_by": {
          "google_plus_user_id": null,
          "twitter_user_id": null,
          "document": "67392343700",
          "phone": "11912231545",
          "email": "euricovidal@gmail.com",
          "groups_names": [
            "Administradores"
          ],
          "permissions": "<permission object>",
          "groups": [
            {
              "permissions": "<permission object>",
              "name": "Administradores",
              "id": 2
            }
          ],
          "name": "Hellen Armstrong Sr.",
          "id": 1,
          "address": "430 Danika Parkways",
          "address_additional": "Suite 386",
          "postal_code": "04005000",
          "district": "Lake Elsafort",
          "device_token": "445dcfb912fade983885d17f9aa42448",
          "device_type": "ios",
          "created_at": "2015-03-03T10:45:08.037-03:00",
          "facebook_user_id": null
        },
        "case_step_data_fields": [],
        "created_at": "2015-03-04T11:11:46.894-03:00",
        "updated_at": "2015-03-04T11:11:46.894-03:00",
        "id": 1,
        "step_id": 5,
        "step_version": 6,
        "my_step": {
          "list_versions": [
            {
              "created_at": "2015-03-04T00:30:06.214-03:00",
              "updated_at": "2015-03-04T00:51:47.232-03:00",
              "permissions": "<permission object>",
              "version_id": 6,
              "active": true,
              "id": 5,
              "title": "Etapa 2",
              "conduction_mode_open": true,
              "step_type": "form",
              "child_flow": null,
              "my_child_flow": null,
              "fields": [
                {
                  "draft": false,
                  "step_id": 5,
                  "active": true,
                  "origin_field_id": null,
                  "category_report_id": null,
                  "category_inventory_id": null,
                  "field_type": "text",
                  "title": "Campo 1",
                  "id": 3,
                  "created_at": "2015-03-04T00:30:27.297-03:00",
                  "updated_at": "2015-03-04T00:51:47.224-03:00",
                  "multiple": false,
                  "filter": null,
                  "requirements": null,
                  "values": null,
                  "user_id": 1,
                  "origin_field_version": null
                }
              ],
              "my_fields": [
                {
                  "draft": false,
                  "step_id": 5,
                  "active": true,
                  "origin_field_id": null,
                  "category_report_id": null,
                  "category_inventory_id": null,
                  "field_type": "text",
                  "title": "Campo 1",
                  "id": 3,
                  "created_at": "2015-03-04T00:30:27.297-03:00",
                  "updated_at": "2015-03-04T00:51:47.224-03:00",
                  "multiple": false,
                  "filter": null,
                  "requirements": null,
                  "values": null,
                  "user_id": 1,
                  "origin_field_version": null
                }
              ]
            }
          ],
          "created_at": "2015-03-04T00:30:06.214-03:00",
          "updated_at": "2015-03-04T00:51:47.232-03:00",
          "permissions": "<permission object>",
          "version_id": 6,
          "active": true,
          "id": 5,
          "title": "Etapa 2",
          "conduction_mode_open": true,
          "step_type": "form",
          "child_flow": null,
          "my_child_flow": null,
          "fields": [
            {
              "draft": false,
              "step_id": 5,
              "active": true,
              "origin_field_id": null,
              "category_report_id": null,
              "category_inventory_id": null,
              "field_type": "text",
              "title": "Campo 1",
              "id": 3,
              "created_at": "2015-03-04T00:30:27.297-03:00",
              "updated_at": "2015-03-04T00:51:47.224-03:00",
              "multiple": false,
              "filter": null,
              "requirements": null,
              "values": null,
              "user_id": 1,
              "origin_field_version": null
            }
          ],
          "my_fields": [
            {
              "draft": false,
              "step_id": 5,
              "active": true,
              "origin_field_id": null,
              "category_report_id": null,
              "category_inventory_id": null,
              "field_type": "text",
              "title": "Campo 1",
              "id": 3,
              "created_at": "2015-03-04T00:30:27.297-03:00",
              "updated_at": "2015-03-04T00:51:47.224-03:00",
              "multiple": false,
              "filter": null,
              "requirements": null,
              "values": null,
              "user_id": 1,
              "origin_field_version": null
            }
          ]
        },
        "trigger_ids": [],
        "responsible_user_id": 1,
        "responsible_group_id": null,
        "executed": true
      }
    ],
    "original_case": null,
    "get_responsible_group": null,
    "get_responsible_user": {
      "google_plus_user_id": null,
      "twitter_user_id": null,
      "document": "67392343700",
      "phone": "11912231545",
      "email": "euricovidal@gmail.com",
      "groups_names": [
        "Administradores"
      ],
      "permissions": "<permission object>",
      "groups": [
        {
          "permissions": "<permission object>",
          "name": "Administradores",
          "id": 2
        }
      ],
      "name": "Hellen Armstrong Sr.",
      "id": 1,
      "address": "430 Danika Parkways",
      "address_additional": "Suite 386",
      "postal_code": "04005000",
      "district": "Lake Elsafort",
      "device_token": "445dcfb912fade983885d17f9aa42448",
      "device_type": "ios",
      "created_at": "2015-03-03T10:45:08.037-03:00",
      "facebook_user_id": null
    },
    "updated_by": null,
    "created_by": {
      "google_plus_user_id": null,
      "twitter_user_id": null,
      "document": "67392343700",
      "phone": "11912231545",
      "email": "euricovidal@gmail.com",
      "groups_names": [
        "Administradores"
      ],
      "permissions": "<permission object>",
      "groups": [
        {
          "permissions": "<permission object>",
          "name": "Administradores",
          "id": 2
        }
      ],
      "name": "Hellen Armstrong Sr.",
      "id": 1,
      "address": "430 Danika Parkways",
      "address_additional": "Suite 386",
      "postal_code": "04005000",
      "district": "Lake Elsafort",
      "device_token": "445dcfb912fade983885d17f9aa42448",
      "device_type": "ios",
      "created_at": "2015-03-03T10:45:08.037-03:00",
      "facebook_user_id": null
    },
    "completed": false,
    "steps_not_fulfilled": [
      4
    ],
    "total_steps": 2,
    "flow_version": 8,
    "initial_flow_id": 3,
    "updated_at": "2015-03-04T11:11:46.891-03:00",
    "created_at": "2015-03-04T11:11:46.891-03:00",
    "updated_by_id": null,
    "created_by_id": 1,
    "id": 1,
    "disabled_steps": [],
    "original_case_id": null,
    "children_case_ids": [],
    "case_step_ids": [
      1
    ],
    "next_step_id": 5,
    "responsible_user_id": 1,
    "responsible_group_id": null,
    "status": "active"
  },
  "message": "Caso criado com sucesso"
}
```
___

### Lista <a name="list"></a>

Endpoint: `/cases`

Method: get

#### Parâmetros de Entrada

| Nome                 | Tipo    | Obrigatório | Descrição                                                   |
|----------------------|---------|-------------|-------------------------------------------------------------|
| display_type         | String  | Não         | para retornar todos os dados utilizar 'full'.               |
| initial_flow_id      | String  | Não         | Texto de IDs de Fluxo Inicial(separados por ,).             |
| initial_flow_version | String  | Não         | Texto de Versões de Fluxo Inicial(separados por ,).         |
| responsible_user_id  | String  | Não         | Texto de IDs de Usuários(separados por ,).                  |
| responsible_group_id | String  | Não         | Texto de IDs de Grupos(separados por ,).                    |
| created_by_id        | String  | Não         | Texto de IDs de Usuários(separados por ,).                  |
| updated_by_id        | String  | Não         | Texto de IDs de Usuários(separados por ,).                  |
| step_id              | String  | Não         | Texto de IDs de Etapas(separados por ,).                    |
| per_page             | Integer | Não         | Quantidade de Casos por páginas.                            |
| page                 | Integer | Não         | Número da página.                                           |

#### Status HTTP

| Código | Descrição                    |
|--------|------------------------------|
| 401    | Acesso não autorizado.       |
| 200    | Se existir um ou mais itens. |

#### Exemplo

##### Request
```json
?display_type=full
```

##### Response
```
Status: 200
Content-Type: application/json
```

| Nome     | Tipo    | Descrição                             |
|----------|---------|---------------------------------------|
| case     | Object  | Vide CaseObject get /cases/1          |

**Sem display_type**
```json
{
  "cases": [
    {
      "completed": false,
      "steps_not_fulfilled": [],
      "total_steps": 1,
      "flow_version": 12,
      "initial_flow_id": 6,
      "updated_at": "2015-03-04T12:11:21.810-03:00",
      "created_at": "2015-03-04T12:11:21.810-03:00",
      "updated_by_id": null,
      "created_by_id": 1,
      "id": 2,
      "disabled_steps": [],
      "original_case_id": 1,
      "children_case_ids": [],
      "case_step_ids": [],
      "next_step_id": 7,
      "responsible_user_id": null,
      "responsible_group_id": null,
      "status": "active"
    },
    {
      "completed": false,
      "steps_not_fulfilled": [
        4
      ],
      "total_steps": 2,
      "flow_version": 8,
      "initial_flow_id": 3,
      "updated_at": "2015-03-04T12:11:21.818-03:00",
      "created_at": "2015-03-04T11:11:46.891-03:00",
      "updated_by_id": 1,
      "created_by_id": 1,
      "id": 1,
      "disabled_steps": [],
      "original_case_id": null,
      "children_case_ids": [
        2
      ],
      "case_step_ids": [
        1
      ],
      "next_step_id": 4,
      "responsible_user_id": 1,
      "responsible_group_id": null,
      "status": "transfer"
    },
    {
      "completed": false,
      "steps_not_fulfilled": [
        4
      ],
      "total_steps": 2,
      "flow_version": 8,
      "initial_flow_id": 3,
      "updated_at": "2015-03-04T12:13:17.473-03:00",
      "created_at": "2015-03-04T12:12:41.309-03:00",
      "updated_by_id": 1,
      "created_by_id": 1,
      "id": 3,
      "disabled_steps": [],
      "original_case_id": null,
      "children_case_ids": [],
      "case_step_ids": [
        2
      ],
      "next_step_id": 4,
      "responsible_user_id": 1,
      "responsible_group_id": null,
      "status": "active"
    }
  ]
}
```

**Com display_type=full**
Retorno consideravel extenso, retorna um Array de CaseObject (vide get /cases/1) com display_type=full
```json
{
  "cases": [CaseObject, CaseObject]
}
```
___

### Exibir <a name="show"></a>

Endpoint: `/cases/:id`

Method: get

#### Parâmetros de Entrada

| Nome            | Tipo    | Obrigatório | Descrição                                                   |
|-----------------|---------|-------------|-------------------------------------------------------------|
| display_type    | String  | Não         | para retornar todos os dados utilizar 'full'.               |

#### Status HTTP

| Código | Descrição                  |
|--------|----------------------------|
| 404    | Não encontrado.            |
| 200    | Retorna Caso.              |

#### Status HTTP

| Código | Descrição                  |
|--------|----------------------------|
| 404    | Não encontrado.            |
| 200    | Retorna Caso.              |

#### Exemplo

##### Request
```
?display_type=full
```

##### Response
```
Status: 200
Content-Type: application/json
```

###### CaseObject
| Nome                       | Tipo       | Descrição                                                                                                  |
|----------------------------|------------|------------------------------------------------------------------------------------------------------------|
| id                         | Interger   | ID do objeto.                                                                                              |
| updated_at                 | DateTime   | Data e horário da última atualização do objeto.                                                            |
| updated_by                 | Object     | Objeto do usuário que atualializou o objeto.                                                                |
| updated_by_id              | Integer    | ID do usuário que atualializou o objeto.                                                                |
| created_at                 | DateTime   | Data e horário da criação do objeto.                                                                       |
| created_by                 | Object     | Objeto do usuário que criou o Caso.                                                                       |
| created_by_id              | Integer    | ID do usuário que criou o Caso.                                                                       |
| total_steps                | Integer    | Número total de Etapas do Caso.                                                                            |
| get_responsible_group      | Object     | Grupo responsável pela Etapa atual.                                                                        |
| get_responsible_group      | Object     | Grupo responsável pela Etapa atual.                                                                        |
| responsible_user_id        | Integer    | ID do Usuário responsável pela Etapa atual.                                                                        |
| responsible_group_id       | Integer    | ID do Grupo responsável pela Etapa atual.                                                                        |
| get_responsible_user       | Object     | Usuário responsável pela Etapa atual.                                                                        |
| status                     | String     | Status do Caso (active, pending, finished, inactive, transfer ou not_satisfied)                                                                |
| completed                  | Boolean    | Se o Caso está completo                                                                                                                       |
| case_steps                 | Array      | Array de Etapas Preenchidas no Caso (vide CaseStepObject)                                                                                      |
| original_case              | Object     | Objeto do Caso original, quando um Caso foi transferido para outro Fluxo                                                                       |
| original_case_id           | Integer    | ID do Objeto do Caso original, quando um Caso foi transferido para outro Fluxo                                                                       |
| children_case_id           | Integer    | ID do Objeto do Caso filho, quando um Caso foi transferido para outro Fluxo                                                                       |
| case_step_ids              | Array      | Array de IDs das Etapas Preenchidas (não é o ID da Etapa do Fluxo)                                                                             |
| initial_flow_id            | Integer    | ID do Fluxo Inicial utilizado                                                                                                                  |
| flow_version               | Integer    | ID da versão do Fluxo Inicial                                                                                                                  |
| current_step               | Object     | Objeto da Etapa atual (vide CaseStepObject), última Etapa Preenchida                                                                           |
| steps                      | Array      | Árvore de Array de todas Etapas do Caso (baseado no Fluxo Inicial) |
| disabled_steps             | Array      | ID de Etapas desabilitadas por Gatilhos                           |
| steps_not_fulfilled        | Array      | ID de Etapas não preenchidas quando o status do Caso é 'not_satisfied' |
| next_step_id               | Integer    | ID da próxima Etapa a ser preenchida                                   |

**Sem display_type**
```json
{
  "case": {
    "completed": false,
    "steps_not_fulfilled": [
      4
    ],
    "total_steps": 2,
    "flow_version": 8,
    "initial_flow_id": 3,
    "updated_at": "2015-03-04T11:21:27.385-03:00",
    "created_at": "2015-03-04T11:11:46.891-03:00",
    "updated_by_id": 1,
    "created_by_id": 1,
    "id": 1,
    "disabled_steps": [],
    "original_case_id": null,
    "children_case_ids": [],
    "case_step_ids": [
      1
    ],
    "next_step_id": 4,
    "responsible_user_id": 1,
    "responsible_group_id": null,
    "status": "active"
  }
}
```

**Com display_type=full**
```json
{
  "case": {
    "steps": [
      {
        "steps": [],
        "flow": {
          "steps_versions": {},
          "resolution_states_versions": {},
          "draft": false,
          "current_version": null,
          "step_id": null,
          "status": "pending",
          "id": 4,
          "title": "Fluxo Filho",
          "description": null,
          "created_by_id": 1,
          "updated_by_id": 1,
          "initial": false,
          "created_at": "2015-03-04T00:30:40.425-03:00",
          "updated_at": "2015-03-04T00:31:03.225-03:00"
        },
        "step": {
          "triggers_versions": {},
          "fields_versions": {},
          "user_id": 1,
          "draft": false,
          "conduction_mode_open": true,
          "child_flow_version": null,
          "child_flow_id": 4,
          "id": 6,
          "title": "Etapa 3",
          "description": null,
          "step_type": "flow",
          "flow_id": 3,
          "created_at": "2015-03-04T00:31:37.531-03:00",
          "updated_at": "2015-03-04T00:51:47.252-03:00",
          "active": true
        }
      },
      {
        "steps": [],
        "flow": null,
        "step": {
          "triggers_versions": {},
          "fields_versions": {
            "3": 5
          },
          "user_id": 1,
          "draft": false,
          "conduction_mode_open": true,
          "child_flow_version": null,
          "child_flow_id": null,
          "id": 5,
          "title": "Etapa 2",
          "description": null,
          "step_type": "form",
          "flow_id": 3,
          "created_at": "2015-03-04T00:30:06.214-03:00",
          "updated_at": "2015-03-04T00:51:47.232-03:00",
          "active": true
        }
      },
      {
        "steps": [],
        "flow": null,
        "step": {
          "triggers_versions": {},
          "fields_versions": {
            "2": 3
          },
          "user_id": 1,
          "draft": false,
          "conduction_mode_open": true,
          "child_flow_version": null,
          "child_flow_id": null,
          "id": 4,
          "title": "Etapa 1",
          "description": null,
          "step_type": "form",
          "flow_id": 3,
          "created_at": "2015-03-04T00:24:26.529-03:00",
          "updated_at": "2015-03-04T00:51:47.210-03:00",
          "active": true
        }
      }
    ],
    "current_step": {
      "updated_by": {
        "google_plus_user_id": null,
        "twitter_user_id": null,
        "document": "67392343700",
        "phone": "11912231545",
        "email": "euricovidal@gmail.com",
        "groups_names": [
          "Administradores"
        ],
        "permissions": "<permission object>",
        "groups": [
          {
            "permissions": "<permission object>",
            "name": "Administradores",
            "id": 2
          }
        ],
        "name": "Hellen Armstrong Sr.",
        "id": 1,
        "address": "430 Danika Parkways",
        "address_additional": "Suite 386",
        "postal_code": "04005000",
        "district": "Lake Elsafort",
        "device_token": "445dcfb912fade983885d17f9aa42448",
        "device_type": "ios",
        "created_at": "2015-03-03T10:45:08.037-03:00",
        "facebook_user_id": null
      },
      "created_by": {
        "google_plus_user_id": null,
        "twitter_user_id": null,
        "document": "67392343700",
        "phone": "11912231545",
        "email": "euricovidal@gmail.com",
        "groups_names": [
          "Administradores"
        ],
        "permissions": "<permission object>",
        "groups": [
          {
            "permissions": "<permission object>",
            "name": "Administradores",
            "id": 2
          }
        ],
        "name": "Hellen Armstrong Sr.",
        "id": 1,
        "address": "430 Danika Parkways",
        "address_additional": "Suite 386",
        "postal_code": "04005000",
        "district": "Lake Elsafort",
        "device_token": "445dcfb912fade983885d17f9aa42448",
        "device_type": "ios",
        "created_at": "2015-03-03T10:45:08.037-03:00",
        "facebook_user_id": null
      },
      "case_step_data_fields": [
        {
          "case_step_data_attachments": [],
          "case_step_data_images": [],
          "value": "teste",
          "field": {
            "list_versions": [
              {
                "previous_field": null,
                "created_at": "2015-03-04T00:29:36.020-03:00",
                "updated_at": "2015-03-04T00:51:47.192-03:00",
                "version_id": 3,
                "active": true,
                "values": null,
                "id": 2,
                "title": "Campo 1",
                "field_type": "text",
                "filter": null,
                "origin_field_id": null,
                "category_inventory": null,
                "category_report": null,
                "requirements": {
                  "presence": "true"
                }
              }
            ],
            "previous_field": null,
            "created_at": "2015-03-04T00:29:36.020-03:00",
            "updated_at": "2015-03-04T00:51:47.192-03:00",
            "version_id": null,
            "active": true,
            "values": null,
            "id": 2,
            "title": "Campo 1",
            "field_type": "text",
            "filter": null,
            "origin_field_id": null,
            "category_inventory": null,
            "category_report": null,
            "requirements": {
              "presence": "true"
            }
          },
          "id": 1
        }
      ],
      "created_at": "2015-03-04T11:11:46.894-03:00",
      "updated_at": "2015-03-04T11:21:27.267-03:00",
      "id": 1,
      "step_id": 5,
      "step_version": 6,
      "my_step": {
        "list_versions": [
          {
            "created_at": "2015-03-04T00:30:06.214-03:00",
            "updated_at": "2015-03-04T00:51:47.232-03:00",
            "permissions": "<permission object>",
            "version_id": 6,
            "active": true,
            "id": 5,
            "title": "Etapa 2",
            "conduction_mode_open": true,
            "step_type": "form",
            "child_flow": null,
            "my_child_flow": null,
            "fields": [
              {
                "draft": false,
                "step_id": 5,
                "active": true,
                "origin_field_id": null,
                "category_report_id": null,
                "category_inventory_id": null,
                "field_type": "text",
                "title": "Campo 1",
                "id": 3,
                "created_at": "2015-03-04T00:30:27.297-03:00",
                "updated_at": "2015-03-04T00:51:47.224-03:00",
                "multiple": false,
                "filter": null,
                "requirements": null,
                "values": null,
                "user_id": 1,
                "origin_field_version": null
              }
            ],
            "my_fields": [
              {
                "draft": false,
                "step_id": 5,
                "active": true,
                "origin_field_id": null,
                "category_report_id": null,
                "category_inventory_id": null,
                "field_type": "text",
                "title": "Campo 1",
                "id": 3,
                "created_at": "2015-03-04T00:30:27.297-03:00",
                "updated_at": "2015-03-04T00:51:47.224-03:00",
                "multiple": false,
                "filter": null,
                "requirements": null,
                "values": null,
                "user_id": 1,
                "origin_field_version": null
              }
            ]
          }
        ],
        "created_at": "2015-03-04T00:30:06.214-03:00",
        "updated_at": "2015-03-04T00:51:47.232-03:00",
        "permissions": "<permission object>",
        "version_id": 6,
        "active": true,
        "id": 5,
        "title": "Etapa 2",
        "conduction_mode_open": true,
        "step_type": "form",
        "child_flow": null,
        "my_child_flow": null,
        "fields": [
          {
            "draft": false,
            "step_id": 5,
            "active": true,
            "origin_field_id": null,
            "category_report_id": null,
            "category_inventory_id": null,
            "field_type": "text",
            "title": "Campo 1",
            "id": 3,
            "created_at": "2015-03-04T00:30:27.297-03:00",
            "updated_at": "2015-03-04T00:51:47.224-03:00",
            "multiple": false,
            "filter": null,
            "requirements": null,
            "values": null,
            "user_id": 1,
            "origin_field_version": null
          }
        ],
        "my_fields": [
          {
            "draft": false,
            "step_id": 5,
            "active": true,
            "origin_field_id": null,
            "category_report_id": null,
            "category_inventory_id": null,
            "field_type": "text",
            "title": "Campo 1",
            "id": 3,
            "created_at": "2015-03-04T00:30:27.297-03:00",
            "updated_at": "2015-03-04T00:51:47.224-03:00",
            "multiple": false,
            "filter": null,
            "requirements": null,
            "values": null,
            "user_id": 1,
            "origin_field_version": null
          }
        ]
      },
      "trigger_ids": [],
      "responsible_user_id": 1,
      "responsible_group_id": null,
      "executed": true
    },
    "case_steps": [
      {
        "updated_by": {
          "google_plus_user_id": null,
          "twitter_user_id": null,
          "document": "67392343700",
          "phone": "11912231545",
          "email": "euricovidal@gmail.com",
          "groups_names": [
            "Administradores"
          ],
          "permissions": "<permission object>",
          "groups": [
            {
              "permissions": "<permission object>",
              "name": "Administradores",
              "id": 2
            }
          ],
          "name": "Hellen Armstrong Sr.",
          "id": 1,
          "address": "430 Danika Parkways",
          "address_additional": "Suite 386",
          "postal_code": "04005000",
          "district": "Lake Elsafort",
          "device_token": "445dcfb912fade983885d17f9aa42448",
          "device_type": "ios",
          "created_at": "2015-03-03T10:45:08.037-03:00",
          "facebook_user_id": null
        },
        "created_by": {
          "google_plus_user_id": null,
          "twitter_user_id": null,
          "document": "67392343700",
          "phone": "11912231545",
          "email": "euricovidal@gmail.com",
          "groups_names": [
            "Administradores"
          ],
          "permissions": "<permission object>",
          "groups": [
            {
              "permissions": "<permission object>",
              "name": "Administradores",
              "id": 2
            }
          ],
          "name": "Hellen Armstrong Sr.",
          "id": 1,
          "address": "430 Danika Parkways",
          "address_additional": "Suite 386",
          "postal_code": "04005000",
          "district": "Lake Elsafort",
          "device_token": "445dcfb912fade983885d17f9aa42448",
          "device_type": "ios",
          "created_at": "2015-03-03T10:45:08.037-03:00",
          "facebook_user_id": null
        },
        "case_step_data_fields": [
          {
            "case_step_data_attachments": [],
            "case_step_data_images": [],
            "value": "teste",
            "field": {
              "list_versions": [
                {
                  "previous_field": null,
                  "created_at": "2015-03-04T00:29:36.020-03:00",
                  "updated_at": "2015-03-04T00:51:47.192-03:00",
                  "version_id": 3,
                  "active": true,
                  "values": null,
                  "id": 2,
                  "title": "Campo 1",
                  "field_type": "text",
                  "filter": null,
                  "origin_field_id": null,
                  "category_inventory": null,
                  "category_report": null,
                  "requirements": {
                    "presence": "true"
                  }
                }
              ],
              "previous_field": null,
              "created_at": "2015-03-04T00:29:36.020-03:00",
              "updated_at": "2015-03-04T00:51:47.192-03:00",
              "version_id": null,
              "active": true,
              "values": null,
              "id": 2,
              "title": "Campo 1",
              "field_type": "text",
              "filter": null,
              "origin_field_id": null,
              "category_inventory": null,
              "category_report": null,
              "requirements": {
                "presence": "true"
              }
            },
            "id": 1
          }
        ],
        "created_at": "2015-03-04T11:11:46.894-03:00",
        "updated_at": "2015-03-04T11:21:27.267-03:00",
        "id": 1,
        "step_id": 5,
        "step_version": 6,
        "my_step": {
          "list_versions": [
            {
              "created_at": "2015-03-04T00:30:06.214-03:00",
              "updated_at": "2015-03-04T00:51:47.232-03:00",
              "permissions": "<permission object>",
              "version_id": 6,
              "active": true,
              "id": 5,
              "title": "Etapa 2",
              "conduction_mode_open": true,
              "step_type": "form",
              "child_flow": null,
              "my_child_flow": null,
              "fields": [
                {
                  "draft": false,
                  "step_id": 5,
                  "active": true,
                  "origin_field_id": null,
                  "category_report_id": null,
                  "category_inventory_id": null,
                  "field_type": "text",
                  "title": "Campo 1",
                  "id": 3,
                  "created_at": "2015-03-04T00:30:27.297-03:00",
                  "updated_at": "2015-03-04T00:51:47.224-03:00",
                  "multiple": false,
                  "filter": null,
                  "requirements": null,
                  "values": null,
                  "user_id": 1,
                  "origin_field_version": null
                }
              ],
              "my_fields": [
                {
                  "draft": false,
                  "step_id": 5,
                  "active": true,
                  "origin_field_id": null,
                  "category_report_id": null,
                  "category_inventory_id": null,
                  "field_type": "text",
                  "title": "Campo 1",
                  "id": 3,
                  "created_at": "2015-03-04T00:30:27.297-03:00",
                  "updated_at": "2015-03-04T00:51:47.224-03:00",
                  "multiple": false,
                  "filter": null,
                  "requirements": null,
                  "values": null,
                  "user_id": 1,
                  "origin_field_version": null
                }
              ]
            }
          ],
          "created_at": "2015-03-04T00:30:06.214-03:00",
          "updated_at": "2015-03-04T00:51:47.232-03:00",
          "permissions": "<permission object>",
          "version_id": 6,
          "active": true,
          "id": 5,
          "title": "Etapa 2",
          "conduction_mode_open": true,
          "step_type": "form",
          "child_flow": null,
          "my_child_flow": null,
          "fields": [
            {
              "draft": false,
              "step_id": 5,
              "active": true,
              "origin_field_id": null,
              "category_report_id": null,
              "category_inventory_id": null,
              "field_type": "text",
              "title": "Campo 1",
              "id": 3,
              "created_at": "2015-03-04T00:30:27.297-03:00",
              "updated_at": "2015-03-04T00:51:47.224-03:00",
              "multiple": false,
              "filter": null,
              "requirements": null,
              "values": null,
              "user_id": 1,
              "origin_field_version": null
            }
          ],
          "my_fields": [
            {
              "draft": false,
              "step_id": 5,
              "active": true,
              "origin_field_id": null,
              "category_report_id": null,
              "category_inventory_id": null,
              "field_type": "text",
              "title": "Campo 1",
              "id": 3,
              "created_at": "2015-03-04T00:30:27.297-03:00",
              "updated_at": "2015-03-04T00:51:47.224-03:00",
              "multiple": false,
              "filter": null,
              "requirements": null,
              "values": null,
              "user_id": 1,
              "origin_field_version": null
            }
          ]
        },
        "trigger_ids": [],
        "responsible_user_id": 1,
        "responsible_group_id": null,
        "executed": true
      }
    ],
    "original_case": null,
    "get_responsible_group": null,
    "get_responsible_user": {
      "google_plus_user_id": null,
      "twitter_user_id": null,
      "document": "67392343700",
      "phone": "11912231545",
      "email": "euricovidal@gmail.com",
      "groups_names": [
        "Administradores"
      ],
      "permissions": "<permission object>",
      "groups": [
        {
          "permissions": "<permission object>",
          "name": "Administradores",
          "id": 2
        }
      ],
      "name": "Hellen Armstrong Sr.",
      "id": 1,
      "address": "430 Danika Parkways",
      "address_additional": "Suite 386",
      "postal_code": "04005000",
      "district": "Lake Elsafort",
      "device_token": "445dcfb912fade983885d17f9aa42448",
      "device_type": "ios",
      "created_at": "2015-03-03T10:45:08.037-03:00",
      "facebook_user_id": null
    },
    "updated_by": {
      "google_plus_user_id": null,
      "twitter_user_id": null,
      "document": "67392343700",
      "phone": "11912231545",
      "email": "euricovidal@gmail.com",
      "groups_names": [
        "Administradores"
      ],
      "permissions": "<permission object>",
      "groups": [
        {
          "permissions": "<permission object>",
          "name": "Administradores",
          "id": 2
        }
      ],
      "name": "Hellen Armstrong Sr.",
      "id": 1,
      "address": "430 Danika Parkways",
      "address_additional": "Suite 386",
      "postal_code": "04005000",
      "district": "Lake Elsafort",
      "device_token": "445dcfb912fade983885d17f9aa42448",
      "device_type": "ios",
      "created_at": "2015-03-03T10:45:08.037-03:00",
      "facebook_user_id": null
    },
    "created_by": {
      "google_plus_user_id": null,
      "twitter_user_id": null,
      "document": "67392343700",
      "phone": "11912231545",
      "email": "euricovidal@gmail.com",
      "groups_names": [
        "Administradores"
      ],
      "permissions": "<permission object>",
      "groups": [
        {
          "permissions": "<permission object>",
          "name": "Administradores",
          "id": 2
        }
      ],
      "name": "Hellen Armstrong Sr.",
      "id": 1,
      "address": "430 Danika Parkways",
      "address_additional": "Suite 386",
      "postal_code": "04005000",
      "district": "Lake Elsafort",
      "device_token": "445dcfb912fade983885d17f9aa42448",
      "device_type": "ios",
      "created_at": "2015-03-03T10:45:08.037-03:00",
      "facebook_user_id": null
    },
    "completed": false,
    "steps_not_fulfilled": [
      4
    ],
    "total_steps": 2,
    "flow_version": 8,
    "initial_flow_id": 3,
    "updated_at": "2015-03-04T11:21:27.385-03:00",
    "created_at": "2015-03-04T11:11:46.891-03:00",
    "updated_by_id": 1,
    "created_by_id": 1,
    "id": 1,
    "disabled_steps": [],
    "original_case_id": null,
    "children_case_ids": [],
    "case_step_ids": [
      1
    ],
    "next_step_id": 4,
    "responsible_user_id": 1,
    "responsible_group_id": null,
    "status": "active"
  }
}
```
__

### Atualizar / Avançar Etapa <a name="update"></a>

Endpoint: `/cases/:id`

Method: put

#### Parâmetros de Entrada

| Nome                 | Tipo    | Obrigatório | Descrição                                                   |
|----------------------|---------|-------------|-------------------------------------------------------------|
| step_id              | Integer | Sim         | ID do primeiro Step do Fluxo.                               |
| fields               | Array   | Sim         | Array de Hash com ID do Campo e Value com o Valor do campo (a value será convertida no valor correto do campo para verificar as validações do campo). |
| responsible_user_id  | Integer | Não         | ID do Grupo que será responsável pela Etapa do Caso. |
| responsible_group_id | Integer | Não         | ID do Grupo que será responsável pela Etapa do Caso. |

#### Status HTTP

| Código | Descrição                  |
|--------|----------------------------|
| 400    | Parâmetros inválidos.      |
| 400    | Etapa está disabilitada    |
| 400    | Etapa não pertence ao Caso |
| 400    | Etapa atual não foi preenchida |
| 401    | Acesso não autorizado.     |
| 405    | Caso está finalizado       |
| 200    | Etapa atualizada com sucesso |

#### Exemplo

##### Request
```json
{
  "step_id": 1,
  "fields": [
    {"id": 1, "value": "1"}
  ]
}
```

##### Response

###### Failure
```
Status: 400
Content-Type: application/json
```

```json
{
  "error": {
    "case_steps.fields": [
      "new_age deve ser maior que 10"
    ]
  }
}
```

###### Success

É criado uma entrado no CasesLogEntries com a ação de 'next_step' se for uma etapa nova ou 'update_step' se for atualização de uma Etapa já existente no Caso.

No retorno de criação do Caso, o retorno é trazido com display_type='full'.

Se for a última Etapa do Caso o Caso será finalizado e será cirada uma entrada no CasesLogEntries com a ação de 'finished'.

Se alguma Etapa foi desabilitada por um Gatilho e alguma outra Etapa depois a desabilitou, quando tentar finalizar o Caso, ele estará como 'not_satisfied' e retornará os IDs dessas Etapas em 'steps_not_fulfilled', quando não tiver mais Etapas no 'steps_not_fulfilled' o Caso será automaticamente finalizado.

Quando houver um Gatilho que foi executado no final do Caso no retorno vai ter dois valores preenchidos **trigger_values** e **trigger_type**.

**trigger_values** terá o ID do item

**trigger_type** terá um dos valroes: "enable_steps", "disable_steps", "finish_flow", "transfer_flow"

```
Status: 200
Content-Type: application/json
```

```json
{
  "trigger_description": null,
  "trigger_values": null,
  "trigger_type": null,
  "case": {
    "steps": [
      {
        "steps": [],
        "flow": {
          "steps_versions": {},
          "resolution_states_versions": {},
          "draft": false,
          "current_version": null,
          "step_id": null,
          "status": "pending",
          "id": 4,
          "title": "Fluxo Filho",
          "description": null,
          "created_by_id": 1,
          "updated_by_id": 1,
          "initial": false,
          "created_at": "2015-03-04T00:30:40.425-03:00",
          "updated_at": "2015-03-04T00:31:03.225-03:00"
        },
        "step": {
          "triggers_versions": {},
          "fields_versions": {},
          "user_id": 1,
          "draft": false,
          "conduction_mode_open": true,
          "child_flow_version": null,
          "child_flow_id": 4,
          "id": 6,
          "title": "Etapa 3",
          "description": null,
          "step_type": "flow",
          "flow_id": 3,
          "created_at": "2015-03-04T00:31:37.531-03:00",
          "updated_at": "2015-03-04T00:51:47.252-03:00",
          "active": true
        }
      },
      {
        "steps": [],
        "flow": null,
        "step": {
          "triggers_versions": {},
          "fields_versions": {
            "3": 5
          },
          "user_id": 1,
          "draft": false,
          "conduction_mode_open": true,
          "child_flow_version": null,
          "child_flow_id": null,
          "id": 5,
          "title": "Etapa 2",
          "description": null,
          "step_type": "form",
          "flow_id": 3,
          "created_at": "2015-03-04T00:30:06.214-03:00",
          "updated_at": "2015-03-04T00:51:47.232-03:00",
          "active": true
        }
      },
      {
        "steps": [],
        "flow": null,
        "step": {
          "triggers_versions": {},
          "fields_versions": {
            "2": 3
          },
          "user_id": 1,
          "draft": false,
          "conduction_mode_open": true,
          "child_flow_version": null,
          "child_flow_id": null,
          "id": 4,
          "title": "Etapa 1",
          "description": null,
          "step_type": "form",
          "flow_id": 3,
          "created_at": "2015-03-04T00:24:26.529-03:00",
          "updated_at": "2015-03-04T00:51:47.210-03:00",
          "active": true
        }
      }
    ],
    "current_step": {
      "updated_by": {
        "google_plus_user_id": null,
        "twitter_user_id": null,
        "document": "67392343700",
        "phone": "11912231545",
        "email": "euricovidal@gmail.com",
        "groups_names": [
          "Administradores"
        ],
        "permissions": "<permission object>",
        "groups": [
          {
            "permissions": "<permission object>",
            "name": "Administradores",
            "id": 2
          }
        ],
        "name": "Hellen Armstrong Sr.",
        "id": 1,
        "address": "430 Danika Parkways",
        "address_additional": "Suite 386",
        "postal_code": "04005000",
        "district": "Lake Elsafort",
        "device_token": "445dcfb912fade983885d17f9aa42448",
        "device_type": "ios",
        "created_at": "2015-03-03T10:45:08.037-03:00",
        "facebook_user_id": null
      },
      "created_by": {
        "google_plus_user_id": null,
        "twitter_user_id": null,
        "document": "67392343700",
        "phone": "11912231545",
        "email": "euricovidal@gmail.com",
        "groups_names": [
          "Administradores"
        ],
        "permissions": "<permission object>",
        "groups": [
          {
            "permissions": "<permission object>",
            "name": "Administradores",
            "id": 2
          }
        ],
        "name": "Hellen Armstrong Sr.",
        "id": 1,
        "address": "430 Danika Parkways",
        "address_additional": "Suite 386",
        "postal_code": "04005000",
        "district": "Lake Elsafort",
        "device_token": "445dcfb912fade983885d17f9aa42448",
        "device_type": "ios",
        "created_at": "2015-03-03T10:45:08.037-03:00",
        "facebook_user_id": null
      },
      "case_step_data_fields": [
        {
          "case_step_data_attachments": [],
          "case_step_data_images": [],
          "value": "teste",
          "field": {
            "list_versions": [
              {
                "previous_field": null,
                "created_at": "2015-03-04T00:29:36.020-03:00",
                "updated_at": "2015-03-04T00:51:47.192-03:00",
                "version_id": 3,
                "active": true,
                "values": null,
                "id": 2,
                "title": "Campo 1",
                "field_type": "text",
                "filter": null,
                "origin_field_id": null,
                "category_inventory": null,
                "category_report": null,
                "requirements": {
                  "presence": "true"
                }
              }
            ],
            "previous_field": null,
            "created_at": "2015-03-04T00:29:36.020-03:00",
            "updated_at": "2015-03-04T00:51:47.192-03:00",
            "version_id": null,
            "active": true,
            "values": null,
            "id": 2,
            "title": "Campo 1",
            "field_type": "text",
            "filter": null,
            "origin_field_id": null,
            "category_inventory": null,
            "category_report": null,
            "requirements": {
              "presence": "true"
            }
          },
          "id": 1
        }
      ],
      "created_at": "2015-03-04T11:11:46.894-03:00",
      "updated_at": "2015-03-04T11:21:27.267-03:00",
      "id": 1,
      "step_id": 5,
      "step_version": 6,
      "my_step": {
        "list_versions": [
          {
            "created_at": "2015-03-04T00:30:06.214-03:00",
            "updated_at": "2015-03-04T00:51:47.232-03:00",
            "permissions": "<permission object>",
            "version_id": 6,
            "active": true,
            "id": 5,
            "title": "Etapa 2",
            "conduction_mode_open": true,
            "step_type": "form",
            "child_flow": null,
            "my_child_flow": null,
            "fields": [
              {
                "draft": false,
                "step_id": 5,
                "active": true,
                "origin_field_id": null,
                "category_report_id": null,
                "category_inventory_id": null,
                "field_type": "text",
                "title": "Campo 1",
                "id": 3,
                "created_at": "2015-03-04T00:30:27.297-03:00",
                "updated_at": "2015-03-04T00:51:47.224-03:00",
                "multiple": false,
                "filter": null,
                "requirements": null,
                "values": null,
                "user_id": 1,
                "origin_field_version": null
              }
            ],
            "my_fields": [
              {
                "draft": false,
                "step_id": 5,
                "active": true,
                "origin_field_id": null,
                "category_report_id": null,
                "category_inventory_id": null,
                "field_type": "text",
                "title": "Campo 1",
                "id": 3,
                "created_at": "2015-03-04T00:30:27.297-03:00",
                "updated_at": "2015-03-04T00:51:47.224-03:00",
                "multiple": false,
                "filter": null,
                "requirements": null,
                "values": null,
                "user_id": 1,
                "origin_field_version": null
              }
            ]
          }
        ],
        "created_at": "2015-03-04T00:30:06.214-03:00",
        "updated_at": "2015-03-04T00:51:47.232-03:00",
        "permissions": "<permission object>",
        "version_id": 6,
        "active": true,
        "id": 5,
        "title": "Etapa 2",
        "conduction_mode_open": true,
        "step_type": "form",
        "child_flow": null,
        "my_child_flow": null,
        "fields": [
          {
            "draft": false,
            "step_id": 5,
            "active": true,
            "origin_field_id": null,
            "category_report_id": null,
            "category_inventory_id": null,
            "field_type": "text",
            "title": "Campo 1",
            "id": 3,
            "created_at": "2015-03-04T00:30:27.297-03:00",
            "updated_at": "2015-03-04T00:51:47.224-03:00",
            "multiple": false,
            "filter": null,
            "requirements": null,
            "values": null,
            "user_id": 1,
            "origin_field_version": null
          }
        ],
        "my_fields": [
          {
            "draft": false,
            "step_id": 5,
            "active": true,
            "origin_field_id": null,
            "category_report_id": null,
            "category_inventory_id": null,
            "field_type": "text",
            "title": "Campo 1",
            "id": 3,
            "created_at": "2015-03-04T00:30:27.297-03:00",
            "updated_at": "2015-03-04T00:51:47.224-03:00",
            "multiple": false,
            "filter": null,
            "requirements": null,
            "values": null,
            "user_id": 1,
            "origin_field_version": null
          }
        ]
      },
      "trigger_ids": [],
      "responsible_user_id": 1,
      "responsible_group_id": null,
      "executed": true
    },
    "case_steps": [
      {
        "updated_by": {
          "google_plus_user_id": null,
          "twitter_user_id": null,
          "document": "67392343700",
          "phone": "11912231545",
          "email": "euricovidal@gmail.com",
          "groups_names": [
            "Administradores"
          ],
          "permissions": "<permission object>",
          "groups": [
            {
              "permissions": "<permission object>",
              "name": "Administradores",
              "id": 2
            }
          ],
          "name": "Hellen Armstrong Sr.",
          "id": 1,
          "address": "430 Danika Parkways",
          "address_additional": "Suite 386",
          "postal_code": "04005000",
          "district": "Lake Elsafort",
          "device_token": "445dcfb912fade983885d17f9aa42448",
          "device_type": "ios",
          "created_at": "2015-03-03T10:45:08.037-03:00",
          "facebook_user_id": null
        },
        "created_by": {
          "google_plus_user_id": null,
          "twitter_user_id": null,
          "document": "67392343700",
          "phone": "11912231545",
          "email": "euricovidal@gmail.com",
          "groups_names": [
            "Administradores"
          ],
          "permissions": "<permission object>",
          "groups": [
            {
              "permissions": "<permission object>",
              "name": "Administradores",
              "id": 2
            }
          ],
          "name": "Hellen Armstrong Sr.",
          "id": 1,
          "address": "430 Danika Parkways",
          "address_additional": "Suite 386",
          "postal_code": "04005000",
          "district": "Lake Elsafort",
          "device_token": "445dcfb912fade983885d17f9aa42448",
          "device_type": "ios",
          "created_at": "2015-03-03T10:45:08.037-03:00",
          "facebook_user_id": null
        },
        "case_step_data_fields": [
          {
            "case_step_data_attachments": [],
            "case_step_data_images": [],
            "value": "teste",
            "field": {
              "list_versions": [
                {
                  "previous_field": null,
                  "created_at": "2015-03-04T00:29:36.020-03:00",
                  "updated_at": "2015-03-04T00:51:47.192-03:00",
                  "version_id": 3,
                  "active": true,
                  "values": null,
                  "id": 2,
                  "title": "Campo 1",
                  "field_type": "text",
                  "filter": null,
                  "origin_field_id": null,
                  "category_inventory": null,
                  "category_report": null,
                  "requirements": {
                    "presence": "true"
                  }
                }
              ],
              "previous_field": null,
              "created_at": "2015-03-04T00:29:36.020-03:00",
              "updated_at": "2015-03-04T00:51:47.192-03:00",
              "version_id": null,
              "active": true,
              "values": null,
              "id": 2,
              "title": "Campo 1",
              "field_type": "text",
              "filter": null,
              "origin_field_id": null,
              "category_inventory": null,
              "category_report": null,
              "requirements": {
                "presence": "true"
              }
            },
            "id": 1
          }
        ],
        "created_at": "2015-03-04T11:11:46.894-03:00",
        "updated_at": "2015-03-04T11:21:27.267-03:00",
        "id": 1,
        "step_id": 5,
        "step_version": 6,
        "my_step": {
          "list_versions": [
            {
              "created_at": "2015-03-04T00:30:06.214-03:00",
              "updated_at": "2015-03-04T00:51:47.232-03:00",
              "permissions": "<permission object>",
              "version_id": 6,
              "active": true,
              "id": 5,
              "title": "Etapa 2",
              "conduction_mode_open": true,
              "step_type": "form",
              "child_flow": null,
              "my_child_flow": null,
              "fields": [
                {
                  "draft": false,
                  "step_id": 5,
                  "active": true,
                  "origin_field_id": null,
                  "category_report_id": null,
                  "category_inventory_id": null,
                  "field_type": "text",
                  "title": "Campo 1",
                  "id": 3,
                  "created_at": "2015-03-04T00:30:27.297-03:00",
                  "updated_at": "2015-03-04T00:51:47.224-03:00",
                  "multiple": false,
                  "filter": null,
                  "requirements": null,
                  "values": null,
                  "user_id": 1,
                  "origin_field_version": null
                }
              ],
              "my_fields": [
                {
                  "draft": false,
                  "step_id": 5,
                  "active": true,
                  "origin_field_id": null,
                  "category_report_id": null,
                  "category_inventory_id": null,
                  "field_type": "text",
                  "title": "Campo 1",
                  "id": 3,
                  "created_at": "2015-03-04T00:30:27.297-03:00",
                  "updated_at": "2015-03-04T00:51:47.224-03:00",
                  "multiple": false,
                  "filter": null,
                  "requirements": null,
                  "values": null,
                  "user_id": 1,
                  "origin_field_version": null
                }
              ]
            }
          ],
          "created_at": "2015-03-04T00:30:06.214-03:00",
          "updated_at": "2015-03-04T00:51:47.232-03:00",
          "permissions": "<permission object>",
          "version_id": 6,
          "active": true,
          "id": 5,
          "title": "Etapa 2",
          "conduction_mode_open": true,
          "step_type": "form",
          "child_flow": null,
          "my_child_flow": null,
          "fields": [
            {
              "draft": false,
              "step_id": 5,
              "active": true,
              "origin_field_id": null,
              "category_report_id": null,
              "category_inventory_id": null,
              "field_type": "text",
              "title": "Campo 1",
              "id": 3,
              "created_at": "2015-03-04T00:30:27.297-03:00",
              "updated_at": "2015-03-04T00:51:47.224-03:00",
              "multiple": false,
              "filter": null,
              "requirements": null,
              "values": null,
              "user_id": 1,
              "origin_field_version": null
            }
          ],
          "my_fields": [
            {
              "draft": false,
              "step_id": 5,
              "active": true,
              "origin_field_id": null,
              "category_report_id": null,
              "category_inventory_id": null,
              "field_type": "text",
              "title": "Campo 1",
              "id": 3,
              "created_at": "2015-03-04T00:30:27.297-03:00",
              "updated_at": "2015-03-04T00:51:47.224-03:00",
              "multiple": false,
              "filter": null,
              "requirements": null,
              "values": null,
              "user_id": 1,
              "origin_field_version": null
            }
          ]
        },
        "trigger_ids": [],
        "responsible_user_id": 1,
        "responsible_group_id": null,
        "executed": true
      }
    ],
    "original_case": null,
    "get_responsible_group": null,
    "get_responsible_user": {
      "google_plus_user_id": null,
      "twitter_user_id": null,
      "document": "67392343700",
      "phone": "11912231545",
      "email": "euricovidal@gmail.com",
      "groups_names": [
        "Administradores"
      ],
      "permissions": "<permission object>",
      "groups": [
        {
          "permissions": "<permission object>",
          "name": "Administradores",
          "id": 2
        }
      ],
      "name": "Hellen Armstrong Sr.",
      "id": 1,
      "address": "430 Danika Parkways",
      "address_additional": "Suite 386",
      "postal_code": "04005000",
      "district": "Lake Elsafort",
      "device_token": "445dcfb912fade983885d17f9aa42448",
      "device_type": "ios",
      "created_at": "2015-03-03T10:45:08.037-03:00",
      "facebook_user_id": null
    },
    "updated_by": {
      "google_plus_user_id": null,
      "twitter_user_id": null,
      "document": "67392343700",
      "phone": "11912231545",
      "email": "euricovidal@gmail.com",
      "groups_names": [
        "Administradores"
      ],
      "permissions": "<permission object>",
      "groups": [
        {
          "permissions": "<permission object>",
          "name": "Administradores",
          "id": 2
        }
      ],
      "name": "Hellen Armstrong Sr.",
      "id": 1,
      "address": "430 Danika Parkways",
      "address_additional": "Suite 386",
      "postal_code": "04005000",
      "district": "Lake Elsafort",
      "device_token": "445dcfb912fade983885d17f9aa42448",
      "device_type": "ios",
      "created_at": "2015-03-03T10:45:08.037-03:00",
      "facebook_user_id": null
    },
    "created_by": {
      "google_plus_user_id": null,
      "twitter_user_id": null,
      "document": "67392343700",
      "phone": "11912231545",
      "email": "euricovidal@gmail.com",
      "groups_names": [
        "Administradores"
      ],
      "permissions": "<permission object>",
      "groups": [
        {
          "permissions": "<permission object>",
          "name": "Administradores",
          "id": 2
        }
      ],
      "name": "Hellen Armstrong Sr.",
      "id": 1,
      "address": "430 Danika Parkways",
      "address_additional": "Suite 386",
      "postal_code": "04005000",
      "district": "Lake Elsafort",
      "device_token": "445dcfb912fade983885d17f9aa42448",
      "device_type": "ios",
      "created_at": "2015-03-03T10:45:08.037-03:00",
      "facebook_user_id": null
    },
    "completed": false,
    "steps_not_fulfilled": [
      4
    ],
    "total_steps": 2,
    "flow_version": 8,
    "initial_flow_id": 3,
    "updated_at": "2015-03-04T11:21:27.385-03:00",
    "created_at": "2015-03-04T11:11:46.891-03:00",
    "updated_by_id": 1,
    "created_by_id": 1,
    "id": 1,
    "disabled_steps": [],
    "original_case_id": null,
    "children_case_ids": [],
    "case_step_ids": [
      1
    ],
    "next_step_id": 4,
    "responsible_user_id": 1,
    "responsible_group_id": null,
    "status": "active"
  },
  "message": "Etapa atualizada com sucesso"
}
```
___

### Finalizar <a name="finish"></a>

Para finalizar um Caso antecipadamente.

Endpoint: `/cases/:id/finish`

Method: put

#### Parâmetros de Entrada

| Nome                | Tipo    | Obrigatório | Descrição                              |
|---------------------|---------|-------------|----------------------------------------|
| resolution_state_id | Integer | Sim         | ID do Estado de Resolução para o Caso. |

#### Status HTTP

| Código | Descrição                  |
|--------|----------------------------|
| 400    | Parâmetros inválidos.      |
| 401    | Acesso não autorizado.     |
| 200    | Se foi criado com sucesso. |

#### Exemplo
##### Response

É criado uma entrado no CasesLogEntries com a ação de 'finished'.

```
Status: 200
Content-Type: application/json
```

```json
{
  "message": "Caso finalizado com sucesso"
}
```
___

### Transferir para outro Fluxo <a name="transfer"></a>

Endpoint: `/cases/:id/transfer`

Method: put

#### Parâmetros de Entrada

| Nome         | Tipo    | Obrigatório | Descrição                                     |
|--------------|---------|-------------|-----------------------------------------------|
| flow_id      | Integer | Sim         | ID do novo Fluxo.                             |
| display_type | String  | Não         | para retornar todos os dados utilizar 'full'. |

#### Status HTTP

| Código | Descrição                  |
|--------|----------------------------|
| 400    | Parâmetros inválidos.      |
| 401    | Acesso não autorizado.     |
| 200    | Se foi criado com sucesso. |

#### Exemplo
##### Response

É criado uma entrado no CasesLogEntries com a ação de 'transfer_flow' para o Caso atual e 'create_case' para o novo Caso.

```
Status: 200
Content-Type: application/json
```

| Nome     | Tipo    | Descrição                             |
|----------|---------|---------------------------------------|
| case     | Object  | Vide CaseObject get /cases/1          |

```json
{
  "case": {
    "completed": false,
    "steps_not_fulfilled": [],
    "total_steps": 1,
    "flow_version": 12,
    "initial_flow_id": 6,
    "updated_at": "2015-03-04T12:11:21.810-03:00",
    "created_at": "2015-03-04T12:11:21.810-03:00",
    "updated_by_id": null,
    "created_by_id": 1,
    "id": 2,
    "disabled_steps": [],
    "original_case_id": 1,
    "children_case_ids": [],
    "case_step_ids": [],
    "next_step_id": 7,
    "responsible_user_id": null,
    "responsible_group_id": null,
    "status": "active"
  },
  "message": "Caso atualizado com sucesso"
}
```
___

### Inativar <a name="inactive"></a>

Endpoint: `/cases/:id`

Method: delete

#### Parâmetros de Entrada

#### Status HTTP

| Código | Descrição                     |
|--------|-------------------------------|
| 404    | Não encontrado.               |
| 200    | Se foi inativado com sucesso. |

#### Exemplo
##### Response

É criado uma entrado no CasesLogEntries com a ação de 'delete_case'.

```
Status: 200
Content-Type: application/json
```

```json
{
  "message": "Caso removido com sucesso"
}
```
___

### Restaurar <a name="restore"></a>

Endpoint: `/cases/:id/restore`

Method: put

#### Parâmetros de Entrada

#### Status HTTP

| Código | Descrição                      |
|--------|--------------------------------|
| 404    | Não encontrado.                |
| 200    | Se foi restaurado com sucesso. |

#### Exemplo
##### Response

É criado uma entrado no CasesLogEntries com a ação de 'restored_case'.

```
Status: 200
Content-Type: application/json
```

```json
{
  "message": "Caso recuperado com sucesso"
}
```
___

### Atualizar Etapa do Caso <a name="update_case_step"></a>

No momento os únicos valores que podem ser atualizados são 'responsible_user_id' e 'responsible_group_id'.

Endpoint: `/cases/:id/case_steps/:case_step_id`

Method: put

#### Parâmetros de Entrada

| Nome                 | Tipo    | Obrigatório | Descrição                                            |
|----------------------|---------|-------------|------------------------------------------------------|
| responsible_user_id  | Integer | Não         | ID do Grupo que será responsável pela Etapa do Caso. |
| responsible_group_id | Integer | Não         | ID do Grupo que será responsável pela Etapa do Caso. |

#### Status HTTP

| Código | Descrição                      |
|--------|--------------------------------|
| 400    | Parâmetros inválidos.          |
| 401    | Acesso não autorizado.         |
| 200    | Se foi atualizado com sucesso. |

#### Exemplo

##### Request
```json
{
  "responsible_user_id": 1
}
```

Se foi enviado alguns dos parametros de responsible será criado uma entrado no CasesLogEntries com a ação de 'transfer_case'.

```
Status: 200
Content-Type: application/json
```

```json
{
  "message": "Estado do Caso atualizado com sucesso"
}
```
___

### Permissões <a name="permissions"></a>

As permissões ficam no Grupo do usuário dentro do atributo permissions.

#### Tipos de Permissões

| Permissão                 | Parâmetro             | Descrição                                                                         |
|---------------------------|-----------------------|-----------------------------------------------------------------------------------|
| can_execute_step          | ID da Etapa           | Pode visualizar e executar/atualizar uma Etapa do Caso.                           |
| can_view_step             | ID da Etapa           | Pode visualizar uma Etapa do Caso.                                                |
| can_execute_all_steps     | ID do Fluxo           | Pode visualizar e executar todas Etapas filhas do Fluxo (filhos diretos).         |
| can_view_all_steps        | ID do Fluxo           | Pode visualizar todas Etapas filhas do Fluxo (filhos diretos).                    |
| flow_can_delete_own_cases | ID do Fluxo           | Pode deletar/restaurar Casos Próprios (necessário permissão de visualizar também) |
| flow_can_delete_all_cases | ID do Fluxo           | Pode deletar/restaurar qualquer Caso (necessário permissão de visualizar também)  |
