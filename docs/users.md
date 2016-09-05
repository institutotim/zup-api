# API - Usuários

## Criando um usuário

Para criar um usuário os únicos parâmetros necessários são: `email`, `password` e `password_confirmation`.

Acesse a página no Swagger-doc para ver os outros parâmetros opcionais.

*Obs:* O código de status retornado por endpoints que criam entidades
no banco é 201 ao invés de 200.

__URI__ `POST /users`

Exemplo de requisição:

    {
      "email": "johnk12@gmail.com",
      "password": "astrongpassword",
      "password_confirmation": "astrongpassword"
    }


Exemplo de resposta:

    {
      "message" : "User created successfully",
      "user" : {
        "id" : 2,
        "password_resetted_at" : null,
        "phone" : null,
        "reset_password_token" : null,
        "address_additional" : null,
        "created_at" : "2014-01-12T03:28:38.576-02:00",
        "address" : null,
        "updated_at" : "2014-01-12T03:28:38.576-02:00",
        "district" : null,
        "postal_code" : null,
        "email" : "johnk12@gmail.com",
        "name" : null,
        "document" : null
      }
    }

## Obtendo informações de um usuário

__URI__ `GET /users/:id`

Exemplo de requisição: `GET /users/2`

Exemplo de resposta:

    {
      "user" : {
        "id" : 2,
        "password_resetted_at" : null,
        "phone" : null,
        "reset_password_token" : null,
        "address_additional" : null,
        "created_at" : "2014-01-12T03:28:38.576-02:00",
        "address" : null,
        "updated_at" : "2014-01-12T03:28:38.576-02:00",
        "district" : null,
        "postal_code" : null,
        "email" : "johnk12@gmail.com",
        "name" : null,
        "document" : null
      }
    }

## Alterando informações de um usuário

__URI__ `PUT /users/:id`

Aceita os mesmo parâmetros ao __criar um usuário__ mas funciona para atualizar um usuário já existente.

Exemplo de requisição:

`PUT /users/2`

    {
      "email": "anotheremail@gmail.com"
    }

Exemplo de resposta:

    {
      "message": "User updated with success",
      "user": {
        "id" : 2,
        "password_resetted_at" : null,
        "phone" : null,
        "reset_password_token" : null,
        "address_additional" : null,
        "created_at" : "2014-01-12T03:28:38.576-02:00",
        "address" : null,
        "updated_at" : "2014-01-12T03:28:38.576-02:00",
        "district" : null,
        "postal_code" : null,
        "email" : "anotheremail@gmail.com",
        "name" : null,
        "document" : null
      }
    }

### Para alterar uma senha

Para alteração de senha, você precisa informar o atributo `current_password`
com a senha atual do usuário.

## Recuperação de senha

Você pode solicitar o envio de e-mail de recuperação de senha através desse endpoint.

__URI__ `PUT /recover_password`

Exemplo de requisição:

    {
      "email": "user@gmail.com"
    }

Exemplo de resposta:

    {
      "message": "Password recovery email sent successfully!"
    }

## Resetar senha

Você pode resetar a senha do usuário mandando como parâmetro o `token` (de password recovery) e `new_password`

__URI__ `PUT /reset_password`

Exemplo de requisição:

    {
      "token": "7fefdd79199b9c85fc238b16601ae00e",
      "new_password": "12345"
    }

Exemplo de resposta:

    {
      "message": "Password changed successfully!"
    }

## Logout

Para fazer logout, basta utilizar o endpoint abaixo quando logado:

__URI__ `DELETE /sign_out`

Passando como parâmetro o __token__ que você deseja invalidar ou
para invalidar todos as chaves de acesso do usuário, só não passar
nenhum parâmetro.

Exemplo, invalidando um token específico:

`DELETE /sign_out`

Parâmetros:

    {
      "token": "asd13s2342bcede4308b1"
    }

## Ativando um usuário

Para ativar um usuário, basta utilizar o seguinte endpoint:

__URI__ `PUT /users/:id/enable`

Para utilizá-lo você precisa ter a permissão de gerenciar usuários em um determinado grupo que o usuário pertença.