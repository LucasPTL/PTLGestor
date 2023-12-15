## PTLGestor
  PTLGestor é um sistema desenvolvido para auxiliar na organização de tarefas.

## Instalação
  Necessita-se apenas de ter um banco firebase pré-criado e as dll's incluidas na pasta, após isso, apenas executar o .exe já será o suficiente para iniciar a aplicação corretamente.

## Utilização do código
  Necessário componente da library ZEOS para conexão com o banco de dados Firebase 2.5.

## Estrutura do sistema
  Model
  Os modelos representam as entidades de classe do sistema, que são as listas de tarefas e as tarefas. Cada lista tem um nome único e pode conter várias tarefas. Cada tarefa tem obrigatoriamente um título, uma descrição e uma data de conclusão opcional.
  
  View
  Como foi desenvolvido em Lazarus/Delphi, o próprio formulário é a view do que é construido.
  
  Controller
  As controllers gerenciam a lógica principalmente da geração dos elementos visuais e operações envolvendo o banco de dados. Há uma controladora para as listas e outra para as tarefas. Elas processam as ações do usuário, como criar uma nova lista, adicionar uma tarefa a 
  uma lista, marcar uma Tarefa como concluída, etc.

## Utilização do Sistema
  O primeiro passo é a configuração do banco, onde, no canto inferior direito do sistema, existe um botão com o símbolo de conexão, onde, caso esteja vermelho, a conexão está inválida, e apitará um erro na parte inferior do sistema. Ao clicar no botão, a configuração é simples, somente sendo necessário redirecionar o arquivo FDB do banco, onde o usuário e a senha estão definidas a padrão do windows para o firebird, podendo alterar, caso seja de sua escolha outra senha/usuário. Ao clicar em testar e depois em confirmar, a sua conexão com o banco estará feita. 

  A primeira tela é a tela inicial, aonde se tem um botão onde sepode adicionar uma nova tarefa, ao clicar, abre-se a tela de criação, aonde é solicitado uma descrição para a lista, não é possível ter duas listas com nome siguais.
  Ao criar uma lista, pode se edita-la, aplicando os mesmos critérios e utilizações da tela de criação. Pode-se gerar um relatório contendo todas as listas, aonde será exibido em uma tabela criada via html no seu navegador padrão, outra opção é a exclusão, aonde só é   
  permitida quando não se tem tarefas cadastradas na lista.

  Ao clicar em uma lista, é feito o redirecionamento para a tela de tarefas, aonde se tem o botão de criação de tarefa, que, ao clicar, abre a tela de criação aonde se tem: Título, Descrição e Data de conclusão, aonde Titulo e Descrição são obrigatórios.
  Na lista de tarefas, se tem os botões de Editar e Exclusão, aonde o Editar segue o mesmo padrão do criar, e a exclusão é feita sem restrições. 
  Caso a tarefa contenha data de conclusão, a exibição será verde, caso contrária, padrão (branco).
  
## Desenvolvido por Lucas Honorio Peratelli.
