## 🌐 [English Version of README](README_EN.md)

# **GeoMap** - Sistema de Pagamento por Serviços Ambientais

**GeoMap** é um sistema desenvolvido com Flutter, projetado para gerenciar beneficiários, relatórios, localização geográfica e integrações com serviços externos, incluindo Firebase e APIs REST. Ele oferece uma interface intuitiva para visualizar, editar e registrar informações sobre áreas ambientais e atividades de beneficiários, com foco em funcionalidades como geolocalização, notificações push e armazenamento offline.

## 🔨 **Funcionalidades do Projeto**

* **Autenticação de Usuários**: Implementação de login, cadastro, recuperação de senha e autenticação com Firebase.
* **Gerenciamento de Beneficiários**: Visualização, edição e registro de beneficiários, com informações detalhadas como dados pessoais e localização geoespacial.
* **Relatórios**: Criação, edição e sincronização de relatórios com dados sobre áreas ambientais, tipos de vegetação, e outros recursos.
* **Localização e Geolocalização**: Obtenção da localização do usuário e manipulação de dados EXIF de fotos, com suporte a coordenadas GPS.
* **Notificações Push**: Envio de notificações push aos usuários utilizando o Firebase Messaging.
* **Armazenamento Local**: Suporte para armazenamento local de dados offline, utilizando `SharedPreferences` e sincronização automática quando a rede estiver disponível.
* **Dashboard**: Painel de controle com gráficos interativos e mapas que exibem informações sobre beneficiários e suas atividades.
* **Mapas Interativos**: Exibição de beneficiários no mapa com dados geoespacionais, utilizando o `flutter_map` para criar mapas dinâmicos e interativos.

### Exemplo Visual do Projeto

![Exemplo Visual](caminho/para/imagem.jpg)

## ✔️ **Técnicas e Tecnologias Utilizadas**

* **Flutter**: Framework utilizado para o desenvolvimento da aplicação móvel.
* **Firebase**: Autenticação de usuários e envio de notificações push.
* **Geolocator**: Para obter a localização geográfica do usuário.
* **Exif**: Para manipulação de dados EXIF em imagens.
* **SharedPreferences**: Para armazenamento local de dados persistentes.
* **http**: Para fazer requisições HTTP e interagir com APIs externas.
* **Cupertino Icons**: Para ícones personalizados no estilo iOS.
* **flutter_localizations**: Suporte a múltiplos idiomas.
* **CSV e PDF**: Manipulação de arquivos CSV e geração de PDFs para relatórios.
* **Webview**: Para renderizar conteúdo da web dentro da aplicação.
* **image_picker**: Para selecionar imagens ou tirar novas fotos.
* **permission_handler**: Para gerenciar permissões de acesso.
* **fl_chart**: Para gráficos interativos dentro do app.
* **hive**: Banco de dados local NoSQL.
* **path_provider**: Para encontrar o diretório adequado para armazenar arquivos.
* **easy_localization**: Para facilitar a tradução e internacionalização da aplicação.
* **uuid**: Para gerar identificadores únicos (UUIDs).
* **flutter_launcher_icons**: Para configurar e gerar ícones para a aplicação.
* **flutter_local_notifications**: Para gerenciar notificações locais no app.
* **csv**: Para manipulação de arquivos CSV.
* **pdf e printing**: Para geração e impressão de documentos PDF.
* **webview_flutter**: Para exibir conteúdo da web dentro da aplicação.
* **latlong2**: Para manipulação de coordenadas geográficas em formatos de latitude e longitude.
* **firebase_core**: Para integrar o Firebase no projeto.

## 📁 **Estrutura do Projeto e Descrição de Cada Pasta/Arquivo**

### **|-- Projeto 3.txt**
* **Descrição**: Arquivo de texto que provavelmente contém informações ou especificações relacionadas ao projeto, como anotações, ideias ou planejamento.

### **|-- beneficiary**
* **Descrição**: Pasta que contém arquivos relacionados à funcionalidade de beneficiários dentro do sistema, como os dados e suas operações.

### **|-- components**
* **Descrição**: Contém componentes reutilizáveis de UI que são utilizados em várias partes do aplicativo.
  - **custom_button.dart**: Define um botão personalizado com estilização específica, utilizado em diversas telas.
  - **custom_input.dart**: Componente que define um campo de entrada (input) personalizado, com validação ou estilização customizada.
  - **whatsapp_button.dart**: Componente que cria um botão estilizado para interagir com o WhatsApp, possivelmente para facilitar o contato com os usuários.

