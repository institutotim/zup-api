# Zeladoria Urbana Participativa - API

## Introdução

Sabemos que o manejo de informação é uma das chaves para uma gestão eficiente, para isso o ZUP apresenta um completo histórico de vida de cada um dos ativos e dos problemas do município, incorporando solicitacões de cidadãos, dados georeferenciados, laudos técnicos, fotografias e ações preventivas realizadas ao longo do tempo. Desta forma, o sistema centraliza todas as informações permitindo uma rápida tomada de decisões tanto das autoridades como dos técnicos em campo.

Esse componente é toda a base do processamento de informação do ZUP, atuando como o ponto final de consumo de todos os componentes envolvidos no sistema, tais como:

* [Painel administrativo WEB](https://git.ntxdev.com.br/zup/zup-painel)
* [Aplicativo WEB para cidadão](https://git.ntxdev.com.br/zup/zup-web-angular)
* [Aplicativo ANDROID para cidadão](https://git.ntxdev.com.br/zup/zup-android-cidadao)
* [Aplicativo ANDROID para uso técnico](https://git.ntxdev.com.br/zup/zup-android-tecnico)
* [Aplicativo iOS para cidadão](https://git.ntxdev.com.br/zup/zup-ios-cidadao)

Esse README informa como subir o projeto em ambiente para desenvolvimento. Para informações sobre como fazer o deploy do projeto para produção, leia o [Guia de instalação](http://docs.zup.ntxdev.com.br/site/installation_docker/).

## Tecnologias utilizadas

O ZUP-API é um projeto escrito em Ruby com diversos componentes e bibliotecas.

### Dependências

Para instalar o ZUP na sua máquina, para desenvolvimento, você precisará:

* Linux server, recomendamos [Ubuntu 14.04+](http://www.ubuntu.com) ou [Debian 8.0+](https://www.debian.org)
* Banco de dados [Postgres 9.4+](http://www.postgresql.org)
* Extensão para dados geoespaciais [Postgis 2.1+](http://postgis.net)
* Editor de imagens via linha de comando  [ImageMagick 6.8+](http://www.imagemagick.org)
* Armazenador/cache e balance de estrura de dados em memória [Redis 2.8.9](http://redis.io)
* Compilador de linguagem - [Ruby 2.2.1](https://www.ruby-lang.org/pt)
* Versionador de código - [GIT 2.7+](https://git-scm.com)
* GEOS - Geometry Engine, Open Source [GEOS](https://trac.osgeo.org/geos/)
* Cubes [Cubes 1.0.1](http://cubes.databrewery.org)

## Instalação

### Instalação de dependências

1. Tenha um servidor [Ubuntu 14.04+](http://www.ubuntu.com) ou [Debian 8.0+](https://www.debian.org) instalado e atualizado.
`
  # apt-get update
`
2. Como root, crie um usuário para aplicação. Usaremos esse usuário para executar algumas coisas:
`
  # useradd -G www-data,sudo --create-home zup-production
`
3. Instale o postgres e postgis:
`
  # apt-get install postgresql postgresql-contrib postgis postgresql-9.4-postgis-2.1 postgresql-9.4-postgis-2.1-scripts
`
Fique atento quanto a versão instalada, você poderá usar a 9.4 ou superior. Caso esteja usando um servidor já com Postgres, verifique a versão com o seguinte comando:
`
  $ psql --version
`

Caso esteja usando Ubuntu 14.04, é possível que a versão 9.4 do postgres não esteja disponível. Nesse caso, adicione o repositório do postgres no server para baixar a versão mais nova. [Veja mais infos aqui](http://www.postgresql.org/download/linux/ubuntu/).

```
  // Abra o arquivo source.list do sistema com seu editor de preferencia (aqui usamos vi)
  # vi /etc/apt/source.list
  // Acrescente a linha do repositório voltada para a versão do ubuntu 14.04
  # deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main
  // Salve o arquivo e rode este comando
  # wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
  # sudo apt-get update
  // Feito isso com sucesso você já pode rodar novamente o comando de instalação do postgres e postgis
  # apt-get install postgresql postgresql-contrib postgis postgresql-9.4-postgis-2.1 postgresql-9.4-postgis-2.1-scripts
```

4.Instale o ImageMagic:

```
  # apt-get install imagemagick
```

5.Instale o git:

```
  # apt-get install git
```

6.Instale o Ruby, utilizaremos o [RVM](https://rvm.io/) mas fique a vontade para instalar de outra forma:

```
  // Antes de instalar precisamos de de uma chave publica de segurança
  # gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
  // Baixe a versão estável
  # \curl -sSL https://get.rvm.io | bash -s stable
  // Recarreque o shell
  # source ~/.rvm/scripts/rvm
  // Teste o RVM
  # type rvm | head -n 1
  // Instale a versão 2.2.1 do ruby
  # rvm install 2.2.1
  // Cheque se o ruby foi instalado
  # ruby -v
```

7.Instale o Redis - Ver mais infos aqui http://redis.io/download

```
  // Instale o buld-essencials para compilar o código
  # sudo apt-get install build-essential
  //Baixe o código
  $ wget http://download.redis.io/releases/redis-stable.tar.gz
  // Descompacte a pasta
  $ tar xzf redis-3.2.0.tar.gz
  // Entre na pasta do fonte da aplicação
  $ cd redis-3.2.0
  // Rode o make
  $ make
```

Caso tenho problemas de instalação causado por algumas bibliotecas faltantes como jemalloc, execute os seguintes passos:

```
  // Instale o jemalloc
  $ cd deps
  $ make jemalloc
  $ make hiredis lua jemalloc linenoise
```

Rode o make test e depois instale no sistema:

```
  $ make test
  $ sudo make install
```

Os binários ficarão compilados no diretório /src. Você pode rodar o regis com

```
  // Server
  $ src/redis-server
  // Client
  $ src/redis-cli
```

### Bibliotecas

Após instalada essas dependências, vamos instalar as bibliotecas, rode o seguinte comando na raiz do projeto:

    bundle install

## Configuração do ambiente

Após ter instalado essas bibliotecas, você precisa configurar as variáveis de ambiente para a aplicação funcionar corretamente.

Abrindo o arquivo `sample.env` na raiz do projeto você tem todas as variáveis de ambiente disponíveis para a configuração do projeto.
Copie este arquivo para a raiz do projeto com o nome `.env` e preencha pelo menos as variáveis que são obrigatórias para o funcionamento do componente:

* `API_URL` - URL completa na qual a API responderá (incluir a porta, caso não seja a porta 80)
* `SMTP_ADDRESS` - Endereço do servidor de SMTP para envio de email
* `SMTP_PORT` - Porta do servidor de SMTP
* `SMTP_USER` - Usuário para autenticação do SMTP
* `SMTP_PASS` - Senha para autenticação do SMTP
* `SMTP_TTLS` - Configuração TTLS para o SMTP
* `SMTP_AUTH` - Configuração do modo de autenticação do SMTP
* `REDIS_URL` - URL onde o servidor Redis está ouvindo (ex.: redis://10.0.0.1:6379)
* `WEB_URL` - A URL completa da URL onde o componente ZUP-PAINEL está acessível publicamente

## Configuração inicial do banco de dados

Após configurar as variáveis de ambiente no arquivo `.env`, você estará pronto para configurar o banco de dados.

Primeiramente, copie o arquivo `config/database.yml.sample` para `config/database.yml` e modifique com os dados do seu Postgres.

Feito isso, faça o _setup_ do banco de dados:

    rake db:setup

**Ao final desse comando será gerado um usuário e senha de administrador, anote-os em um lugar seguro, você precisará dele para logar no sistema pela primeira vez.**

Para iniciar o servidor, você só precisa executar o seguinte comando:

    bundle exec foreman start -f Procfile.dev

Se tudo estiver ok, este deverá ser o seu output:

```
12:05:22 web.1    | started with pid 63360
12:05:22 worker.1 | started with pid 63361
12:05:23 web.1    | =============== Phusion Passenger Standalone web server started ===============
12:05:23 web.1    | PID file: /Users/user/projects/zup-api/passenger.3000.pid
12:05:23 web.1    | Log file: /Users/user/projects/zup-api/log/passenger.3000.log
12:05:23 web.1    | Environment: development
12:05:23 web.1    | Accessible via: http://0.0.0.0:3000/
12:05:23 web.1    |
12:05:23 web.1    | You can stop Phusion Passenger Standalone by pressing Ctrl-C.
12:05:23 web.1    | Problems? Check https://www.phusionpassenger.com/library/admin/standalone/troubleshooting/
12:05:23 web.1    | ===============================================================================
12:05:25 web.1    | App 63391 stdout:
12:05:29 worker.1 | /Users/user/projects/zup-api/lib/mapquest.rb:6: warning: already initialized constant Mapquest::API_ROOT
12:05:29 worker.1 | /Users/user/projects/zup-api/lib/mapquest.rb:6: warning: previous definition of API_ROOT was here
12:05:29 worker.1 | 2015-09-23T15:05:29.390Z 63361 TID-owtng2518 INFO: Booting Sidekiq 3.4.2 with redis options {:url=>"redis://127.0.0.1:6379", :namespace=>"zup"}
12:05:29 worker.1 | 2015-09-23T15:05:29.431Z 63361 TID-owtng2518 INFO: Cron Jobs - add job with name: unlock_inventory_items
12:05:29 worker.1 | 2015-09-23T15:05:29.437Z 63361 TID-owtng2518 INFO: Cron Jobs - add job with name: set_reports_overdue
12:05:29 worker.1 | 2015-09-23T15:05:29.443Z 63361 TID-owtng2518 INFO: Cron Jobs - add job with name: expire_access_keys
12:05:29 worker.1 | 2015-09-23T15:05:29.454Z 63361 TID-owtng2518 INFO: Running in ruby 2.2.1p85 (2015-02-26 revision 49769) [x86_64-darwin14]
12:05:29 worker.1 | 2015-09-23T15:05:29.454Z 63361 TID-owtng2518 INFO: See LICENSE and the LGPL-3.0 for licensing details.
12:05:29 worker.1 | 2015-09-23T15:05:29.454Z 63361 TID-owtng2518 INFO: Upgrade to Sidekiq Pro for more features and support: http://sidekiq.org/pro
12:05:29 worker.1 | 2015-09-23T15:05:29.454Z 63361 TID-owtng2518 INFO: Starting processing, hit Ctrl-C to stop
12:05:30 web.1    | App 63391 stderr: /Users/user/projects/zup-api/lib/mapquest.rb:6: warning: already initialized constant Mapquest::API_ROOT
12:05:30 web.1    | App 63391 stderr: /Users/user/projects/zup-api/lib/mapquest.rb:6: warning: previous definition of API_ROOT was here
12:05:31 web.1    | App 63411 stdout:
```

Você poderá acessar a seguinte URL para certificar-se que o servidor subiu corretamente:

[](http://127.0.0.1:3000/feature_flags)

Está pronto! Para maiores informações sobre os componentes internos da API, leia os documentos escritos na pasta `docs/` que pode ser encontrada na raiz do projeto.

## Instalação do Cubes

O ZUP utiliza o [Cubes](http://cubes.databrewery.org) para a interface analítica com o banco de dados, fornecendo os dados e funcionalidades necessárias para o funcionamento do módulo de relatórios.

Para isto, é necessário a instalação do Cubes **na versão 1.0.1**, você pode utilizar o seguinte comando para instalar através do **pip**:

    pip install Flask SQLAlchemy psycopg2 cubes==1.0.1
