# Itens de Inventário

## Criando um item de inventário

`POST /inventory/categories/:id/items`

A criação de um item de inventário é feito com parâmetros dinâmicos, seguir a estrutura do exemplo de requisição abaixo.

Suponhamos que temos uma __Categoria de Inventário__ com a seguinte estrutura:

`GET /inventory/categories/1/form`

    {
      "id": 1,
      "title": "Praças",
      "description: "Praças da cidade."
      "sections": [{
        "title": "Nome da praça",
        "permissions": {},
        "position": 0,
        "fields": [{
          "id": 6,
          "title": "nome",
          "kind": "text",
          "size": "M",
          "permissions": {},
          "label": "Nome",
          "position": 0
        }]
      }]
    }

Para criar um item para esta categoria, um exemplo de requisição válida seria:

`POST /inventory/categories/1/items`

    {
      "data": {
        "6": "Praça São Jorge"
      ]
    }

Onde `"6"` é o id do campo (`inventory_field`) e `"Praça São Jorge"`
é o conteúdo daquele campo.

Um exemplo de resposta

    {
      "message" : "Item created successfully",
      "item" : {
        "id" : 2,
        "data" : [
          {
            "content" : "Praça São Jorge",
            "field" : {
              "required" : false,
              "position" : 0,
              "id" : 102,
              "created_at" : "2014-01-12T16:36:35.265-02:00",
              "title" : "nome",
              "size" : null,
              "inventory_section_id" : 12,
              "kind" : "text",
              "options" : {
                "size" : "M",
                "label" : "Nome"
              },
              "permissions" : {},
              "updated_at" : "2014-01-12T16:36:35.265-02:00"
            }
          }
        ]
      }
    }

## Campos com escolhas (kind igual a `checkbox`, `select` e `radio`)