### **|-- firebase_options.dart**
* **Descrição**: Arquivo de configuração do Firebase, que inclui as opções de integração do Firebase com o aplicativo, como as chaves de autenticação e outros detalhes de configuração necessários para Firebase.

### **|-- ideias.txt**
* **Descrição**: Arquivo de texto que provavelmente contém ideias e propostas para novas funcionalidades ou melhorias no sistema.

### **|-- main.dart**
* **Descrição**: Arquivo principal de entrada do aplicativo. Nele, o Flutter inicializa a aplicação e define as rotas principais do sistema.

### **|-- models**
* **Descrição**: Contém as representações dos dados da aplicação, como classes que mapeiam as entidades do sistema.
  - **activity.dart**: Representação de uma atividade realizada por um beneficiário ou no contexto ambiental.
  - **beneficiary.dart**: Representação de um beneficiário, com suas informações pessoais, localização e outras propriedades.
  - **offline_record.dart**: Representação de um registro feito offline, que será sincronizado com o servidor assim que possível.
  - **report.dart**: Representação de um relatório de atividades ou dados ambientais.

### **|-- screens**
* **Descrição**: Contém as telas (screens) da aplicação, onde as interfaces do usuário são desenhadas e interagem com os dados.
  - **admin_screen.dart**: Tela principal para o administrador, provavelmente com controle de acesso a recursos e informações sensíveis.
  - **beneficiary_detail_screen.dart**: Tela que exibe detalhes de um beneficiário, incluindo suas informações e atividades.
  - **beneficiary_edit_screen.dart**: Tela para editar informações de um beneficiário.
  - **beneficiary_screen.dart**: Tela de listagem de beneficiários, onde os usuários podem visualizar ou selecionar beneficiários.
  - **dashboard**
    - **activity_chart.dart**: Componente que exibe gráficos sobre as atividades ou dados coletados.
    - **dashboard_screen.dart**: Tela do dashboard que reúne os principais dados, gráficos e informações sobre os beneficiários e suas atividades.
    - **embedded_dashboard.dart**: Uma versão incorporada do dashboard, possivelmente uma versão compactada ou mais simples.
    - **map_view.dart**: Tela que exibe o mapa com localização dos beneficiários ou áreas de interesse.
    - **summary_cards.dart**: Componente que exibe resumos de dados em cartões, como total de beneficiários ou áreas mapeadas.
  - **forgot_password_screen.dart**: Tela onde o usuário pode solicitar a recuperação de senha.
  - **home_screen.dart**: Tela principal do usuário, onde ele tem acesso ao conteúdo principal da aplicação.
  - **login_screen.dart**: Tela de login onde o usuário insere suas credenciais para acessar o sistema.
  - **profile_screen.dart**: Tela onde o usuário pode visualizar e editar suas informações de perfil.
  - **report_edit_screen.dart**: Tela para editar um relatório previamente criado.
  - **signup_screen.dart**: Tela de cadastro para novos usuários se registrarem no sistema.

### **|-- services**
* **Descrição**: Contém os serviços responsáveis por interagir com APIs externas, realizar operações de backend ou gerenciar funcionalidades internas.
  - **api_service.dart**: Serviço responsável por realizar requisições HTTP para APIs externas.
  - **auth_service.dart**: Serviço de autenticação, responsável pelo login, cadastro e recuperação de senha.
  - **geolocation_service.dart**: Serviço que obtém e manipula a localização geográfica do usuário.
  - **image_processing_service.dart**: Serviço para processar imagens, como análise com IA ou manipulação de metadados EXIF.
  - **local_storage_service.dart**: Serviço que gerencia o armazenamento local de dados (ex: `SharedPreferences`).
  - **notification_service.dart**: Serviço responsável por gerenciar as notificações, tanto push quanto locais, com o Firebase.
  - **report_service.dart**: Serviço que lida com a criação, edição e sincronização de relatórios.
  - **session_manager.dart**: Serviço que gerencia a sessão do usuário, como autenticação e dados persistentes da sessão.

