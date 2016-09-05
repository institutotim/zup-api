# Perímetros

## Criando um perímetro

__URI__ `POST /reports/perimeters`

### Parâmetros de entrada

| Nome            | Tipo    | Obrigatório | Descrição                                                                   |
|-----------------|---------|-------------|-----------------------------------------------------------------------------|
| title           | Integer | Sim         | O título do perímetro                                                       |
| shp_file        | Hash    | Sim         | Arquivo .shp que armazena as informações do perímetro. Codificado em base64 |
| shx_file        | Hash    | Sim         | Arquivo .shx que armazena os indices do perímetro. Codificado em base64     |
| solver_group_id | Integer | Não         | Grupo solucionador padrão para o perímetro                                  |
| active          | Boolean | Não         | Define se o perímetro esta ativo ou inativo                                 |
| priority        | Integer | Não         | Prioridade do perímetro                                                     |

Exemplo de requisição:

`POST /reports/perimeters`

    {
      "title": "Perímetro",
      "shp_file": { "file_name": "perimetro.shp", "content": "codificado em base64" },
      "shx_file": { "file_name": "perimetro.shx", "content": "codificado em base64" },
      "solver_group_id": 1000
    }

Exemplo de resposta:

    {
      "perimeter": {
        "id": 1000,
        "title": "Perímetro",
        "status": "pendent",
        "active": true,
        "priority": 0,
        "created_at": "2014-02-10T13:14:49.519-02:00",
        "updated_at": "2014-02-10T13:14:49.519-02:00",
        "group": { "id": 1000, "name": "Grupo" }
      }
    }

## Alterando um perímetro

__URI__ `PUT /reports/perimeters/{id}`

### Parâmetros de entrada

| Nome            | Tipo    | Obrigatório | Descrição                                  |
|-----------------|---------|-------------|--------------------------------------------|
| title           | Integer | Sim         | O título do perímetro                      |
| solver_group_id | Integer | Não         | Grupo solucionador padrão para o perímetro |
| active          | Boolean | Não         | Define se o perímetro esta ativo ou inativo|
| priority        | Integer | Não         | Prioridade do perímetro                    |

Exemplo de requisição:

`PUT /reports/perimeters/1`

    {
      "title": "Perímetro",
      "solver_group_id": 1000
    }

Exemplo de resposta:

    {
      "perimeter": {
        "id": 1,
        "title": "Perímetro",
        "status": "pendent",
        "active": true,
        "priority": 0,
        "created_at": "2014-02-10T13:14:49.519-02:00",
        "updated_at": "2014-02-10T13:14:49.519-02:00",
        "group": { "id": 1000, "name": "Grupo" }
      }
    }

## Removendo um perímetro

__URI__ `DELETE /reports/perimeters/{id}`

## Consultando um perímetro

__URI__ `GET /reports/perimeters/{id}`

Exemplo de requisição:

`GET /reports/perimeters/1`

Exemplo de resposta:

    {
      "perimeter": {
        "id": 1,
        "title": "Perímetro",
        "status": "pendent",
        "active": true,
        "priority": 0,
        "created_at": "2014-02-10T13:14:49.519-02:00",
        "updated_at": "2014-02-10T13:14:49.519-02:00",
        "group": { "id": 1000, "name": "Grupo" }
      }
    }

## Listando perímetros

__URI__ `GET /reports/perimeters`

Exemplo de parâmetros para a requisição:

`GET /reports/perimeters`

Exemplo de resposta:

    {
      "perimeters": [
        {
          "id": 1000,
          "title": "Perímetro",
          "status": "pendent",
          "active": true,
          "priority": 0,
          "created_at": "2014-02-10T13:14:49.519-02:00",
          "updated_at": "2014-02-10T13:14:49.519-02:00",
          "group": { "id": 1000, "name": "Grupo" }
        },
        ...
      ]
    }
