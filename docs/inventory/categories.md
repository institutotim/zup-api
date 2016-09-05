# API - Inventário/Categorias

## Criando uma categoria de inventário

__URI__ `POST /inventory/categories`

__ATENCÃO: O post para esse endpoint deve ser no formado de
form/multipart para fazer o upload dos arquivos corretamente.
Não enviar como JSON neste caso.__

Exemplo de requisição:

    {
      "title": "árvores",
      "description: "árvores da cidade",
      "plot_format": "pin",
      "icon": (uploaded_file),
      "marker": (uploaded_file)
    }

Exemplo de resposta:

    {
      "category" : {
        "id" : 3,
        "title" : "Árvores",
        "plot_format": "pin",
        "description" : "Árvores da cidade,
        "created_at" : "2014-01-12T00:51:47.319-02:00",
        "updated_at" : "2014-01-12T00:51:47.319-02:00"
      },
      "message" : "Category created with success"
    }

### Icons, pins, markers

Uma categoria de inventário pode ter icons, pins e markers, vamos explicar a diferença entre esses campos.

Essas imagens devem ser o pictograma branco que vai entrar dentro de `icon` e `markers`. Esse pictograma que você enviar será inserido dentro de outras imagens coloridas com a cor da categoria.

São geradas várias versões para cada uma delas, então o campo de retorno sempre vai ser um objeto com as diversas versões.

* `icon` - é o ícone da categoria, aparece nos filtros
* `pins` - é a bolinha que aparece no mapa sem nenhum ícone dentro, essa imagem é gerada automaticamente então você pode enviar qualquer imagem
* `markers` - é o marcador que aparece no mapa, com o ícone branco que você enviou nesse campo.

Resumindo, ao criar a categoria você envia somente o ícone branco com fundo transparente que será inserido nas outras imagens de base.

No retorno, você receberá as várias versões geradas para imagem.

__Atenção: Essas imagens devem ser encodadas e enviadas somente em base64.__

## Alterando uma categoria

__URI__ `PUT /inventory/categories/:id`

Exemplo de requisição:

    {
      "title": "Árvores",
      "description: "Árvores da cidade",
      "token": "e40678fa7cb48f9fa3a734d202f10b88"
    }

Exemplo de resposta:

    {
      "category" : {
        "id" : 3,
        "title" : "Árvores",
        "plot_format": "pin",
        "description" : "Árvores da cidade,
        "created_at" : "2014-01-12T00:51:47.319-02:00",
        "updated_at" : "2014-01-12T00:51:47.319-02:00"
      },
      "message" : "Category updated successfully"
    }

## Deletando uma categoria

__URI__ `DELETE /inventory/categories/:id`

Exemplo de resposta:

    {
      "message": "Category deleted successfully"
    }

## Obtendo dado de uma categoria

__URI__ `GET /inventory/categories/1`

Exemplo de resposta:

    {
        "category": {
            "id": 1,
            "title": "Random name 1",
            "description": "A cool category",
            "plot_format": "pin",
            "marker": {
                "retina": {
                    "web": "/uploads/inventory/category/1/markers/retina_web_valid_report_category_marker.png",
                    "mobile": "/uploads/inventory/category/1/markers/retina_mobile_valid_report_category_marker.png"
                },
                "default": {
                    "web": "/uploads/inventory/category/1/markers/default_web_valid_report_category_marker.png",
                    "mobile": "/uploads/inventory/category/1/markers/default_mobile_valid_report_category_marker.png"
                }
            },
            "icon": {
                "retina": {
                    "web": {
                        "active": "/uploads/inventory/category/1/icons/retina_web_active_valid_report_category_icon.png",
                        "disabled": "/uploads/inventory/category/1/icons/retina_web_disabled_valid_report_category_icon.png"
                    },
                    "mobile": {
                        "active": "/uploads/inventory/category/1/icons/retina_mobile_active_valid_report_category_icon.png",
                        "disabled": "/uploads/inventory/category/1/icons/retina_mobile_disabled_valid_report_category_icon.png"
                    }
                },
                "default": {
                    "web": {
                        "active": "/uploads/inventory/category/1/icons/default_web_active_valid_report_category_icon.png",
                        "disabled": "/uploads/inventory/category/1/icons/default_web_disabled_valid_report_category_icon.png"
                    },
                    "mobile": {
                        "active": "/uploads/inventory/category/1/icons/default_mobile_active_valid_report_category_icon.png",
                        "disabled": "/uploads/inventory/category/1/icons/default_mobile_disabled_valid_report_category_icon.png"
                    }
                }
            }
        }
    }

