# Rastreamento de Encomendas

Um aplicativo mobile desenvolvido em Flutter para gerenciar e rastrear encomendas. Com este app, o usuário pode cadastrar encomendas, visualizar seus detalhes, atualizar o status (simulado ou via API) e excluir registros. O projeto utiliza SQLite para armazenamento local e demonstra práticas de CRUD, integração com API e gerenciamento de estado.

## Funcionalidades

- **Cadastro de Encomendas:** Adicione novas encomendas com informações como nome, código de rastreamento e transportadora.
- **Listagem:** Visualize todas as encomendas cadastradas em uma lista.
- **Detalhes e Atualização:** Ao selecionar uma encomenda, veja os detalhes e atualize o status (integrado com um serviço de rastreamento).
- **Exclusão:** Remova encomendas indesejadas.
- **Armazenamento Local:** Dados persistentes usando SQLite (via pacote `sqflite` e `sqflite_common_ffi` para ambientes desktop).

## Tecnologias Utilizadas

- **Flutter & Dart:** Framework para desenvolvimento mobile.
- **SQLite:** Banco de dados local.
- **sqflite / sqflite_common_ffi:** Gerenciamento do banco de dados.
- **HTTP:** Requisições para simular ou integrar a uma API de rastreamento.
- **Provider (ou outro gerenciador de estado, se for utilizado):** Gerenciamento de estado (no exemplo inicial não implementado, mas pode ser evoluído).

## Estrutura do Projeto

- **/lib**
  - **/models**          -> Modelos de dados (ex: encomenda.dart)
  - **/services**        -> Comunicação com API e banco de dados (ex: database_helper.dart, tracking_service.dart)
  - **/screens**         -> Telas do aplicativo (ex: home_screen.dart, add_encomenda_screen.dart, detalhes_encomenda_screen.dart)
  - **/widgets**        -> Widgets reutilizáveis (caso seja necessário)

## Pré-requisitos

- [Flutter](https://flutter.dev/docs/get-started/install) instalado.
- Se for executar no Linux/desktop, é necessário instalar a biblioteca SQLite:
  - **Ubuntu/Debian:** `sudo apt update && sudo apt install libsqlite3-dev`
  - **Outras distribuições:** Consulte a documentação da sua distro para instalar o `sqlite3`.

## Instalação

1. **Clone o repositório:**

   ```bash
   git clone https://github.com/seu-usuario/rastreamento_flutter.git
   cd rastreamento_flutter
   ```

2. **Instale as dependências:**

   ```bash
   flutter pub get
   ```

3. **(Para Desktop) Configure o SQLite no ambiente:**

   Se estiver utilizando Linux, por exemplo, certifique-se que a biblioteca `libsqlite3.so` esteja instalada e, se necessário, configure a variável de ambiente:

   ```bash
   export LD_LIBRARY_PATH=/usr/lib:$LD_LIBRARY_PATH
   ```

## Execução

Para executar o aplicativo, utilize o comando:

```bash
flutter run
```

Se preferir rodar em um dispositivo ou emulador, selecione o dispositivo desejado no seu ambiente de desenvolvimento.

## Uso

1. **Tela Inicial:** Visualize a lista de encomendas cadastradas.
2. **Adicionar Encomenda:** Clique no botão "+" para cadastrar uma nova encomenda.
3. **Detalhes:** Clique em uma encomenda para visualizar detalhes e atualizar o status.
4. **Excluir:** Use o ícone de lixeira para remover uma encomenda.

## Possíveis Melhorias

- **Integração Real com API:** Substituir o serviço de rastreamento simulado por uma API real.
- **Notificações Push:** Integrar notificações para alertar sobre atualizações de status.
- **Gerenciamento de Estado:** Implementar Provider, Bloc ou Riverpod para um gerenciamento de estado mais robusto.
- **Interface do Usuário:** Refinar o design e a usabilidade da interface.

## Contribuição

Contribuições são bem-vindas! Sinta-se à vontade para abrir _issues_ ou enviar _pull requests_.

## Licença

Distribuído sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

---

*Desenvolvido com ❤️ em Flutter.*


---

### Como Utilizar

1. **Crie ou atualize o arquivo `README.md`** na raiz do seu projeto com o conteúdo acima (ou adaptado conforme o seu projeto).
2. **Faça o commit e envie para o GitHub:**

   ```bash
   git add README.md
   git commit -m "Adiciona README.md com informações do projeto"
   git push
   ```
