Documentação da API Papacapim
Bem-vindo(a) à documentação da API Papacapim. Este documento será seu guia para entender os endpoints da API, ajudando-o a construir um font-end para integração com nosso back-end. Esta documentação está dividida da seguinte maneira:

Como acessar a API
Autenticação
Usuários
Seguidores
Postagens
Curtidas
Em cada tópico da documentação será exibido um exemplo do corpo da requisição e da resposta. As chaves JSON em cada exemplo são auto-explicativas.

O que é a API Papacapim?

É uma API RESTful bem simples que eu criei para que meus alunos pudessem praticar React Native na disciplina Desenvolvimento Mobile (IFBA). Minha intenção era dar a eles uma API suficiente para que pudessem fazer requisições e produzir assim um front-end, servindo de objeto de avaliação da disciplina.

Como acessar a API
A API Papacapim é aberta e qualquer um pode acessá-la para praticar a criação de front-ends com consumo de APIs através da URL https://api.papacapim.just.pro.br.

Retornar ao início

Autenticação
Todos os endpoints, com exceção do endpoint para criação de um novo usuário, requerem autenticação. Desta forma, apenas usuários autenticados poderão acessar a API e todos os objetos que forem criados serão associados ao usuário autenticado.

A autenticação no Papacapim funciona através de um token de sessão. Este token deverá ser enviado a cada requisição no cabeçalho HTTP através da chave x-session-token. Para obter um token basta criar uma nova sessão usando seu usuário e senha (caso não tenha usuário, crie antes usando o endpoint Criar usuário). Para encerrar a sessão (uma espécie de log-out), basta deletar a sessão previamente criada.

Nova sessão: POST /sessions
Corpo
Objeto JSON contendo login e senha.


      {
        "login": "frankson",
        "password": "123mudar"
      }
    
Resposta: 200
Objeto JSON da sessão criada. Armazene o valor de token para usar nas próximas requisições.


      {
        "id": 1,
        "user_login": "frankson",
        "token": "12835982-bc61-4f48-9561-ec1471969c6e",
        "ip": "::1",
        "created_at": "2024-08-03T12:38:19.997Z",
        "updated_at": "2024-08-03T12:38:19.997Z"
      }
    
Encerrar sessão: DELETE /sessions/1
Resposta: 204
Sem conteúdo.

Retornar ao início

Usuários
Nos endpoints a seguir trataremos da manipulação de usuários da plataforma. A criação de novos usuários é livre e pode ser feita por qualquer um (este é o único endpoint que não precisa de autenticação). Após criado um usuário você poderá autenticá-lo e acessar os outros endpoints.

Criar usuário: POST /users
Corpo
Um objeto JSON contendo o login, nome, senha e confirmação de senha do novo usuário.


      {
        "user": {
          "login": "frankson",
          "name": "Frankson Barreto",
          "password": "123mudar",
          "password_confirmation": "123mudar"
        }
      }
    
Resposta: 201
O corpo da resposta conterá um JSON do usuário criado.


      {
        "id": 3,
        "login": "frankson",
        "name": "Frankson Barreto",
        "created_at": "2024-08-03T12:04:12.460Z",
        "updated_at": "2024-08-03T12:04:12.460Z"
      }
    
Alterar usuário: PATCH /users/1
Corpo
Um objeto JSON contendo o login, nome, senha e confirmação de senha do novo usuário. Neste caso os campos são todos opcionais. Por exemplo: se deseja mudar apenas o login, basta enviar login; se deseja apenas alterar a senha, basta enviar password e password_confirmation. É possível enviar tudo para alterar todos os dados caso queira.

Por razões de segurança, todas as sessões ativas serão excluídas ao alterar a senha e será preciso criar uma nova sessão para continuar acessando a API.


      {
        "user": {
          "login": "franks",
          "name": "Frankson Batista",
          "password": "senhanova",
          "password_confirmation": "senhanova"
        }
      }
    
Resposta: 201
O corpo da resposta conterá um JSON com os novos dados do usuário.


      {
        "id": 3,
        "login": "franks",
        "name": "Frankson Batista",
        "created_at": "2024-08-03T12:04:12.460Z",
        "updated_at": "2024-08-03T13:11:48.310Z"
      }
    
