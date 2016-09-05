# Autenticação

O Usuário deve ser autenticado no sistema para poder realizar algumas requisições, utilize o endpoint de autenticação:

`POST /authenticate`

### Parâmetros de entrada

| Nome     | Tipo   | Obrigatório | Descrição       |
|----------|--------|-------------|-----------------|
| email    | String | Sim         | E-mail da conta |
| password | String | Sim         | Senha da conta  |


Exemplo de requisição:

    {
      "email": "user@gmail.com",
      "password": "registeredpassword"
    }

Exemplo de resposta:

    {
      "user": ...,
      "token": "d8068c68c63c8e74310e9dc680063a3f"
    }

**Esse token retornado deverá ser enviado no HEADER das requisições da seguinte maneira: `X-App-Token: token`**
