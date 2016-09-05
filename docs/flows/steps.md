# Documentação ZUP-API - Fluxos - Etapas

## Protocolo

O protocolo usado é REST e recebe como parâmetro um JSON, é necessário executar a chamada de autênticação e utilizar o TOKEN nas chamadas desse Endpoint.
Necessário criação de um Fluxo para utilização correta desse endpoint.

Endpoint Staging: `http://staging.zup.sapience.io/flows/:flow_id/steps`

Exemplo de como realizar um request usando a ferramenta cURL:

```bash
curl -X POST --data-binary @steps-data.json -H 'Content-Type:application/json' -H 'X-App-Token:TOKEN' http://staging.zup.sapience.io/flows/:flow_id/steps
```
Ou
```bash
curl -X POST --data-binary '{"campo":"valor"}' -H 'Content-Type:application/json' -H 'X-App-Token:TOKEN' http://staging.zup.sapience.io/flows/:flow_id/steps
```

## Serviços

### Índice

* [Listagem](#list)
* [Criação](#create)
* [Edição](#update)
* [Exibir](#show)
* [Deleção](#delete)
* [Redefinir Ordenação](#order)
* [Permissão](#permission)

___

### Exibir <a name="show"></a>

Endpoint: `/flows/:flow_id/steps/:id`

Method: get

#### Parâmetros de Entrada

| Nome          | Tipo    | Obrigatório | Descrição                                      |
|---------------|---------|-------------|------------------------------------------------|
| display_type  | String  | Não         | Para retornar todos os valores utilize 'full'. |

#### Status HTTP

| Código | Descrição              |
|--------|------------------------|
| 401    | Acesso não autorizado. |
| 404    | Não encontrado.        |
| 200    | Exibe Etapa.           |

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

###### FieldObject
| Nome                  | Tipo       | Descrição                                                                        |
|-----------------------|------------|----------------------------------------------------------------------------------|
| id                    | Interger   | ID do objeto.                                                                    |
| list_versions         | Array      | Array contento todas as versões do objeto.                                       |
| created_at            | DateTime   | Data e horário da criação do objeto.                                             |
| updated_at            | DateTime   | Data e horário da última atualização do objeto.                                  |
| title                 | String     | Título do Objeto.                                                                |
| active                | Boolean    | Se o objeto esta ativo.                                                          |
| conduction_mode_open  | Boolean    | Se o modo de condução da Etapa é Aberto.                                         |
| step_type             | String     | Tipo da Etapa (form ou flow)                                                     |
| version_id            | Interger   | ID da Versão do objeto.                                                          |
| permissions           | Object     | Lista de permissões (com chave a permissão e o valor é um array de ID de Grupos) |
| child_flow            | Object     | Se a Etapa for do Tipo "flow" deve haver um Fluxo filho (atual) |
| my_child_flow         | Object     | Se a Etapa for do Tipo "flow" deve haver um Fluxo filho (correspondente a versão da Etapa) |
| fields                | Array      | Se a Etapa for do Tipo "form" deve haver Campos (atual) |
| my_fields             | Array      | Se a Etapa for do Tipo "form" deve haver Campos (correspondente a versão da Etapa) |

**Sem display_type**
```json
{
  "step": {
    "list_versions": null,
    "created_at": "2015-03-03T10:53:39.760-03:00",
    "updated_at": "2015-03-03T13:30:29.090-03:00",
    "id": 1,
    "title": "Etapa 1",
    "conduction_mode_open": true,
    "step_type": "form",
    "child_flow_id": null,
    "fields_id": [
      1
    ],
    "active": true,
    "version_id": null
  }
}
```

**Com display_type=full**
```json
{
  "step": {
    "list_versions": null,
    "created_at": "2015-03-03T10:53:39.760-03:00",
    "updated_at": "2015-03-03T13:30:29.090-03:00",
    "permissions": {
      "can_execute_step": [],
      "can_view_step": []
    },
    "version_id": null,
    "active": true,
    "id": 1,
    "title": "Etapa 1",
    "conduction_mode_open": true,
    "step_type": "form",
    "child_flow": null,
    "my_child_flow": null,
    "fields": [
      {
        "draft": true,
        "step_id": 1,
        "active": true,
        "origin_field_id": null,
        "category_report_id": null,
        "category_inventory_id": null,
        "field_type": "text",
        "title": "Campo 1",
        "id": 1,
        "created_at": "2015-03-03T13:30:29.082-03:00",
        "updated_at": "2015-03-03T13:30:29.082-03:00",
        "multiple": false,
        "filter": null,
        "requirements": {
          "presence": "true"
        },
        "values": null,
        "user_id": 1,
        "origin_field_version": null
      }
    ],
    "my_fields": [
      {
        "draft": true,
        "step_id": 1,
        "active": true,
        "origin_field_id": null,
        "category_report_id": null,
        "category_inventory_id": null,
        "field_type": "text",
        "title": "Campo 1",
        "id": 1,
        "created_at": "2015-03-03T13:30:29.082-03:00",
        "updated_at": "2015-03-03T13:30:29.082-03:00",
        "multiple": false,
        "filter": null,
        "requirements": {
          "presence": "true"
        },
        "values": null,
        "user_id": 1,
        "origin_field_version": null
      }
    ]
  }
}
```
___

### Listagem de Etapas <a name="list"></a>

Endpoint: `/flows/:flow_id/steps`

Method: get

#### Parâmetros de Entrada

| Nome          | Tipo    | Obrigatório | Descrição                                      |
|---------------|---------|-------------|------------------------------------------------|
| display_type  | String  | Não         | Para retornar todos os valores utilize 'full'. |

#### Status HTTP

| Código | Descrição                                    |
|--------|----------------------------------------------|
| 401    | Acesso não autorizado.                       |
| 200    | Exibe listagem de Etapas (com zero ou mais). |

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

| Nome          | Tipo    | Descrição                                        |
|---------------|---------|--------------------------------------------------|
| steps         | Array   | Array de Etapas (video StepObject get /step/:id) |

**Sem display_type**
```json
{
  "steps": [
    {
      "list_versions": null,
      "created_at": "2015-03-03T10:53:39.760-03:00",
      "updated_at": "2015-03-03T13:30:29.090-03:00",
      "id": 1,
      "title": "Etapa 1",
      "conduction_mode_open": true,
      "step_type": "form",
      "child_flow_id": null,
      "fields_id": [
        1
      ],
      "active": true,
      "version_id": null
    },
    {
      "list_versions": null,
      "created_at": "2015-03-03T14:06:58.394-03:00",
      "updated_at": "2015-03-03T14:06:58.394-03:00",
      "id": 2,
      "title": "Etaoa 2",
      "conduction_mode_open": true,
      "step_type": "form",
      "child_flow_id": null,
      "fields_id": [],
      "active": true,
      "version_id": null
    },
    {
      "list_versions": null,
      "created_at": "2015-03-03T14:21:38.430-03:00",
      "updated_at": "2015-03-03T14:21:38.430-03:00",
      "id": 3,
      "title": "Etapa 3",
      "conduction_mode_open": true,
      "step_type": "flow",
      "child_flow_id": 2,
      "fields_id": [],
      "active": true,
      "version_id": null
    }
  ]
}
```

**Com display_type=full**
```json
{
  "steps": [
    {
      "list_versions": null,
      "created_at": "2015-03-03T10:53:39.760-03:00",
      "updated_at": "2015-03-03T13:30:29.090-03:00",
      "permissions": {
        "can_execute_step": [],
        "can_view_step": []
      },
      "version_id": null,
      "active": true,
      "id": 1,
      "title": "Etapa 1",
      "conduction_mode_open": true,
      "step_type": "form",
      "child_flow": null,
      "my_child_flow": null,
      "fields": [
        {
          "draft": true,
          "step_id": 1,
          "active": true,
          "origin_field_id": null,
          "category_report_id": null,
          "category_inventory_id": null,
          "field_type": "text",
          "title": "Campo 1",
          "id": 1,
          "created_at": "2015-03-03T13:30:29.082-03:00",
          "updated_at": "2015-03-03T13:30:29.082-03:00",
          "multiple": false,
          "filter": null,
          "requirements": {
            "presence": "true"
          },
          "values": null,
          "user_id": 1,
          "origin_field_version": null
        }
      ],
      "my_fields": [
        {
          "draft": true,
          "step_id": 1,
          "active": true,
          "origin_field_id": null,
          "category_report_id": null,
          "category_inventory_id": null,
          "field_type": "text",
          "title": "Campo 1",
          "id": 1,
          "created_at": "2015-03-03T13:30:29.082-03:00",
          "updated_at": "2015-03-03T13:30:29.082-03:00",
          "multiple": false,
          "filter": null,
          "requirements": {
            "presence": "true"
          },
          "values": null,
          "user_id": 1,
          "origin_field_version": null
        }
      ]
    },
    {
      "list_versions": null,
      "created_at": "2015-03-03T14:06:58.394-03:00",
      "updated_at": "2015-03-03T14:06:58.394-03:00",
      "permissions": {
        "can_execute_step": [],
        "can_view_step": []
      },
      "version_id": null,
      "active": true,
      "id": 2,
      "title": "Etaoa 2",
      "conduction_mode_open": true,
      "step_type": "form",
      "child_flow": null,
      "my_child_flow": null,
      "fields": [],
      "my_fields": []
    },
    {
      "list_versions": null,
      "created_at": "2015-03-03T14:21:38.430-03:00",
      "updated_at": "2015-03-03T14:21:38.430-03:00",
      "permissions": {
        "can_execute_step": [],
        "can_view_step": []
      },
      "version_id": null,
      "active": true,
      "id": 3,
      "title": "Etapa 3",
      "conduction_mode_open": true,
      "step_type": "flow",
      "child_flow": {
        "list_versions": [
          {
            "created_at": "2015-03-03T14:20:55.690-03:00",
            "updated_at": "2015-03-03T14:21:07.015-03:00",
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
            "steps_versions": {},
            "my_steps_flows": [],
            "my_steps": [],
            "steps": [],
            "initial": false,
            "description": null,
            "title": "Fluxo Filho",
            "id": 2,
            "resolution_states": [],
            "my_resolution_states": [],
            "resolution_states_versions": {},
            "status": "pending",
            "draft": false,
            "total_cases": 0,
            "version_id": 1,
            "permissions": {
              "flow_can_delete_all_cases": [],
              "flow_can_delete_own_cases": [],
              "flow_can_execute_all_steps": [],
              "flow_can_view_all_steps": []
            }
          }
        ],
        "created_at": "2015-03-03T14:20:55.690-03:00",
        "updated_at": "2015-03-03T14:21:07.015-03:00",
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
        "steps_versions": {},
        "my_steps_flows": [],
        "my_steps": [],
        "steps": [],
        "initial": false,
        "description": null,
        "title": "Fluxo Filho",
        "id": 2,
        "resolution_states": [],
        "my_resolution_states": [],
        "resolution_states_versions": {},
        "status": "pending",
        "draft": false,
        "total_cases": 0,
        "version_id": null,
        "permissions": {
          "flow_can_delete_all_cases": [],
          "flow_can_delete_own_cases": [],
          "flow_can_execute_all_steps": [],
          "flow_can_view_all_steps": []
        }
      },
      "my_child_flow": {
        "list_versions": [
          {
            "created_at": "2015-03-03T14:20:55.690-03:00",
            "updated_at": "2015-03-03T14:21:07.015-03:00",
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
            "steps_versions": {},
            "my_steps_flows": [],
            "my_steps": [],
            "steps": [],
            "initial": false,
            "description": null,
            "title": "Fluxo Filho",
            "id": 2,
            "resolution_states": [],
            "my_resolution_states": [],
            "resolution_states_versions": {},
            "status": "pending",
            "draft": false,
            "total_cases": 0,
            "version_id": 1,
            "permissions": {
              "flow_can_delete_all_cases": [],
              "flow_can_delete_own_cases": [],
              "flow_can_execute_all_steps": [],
              "flow_can_view_all_steps": []
            }
          }
        ],
        "created_at": "2015-03-03T14:20:55.690-03:00",
        "updated_at": "2015-03-03T14:21:07.015-03:00",
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
        "steps_versions": {},
        "my_steps_flows": [],
        "my_steps": [],
        "steps": [],
        "initial": false,
        "description": null,
        "title": "Fluxo Filho",
        "id": 2,
        "resolution_states": [],
        "my_resolution_states": [],
        "resolution_states_versions": {},
        "status": "pending",
        "draft": false,
        "total_cases": 0,
        "version_id": null,
        "permissions": {
          "flow_can_delete_all_cases": [],
          "flow_can_delete_own_cases": [],
          "flow_can_execute_all_steps": [],
          "flow_can_view_all_steps": []
        }
      },
      "fields": [],
      "my_fields": []
    }
  ]
}
```
___

### Redefinir Ordenação das Etapas <a name="order"></a>

Endpoint: `/flows/:flow_id/steps`

Method: put

#### Parâmetros de Entrada

| Nome | Tipo  | Obrigatório | Descrição                                   |
|------|-------|-------------|---------------------------------------------|
| ids  | Array | Sim         | Array com ids das Etapas na ordem desejada. |

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
  "message": "Ordem das Etadas atualizada com sucesso"
}
```
___

### Criação de Etapa <a name="create"></a>

Ao cadastrar uma Etapa do Tipo Fluxo, o Fluxo Filho deve estar publicado.

Endpoint: `/flows/:flow_id/steps`

Method: post

#### Parâmetros de Entrada

| Nome                  | Tipo    | Obrigatório | Descrição                                                           |
|-----------------------|---------|-------------|---------------------------------------------------------------------|
| title                 | String  | Sim         | Título da Etapa. (até 100 caracteres)                               |
| step_type             | String  | Sim         | Tipo da Etapa. (Fluxo=flow ou Formulário=form)                      |
| conduction_modeo_open | Boolean | Não         | Modo de Condução da Etapa. (por padrão é Aberto/true)               |
| child_flow_id         | Integer | Não         | Se step_type for flow é necessário informar o id do Fluxo filho     |
| child_flow_version    | Integer | Não         | Se step_type for flow é necessário informar a versão do Fluxo filho |

#### Status HTTP

| Código | Descrição                          |
|--------|------------------------------------|
| 400    | Parâmetros inválidos.              |
| 401    | Acesso não autorizado.             |
| 201    | Se a Etapa foi criada com sucesso. |

#### Exemplo

##### Request
```json
{
  "title": "Título da Etapa",
  "step_type": "flow",
  "conduction_mode_open": false,
  "child_flow_id": 1,
  "child_flow_version": 1,
}
```

##### Response
```
Status: 201
Content-Type: application/json
```

| Nome        | Tipo    | Descrição                              |
|-------------|---------|----------------------------------------|
| stepe       | Object  | Etapa (vide StepObject get /steps/:id) |

```json
{
  "step": {
    "list_versions": null,
    "created_at": "2015-03-03T14:06:58.394-03:00",
    "updated_at": "2015-03-03T14:06:58.394-03:00",
    "permissions": {
      "can_execute_step": [],
      "can_view_step": []
    },
    "version_id": null,
    "active": true,
    "id": 2,
    "title": "Etaoa 2",
    "conduction_mode_open": true,
    "step_type": "form",
    "child_flow": null,
    "my_child_flow": null,
    "fields": [],
    "my_fields": []
  },
  "message": "Etapa criada com sucesso"
}
```
___

### Edição da Etapa <a name="update"></a>

Endpoint: `/flows/:flow_id/steps/:id`

Method: put

#### Parâmetros de Entrada

| Nome                  | Tipo    | Obrigatório | Descrição                                                           |
|-----------------------|---------|-------------|---------------------------------------------------------------------|
| title                 | String  | Sim         | Título da Etapa. (até 100 caracteres)                               |
| step_type             | String  | Sim         | Tipo da Etapa. (Fluxo=flow ou Formulário=form)                      |
| conduction_modeo_open | Boolean | Não         | Modo de Condução da Etapa. (por padrão é Aberto/true)               |
| child_flow_id         | Integer | Não         | Se step_type for flow é necessário informar o id do Fluxo filho     |
| child_flow_version    | Integer | Não         | Se step_type for flow é necessário informar a versão do Fluxo filho |

#### Status HTTP

| Código | Descrição                              |
|--------|----------------------------------------|
| 400    | Parâmetros inválidos.                  |
| 401    | Acesso não autorizado.                 |
| 404    | Etapa não existe.                      |
| 200    | Se a Etapa foi atualizada com sucesso. |

#### Exemplo

##### Request
```json
{
  "title": "Novo Título da Etapa"
}
```

##### Response
```
Status: 200
Content-Type: application/json
```

```json
{
  "message": "Etapa atualizada com sucesso"
}
```
___

### Deleção <a name="delete"></a>

Endpoint: `/flows/:flow_id/steps/:id`

Method: delete

Se houver algum Caso criado para o Fluxo pai da Etapa (pode ver com a opção GET do Fluxo e o atributo "total_cases")
a Etapa não poderá ser apagado e será inativado, caso não possua Casos será excluido fisicamente.

#### Parâmetros de Entrada

Nenhum parâmetro de entrada, apenas o **id** na url.

#### Status HTTP

| Código | Descrição                     |
|--------|-------------------------------|
| 401    | Acesso não autorizado.        |
| 404    | Não existe.                   |
| 200    | Registro apagado com sucesso. |

#### Exemplo

##### Response
```
Status: 200
Content-Type: application/json
```

```json
{
  "message": "Etapa apagada com sucesso"
}
```

___

### Permissão <a name="permission"></a>

Altera permissões de grupos que podem visualizar ou executar a etapa indicada.

Endpoint: `/flows/:flow_id/steps/:id/permissions`

Method: PUT

#### Parâmetros de Entrada

| Nome            | Tipo    | Obrigatório | Descrição                                      |
|-----------------|---------|-------------|------------------------------------------------|
| group_ids       | Array   | Sim         | Array de IDs dos Grupos a seram alterados.     |
| permission_type | String  | Sim         | Tipo de permissão a ser adicionado.            |

#### Tipos de Permissões

| Permissão                 | Parâmetro             | Descrição                                                                         |
|---------------------------|-----------------------|-----------------------------------------------------------------------------------|
| can_execute_step          | ID da Etapa           | Pode visualizar e executar/atualizar uma Etapa do Caso.                           |
| can_view_step             | ID da Etapa           | Pode visualizar uma Etapa do Caso.                                                |

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