# Relatos

## Criando um item de relato

__URI__ `POST /reports/:category_id/items`

### Parâmetros de entrada

| Nome              | Tipo    | Obrigatório | Descrição                                                                       |
|-------------------|---------|-------------|---------------------------------------------------------------------------------|
| category_id       | Integer | Sim         | O id da categoria de relato                                                     |
| inventory_item_id | Integer | Não         | O id do item de inventário                                                      |
| latitude          | String  | Não         | Latitude do relato. Irá usar do inventário se não for preenchido.               |
| longitude         | String  | Não         | Longitude do relato. Irá usar do inventário se não for preenchido.              |
| description       | String  | Não         | Descrição do relato                                                             |
| address           | String  | Não         | Endereço completo do relato                                                     |
| reference         | String  | Não         | Referência do endereço                                                          |
| number            | String  | Não         | Número do endereço                                                              |
| district          | String  | Não         | Bairro do relato                                                                |
| city              | String  | Não         | Cidade do relato                                                                |
| state             | String  | Não         | Estado do relato                                                                |
| country           | String  | Não         | País do relato                                                                  |
| images            | Array   | Não         | Um array de imagens, encodadas em base64, para esse relato.                     |
| status_id         | Integer | Não         | O status do relato, irá utilizar o status inicial padrão da categoria de relato |
| user_id           | Integer | Não         | Para associar um usuário com o relato                                           |
| confidential      | Boolean | Não         | Se o relato é confidencial (não é visível para os munícipes)                    |
| from_panel        | Boolean | Não         |                                                                                 |

Exemplo de requisição:

`POST /reports/1/items`

    {
      "latitude": "-23.5734740",
      "longitude": "-46.6431520",
      "address": "Rua Abilio Soares, 140",
      "description": "Situação ruim",
      "reference": "Próximo ao Posto de Saúde"
    }

Exemplo de resposta:

    {
        "report": {
            "id": 1824,
            "protocol": 1824000014649690,
            "address": "Rua Abilio Soares, 140",
            "position": {
                "latitude": -23.573474,
                "longitude": -46.643152
            },
            "description": null,
            "category_icon": {
                "url": "/uploads/reports/category/1/icons/valid_report_category_icon.png",
                "retina": {
                    "url": "/uploads/reports/category/1/icons/retina_valid_report_category_icon.png"
                },
                "default": {
                    "url": "/uploads/reports/category/1/icons/default_valid_report_category_icon.png"
                }
            },
            "inventory_categories": [],
            "images": [],
            "status": {
                "id": 2,
                "title": "Initial status",
                "color": "#ff0000",
                "initial": true,
                "final": false
            },
            "category": {
                "id": 1,
                "title": "Limpeza de Boca",
                "icon": {
                    "retina": {
                        "web": {
                            "active": "/uploads/reports/category/1/icons/retina_web_active_valid_report_category_icon.png",
                            "disabled": "/uploads/reports/category/1/icons/retina_web_disabled_valid_report_category_icon.png"
                        },
                        "mobile": {
                            "active": "/uploads/reports/category/1/icons/retina_mobile_active_valid_report_category_icon.png",
                            "disabled": "/uploads/reports/category/1/icons/retina_mobile_disabled_valid_report_category_icon.png"
                        }
                    },
                    "default": {
                        "web": {
                            "active": "/uploads/reports/category/1/icons/default_web_active_valid_report_category_icon.png",
                            "disabled": "/uploads/reports/category/1/icons/default_web_disabled_valid_report_category_icon.png"
                        },
                        "mobile": {
                            "active": "/uploads/reports/category/1/icons/default_mobile_active_valid_report_category_icon.png",
                            "disabled": "/uploads/reports/category/1/icons/default_mobile_disabled_valid_report_category_icon.png"
                        }
                    }
                },
                "marker": {
                    "retina": {
                        "web": "/uploads/reports/category/1/markers/retina_web_valid_report_category_marker.png",
                        "mobile": "/uploads/reports/category/1/markers/retina_mobile_valid_report_category_marker.png"
                    },
                    "default": {
                        "web": "/uploads/reports/category/1/markers/default_web_valid_report_category_marker.png",
                        "mobile": "/uploads/reports/category/1/markers/default_mobile_valid_report_category_marker.png"
                    }
                },
                "color": "#f3f3f3",
                "resolution_time": null,
                "user_response_time": null,
                "allows_arbitrary_position": false,
                "statuses": [
                    {
                        "id": 1,
                        "title": "Random status 1",
                        "color": "#ff0000",
                        "initial": false,
                        "final": false
                    },
                    {
                        "id": 2,
                        "title": "Initial status",
                        "color": "#ff0000",
                        "initial": true,
                        "final": false
                    },
                    {
                        "id": 3,
                        "title": "Final status",
                        "color": "#ff0000",
                        "initial": false,
                        "final": true
                    }
                ]
            },
            "user": {
                "id": 70,
                "name": "Hans Ratke",
                "email": "harmon_keeling@mcglynn.ca",
                "phone": "11912231545",
                "document": "55330938180",
                "address": "491 Jakubowski Harbor",
                "address_additional": "Suite 345",
                "postal_code": "04005000",
                "district": "Maciburgh",
                "created_at": "2014-02-10T13:14:49.519-02:00"
            },
            "inventory_item": null,
            "created_at": "2014-02-21T16:36:03.215-03:00",
            "updated_at": "2014-02-21T16:36:03.215-03:00"
        }
    }

