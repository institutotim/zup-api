# Documentação ZUP-API - Fluxos

## Protocolo

O protocolo usado é REST e recebe como parâmetro um JSON, é necessário executar a chamada de autênticação e utilizar o TOKEN nas chamadas desse Endpoint.

Endpoint Staging: `http://staging.zup.sapience.io/flows`

Exemplo de como realizar um request usando a ferramenta cURL:

```bash
curl -X POST --data-binary @flows-data.json -H 'Content-Type:application/json' -H 'X-App-Token:TOKEN' http://staging.zup.sapience.io/flows
```
Ou
```bash
curl -X POST --data-binary '{"campo":"valor"}' -H 'Content-Type:application/json' -H 'X-App-Token:TOKEN' http://staging.zup.sapience.io/flows
```

## Serviços

### Índice

* [Listagem de Fluxos](#list)
* [Criação de Fluxo](#create)
* [Exibir Fluxo](#show)
* [Publicar Fluxo](#publish)
* [Alterar Versão Corrente](#change_version)
* [Edição de Fluxo](#update)
* [Deleção de Fluxo](#delete)
* [Adicionar Permissão](#permission_add)
* [Remover Permissão](#permission_rem)

___

### Listagem de Fluxos <a name="list"></a>

Endpoint: `/flows`

Method: get

#### Parâmetros de Entrada

| Nome          | Tipo    | Obrigatório | Descrição                                      |
|---------------|---------|-------------|------------------------------------------------|
| initial       | Boolena | Não         | Para retornar Fluxos que forem iniciais.       |
| display_type  | String  | Não         | Para retornar todos os valores utilize 'full'. |

#### Status HTTP

| Código | Descrição                                    |
|--------|----------------------------------------------|
| 401    | Acesso não autorizado.                       |
| 200    | Exibe listagem de fluxos (com zero ou mais). |

#### Exemplo

##### Response
```
Status: 200
Content-Type: application/json
```

| Nome        | Tipo    | Descrição                                |
|-------------|---------|------------------------------------------|
| flows       | Array   | Array de flows (vide FlowObject get /flows/:id) |

```json
{
  "flows": [
    {
      "list_versions": [
        {
          "created_at": "2015-03-04T00:30:40.425-03:00",
          "my_resolution_states": [],
          "resolution_states": [],
          "steps_id": [],
          "steps_versions": {},
          "initial": false,
          "description": null,
          "title": "Fluxo Filho",
          "id": 4,
          "resolution_states_versions": {},
          "status": "pending",
          "draft": false,
          "total_cases": 0,
          "version_id": 2,
          "created_by_id": 1,
          "updated_by_id": 1,
          "updated_at": "2015-03-04T00:31:03.225-03:00"
        }
      ],
      "created_at": "2015-03-04T00:30:40.425-03:00",
      "my_resolution_states": [],
      "resolution_states": [],
      "steps_id": [],
      "steps_versions": {},
      "initial": false,
      "description": null,
      "title": "Fluxo Filho",
      "id": 4,
      "resolution_states_versions": {},
      "status": "pending",
      "draft": false,
      "total_cases": 0,
      "version_id": null,
      "created_by_id": 1,
      "updated_by_id": 1,
      "updated_at": "2015-03-04T00:31:03.225-03:00"
    },
    {
      "list_versions": [
        {
          "created_at": "2015-03-04T00:17:01.471-03:00",
          "my_resolution_states": [],
          "resolution_states": [
            {
              "list_versions": null,
              "created_at": "2015-03-04T02:08:10.302-03:00",
              "updated_at": "2015-03-04T02:08:10.302-03:00",
              "version_id": null,
              "active": true,
              "default": true,
              "title": "Resolução 1",
              "id": 1
            }
          ],
          "steps_id": [
            "6",
            "5",
            "4"
          ],
          "steps_versions": {
            "6": 7,
            "5": 6,
            "4": 4
          },
          "initial": false,
          "description": null,
          "title": "Fluxo Inicial",
          "id": 3,
          "resolution_states_versions": {},
          "status": "pending",
          "draft": false,
          "total_cases": 0,
          "version_id": 8,
          "created_by_id": 1,
          "updated_by_id": 1,
          "updated_at": "2015-03-04T00:52:08.985-03:00"
        }
      ],
      "created_at": "2015-03-04T00:17:01.471-03:00",
      "my_resolution_states": [
        {
          "list_versions": null,
          "created_at": "2015-03-04T02:08:10.302-03:00",
          "updated_at": "2015-03-04T02:08:10.302-03:00",
          "version_id": null,
          "active": true,
          "default": true,
          "title": "Resolução 1",
          "id": 1
        }
      ],
      "resolution_states": [
        {
          "list_versions": null,
          "created_at": "2015-03-04T02:08:10.302-03:00",
          "updated_at": "2015-03-04T02:08:10.302-03:00",
          "version_id": null,
          "active": true,
          "default": true,
          "title": "Resolução 1",
          "id": 1
        }
      ],
      "steps_id": [
        "6",
        "5",
        "4"
      ],
      "steps_versions": {
        "6": 7,
        "5": 6,
        "4": 4
      },
      "initial": false,
      "description": null,
      "title": "Fluxo Inicial",
      "id": 3,
      "resolution_states_versions": {
        "1": null
      },
      "status": "active",
      "draft": true,
      "total_cases": 0,
      "version_id": null,
      "created_by_id": 1,
      "updated_by_id": 1,
      "updated_at": "2015-03-04T02:08:10.320-03:00"
    },
    {
      "list_versions": null,
      "created_at": "2015-03-04T02:22:55.397-03:00",
      "my_resolution_states": [],
      "resolution_states": [],
      "steps_id": [],
      "steps_versions": {},
      "initial": false,
      "description": null,
      "title": "Fluxo Filho",
      "id": 5,
      "resolution_states_versions": {},
      "status": "pending",
      "draft": true,
      "total_cases": 0,
      "version_id": null,
      "created_by_id": 1,
      "updated_by_id": null,
      "updated_at": "2015-03-04T02:22:55.397-03:00"
    }
  ]
}
```
___

### Criação de Fluxo <a name="create"></a>

Endpoint: `/flows`

Method: post

#### Parâmetros de Entrada

| Nome                  | Tipo    | Obrigatório | Descrição                                                 |
|-----------------------|---------|-------------|-----------------------------------------------------------|
| title                 | String  | Sim         | Título do Fluxo. (até 100 caracteres)                     |
| description           | Text    | Não         | Descrição do Fluxo. (até 600 caracteres)                  |
| initial               | Boolean | Não         | Para definir um Fluxo como inicial.                       |
| resolution_states     | Array   | Não         | Conjunto de estado de resolução (ver campos abaixo).      |

#### Parâmetros para estados de resolução

| Nome                  | Tipo    | Obrigatório | Descrição                                                 |
|-----------------------|---------|-------------|-----------------------------------------------------------|
| title                 | String  | Sim         | Título do Fluxo. (até 100 caracteres)                     |
| default               | Boolean | Não         | Se verdadeiro, novos casos são criados com este estado.   |
| active                | Boolean | Não         | Se falso este estado foi excluído e não pode ser usado.   |


#### Status HTTP

| Código | Descrição                          |
|--------|------------------------------------|
| 400    | Parâmetros inválidos.              |
| 401    | Acesso não autorizado.             |
| 201    | Se o Fluxo foi criado com sucesso. |

#### Exemplo

##### Request
```json
{
  "title": "Título do Fluxo",
  "description": "Descrição para o Fluxo"
}
```

##### Response
```
Status: 201
Content-Type: application/json
```

| Nome        | Tipo    | Descrição                                |
|-------------|---------|------------------------------------------|
| flow        | Object  | Vide FlowObject get /flows/:id           |

```json
{
  "flow": {
    "list_versions": null,
    "created_at": "2015-03-04T02:22:55.397-03:00",
    "updated_at": "2015-03-04T02:22:55.397-03:00",
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
      "permissions": {
        "flow_can_delete_own_cases": [],
        "flow_can_delete_all_cases": [],
        "create_reports_from_panel": true,
        "updated_at": "2015-03-03T10:45:07.465-03:00",
        "created_at": "2015-03-03T10:45:07.461-03:00",
        "view_categories": false,
        "edit_reports": true,
        "edit_inventory_items": true,
        "delete_reports": false,
        "delete_inventory_items": false,
        "manage_config": true,
        "manage_inventory_formulas": true,
        "manage_reports": true,
        "id": 2,
        "group_id": 2,
        "manage_flows": true,
        "manage_users": true,
        "manage_inventory_categories": true,
        "manage_inventory_items": true,
        "manage_groups": true,
        "manage_reports_categories": true,
        "view_sections": false,
        "panel_access": true,
        "groups_can_edit": [],
        "groups_can_view": [],
        "reports_categories_can_edit": [],
        "reports_categories_can_view": [],
        "inventory_categories_can_edit": [],
        "inventory_categories_can_view": [],
        "inventory_sections_can_view": [],
        "inventory_sections_can_edit": [],
        "inventory_fields_can_edit": [],
        "inventory_fields_can_view": [],
        "flow_can_view_all_steps": [],
        "flow_can_execute_all_steps": [],
        "can_view_step": [],
        "can_execute_step": []
      },
      "groups": [
        {
          "permissions": {
            "flow_can_delete_own_cases": [],
            "flow_can_delete_all_cases": [],
            "create_reports_from_panel": true,
            "updated_at": "2015-03-03T10:45:07.465-03:00",
            "created_at": "2015-03-03T10:45:07.461-03:00",
            "view_categories": false,
            "edit_reports": true,
            "edit_inventory_items": true,
            "delete_reports": false,
            "delete_inventory_items": false,
            "manage_config": true,
            "manage_inventory_formulas": true,
            "manage_reports": true,
            "id": 2,
            "group_id": 2,
            "manage_flows": true,
            "manage_users": true,
            "manage_inventory_categories": true,
            "manage_inventory_items": true,
            "manage_groups": true,
            "manage_reports_categories": true,
            "view_sections": false,
            "panel_access": true,
            "groups_can_edit": [],
            "groups_can_view": [],
            "reports_categories_can_edit": [],
            "reports_categories_can_view": [],
            "inventory_categories_can_edit": [],
            "inventory_categories_can_view": [],
            "inventory_sections_can_view": [],
            "inventory_sections_can_edit": [],
            "inventory_fields_can_edit": [],
            "inventory_fields_can_view": [],
            "flow_can_view_all_steps": [],
            "flow_can_execute_all_steps": [],
            "can_view_step": [],
            "can_execute_step": []
          },
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
    "steps_versions": {},
    "my_steps_flows": [],
    "my_steps": [],
    "steps": [],
    "initial": false,
    "description": null,
    "title": "Fluxo Filho",
    "id": 5,
    "resolution_states": [],
    "my_resolution_states": [],
    "resolution_states_versions": {},
    "status": "pending",
    "draft": true,
    "total_cases": 0,
    "version_id": null,
    "permissions": {
      "flow_can_delete_all_cases": [],
      "flow_can_delete_own_cases": [],
      "flow_can_execute_all_steps": [],
      "flow_can_view_all_steps": []
    }
  },
  "message": "Fluxo criado com sucesso"
}
```
___

### Edição de Fluxo <a name="update"></a>

Endpoint: `/flows/:id`

Method: put

#### Parâmetros de Entrada

| Nome        | Tipo    | Obrigatório | Descrição                                |
|-------------|---------|-------------|------------------------------------------|
| title       | String  | Sim         | Título do Fluxo. (até 100 caracteres)    |
| description | Text    | Não         | Descrição do Fluxo. (até 600 caracteres) |
| initial     | Boolean | Não         | Para definir um Fluxo como inicial.      |
| resolution_states     | Array   | Não         | Conjunto de estado de resolução (ver campos abaixo).      |

#### Parâmetros para estados de resolução

| Nome                  | Tipo    | Obrigatório | Descrição                                                 |
|-----------------------|---------|-------------|-----------------------------------------------------------|
| title                 | String  | Sim         | Título do Fluxo. (até 100 caracteres)                     |
| default               | Boolean | Não         | Se verdadeiro, novos casos são criados com este estado.   |
| active                | Boolean | Não         | Se falso este estado foi excluído e não pode ser usado.   |


#### Status HTTP

| Código | Descrição                              |
|--------|----------------------------------------|
| 400    | Parâmetros inválidos.                  |
| 401    | Acesso não autorizado.                 |
| 404    | Fluxo não existe.                      |
| 200    | Se o Fluxo foi atualizado com sucesso. |

#### Exemplo

##### Request
```json
{
  "title": "Novo Título do Fluxo"
}
```

##### Response
```
Status: 200
Content-Type: application/json
```

```json
{
  "message": "Fluxo atualizado com sucesso"
}
```
___

### Deleção de Fluxo <a name="delete"></a>

Endpoint: `/flows/:id`

Method: delete

Se houver algum Caso criado para o Fluxo (pode ver com a opção GET do Fluxo e o atributo "total_cases")
o Fluxo não poderá ser apagado e será inativado, caso não possua Casos será excluido fisicamente.

#### Parâmetros de Entrada

Nenhum parâmetro de entrada, apenas o **id** na url.

#### Status HTTP

| Código | Descrição                            |
|--------|--------------------------------------|
| 401    | Acesso não autorizado.               |
| 404    | Fluxo não existe.                    |
| 200    | Se o Fluxo foi apagado com sucesso. |

#### Exemplo

##### Response
```
Status: 200
Content-Type: application/json
```

```json
{
  "message": "Fluxo apagado com sucesso"
}
```
___

### Exibir Fluxo <a name="show"></a>

Endpoint: `/flows/:id`

Method: get

#### Parâmetros de Entrada

| Nome          | Tipo     | Obrigatório | Descrição                                                      |
|---------------|----------|-------------|----------------------------------------------------------------|
| version       | Interger | Não         | Versão do Fluxo, para quando a versão corrente não é a última. |
| display_type  | String   | Não         | Para retornar todos os valores utilize 'full'.                 |

#### Status HTTP

| Código | Descrição               |
|--------|-------------------------|
| 401    | Acesso não autorizado.  |
| 404    | Fluxo não existe.       |
| 200    | Exibe o Fluxo buscado.  |

#### Exemplo

##### Response
```
Status: 200
Content-Type: application/json
```

###### FlowObject
| Nome                       | Tipo       | Descrição                                                                                                  |
|----------------------------|------------|------------------------------------------------------------------------------------------------------------|
| id                         | Interger   | ID do objeto.                                                                                              |
| list_versions              | Array      | Array contento todas as versões do objeto.                                                                 |
| created_by                 | Object     | Objeto do usuário que criou o Fluxo.                                                                       |
| updated_by                 | Object     | Objeto do usuário que atualializou o Fluxo.                                                                |
| created_at                 | DateTime   | Data e horário da criação do objeto.                                                                       |
| updated_at                 | DateTime   | Data e horário da última atualização do objeto.                                                            |
| title                      | String     | Título do Objeto.                                                                                          |
| description                | String     | Descrição do Objeto.                                                                                       |
| status                     | String     | Status do Fluxo (active, inactive, pending)                                                                |
| initial                    | Boolean    | Se o Fluxo é Inicial ou não. (só pode ser criado Caso com Fluxo Inicial)                                   |
| draft                      | Boolean    | Se o Fluxo está como rascunho e precisa ser publicado (qualquer alteração no Fluxo ou nos derivados define o Fluxo como Rascunho e precisa ser publicado para gerar uma versão). |
| resolution_states          | Array      | Array de Estados de Resolução (vide ResolutionStateObject get /flows/1/resolution_states)                  |
| my_resolution_states       | Array      | Array de Estados de Resolução com a versão correspondente ao Fluxo (vide ResolutionStateObject get /flows/1/resolution_states) |
| version_id                 | Interger   | ID da Versão do objeto.                                                                                    |
| permissions                | Object     | Lista de permissões (com chave a permissão e o valor é um array de ID de Grupos)                           |
| total_cases                | Integer    | Total de Casos utlizando o Fluxo ou uma Etapa do Fluxo (quando o Fluxo não é inicial)                      |
| steps                      | Array      | Array de Etapas com a última versão da Etapa (para Edição, pios pode estar sendo editado e estar em modo rascunho, vide StepObject get /flows/1/steps/1)                                        |
| my_steps                   | Array      | Array de Etapas com a versão correspondente ao Fluxo (vide StepObject get /flows/1/steps/1)                |
| steps_versions             | Array      | Array de Hash com a chave sendo o ID da Etapa e o valor sendo o ID da Versão (exibindo a ordem das Etapas) |
| resolution_states_versions | Array      | Array de Hash com a chave sendo o ID do Estado de Resolução e o valor sendo o ID da Versão                 |
| my_steps_flows             | Array      | Array de Etapas e quando for do tipo Fluxo retorna o Fluxo Filho (my_child_flow) e suas Etapas (my_steps). |
| current_version            | Integer    | Versão usável, que será utilizada quando tentar criar um Caso. |

**Sem display_type**
```json
{
  "flow": {
    "list_versions": [
      {
        "created_at": "2015-03-04T00:17:01.471-03:00",
        "my_resolution_states": [],
        "resolution_states": [
          {
            "list_versions": null,
            "created_at": "2015-03-04T02:08:10.302-03:00",
            "updated_at": "2015-03-04T02:08:10.302-03:00",
            "version_id": null,
            "active": true,
            "default": true,
            "title": "Resolução 1",
            "id": 1
          }
        ],
        "steps_id": [
          "6",
          "5",
          "4"
        ],
        "steps_versions": {
          "6": 7,
          "5": 6,
          "4": 4
        },
        "initial": false,
        "description": null,
        "title": "Fluxo Inicial",
        "id": 3,
        "resolution_states_versions": {},
        "status": "pending",
        "draft": false,
        "total_cases": 0,
        "version_id": 8,
        "created_by_id": 1,
        "updated_by_id": 1,
        "updated_at": "2015-03-04T00:52:08.985-03:00"
      }
    ],
    "created_at": "2015-03-04T00:17:01.471-03:00",
    "my_resolution_states": [
      {
        "list_versions": null,
        "created_at": "2015-03-04T02:08:10.302-03:00",
        "updated_at": "2015-03-04T02:08:10.302-03:00",
        "version_id": null,
        "active": true,
        "default": true,
        "title": "Resolução 1",
        "id": 1
      }
    ],
    "resolution_states": [
      {
        "list_versions": null,
        "created_at": "2015-03-04T02:08:10.302-03:00",
        "updated_at": "2015-03-04T02:08:10.302-03:00",
        "version_id": null,
        "active": true,
        "default": true,
        "title": "Resolução 1",
        "id": 1
      }
    ],
    "steps_id": [
      "6",
      "5",
      "4"
    ],
    "steps_versions": {
      "6": 7,
      "5": 6,
      "4": 4
    },
    "initial": false,
    "description": null,
    "title": "Fluxo Inicial",
    "id": 3,
    "resolution_states_versions": {
      "1": null
    },
    "status": "active",
    "draft": true,
    "total_cases": 0,
    "version_id": null,
    "created_by_id": 1,
    "updated_by_id": 1,
    "updated_at": "2015-03-04T02:08:10.320-03:00"
  }
}
```

**Com display_type=full**
```json
{
  "flow": {
    "list_versions": [
      {
        "created_at": "2015-03-04T00:17:01.471-03:00",
        "updated_at": "2015-03-04T00:52:08.985-03:00",
        "updated_by": {
          "google_plus_user_id": null,
          "twitter_user_id": null,
          "document": "67392343700",
          "phone": "11912231545",
          "email": "euricovidal@gmail.com",
          "groups_names": [
            "Administradores"
          ],
          "permissions": {
            "flow_can_delete_own_cases": [],
            "flow_can_delete_all_cases": [],
            "create_reports_from_panel": true,
            "updated_at": "2015-03-03T10:45:07.465-03:00",
            "created_at": "2015-03-03T10:45:07.461-03:00",
            "view_categories": false,
            "edit_reports": true,
            "edit_inventory_items": true,
            "delete_reports": false,
            "delete_inventory_items": false,
            "manage_config": true,
            "manage_inventory_formulas": true,
            "manage_reports": true,
            "id": 2,
            "group_id": 2,
            "manage_flows": true,
            "manage_users": true,
            "manage_inventory_categories": true,
            "manage_inventory_items": true,
            "manage_groups": true,
            "manage_reports_categories": true,
            "view_sections": false,
            "panel_access": true,
            "groups_can_edit": [],
            "groups_can_view": [],
            "reports_categories_can_edit": [],
            "reports_categories_can_view": [],
            "inventory_categories_can_edit": [],
            "inventory_categories_can_view": [],
            "inventory_sections_can_view": [],
            "inventory_sections_can_edit": [],
            "inventory_fields_can_edit": [],
            "inventory_fields_can_view": [],
            "flow_can_view_all_steps": [],
            "flow_can_execute_all_steps": [],
            "can_view_step": [],
            "can_execute_step": []
          },
          "groups": [
            {
              "permissions": {
                "flow_can_delete_own_cases": [],
                "flow_can_delete_all_cases": [],
                "create_reports_from_panel": true,
                "updated_at": "2015-03-03T10:45:07.465-03:00",
                "created_at": "2015-03-03T10:45:07.461-03:00",
                "view_categories": false,
                "edit_reports": true,
                "edit_inventory_items": true,
                "delete_reports": false,
                "delete_inventory_items": false,
                "manage_config": true,
                "manage_inventory_formulas": true,
                "manage_reports": true,
                "id": 2,
                "group_id": 2,
                "manage_flows": true,
                "manage_users": true,
                "manage_inventory_categories": true,
                "manage_inventory_items": true,
                "manage_groups": true,
                "manage_reports_categories": true,
                "view_sections": false,
                "panel_access": true,
                "groups_can_edit": [],
                "groups_can_view": [],
                "reports_categories_can_edit": [],
                "reports_categories_can_view": [],
                "inventory_categories_can_edit": [],
                "inventory_categories_can_view": [],
                "inventory_sections_can_view": [],
                "inventory_sections_can_edit": [],
                "inventory_fields_can_edit": [],
                "inventory_fields_can_view": [],
                "flow_can_view_all_steps": [],
                "flow_can_execute_all_steps": [],
                "can_view_step": [],
                "can_execute_step": []
              },
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
          "permissions": {
            "flow_can_delete_own_cases": [],
            "flow_can_delete_all_cases": [],
            "create_reports_from_panel": true,
            "updated_at": "2015-03-03T10:45:07.465-03:00",
            "created_at": "2015-03-03T10:45:07.461-03:00",
            "view_categories": false,
            "edit_reports": true,
            "edit_inventory_items": true,
            "delete_reports": false,
            "delete_inventory_items": false,
            "manage_config": true,
            "manage_inventory_formulas": true,
            "manage_reports": true,
            "id": 2,
            "group_id": 2,
            "manage_flows": true,
            "manage_users": true,
            "manage_inventory_categories": true,
            "manage_inventory_items": true,
            "manage_groups": true,
            "manage_reports_categories": true,
            "view_sections": false,
            "panel_access": true,
            "groups_can_edit": [],
            "groups_can_view": [],
            "reports_categories_can_edit": [],
            "reports_categories_can_view": [],
            "inventory_categories_can_edit": [],
            "inventory_categories_can_view": [],
            "inventory_sections_can_view": [],
            "inventory_sections_can_edit": [],
            "inventory_fields_can_edit": [],
            "inventory_fields_can_view": [],
            "flow_can_view_all_steps": [],
            "flow_can_execute_all_steps": [],
            "can_view_step": [],
            "can_execute_step": []
          },
          "groups": [
            {
              "permissions": {
                "flow_can_delete_own_cases": [],
                "flow_can_delete_all_cases": [],
                "create_reports_from_panel": true,
                "updated_at": "2015-03-03T10:45:07.465-03:00",
                "created_at": "2015-03-03T10:45:07.461-03:00",
                "view_categories": false,
                "edit_reports": true,
                "edit_inventory_items": true,
                "delete_reports": false,
                "delete_inventory_items": false,
                "manage_config": true,
                "manage_inventory_formulas": true,
                "manage_reports": true,
                "id": 2,
                "group_id": 2,
                "manage_flows": true,
                "manage_users": true,
                "manage_inventory_categories": true,
                "manage_inventory_items": true,
                "manage_groups": true,
                "manage_reports_categories": true,
                "view_sections": false,
                "panel_access": true,
                "groups_can_edit": [],
                "groups_can_view": [],
                "reports_categories_can_edit": [],
                "reports_categories_can_view": [],
                "inventory_categories_can_edit": [],
                "inventory_categories_can_view": [],
                "inventory_sections_can_view": [],
                "inventory_sections_can_edit": [],
                "inventory_fields_can_edit": [],
                "inventory_fields_can_view": [],
                "flow_can_view_all_steps": [],
                "flow_can_execute_all_steps": [],
                "can_view_step": [],
                "can_execute_step": []
              },
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
        "steps_versions": {
          "6": 7,
          "5": 6,
          "4": 4
        },
        "my_steps_flows": [
          {
            "my_child_flow": {
              "my_steps": [],
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
          },
          {
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
          },
          {
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
        ],
        "my_steps": [
          {
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
          },
          {
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
          },
          {
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
        ],
        "steps": [
          {
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
          },
          {
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
          },
          {
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
        ],
        "initial": false,
        "description": null,
        "title": "Fluxo Inicial",
        "id": 3,
        "resolution_states": [
          {
            "list_versions": null,
            "created_at": "2015-03-04T02:08:10.302-03:00",
            "updated_at": "2015-03-04T02:08:10.302-03:00",
            "version_id": null,
            "active": true,
            "default": true,
            "title": "Resolução 1",
            "id": 1
          }
        ],
        "my_resolution_states": [],
        "resolution_states_versions": {},
        "status": "pending",
        "draft": false,
        "total_cases": 0,
        "version_id": 8,
        "permissions": {
          "flow_can_delete_all_cases": [],
          "flow_can_delete_own_cases": [],
          "flow_can_execute_all_steps": [],
          "flow_can_view_all_steps": []
        }
      }
    ],
    "created_at": "2015-03-04T00:17:01.471-03:00",
    "updated_at": "2015-03-04T02:08:10.320-03:00",
    "updated_by": {
      "google_plus_user_id": null,
      "twitter_user_id": null,
      "document": "67392343700",
      "phone": "11912231545",
      "email": "euricovidal@gmail.com",
      "groups_names": [
        "Administradores"
      ],
      "permissions": {
        "flow_can_delete_own_cases": [],
        "flow_can_delete_all_cases": [],
        "create_reports_from_panel": true,
        "updated_at": "2015-03-03T10:45:07.465-03:00",
        "created_at": "2015-03-03T10:45:07.461-03:00",
        "view_categories": false,
        "edit_reports": true,
        "edit_inventory_items": true,
        "delete_reports": false,
        "delete_inventory_items": false,
        "manage_config": true,
        "manage_inventory_formulas": true,
        "manage_reports": true,
        "id": 2,
        "group_id": 2,
        "manage_flows": true,
        "manage_users": true,
        "manage_inventory_categories": true,
        "manage_inventory_items": true,
        "manage_groups": true,
        "manage_reports_categories": true,
        "view_sections": false,
        "panel_access": true,
        "groups_can_edit": [],
        "groups_can_view": [],
        "reports_categories_can_edit": [],
        "reports_categories_can_view": [],
        "inventory_categories_can_edit": [],
        "inventory_categories_can_view": [],
        "inventory_sections_can_view": [],
        "inventory_sections_can_edit": [],
        "inventory_fields_can_edit": [],
        "inventory_fields_can_view": [],
        "flow_can_view_all_steps": [],
        "flow_can_execute_all_steps": [],
        "can_view_step": [],
        "can_execute_step": []
      },
      "groups": [
        {
          "permissions": {
            "flow_can_delete_own_cases": [],
            "flow_can_delete_all_cases": [],
            "create_reports_from_panel": true,
            "updated_at": "2015-03-03T10:45:07.465-03:00",
            "created_at": "2015-03-03T10:45:07.461-03:00",
            "view_categories": false,
            "edit_reports": true,
            "edit_inventory_items": true,
            "delete_reports": false,
            "delete_inventory_items": false,
            "manage_config": true,
            "manage_inventory_formulas": true,
            "manage_reports": true,
            "id": 2,
            "group_id": 2,
            "manage_flows": true,
            "manage_users": true,
            "manage_inventory_categories": true,
            "manage_inventory_items": true,
            "manage_groups": true,
            "manage_reports_categories": true,
            "view_sections": false,
            "panel_access": true,
            "groups_can_edit": [],
            "groups_can_view": [],
            "reports_categories_can_edit": [],
            "reports_categories_can_view": [],
            "inventory_categories_can_edit": [],
            "inventory_categories_can_view": [],
            "inventory_sections_can_view": [],
            "inventory_sections_can_edit": [],
            "inventory_fields_can_edit": [],
            "inventory_fields_can_view": [],
            "flow_can_view_all_steps": [],
            "flow_can_execute_all_steps": [],
            "can_view_step": [],
            "can_execute_step": []
          },
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
      "permissions": {
        "flow_can_delete_own_cases": [],
        "flow_can_delete_all_cases": [],
        "create_reports_from_panel": true,
        "updated_at": "2015-03-03T10:45:07.465-03:00",
        "created_at": "2015-03-03T10:45:07.461-03:00",
        "view_categories": false,
        "edit_reports": true,
        "edit_inventory_items": true,
        "delete_reports": false,
        "delete_inventory_items": false,
        "manage_config": true,
        "manage_inventory_formulas": true,
        "manage_reports": true,
        "id": 2,
        "group_id": 2,
        "manage_flows": true,
        "manage_users": true,
        "manage_inventory_categories": true,
        "manage_inventory_items": true,
        "manage_groups": true,
        "manage_reports_categories": true,
        "view_sections": false,
        "panel_access": true,
        "groups_can_edit": [],
        "groups_can_view": [],
        "reports_categories_can_edit": [],
        "reports_categories_can_view": [],
        "inventory_categories_can_edit": [],
        "inventory_categories_can_view": [],
        "inventory_sections_can_view": [],
        "inventory_sections_can_edit": [],
        "inventory_fields_can_edit": [],
        "inventory_fields_can_view": [],
        "flow_can_view_all_steps": [],
        "flow_can_execute_all_steps": [],
        "can_view_step": [],
        "can_execute_step": []
      },
      "groups": [
        {
          "permissions": {
            "flow_can_delete_own_cases": [],
            "flow_can_delete_all_cases": [],
            "create_reports_from_panel": true,
            "updated_at": "2015-03-03T10:45:07.465-03:00",
            "created_at": "2015-03-03T10:45:07.461-03:00",
            "view_categories": false,
            "edit_reports": true,
            "edit_inventory_items": true,
            "delete_reports": false,
            "delete_inventory_items": false,
            "manage_config": true,
            "manage_inventory_formulas": true,
            "manage_reports": true,
            "id": 2,
            "group_id": 2,
            "manage_flows": true,
            "manage_users": true,
            "manage_inventory_categories": true,
            "manage_inventory_items": true,
            "manage_groups": true,
            "manage_reports_categories": true,
            "view_sections": false,
            "panel_access": true,
            "groups_can_edit": [],
            "groups_can_view": [],
            "reports_categories_can_edit": [],
            "reports_categories_can_view": [],
            "inventory_categories_can_edit": [],
            "inventory_categories_can_view": [],
            "inventory_sections_can_view": [],
            "inventory_sections_can_edit": [],
            "inventory_fields_can_edit": [],
            "inventory_fields_can_view": [],
            "flow_can_view_all_steps": [],
            "flow_can_execute_all_steps": [],
            "can_view_step": [],
            "can_execute_step": []
          },
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
    "steps_versions": {
      "6": 7,
      "5": 6,
      "4": 4
    },
    "my_steps_flows": [
      {
        "my_child_flow": {
          "my_steps": [],
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
      },
      {
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
      },
      {
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
    ],
    "my_steps": [
      {
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
      },
      {
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
      },
      {
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
    ],
    "steps": [
      {
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
      },
      {
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
      },
      {
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
    ],
    "initial": false,
    "description": null,
    "title": "Fluxo Inicial",
    "id": 3,
    "resolution_states": [
      {
        "list_versions": null,
        "created_at": "2015-03-04T02:08:10.302-03:00",
        "updated_at": "2015-03-04T02:08:10.302-03:00",
        "version_id": null,
        "active": true,
        "default": true,
        "title": "Resolução 1",
        "id": 1
      }
    ],
    "my_resolution_states": [
      {
        "list_versions": null,
        "created_at": "2015-03-04T02:08:10.302-03:00",
        "updated_at": "2015-03-04T02:08:10.302-03:00",
        "version_id": null,
        "active": true,
        "default": true,
        "title": "Resolução 1",
        "id": 1
      }
    ],
    "resolution_states_versions": {
      "1": null
    },
    "status": "active",
    "draft": true,
    "total_cases": 0,
    "version_id": null,
    "permissions": {
      "flow_can_delete_all_cases": [],
      "flow_can_delete_own_cases": [],
      "flow_can_execute_all_steps": [],
      "flow_can_view_all_steps": []
    }
  }
}
```

___

### Publicar Fluxo <a name="publish"></a>

Quando o Fluxo estiver com alterações, vai estar com draft=true, assim é necessário publicar o Fluxo para criar uma versão,
se o Fluxo não tiver casos será atualizada a última versão com as alteração, se tiver algum Caso para o Fluxo será criada uma nova versão.

Endpoint: `/flows/:id/publish`

Method: post

#### Parâmetros de Entrada

#### Status HTTP

| Código | Descrição               |
|--------|-------------------------|
| 401    | Acesso não autorizado.  |
| 404    | Fluxo não existe.       |
| 201    | Mensagem de sucesso.    |

#### Exemplo

##### Response
```
Status: 201
Content-Type: application/json
```

```json
{
  "message": "Fluxo publicado com sucesso"
}
```

___

### Alterar Versão Corrente <a name="change_version"></a>

Endpoint: `/flows/:id/version`

Method: put

#### Parâmetros de Entrada

| Nome          | Tipo     | Obrigatório | Descrição                                        |
|---------------|----------|-------------|--------------------------------------------------|
| new_version   | Interger | Sim         | Versão do Fluxo, para alterar a versão corrente. |

#### Status HTTP

| Código | Descrição               |
|--------|-------------------------|
| 400    | Versão não é válida.    |
| 401    | Acesso não autorizado.  |
| 404    | Fluxo não existe.       |
| 200    | Mensagem de sucesso.    |

#### Exemplo

##### Response
```
Status: 200
Content-Type: application/json
```

```json
{
  "message": "Versão do Fluxo atualizado para 2"
}
```

___

### Adicionar Permissão <a name="permission_add"></a>

Endpoint: `/flows/:id/permissions`

Method: put

#### Parâmetros de Entrada

| Nome            | Tipo    | Obrigatório | Descrição                                      |
|-----------------|---------|-------------|------------------------------------------------|
| group_ids       | Array   | Sim         | Array de IDs dos Grupos a seram alterados.     |
| permission_type | String  | Sim         | Tipo de permissão a ser adicionado.            |

#### Tipos de Permissões

| Permissão                  | Parâmetro             | Descrição                                                                         |
|----------------------------|-----------------------|-----------------------------------------------------------------------------------|
| flow_can_execute_all_steps | ID do Fluxo           | Pode visualizar e executar todas Etapas filhas do Fluxo (filhos diretos).         |
| flow_can_view_all_steps    | ID do Fluxo           | Pode visualizar todas Etapas filhas do Fluxo (filhos diretos).                    |
| flow_can_delete_own_cases  | ID do Fluxo           | Pode deletar/restaurar Casos Próprios (necessário permissão de visualizar também) |
| flow_can_delete_all_cases  | ID do Fluxo           | Pode deletar/restaurar qualquer Caso (necessário permissão de visualizar também)  |

#### Status HTTP

| Código | Descrição               |
|--------|-------------------------|
| 400    | Permissão não existe.   |
| 401    | Acesso não autorizado.  |
| 404    | Não existe.             |
| 200    | Atualizado com sucesso. |

#### Exemplo

##### Response
```
Status: 200
Content-Type: application/json
```

```json
{
  message: "Permissões atualizadas com sucesso"
}
```

___

### Remover Permissão <a name="permission_rem"></a>

Endpoint: `/flows/:id/permissions`

Method: delete

#### Parâmetros de Entrada

| Nome            | Tipo    | Obrigatório | Descrição                                      |
|-----------------|---------|-------------|------------------------------------------------|
| group_ids       | Array   | Sim         | Array de IDs dos Grupos a seram alterados.     |
| permission_type | String  | Sim         | Tipo de permissão a ser removida.              |

#### Tipos de Permissões

| Permissão                  | Parâmetro             | Descrição                                                                         |
|----------------------------|-----------------------|-----------------------------------------------------------------------------------|
| flow_can_execute_all_steps | ID do Fluxo           | Pode visualizar e executar todas Etapas filhas do Fluxo (filhos diretos).         |
| flow_can_view_all_steps    | ID do Fluxo           | Pode visualizar todas Etapas filhas do Fluxo (filhos diretos).                    |
| flow_can_delete_own_cases  | ID do Fluxo           | Pode deletar/restaurar Casos Próprios (necessário permissão de visualizar também) |
| flow_can_delete_all_cases  | ID do Fluxo           | Pode deletar/restaurar qualquer Caso (necessário permissão de visualizar também)  |

#### Status HTTP

| Código | Descrição               |
|--------|-------------------------|
| 400    | Permissão não existe.   |
| 401    | Acesso não autorizado.  |
| 404    | Não existe.             |
| 200    | Atualizado com sucesso. |

#### Exemplo

##### Response
```
Status: 200
Content-Type: application/json
```

```json
{
  message: "Permissões atualizadas com sucesso"
}
```