Para campos onde o usuário tem que escolher dentre uma lista de opções (veja `docs/inventory/field_options.md),
o `content` deve ser o id das opções que deseja escolher:

    {
      "data": {
        "1": [12, 32]
      }
    }

Onde `12` e `32` são os ids das opções que deseja selecionar para o campo.

## Campos com `kind` igual `images`

Para campos do tipo `images`, um exemplo de requisição seria:

    {
      "data": [
        {
          "content": "imagem-encodada-aqui"
        }
      ]
    }

Você deve passar um __array__ com as imagens encodadas em base64.

### Removendo uma imagem

Para remover uma imagem, você precisa passar um atributo `destroy` como `true`
no array, assim como o 'id´ da imagem (retornada na listagem do item)

{
  "data": [
    {
      "id": "123132",
      "destroy": true
    }
  ]
}

Você pode remover e adicinoar imagens em uma única requisição.

## Alterando item

Para alterar um item de inventário, utilizar o seguinte endpoint:

__URI__ `PUT /inventory/categories/:id/items/:id`

Exemplo de requisição:

`PUT /inventory/categories/2items/1`

    {
      "data": {
        "6": "Praça São Jorge"
      }
    }

Resposta:

    {
      "message" : "Item created successfully",
      "item" : {
        "id" : 2,
        "data" : [
          {
            "content" : "Praça São Jorge",
            "field" : {
              "required" : false,
              "position" : 0,
              "id" : 102,
              "created_at" : "2014-01-12T16:36:35.265-02:00",
              "title" : "nome",
              "size" : null,
              "inventory_section_id" : 12,
              "kind" : "text",
              "options" : {
                "size" : "M",
                "label" : "Nome"
              },
              "permissions" : {},
              "updated_at" : "2014-01-12T16:36:35.265-02:00"
            }
          }
        ]
      }
    }

## Consultando itens de inventário

Você pode listar os itens de inventário de duas formas:
* Apenas listando os itens, sem categorias, para isso basta não passar parâmetros
* Filtrando por conteúdo de campo específico (quando buscando por categoria)

__URI__ `GET /inventory/items`

Exemplo de parâmetros para a requisição:

    {
      "filters": [{
        "field_id": 1,
        "content": "Árvor"
      }],
      "inventory_category_id": 2
    }

Exemplo de resposta:

    {
      "items": [{
        "id" : 2,
        "data" : [{
          "content" : "Árvore da Praça",
          "field" : {
            "required" : false,
            "position" : 0,
            "id" : 102,
            "created_at" : "2014-01-12T16:36:35.265-02:00",
            "title" : "nome",
            "size" : null,
            "inventory_section_id" : 12,
            "kind" : "text",
            "options" : {
              "size" : "M",
              "label" : "Nome"
            },
            "permissions" : {},
            "updated_at" : "2014-01-12T16:36:35.265-02:00"
          }
        }]
      }]
    }


## Consultando um item de inventário

Você pode exibir as informações de um item de inventário passando o parâmetro
o `id` da categoria e o `id` do item desejado para o seguinte endpoint:

__URI__ `GET /inventory/categories/{category_id}/items/{item_id}`

Exemplo de parâmetros para a requisição:

    /inventory/categories/1/items/1

Exemplo de resposta:

    {
       "item":{
          "id":1,
          "position":{
             "latitude":38.9381545320739,
             "longitude":-73.9212453413708
          },
          "inventory_category_id":1,
          "data":[
             {
                "inventory_field_id":24,
                "content":"Random name 37"
             },
             {
                "inventory_field_id":23,
                "content":"Random name 38"
             },
             {
                "inventory_field_id":22,
                "content":"Random name 39"
             },
             {
                "inventory_field_id":21,
                "content":"Random name 40"
             },
             {
                "inventory_field_id":20,
                "content":"Random name 41"
             }
          ]
       }
    }



### Filtrando por posição geográfica

Você pode inserir filtros geográficos na sua consulta, basta passar a coordenada
do centro da tela do usuário, e uma distância em metros para raio ao redor desta
localização. Utilize o parâmetro `max_items` para controlar o número de itens
retornados.

As informações relacionadas aos campos (presentes em `data`) devem ser buscadas
na listagem da categoria de inventário indicada por `category_id`.

**Atenção**: Esta implementação será atualizada assim que possível para incluir
melhor controle de tela e distribuição de pontos, acompanhe nas issues:

https://ntxdev.atlassian.net/browse/ZUPAPI-81

https://ntxdev.atlassian.net/browse/ZUPAPI-78

__URI__ `GET /inventory/items`

__Query string:__

    ?position[latitude]=40.86            Latitude do ponto de origem
    &position[longitude]=-122.03         Longitude do ponto de origem
    &position[distance]=10000            Radio em metros
    &limit=40
    &zoom=18                             O zoom reportado pelo Google Maps


_Nota_: O parâmetro `distance` deve ser expresso em metros.

O parâmetro `limit` define o limite de objetos que serão retornados para
ser plotado no mapa.

    {
        "items": [
            {
                "id": 42,
                "position": {
                    "latitude": 40.8377346033077,
                    "longitude": -122.078250641083
                },
                "inventory_category_id": 2,
                "data": [
                    {
                        "inventory_field_id": 48,
                        "content": "Random name 1021"
                    },
                    {
                        "inventory_field_id": 47,
                        "content": "Random name 1022"
                    },
                    {
                        "inventory_field_id": 46,
                        "content": "Random name 1023"
                    },
                    {
                        "inventory_field_id": 45,
                        "content": "Random name 1024"
                    }
                ]
            },
            {
               "id":43,
               "position":{
                  "latitude":41.8377346033077,
                  "longitude":-102.078250641083
               },
               "inventory_category_id":2,
               "data":[
                  {
                     "inventory_field_id":48,
                     "content":"Random name 1021"
                  },
                  {
                     "inventory_field_id":47,
                     "content":"Random name 1022"
                  },
                  {
                     "inventory_field_id":46,
                     "content":"Random name 1023"
                  },
                  {
                     "inventory_field_id":45,
                     "content":"Random name 1024"
                  }
               ]
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


#### Exibindo o item na forma compacta

Para exibir a listagem de itens sem a informação de `data`, basta passar o seguinte parâmetro: `display_type` como `basic` na requisição

__Query string:__

    ?display_type=basic

## 'Lock' na edição do item de inventário

Para travar a edição do item de inventário, você deve fazer um request para o seguinte endpoint:

`PATCH /inventory/categories/:category_id/items/:id/update_access`

Após 1 minuto, o item será destravado automaticamente se não for mais recebido esse `heartbeat`, dessa forma, faça o request com uma frequência menor que 60 segundos.