### **|-- theme.dart**
* **Descrição**: Arquivo que define o tema visual do aplicativo (cores, fontes, estilos de widgets). Ele contém as configurações de tema claro e escuro para a interface do usuário.

### **|-- utils**
* **Descrição**: Contém utilitários auxiliares para funcionalidades gerais do sistema.
  - **date_helper.dart**: Utilitário para manipulação e formatação de datas no aplicativo, facilitando a exibição e manipulação de datas no formato adequado.

## **Instalação**

### Passo 1: Clone o Repositório

Clone o repositório para o seu computador utilizando o comando:

```bash
git clone <URL_DO_REPOSITORIO>
````

### Passo 2: Instale as Dependências

Acesse o diretório do projeto e instale as dependências do projeto:

```bash
cd competspa
flutter pub get
```

### Passo 3: Execute o Aplicativo

Para rodar o aplicativo, utilize o comando abaixo:

```bash
flutter run
```

Se estiver utilizando um dispositivo Android ou iOS, o aplicativo será carregado no emulador ou no dispositivo físico.

## **Configuração do Firebase**

O projeto utiliza o Firebase para autenticação e notificações push. Para configurar o Firebase:

1. Crie um novo projeto no [Firebase Console](https://console.firebase.google.com/).
2. Adicione o **Firebase SDK** ao seu aplicativo para Android e iOS.
3. Configure as chaves de autenticação no arquivo `firebase_options.dart`.
4. Baixe o arquivo de configuração do Firebase (GoogleService-Info.plist para iOS e google-services.json para Android) e adicione-os nas pastas apropriadas do projeto.

## **Dependências do Projeto**

Aqui está a lista de dependências que o projeto utiliza:

* **flutter\_localizations**: Suporte a múltiplos idiomas.
* **geolocator**: Para obter a localização do usuário.
* **google\_maps\_flutter**: Para exibir mapas no aplicativo.
* **firebase\_messaging**: Para enviar notificações push.
* **image\_picker**: Para tirar fotos ou selecionar imagens.
* **fl\_chart**: Para gráficos interativos.
* **pdf**: Para gerar relatórios em formato PDF.
* **csv**: Para manipulação de arquivos CSV.
* **hive**: Banco de dados local NoSQL.
* **permission\_handler**: Para gerenciar permissões de acesso.
* **flutter\_map**: Para exibir mapas interativos.
* **firebase\_core**: Para integrar o Firebase no projeto.

## **Funcionalidades**

### **Gerenciamento de Beneficiários**

O aplicativo permite que o usuário visualize, adicione e edite informações sobre os beneficiários, incluindo dados pessoais e a área geoespacial. Essas informações podem ser salvas localmente ou enviadas para um servidor.

### **Relatórios de Atividades**

A funcionalidade de relatórios permite que o usuário registre atividades, como a criação e envio de relatórios sobre áreas cobertas, tipos de vegetação, recursos naturais e humanos, entre outros.

### **Mapas Interativos**

A aplicação utiliza a biblioteca `flutter_map` para exibir mapas interativos. Os pontos dos beneficiários são mostrados no mapa com marcadores. Ao clicar em um marcador, o usuário pode visualizar mais detalhes sobre o beneficiário.

### **Notificações Push**

O Firebase é utilizado para enviar notificações para os usuários. As notificações podem ser programadas para alertar os usuários sobre novas atividades ou relatórios, como a sincronização de dados offline.

## **Internacionalização**

O projeto usa `easy_localization` para suportar múltiplos idiomas. Atualmente, a aplicação está configurada para suportar o português, mas novos idiomas podem ser facilmente adicionados criando arquivos de tradução em `assets/translations/`.

## **Deploy**

### Para iOS

1. Abra o projeto no Xcode (`ios/Runner.xcworkspace`).
2. Conecte seu dispositivo ou use o simulador.
3. Selecione **Product > Archive** para criar um arquivo de distribuição.
4. Faça o upload para a App Store.

### Para Android

1. Execute o comando abaixo para gerar o APK:

```bash
flutter build apk --release
```

2. O arquivo gerado estará em `build/app/outputs/flutter-apk/app-release.apk`.
3. Envie o APK para a Google Play Store ou instale diretamente no seu dispositivo.

## **Contribuindo**

Se você deseja contribuir com melhorias ou correções para o projeto, fique à vontade para fazer um **fork** do repositório e enviar um **pull request** com suas modificações.