### Especificando o usuário na criação do relato

Para especificar o usuário na criação do relato, utilize-se do parâmetro `user_id` na requisição:

    {
      ...
      'user_id': 123
    }

## Alterando um relato

__URI__ `PUT /reports/:category_id/items/:id`

### Parâmetros de entrada

| Nome              | Tipo    | Obrigatório | Descrição                                                                       |
|-------------------|---------|-------------|---------------------------------------------------------------------------------|
| category_id       | Integer | Sim         | O id da categoria de relato                                                     |
| inventory_item_id | Integer | Não         | O id do item de inventário                                                      |
| latitude          | String  | Não         | Latitude do relato. Irá usar do inventário se não for preenchido.               |
| longitude         | String  | Não         | Longitude do relato. Irá usar do inventário se não for preenchido.              |
| description       | String  | Não         | Descrição do relato                                                             |
| address           | String  | Não         | Endereço completo do relato                                                     |
| reference         | String  | Não         | Referência do endereço                                                          |
| number            | String  | Não         | Número do endereço                                                              |
| district          | String  | Não         | Bairro do relato                                                                |
| city              | String  | Não         | Cidade do relato                                                                |
| state             | String  | Não         | Estado do relato                                                                |
| country           | String  | Não         | País do relato                                                                  |
| images            | Array   | Não         | Um array de imagens, encodadas em base64, para esse relato.                     |
| status_id         | Integer | Não         | O status do relato, irá utilizar o status inicial padrão da categoria de relato |
| user_id           | Integer | Não         | Para associar um usuário com o relato                                           |
| confidential      | Boolean | Não         | Se o relato é confidencial (não é visível para os munícipes)                    |

Exemplo de requisição:

    {
      "description": "Árvore caiu aqui na rua",
    }