Você pode opter mais campos passando o parâmetro `display_type` como `full`
na requisição:

`GET /inventory/categories/2?display_type=full`

Exemplo de resposta:

{
  "sections" : [
    {
      "fields" : [
        {
          "position" : 0,
          "id" : 101,
          "title" : "latitude",
          "label" : "Latitude",
          "kind" : "text"
        },
        ...
      ],
      "id" : 11
    },
    ...
  ],
  "id" : 2,
  "created_at" : "2014-01-11T16:08:57.769-02:00",
  "title" : "Random name 2",
  "description" : "A cool category",
  "updated_at" : "2014-01-11T16:08:57.769-02:00"
}


## Listando categorias

__URI__ `GET /inventory/categories`

Exemplo de resposta:

    {
      "categories" : [
        {
          "id" : 2,
          "title" : "Random name 2",
          "plot_format": "pin",
          "description" : "A cool category",
          "created_at" : "2014-01-11T16:08:57.769-02:00",
          "updated_at" : "2014-01-11T16:08:57.769-02:00"
        },
        {
          "id" : 3,
          "title" : "Cool group",
          "plot_format": "pin",
          "description" : null,
          "created_at" : "2014-01-12T00:51:47.319-02:00",
          "updated_at" : "2014-01-12T00:51:47.319-02:00"
        }
      ]
    }

### Com parâmetros

Para efetuar uma busca pelo título da categoria, apenas
envie um parâmetro "title" na requisição.

__URI__ `GET /inventory/categories`

Exemplo de requisição:

    {
      "title": "Cool"
    }

Exemplo de resposta:

    {
      "categories" : [
        {
          "id" : 2,
          "created_at" : "2014-01-11T16:08:57.769-02:00",
          "title" : "Random name 2",
          "description" : "A cool category",
          "plot_format": "pin",
          "updated_at" : "2014-01-11T16:08:57.769-02:00"
        },
        {
          "id" : 3,
          "created_at" : "2014-01-12T00:51:47.319-02:00",
          "title" : "Cool group",
          "description" : null,
          "plot_format": "pin",
          "updated_at" : "2014-01-12T00:51:47.319-02:00"
        }
      ]
    }

### Paginação

Você pode efetuar a paginação na listagem com os seguintes parâmetros (ambos opcionais):

{
  "per_page": 10,
  "page": 2
}

O parâmetro `per_page` é `25` por padrão.

## Criando/atualizando formulário

*Observação:* Por padrão, todas as categorias já vem com a seção "Localização" por padrão.

__URI__ `PUT /inventory/categories/:id/form`

O único parâmetro necessário é o `sections`, que deve ser um array de todas as seções com seus respectivos campos. Seguir a estrutura do exemplo abaixo.

Exemplo de requisição:

    {
      "sections": [{
        "title": "Localização",
        "permissions": {},
        "position": 0,
        "fields": [{
          "title": "latitude",
          "kind": "text",
          "size": "M",
          "permissions": {},
          "label": "Latitude",
          "position": 0
        }]
      }
    }

Exemplo de resposta:

    {
      "message": "Category's form updated successfully"
    }

### Tipos especiais de campos

#### Imagens

Passando um campo como `kind` igual a `images`, o conteúdo (`content`) atribuído para
este campo deve ser no formato de array com as imagens encodadas em Base64.

Exemplo de campo do tipo `images`:

    {
      ...
      "fields": [{
        "title": "imagens",
        "kind": "images",
        "permissions": {},
        "label": "Imagens",
        "position": 0
      }]
      ...
    }


Ao criar um item para este campo, o atributo `content` deve ser um array de
imagens encodadas.

### Deletando seção ou campo do formulário

Para deletar uma seção ou campo, apenas mande um atributo `destroy` no
seu JSON, exemplo:

    // Essa seção será destruída
    // Você pode fazer a mesma coisa dentro de "fields"
    {
      "sections": [{
        "id": 1234,
        "destroy": true,
        "title": "Localização",
        "permissions": {},
        "position": 0,
        "fields": [{
          "title": "latitude",
          "kind": "text",
          "size": "M",
          "permissions": {},
          "label": "Latitude",
          "position": 0
        }]
      }
    }

## 'Lock' na edição do formulário da categoria

Para travar a edição do formulário da categoria, você deve fazer um request para o seguinte endpoint:

`PATCH /inventory/categories/:id/update_access`

Após 1 minuto, a categoria será destravada automaticamente se não for mais recebido esse `heartbeat`, dessa forma, faça o request com uma frequência menor que 60 segundos.
