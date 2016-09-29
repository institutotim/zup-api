# Requisitos de Hardware

## Requisitos básicos
O ZUP contém dois componentes que necessitam a utilização de um servidor para hospedar a aplicação: o componente API e Web.

O componente Web tem o propósito de servir os arquivos estáticos (páginas HTML, scripts Javascript, imagens e etc) então não demanda muito recurso do servidor.

Já o componente API é responsável por controlar e assegurar toda a lógica de negócio de aplicação, portanto é necessário os seguintes requisitos de modo que a aplicação possa funcionar minimamente sem problemas em apenas um servidor:

* CPU com 4 Cores @ 2.0 GHZ
* 8GB de RAM
* 60GB de espaço em disco (preferencialmente SSD)
* Transferência de 100 Mbps

**Essa configuração-base atende até a quantidade de 150 usuários por dia.**

## Alta disponibilidade
Para uma configuração básica de alta disponibilidade, sugerimos a seguinte arquitetura:

**Descritivo:**
* Um servidor para servir como load balancer da aplicação:
  * CPU 2 Cores @ 2.0 GHZ
  * 1GB de RAM
  * Transferência de 100 Mbps
* Dois servidores da API:
  * CPU com 2 Cores @ 2.0 GHZ
  * 2GB de RAM
  * 20GB de espaço em disco (preferencialmente SSD)
  * Transferência de 100 Mbps
* Um servidor dedicado para o Postgres:
  * CPU com 2 Cores @ 2.0 GHZ
  * 4GB de RAM
  * 40GB de espaço em disco (preferencialmente SSD)
  * Transferência de 100 Mbps
* Um servidor dedicado para o Redis
  * CPU com 2 Cores @ 2.0 GHZ
  * 4GB de RAM
  * 10GB de espaço em disco (preferencialmente SSD)
  * Transferência de 100 Mbps

**Esta é uma configuração mínima de alta disponibilidade e alta performance da aplicação, no caso do componente da API parar de responder.**


## Progressão

Ao aumentar o acesso de usuário por dia, deve-se adicionar mais servidores API e de banco de dados à arquitetura - para escalonamento horizontal: conforme tabela abaixo:

### Escalonamento horizontal

| Usuários por dia  |                                       API                                      |                                   Postgresql                                  |                                     Redis                                     |
|:-----------------:|:------------------------------------------------------------------------------:|:-----------------------------------------------------------------------------:|:-----------------------------------------------------------------------------:|
|       0-150       | 2 servidores (2 Cores @ 2.0 GHZ /  2GB de RAM / 20GB de disco (SSD) /100 Mbps) |  1 servidor (2 Cores @ 2.0 GHZ / 4GB de RAM / 20GB de disco (SSD) / 100 Mbps) |  1 servidor (2 Cores @ 2.0 GHZ / 4GB de RAM / 10GB de disco (SSD) / 100 Mbps) |
|      150-300      | 3 servidores (2 Cores @ 2.0 GHZ / 2GB de RAM / 20GB de disco (SSD) / 100 Mbps) |  1 servidor (4 Cores @ 2.0 GHZ / 4GB de RAM / 60GB de disco (SSD) / 100 Mbps) |  1 servidor (2 Cores @ 2.0 GHZ / 8GB de RAM / 20GB de disco (SSD) / 100 Mbps) |
|      300-450      | 4 servidores (2 Cores @ 2.0 GHZ / 2GB de RAM / 20GB de disco (SSD) / 100 Mbps) | 1 servidor (6 Cores @ 2.0 GHZ / 8GB de RAM / 120GB de disco (SSD) / 100 Mbps) | 1 servidor (4 Cores @ 2.0 GHZ / 12GB de RAM / 40GB de disco (SSD) / 100 Mbps) |
|      450-600      |  4 servidores (2 Cores @ 2.0 GHZ / 2GB de RAM / 20GB de disco (SSD) / 1 Gbps)  |  1 servidor (8 Cores @ 2.0 GHZ / 8GB de RAM / 200GB de disco (SSD) / 1 Gbps)  |  1 servidor (8 Cores @ 2.0 GHZ / 16GB de RAM / 80GB de disco (SSD) / 1 Gbps)  |

**Usuário** ativo do painel, trabalhando em horário comercial com o ZUP - realizando consultas, criando relatos, inventários e etc.

### Escalonamento vertical

| Usuários por dia  |               Servidor com Web + API + Postgres +  SQL              |
|:-----------------:|:-------------------------------------------------------------------:|
|       0-150       |  4 Cores @ 2.0 GHZ / 8GB de RAM /  60GB de disco / (SSD) / 100 Mbps |
|      150-300      | 6 Cores @ 2.0 GHZ /  12GB de RAM / 100GB de disco (SSD) /  100 Mbps |
|      300-450      |  8 Cores @ 2.0 GHZ / 16GB de RAM / 150GB de disco (SSD) / 100 Mbps  |
|      450-600      |   12 Cores @ 2.0 GHZ / 16GB de RAM / 250GB de disco (SSD) / 1Gbps   |

**Usuário** ativo do painel, trabalhando em horário comercial com o ZUP - realizando consultas, criando relatos, inventários e etc.