Listar usuários: GET /users
Parâmetros de URL
page: (opcional, inteiro) Determina a página da listagem para evitar que todos os usuários sejam listados ao mesmo tempo.
search: (opcional, string) Busca usuários pelo nome. Se omitido, retorna todos os usuários cadastrados.
Resposta: 200
O corpo da resposta conterá um JSON com a lista de usuários.


      [
        {
          "id": 1,
          "login": "just",
          "name": "J. P. Just",
          "created_at": "2024-07-28T16:27:42.869Z",
          "updated_at": "2024-07-28T16:27:42.869Z"
        },
        {
          "id": 2,
          "login": "teste",
          "name": "Testador",
          "created_at": "2024-07-28T16:28:20.995Z",
          "updated_at": "2024-07-28T16:28:20.995Z"
        },
        {
          "id": 3,
          "login": "frankson",
          "name": "Frankson Barreto",
          "created_at": "2024-08-03T12:04:12.460Z",
          "updated_at": "2024-08-03T12:04:12.460Z"
        }
      ]
    
Obter usuário específico: GET /users/{login}
Parâmetros de URL
{login}: (string) Login do usuário que deseja obter.
Resposta: 200
O corpo da resposta conterá um JSON com os dados do usuário.


      {
        "id": 1,
        "login": "just",
        "name": "J. P. Just",
        "created_at": "2024-07-28T16:27:42.869Z",
        "updated_at": "2024-07-28T16:27:42.869Z"
      }
    
Excluir usuário: DELETE /users/1
Resposta: 204
Sem conteúdo.

Retornar ao início

Seguidores
Os endpoints de seguidores permitirão que um usuário siga alguém ou liste os seguidores de alguém.

Seguir alguém: POST /users/{login}/followers
Parâmetros de URL
{login}: (string): Login do usuário que você deseja seguir.
Resposta: 201
O corpo da resposta conterá um JSON com os dados da relação de seguidor criada.


      {
        "id": 6,
        "follower_login": "frankson",
        "followed_login": "just",
        "created_at": "2024-08-03T13:24:00.637Z",
        "updated_at": "2024-08-03T13:24:00.637Z"
      }
    
Listar seguidores: GET /users/{login}/followers
Parâmetros de URL
{login}: (string) Login do usuário o qual você quer listar os seguidores.
Resposta: 200
O corpo da resposta conterá um JSON com a lista de seguidores deste usuário.


      [
        {
          "id": 1,
          "login": "just",
          "name": "J. P. Just",
          "created_at": "2024-07-28T16:27:42.869Z",
          "updated_at": "2024-07-28T16:27:42.869Z"
        },
        {
          "id": 3,
          "login": "frankson",
          "name": "Frankson Barreto",
          "created_at": "2024-08-03T12:04:12.460Z",
          "updated_at": "2024-08-03T12:04:12.460Z"
        }
      ]
    
Deixar de seguir: DELETE /users/{login}/followers/1
Parâmetros de URL
{login}: (string) Login do usuário o qual você quer deixar de seguir.
Resposta: 204
Sem conteúdo.

Retornar ao início

Postagens
Nos endpoints a seguir trataremos da manipulação de postagens, possibilitando a criação de novas postagens, respostas a postagens de outros usuários e exclusão de postagens.

Nova postagem: POST /posts
Corpo
Um objeto JSON contendo a postagem.


      {
        "post": {
          "message": "Acabei de entrar no Papacapim!"
        }
      }
    
Resposta: 201
O corpo da resposta conterá um JSON com a postagem criada.


      {
        "id": 7,
        "user_login": "frankson",
        "post_id": null,
        "message": "Acabei de entrar no Papacapim!",
        "created_at": "2024-08-03T13:34:18.103Z",
        "updated_at": "2024-08-03T13:34:18.103Z"
      }
    
Responder uma postagem: POST /posts/{id}/replies
Parâmetros de URL
{id}: (inteiro) ID da postagem que será respondida.
Corpo
Um objeto JSON contendo a postagem.


      {
        "reply": {
          "message": "Também entrei no Papacapim essa semana. É muito massa!",
        }
      }
    
Resposta: 201
O corpo da resposta conterá um JSON com a postagem criada.


      {
        "id": 8,
        "user_login": "just",
        "post_id": 7,
        "message": "Também entrei no Papacapim essa semana. É muito massa!",
        "created_at": "2024-08-03T13:36:56.977Z",
        "updated_at": "2024-08-03T13:36:56.977Z"
      }
    
