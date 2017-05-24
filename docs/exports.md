# Exportações

## Criando uma exportação

__URI__ `POST /exports`

### Parâmetros de entrada

| Nome                  | Tipo   | Obrigatório | Descrição                                                        |
|-----------------------|--------|-------------|---------------------------------------------------- -------------|
| kind                  | String | Sim         | Tipo da exportação, relato (`report`) ou inventário (`inventory`)|
| inventory_category_id | Integer| Não         | O id da categoria de inventário, obrigatório para inventários    |
| filters               | Hash   | Não         | Define os filtros que serão utilizados para a pesquisa           |

Exemplo de dados para requisição

  `POST /exports`

    {
      "kind": "inventory",
      "inventory_category_id": 1000,
      "filters": {
        "users_ids": "1,2,3",
        "statuses_ids": "4,7"
      }
    }

Exemplo de resposta

    {
      "export": {
        "id": 1000,
        "kind": "report",
        "url": "url_to_file",
        "status": "pendent",
        "created_at": "01/01/2016 12:00:00 -0200",
        "category": {
          "id": 1000,
          "title": "Categoria"
        }
      }
    }

## Removendo uma exportação

Para remover uma exportação permanentemente, só necessita fazer uma requisição em:

__URI__ `DELETE /exports/:id`


## Listando exportações

__URI__ `GET /exports`

### Parâmetros de entrada

| Nome  | Tipo  | Obrigatório | Descrição                                                       |
|-------|-------|-------------|---------------------------------------------------- ------------|
| sort  | String| Não         | Campo que será ordenado (`created_at`, `status`)                |
| order | String| Não         | Define se a ordem será crescente (`asc`) ou decrescente (`desc`)|

Exemplo de requisição:

`GET /exports`


Exemplo de resposta:

    {
      "exports": [{
        "id": 1000,
        "kind": "report",
        "url": "url_to_file",
        "status": "pendent",
        "created_at": "01/01/2016 12:00:00 -0200",
        "category": {
          "id": 1000,
          "title": "Categoria"
        }
      }]
    }