Exemplo de resposta:

    {
        "report": {
            "id": 1824,
            "protocol": 1824000014649690,
            "address": "Rua Abilio Soares, 140",
            "position": {
                "latitude": -23.573474,
                "longitude": -46.643152
            },
            "description": "Árvore caiu aqui na rua",
            "category_icon": {
                "url": "/uploads/reports/category/1/icons/valid_report_category_icon.png",
                "retina": {
                    "url": "/uploads/reports/category/1/icons/retina_valid_report_category_icon.png"
                },
                "default": {
                    "url": "/uploads/reports/category/1/icons/default_valid_report_category_icon.png"
                }
            },
            "inventory_categories": [],
            "images": [],
            "status": {
                "id": 2,
                "title": "Initial status",
                "color": "#ff0000",
                "initial": true,
                "final": false
            },
            "category": {
                "id": 1,
                "title": "Limpeza de Boca",
                "icon": {
                    "retina": {
                        "web": {
                            "active": "/uploads/reports/category/1/icons/retina_web_active_valid_report_category_icon.png",
                            "disabled": "/uploads/reports/category/1/icons/retina_web_disabled_valid_report_category_icon.png"
                        },
                        "mobile": {
                            "active": "/uploads/reports/category/1/icons/retina_mobile_active_valid_report_category_icon.png",
                            "disabled": "/uploads/reports/category/1/icons/retina_mobile_disabled_valid_report_category_icon.png"
                        }
                    },
                    "default": {
                        "web": {
                            "active": "/uploads/reports/category/1/icons/default_web_active_valid_report_category_icon.png",
                            "disabled": "/uploads/reports/category/1/icons/default_web_disabled_valid_report_category_icon.png"
                        },
                        "mobile": {
                            "active": "/uploads/reports/category/1/icons/default_mobile_active_valid_report_category_icon.png",
                            "disabled": "/uploads/reports/category/1/icons/default_mobile_disabled_valid_report_category_icon.png"
                        }
                    }
                },
                "marker": {
                    "retina": {
                        "web": "/uploads/reports/category/1/markers/retina_web_valid_report_category_marker.png",
                        "mobile": "/uploads/reports/category/1/markers/retina_mobile_valid_report_category_marker.png"
                    },
                    "default": {
                        "web": "/uploads/reports/category/1/markers/default_web_valid_report_category_marker.png",
                        "mobile": "/uploads/reports/category/1/markers/default_mobile_valid_report_category_marker.png"
                    }
                },
                "color": "#f3f3f3",
                "resolution_time": null,
                "user_response_time": null,
                "allows_arbitrary_position": false,
                "statuses": [
                    {
                        "id": 1,
                        "title": "Random status 1",
                        "color": "#ff0000",
                        "initial": false,
                        "final": false
                    },
                    {
                        "id": 2,
                        "title": "Initial status",
                        "color": "#ff0000",
                        "initial": true,
                        "final": false
                    },
                    {
                        "id": 3,
                        "title": "Final status",
                        "color": "#ff0000",
                        "initial": false,
                        "final": true
                    }
                ]
            },
            "user": {
                "id": 70,
                "name": "Hans Ratke",
                "email": "harmon_keeling@mcglynn.ca",
                "phone": "11912231545",
                "document": "55330938180",
                "address": "491 Jakubowski Harbor",
                "address_additional": "Suite 345",
                "postal_code": "04005000",
                "district": "Maciburgh",
                "created_at": "2014-02-10T13:14:49.519-02:00"
            },
            "inventory_item": null,
            "created_at": "2014-02-21T16:36:03.215-03:00",
            "updated_at": "2014-02-21T16:39:58.995-03:00"
        }
    }

### Atualizando uma imagem do relatório

Para atualizar uma imagem do relatório você pode passar o parâmetro `images`
no corpo da requisição no seguinte formato:

    {
      "images": [{
        "id": 1,
        "file": "imagem encodada em base64 aqui"
      }]
    }

**Lembrando que desse modo a imagem precisa ser encodada em Base64 para
a alteração ser feita.**

### Atualizando status do relatório

Para atualizar o status de um item de relato, você deve passar o atributo
`status_id` na requisição:

    {
      "status_id": 1
    }

O id do status deve pertencer à categoria de relato que o item pertence
e deve ser um status válido.

## Removendo um relato

Para remover um relato permanentemente, só necessita fazer uma requisição em:

__URI__ `DELETE /reports/items/:id`


## Consultando um item de relato

Você pode exibir as informações de um item de relato passando o parâmetro
`id` do item desejado para o seguinte endpoint:

__URI__ `GET /reports/items/{item_id}`

Exemplo de parâmetros para a requisição:

    /reports/items/1

Exemplo de resposta:

    {
        "report": {
            "id": 1,
            "protocol": null,
            "address": "Some random thing, 20",
            "position": {
                "latitude": -13.12427698396538,
                "longitude": -21.385812899349485
            },
            "description": null,
            "images": [],
            "status": {
                "id": 1,
                "title": "Test",
                "color": "#FFFFFF",
                "initial": true,
                "final": false
            },
            "category": {
                "id": 1,
                "title": "Teste",
                "icon": {
                    "url": "/uploads/map_pin_boca-lobo.png"
                },
                "marker": {
                    "url": "/uploads/map_pin_boca-lobo.png"
                },
                "resolution_time": 13,
                "user_response_time": null,
                "allows_arbitrary_position": false,
                "statuses": [
                    {
                        "id": 2,
                        "title": "Test 2",
                        "color": "#FF0000",
                        "initial": false,
                        "final": true
                    },
                    {
                        "id": 1,
                        "title": "Test",
                        "color": "#FFFFFF",
                        "initial": true,
                        "final": false
                    }
                ]
            },
            "user": {
                "id": 1,
                "name": null,
                "email": "teste@gmail.com",
                "phone": null,
                "document": null,
                "address": null,
                "address_additional": null,
                "postal_code": null,
                "district": null,
                "created_at": "2014-01-12T19:20:29.863-02:00",
                "groups": [
                    {
                        "id": 1,
                        "name": "Administradores",
                        "permissions": {
                            "add_users": "true"
                        },
                        "created_at": "2014-01-26T08:19:30.495-02:00",
                        "updated_at": "2014-01-26T08:19:30.495-02:00"
                    }
                ]
            },
            "inventory_item": null,
            "created_at": "2014-01-12T19:21:59.325-02:00",
            "updated_at": "2014-01-25T21:42:03.942-02:00"
        }
    }