Listar postagens e feed: GET /posts
Parâmetros de URL
page: (opcional, inteiro) Determina a página da listagem para evitar que todos as postagens sejam listadas ao mesmo tempo.
feed: (opcional, inteiro) Se for 1 lista apenas postagens feitas pelos usuários que você segue.
search: (opcional, string) Busca mensagens com algum do(s) termo(s) especificado(s).
Resposta: 200
O corpo da resposta conterá um JSON com a lista de postagens.


      [
        {
          "id": 2,
          "user_login": "just",
          "post_id": null,
          "message": "Vou passar a usar esta rede.",
          "created_at": "2024-08-01T14:30:33.000Z",
          "updated_at": "2024-08-01T14:30:33.000Z"
        },
        {
          "id": 6,
          "user_login": "gustavo",
          "post_id": 2,
          "message": "Esta rede é muito massa!",
          "created_at": "2024-08-01T14:31:05.000Z",
          "updated_at": "2024-08-01T14:31:05.000Z"
        },
        {
          "id": 7,
          "user_login": "frankson",
          "post_id": null,
          "message": "Acabei de entrar no Papacapim!",
          "created_at": "2024-08-03T13:34:18.103Z",
          "updated_at": "2024-08-03T13:34:18.103Z"
        },
        {
          "id": 8,
          "user_login": "just",
          "post_id": 7,
          "message": "Também entrei no Papacapim essa semana. É muito massa!",
          "created_at": "2024-08-03T13:36:56.977Z",
          "updated_at": "2024-08-03T13:36:56.977Z"
        }
      ]
    
Listar postagens do usuário: GET /users/{login}/posts
Parâmetros de URL
{login}: (string) Determina qual usuário autor das postagens a serem listadas.
page: (opcional, inteiro) Determina a página da listagem para evitar que todos as postagens sejam listadas ao mesmo tempo.
Resposta: 200
O corpo da resposta conterá um JSON com a lista de postagens.


      [
        {
          "id": 2,
          "user_login": "just",
          "post_id": null,
          "message": "Vou passar a usar esta rede.",
          "created_at": "2024-08-01T14:30:33.000Z",
          "updated_at": "2024-08-01T14:30:33.000Z"
        },
        {
          "id": 8,
          "user_login": "just",
          "post_id": 7,
          "message": "Também entrei no Papacapim essa semana. É muito massa!",
          "created_at": "2024-08-03T13:36:56.977Z",
          "updated_at": "2024-08-03T13:36:56.977Z"
        }
      ]
    
Listar respostas: GET /posts/{id}/replies
Parâmetros de URL
{id}: (inteiro) Determina o ID da postagem da qual serão listadas as respostas.
page: (opcional, inteiro) Determina a página da listagem para evitar que todos as postagens sejam listadas ao mesmo tempo.
Resposta: 200
O corpo da resposta conterá um JSON com a lista de respostas.


      [
        {
          "id": 6,
          "user_login": "gustavo",
          "post_id": 2,
          "message": "Esta rede é muito massa!",
          "created_at": "2024-08-01T14:31:05.000Z",
          "updated_at": "2024-08-01T14:31:05.000Z"
        },
      ]
    
Excluir postagem: DELETE /posts/{id}
Parâmetros de URL
id: (inteiro) ID da postagem que deseja excluir.
Resposta: 204
Sem conteúdo.

Retornar ao início

Curtidas
Nos endpoints a seguir trataremos da manipulação de curtidas em uma postagem. Eles permitirão curtir uma postagem, descurtir e visualizar curtidas.

Curtir postagem: POST /posts/{id}/likes
Parâmetros de URL
id: (inteiro) ID da postagem que deseja curtir.
Resposta: 201
O corpo da resposta conterá um JSON com dados da curtida.


      {
        "id": 2,
        "user_login": "frankson",
        "post_id": 7,
        "created_at": "2024-08-03T13:49:23.226Z",
        "updated_at": "2024-08-03T13:49:23.226Z"
      }
    
Listar curtidas: GET /posts/{id}/likes
Parâmetros de URL
id: (inteiro) ID da postagem que deseja visualizar curtidas.
Resposta: 200
O corpo da resposta conterá um JSON com a lista de curtidas.


      [
        {
          "id": 2,
          "user_login": "just",
          "post_id": 1,
          "created_at": "2024-08-03T13:49:23.226Z",
          "updated_at": "2024-08-03T13:49:23.226Z"
        },
        {
          "id": 3,
          "user_login": "frankson",
          "post_id": 1,
          "created_at": "2024-08-03T10:51:44.000Z",
          "updated_at": "2024-08-03T10:51:44.000Z"
        }
      ]
    
Remover curtida: DELETE /posts/{id}/likes/1
Parâmetros de URL
id: (inteiro) ID da postagem que deseja descurtir.
Resposta: 204
Sem conteúdo.

Retornar ao início