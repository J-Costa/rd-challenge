## Documentação do Projeto

### Ambiente de Desenvolvimento

#### Execução do projeto
O projeto pode ser executado de duas formas:

##### Utilizando DevContainer
Se você utiliza VSCode com a extensão Remote Containers, basta abrir o projeto no VSCode e aceitar a sugestão para abrir no container. O ambiente será configurado automaticamente com todas as dependências necessárias.

##### Utilizando Docker Compose
Caso você já possua o ruby instalado localmente, você pode executar o projeto utilizando o Docker Compose. Para isso, execute o seguinte comando:


```bash
docker compose up db redis -d
```

Este comando iniciará os seguintes serviços:
- O banco de dados PostgreSQL
- Redis para o Sidekiq

Dessa forma, os serviços de banco de dados e fila são executados em containers, enquanto a aplicação Ruby on Rails é executada localmente. 
Basta então instalar as dependências do projeto com:

```bash
bundle install
```
e, em seguida, criar e migrar o banco de dados:

```bash
rails db:setup
```

Independentemente do método escolhido, após instalar as dependências e configurar o banco de dados, você pode rodar o servidor Rails e o Sidekiq localmente com o seguinte comando:
```bash
bin/dev
```

Este comando inicia tanto o servidor Rails quanto o Sidekiq localmente, mas conectando-se aos serviços em containers. 

#### Dados de Teste
Optei por utilizar fixtures no lugar de factories para os testes. Esta decisão foi baseada nos seguintes fatores:
- **Simplicidade**: As fixtures fornecem uma maneira direta de preparar dados de teste
- **Consistência**: Os dados são definidos de forma declarativa, facilitando a manutenção de um estado consistente durante os testes
- **Performance**: As fixtures são carregadas uma única vez por suite de testes, sendo mais eficientes em termos de desempenho para este projeto

#### Gerenciamento de Carrinhos Abandonados
Para o tratamento de carrinhos abandonados, implementei um job utilizando Sidekiq que:
- Verifica carrinhos sem atividade por mais de 3 horas e os marca como abandonados
- Remove carrinhos abandonados há mais de 7 dias
- É executado em intervalos regulares para manter o sistema limpo


#### Tratamento de Erros
Implementei validações e tratamento de erros para casos como:
- Tentativas de adicionar quantidades negativas de produtos
- Remoção de produtos inexistentes no carrinho
- Manipulação de carrinhos inválidos ou expirados


#### Performance dos Jobs
Para garantir a performance dos jobs, utilizei as seguintes práticas:
- **Batch Processing**: Busca por lotes de carrinhos no banco de dados pesnando em performance e escalabilidade
  - Poderia ser feito com um `update_all`, mas optei por buscar os carrinhos e processá-los individualmente utilizando os métodos de model.
- **Indexação**: Adicionei índices nas colunas mais consultadas no `cart`, para acelerar as consultas dentro dos jobs e para auxiliar na performance geral do sistema


#### CI
Para garantir a qualidade do código e a execução dos testes, implementei um pipeline de CI utilizando GitHub Actions. O workflow é acionado em push e pull requests, executando os seguintes passos:
- Escaneamento de segurança com `brakeman`
- Verificação de estilo de código com `rubocop`
- Execução dos testes com `rspec`

#### Docs via gem [oas_rails](https://github.com/a-chacon/oas_rails)
A gem oas_rails é bem legal, por meio de comentários no controller é possível gerar docs para os endpoints de forma 'automática' ao estilo do que o FastAPI faz no Python.
Apesar de "poluir" os controllers, a funcionalidade da gem é legal e pode até reduzir custos com ferramentas externas para documentação de API.

Além de ser interativa e permitir testar o endpoint direto pela doc.
Com o app rodando basta acessar `/docs` para poder visualizar:
![image](https://github.com/user-attachments/assets/108b8012-7c9d-45d1-8d06-1fc0420866aa)
