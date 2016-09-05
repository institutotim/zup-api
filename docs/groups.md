API - Grupos

# Listar usuários de um grupo

Endpoint: `GET /groups/:id/users`

Exemplo de retorno:

    {
        "group": {
            "id": 1,
            "name": "Random name 1",
            "permissions": {
                "view_sections": "true",
                "view_categories": "true"
            }
        },
        "users": [
            {
                "id": 72,
                "name": "Jennyfer Schimmel",
                "email": "ewald@lubowitz.biz",
                "phone": "11912231545",
                "document": "43413254189",
                "address": "084 Norval Stream",
                "address_additional": "Suite 063",
                "postal_code": "04005000",
                "district": "New Ian",
                "created_at": "2014-02-02T00:18:15.955-02:00"
            },
            {
                "id": 73,
                "name": "Jennyfer Schimmel",
                "email": "summer.buckridge@okunevalynch.us",
                "phone": "11912231545",
                "document": "43413254189",
                "address": "084 Norval Stream",
                "address_additional": "Suite 063",
                "postal_code": "04005000",
                "district": "New Ian",
                "created_at": "2014-02-02T00:18:16.179-02:00"
            },
            ...
        ]
    }

# Modificar permissões de um grupo

Endpoint: `PUT /groups/:id/permissions`

Exemplo de requisição:

    {
      "manage_users": true,
      "manage_groups": true,
      "manage_inventory_items": true,
      "manage_reports_items": true
    }

Exemplo de resposta:

    {
        "group": {
            "id": 1,
            "name": "Random name 1",
            "permissions": {
                "manage_users": true,
                "manage_groups": true,
                "view_sections": "true",
                "view_categories": "true",
                "manage_inventory_items": true
            }
        }
    }

Ver no swagger a lista de todos os métodos disponíveis para a permissão de grupos
