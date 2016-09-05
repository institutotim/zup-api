# Endpoints de relatos de feedback

Ao finalizar um relato, o usuário tem um tempo para poder dar um feedback sobre o atendimento daquele relato.

## Obtendo o feedback associado ao relato

Quando existir um feedback associado ao relato você pode obter o feedback através do endpoint:

    GET /reports/:id/feedback

Exemplo de retorno

    {
      "feedback": {
        "id": 1,
        "kind": "positive",
        "content": "Tudo foi arrumado!",
        "user": {
          "name": "Alejandrin Muller",
          "groups": [
            {
              "id": 1,
              "name": "P\u00fablico",
              "permissions": {
                "view_sections": "true",
                "view_categories": "true"
              },
              "created_at": "2014-03-08T10:41:07.696-03:00",
              "updated_at": "2014-03-08T10:41:07.696-03:00",
              "guest": true
            },
            {
              "id": 2,
              "name": "Admins",
              "permissions": {
                "manage_users": "true",
                "manage_groups": "true",
                "manage_reports": "true",
                "manage_inventory_items": "true",
                "manage_reports_categories": "true",
                "manage_inventory_categories": "true"
              },
              "created_at": "2014-03-08T10:41:07.750-03:00",
              "updated_at": "2014-03-08T10:41:07.750-03:00",
              "guest": false
            }
          ]
        },
        "images": []
      }
    }

## Criando um feedback

Você só pode criar um feedback se ainda não passou o prazo de feedback do usuário (`user_response_time` da categoria de relato)

Endpoint:

    POST /reports/:id/feedback

Exemplo de retorno:

    {
      "feedback": {
        "id": 1,
        "kind": "positive",
        "content": "Tudo foi arrumado!",
        "user": {
          "name": "Alejandrin Muller",
          "groups": [
            {
              "id": 1,
              "name": "P\u00fablico",
              "permissions": {
                "view_sections": "true",
                "view_categories": "true"
              },
              "created_at": "2014-03-08T10:41:07.696-03:00",
              "updated_at": "2014-03-08T10:41:07.696-03:00",
              "guest": true
            },
            {
              "id": 2,
              "name": "Admins",
              "permissions": {
                "manage_users": "true",
                "manage_groups": "true",
                "manage_reports": "true",
                "manage_inventory_items": "true",
                "manage_reports_categories": "true",
                "manage_inventory_categories": "true"
              },
              "created_at": "2014-03-08T10:41:07.750-03:00",
              "updated_at": "2014-03-08T10:41:07.750-03:00",
              "guest": false
            }
          ]
        },
        "images": []
      }
    }
