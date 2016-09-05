# API: Estatísticas de Relato

Para fazer a consulta de estatísticas de relato, usar o seguinte endpoint:

`GET /reports/stats`

Exemplo com parâmetro:

`/reports/stats?category_id=1`

ou como array

`/reports/stats?category_id[]=1&category_id[]=2`

Exemplo de resposta:

    {
        "stats": [
            {
                "category_id": 1,
                "name": "Limpeza de Boca",
                "statuses": [
                    {
                        "status_id": 3,
                        "title": "Final status",
                        "count": 0
                    },
                    {
                        "status_id": 2,
                        "title": "Initial status",
                        "count": 910
                    },
                    {
                        "status_id": 1,
                        "title": "Random status 1",
                        "count": 0
                    }
                ]
            }
        ]
    }


## Filtrando por data

Você pode filtrar por data passando os parâmetros `begin_date`
e/ou `end_date` no formato ISO-8601.
