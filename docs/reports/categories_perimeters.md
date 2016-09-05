# Perímetros da Categoria de Relatos

## Adicionado um perímetro na categoria

__URI__ `POST /reports/categories/{category_id}/perimeters`

### Parâmetros de entrada

| Nome         | Tipo    | Obrigatório | Descrição                   |
|--------------|---------|-------------|--------------------------------------------|
| category_id  | Integer | Sim         | O id da categoria de relato |
| group_id     | Integer | Sim         | O id do grupo solucionador  |
| perimeter_id | Integer | Sim         | O id do perímetro           |
| active       | Boolean | Não         | Define se o perímetro esta ativo ou inativo|
| priority     | Integer | Não         | Prioridade do perímetro                    |

Exemplo de requisição:

`POST /reports/categories/1/perimeters`

    {
      "group_id": 1001,
      "perimeter_id": 1000
    }

Exemplo de resposta:

    {
      "perimeter": {
        "id": 1000,
        "active": true,
        "priority": 0,
        "category": {
          "id": 1000,
          "title": "Grupo"
        },
        "perimeter": {
          "id": 1000,
          "title": "Grupo",
          "status": "pendent"
        },
        "group": {
          "id": 1000,
          "name": "Grupo"
        },
        "created_at": "2014-02-10T13:14:49.519-02:00",
        "updated_at": "2014-02-10T13:14:49.519-02:00"
      }
    }

## Alterando um perímetro da categoria

__URI__ `PUT /reports/categories/{category_id}/perimeters/{id}`

### Parâmetros de entrada

| Nome         | Tipo    | Obrigatório | Descrição                                  |
|--------------|---------|-------------|--------------------------------------------|
| group_id     | Integer | Sim         | O id do grupo solucionador                 |
| perimeter_id | Integer | Sim         | O id do perímetro                          |
| active       | Boolean | Não         | Define se o perímetro esta ativo ou inativo|
| priority     | Integer | Não         | Prioridade do perímetro                    |

Exemplo de requisição:

`PUT /reports/categories/{category_id}/perimeters/1`

    {
      "group_id": 1002,
      "perimeter_id": 1001
    }

Exemplo de resposta:

    {
      "perimeter": {
        "id": 1,
        "active": true,
        "priority": 0,
        "category": {
          "id": 1000,
          "title": "Grupo"
        },
        "perimeter": {
          "id": 1001,
          "title": "Grupo",
          "status": "pendent"
        },
        "group": {
          "id": 1002,
          "name": "Grupo"
        },
        "created_at": "2014-02-10T13:14:49.519-02:00",
        "updated_at": "2014-02-10T13:14:49.519-02:00"
      }
    }

## Removendo um perímetro da categoria

__URI__ `DELETE /reports/categories/{category_id}/perimeters/{id}`

## Consultando um perímetro

__URI__ `GET /reports/categories/{category_id}/perimeters/{id}`

Exemplo de requisição:

`GET /reports/categories/{category_id}/perimeters/1`

Exemplo de resposta:

    {
      "perimeter": {
        "id": 1,
        "active": true,
        "priority": 0,
        "category": {
          "id": 1000,
          "title": "Grupo"
        },
        "perimeter": {
          "id": 1000,
          "title": "Grupo",
          "status": "pendent"
        },
        "group": {
          "id": 1000,
          "name": "Grupo"
        },
        "created_at": "2014-02-10T13:14:49.519-02:00",
        "updated_at": "2014-02-10T13:14:49.519-02:00"
      }
    }

## Listando perímetros da categoria

__URI__ `GET /reports/categories/{category_id}/perimeters/`

Exemplo de parâmetros para a requisição:

`GET /reports/categories/{category_id}/perimeters/`

Exemplo de resposta:

    {
      "perimeters": [
        {
          "id": 1,
          "active": true,
          "priority": 0,
          "category": {
            "id": 1000,
            "title": "Grupo"
          },
          "perimeter": {
            "id": 1000,
            "title": "Grupo",
            "status": "pendent"
          },
          "group": {
            "id": 1000,
            "name": "Grupo"
          },
          "created_at": "2014-02-10T13:14:49.519-02:00"
          "updated_at": "2014-02-10T13:14:49.519-02:00"
        },
        ...
      ]
    }