### Consultando itens de relato por posição geográfica

Você pode listar itens de relatos geograficamente, para isso basta passar a coordenada
do centro da tela do usuário, e uma distância em metros para raio ao redor desta
localização. Utilize o parâmetro `limit` para controlar o número de itens
retornados.

As informações relacionadas aos status devem ser buscadas na listagem da categoria de
relato indicada por `category_id`.

**Atenção**: Esta implementação será atualizada assim que possível para incluir
melhor controle de tela e distribuição de pontos, acompanhe nas issues:

https://ntxdev.atlassian.net/browse/ZUPAPI-81

https://ntxdev.atlassian.net/browse/ZUPAPI-78

__URI__ `GET /reports/items`

__Query string:__

    ?position[latitude]=40.86            Latitude do ponto de origem
    &position[longitude]=-122.03         Longitude do ponto de origem
    &position[distance]=10000            Radio em metros
    &limit=40
    &zoom=18                             O zoom reportado pelo Google Maps

_Nota_: O parâmetro `distance` deve ser expresso em metros.

O parâmetro `limit` define o limite de objetos que serão retornados para
ser plotado no mapa.

Exemplo de resposta:

    {
        "reports": [
            {
                "id": 171,
                "protocol": 1710000196684042,
                "address": "Some street",
                "position": {
                    "latitude": -5.9764499019623365,
                    "longitude": -18.572619292478098
                },
                "description": null,
                "images": [],
                "status_id": 1,
                "category_id": 1,
                "inventory_item_id": null,
                "created_at": "2014-01-25T23:37:05.218-02:00",
                "updated_at": "2014-01-25T23:37:05.218-02:00"
            },
            {
                "id": 197184,
                "protocol": 1971840000136235,
                "address": "Some street",
                "position": {
                    "latitude": -6.0398746758553585,
                    "longitude": -18.431211356027262
                },
                "description": null,
                "images": [],
                "status_id": 1,
                "category_id": 1,
                "inventory_item_id": null,
                "created_at": "2014-01-26T04:10:13.882-02:00",
                "updated_at": "2014-01-26T04:10:13.882-02:00"
            }
        ]
    }

#### Busca por múltiplas posições

Você efetuar buscas utilizando múltiplos pontos para busca, passando a query string assim:

__Query string:__

    ?position[0][latitude]=40.86            Latitude do ponto de origem
    &position[0][longitude]=-122.03         Longitude do ponto de origem
    &position[0][distance]=10000            Radio em metros
    &position[1][latitude]=40.86
    &position[1][longitude]=-122.03
    &position[1][distance]=10000

    &limit=40
    &zoom=18                             O zoom reportado pelo Google Maps

### Listando relatos de uma categoria de relato

Para listar os relatos de uma categoria de relato, utilizar o seguinte endpoint:

```
GET /reports/{category_id}/items
```

O retorno é o mesmo dos outros endpoints de listagem.

### Listando relatos de um usuário em específico

Para listar os relatos de um usuário em específico, você deve utilizar o seguinte endpoint:

```
GET /users/{user_id}/items
```

O retorno é o mesmo dos outros endpoints de listagem.

### Criando um relato sigiloso

Para um relato ser marcado como sigiloso, nos endpoints de criação e atualização de um item de relato, você pode passar o parâmetro `confidential` com `true` para torná-lo sigiloso.

__URI__ `POST /reports/:category_id/items`

    {
      ...
      "confidential": true
    }

## Migrando um relato de categoria

Para alterar um relato de categoria, basta utilizar o seguinte endpoint:

__URI__ `PUT /reports/:category_id/items/:id/change_category`

E passar os seguintes parâmetros:

    {
      "new_category_id": 2,
      "new_status_id": 3
    }

* `new_category_id` é o id da nova categoria do item
* `new_status_id` é o id do novo status (já da nova categoria) que o item deve ser transferido para
