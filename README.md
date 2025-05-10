## 🌐 [English Version of README](README_EN.md)

# **GeoMap** - Sistema de Pagamento por Serviços Ambientais

**GeoMap** é um sistema desenvolvido com Flutter, que oferece funcionalidades para gerenciar beneficiários, relatórios, localização geográfica e integrações com serviços externos, incluindo Firebase e APIs REST. Este sistema foi projetado para fornecer uma interface fácil de usar para visualizar, editar e registrar informações relacionadas a áreas ambientais e atividades de beneficiários.

## 🔨 **Funcionalidades do Projeto**

* **Autenticação de Usuários**: Login, cadastro e recuperação de senha.
* **Gerenciamento de Beneficiários**: Visualização, edição e registro de beneficiários.
* **Relatórios**: Criação, edição e sincronização de relatórios.
* **Localização e Geolocalização**: Obtenção da localização do usuário e manipulação de dados EXIF de fotos.
* **Notificações Push**: Envio de notificações usando o Firebase.
* **Armazenamento Local**: Suporte para armazenamento local de dados offline, utilizando o SharedPreferences.
* **Dashboard**: Painel de controle com gráficos e mapas interativos.
* **Mapas Interativos**: Exibição de beneficiários no mapa com dados geoespaciais.

### Exemplo Visual do Projeto

![Exemplo Visual](caminho/para/imagem.jpg)

## ✔️ **Técnicas e Tecnologias Utilizadas**

* **Flutter**: Framework utilizado para o desenvolvimento da aplicação móvel.
* **Firebase**: Para autenticação de usuários e notificações push.
* **Geolocator**: Para obter a localização geográfica do usuário.
* **Exif**: Para manipulação de dados EXIF em imagens.
* **SharedPreferences**: Para armazenamento local de dados persistentes.
* **http**: Para fazer requisições HTTP para interagir com APIs externas.
* **Cupertino Icons**: Para ícones personalizados no estilo iOS.
* **flutter\_localizations**: Para suporte a múltiplos idiomas.
* **CSV e PDF**: Manipulação de arquivos CSV e geração de PDFs.
* **Webview**: Para renderizar conteúdo web dentro da aplicação.
* **image\_picker**: Para selecionar imagens da galeria ou tirar novas fotos.
* **permission\_handler**: Para solicitar permissões do usuário.
* **fl\_chart**: Para gráficos interativos dentro do app.
* **hive**: Para armazenamento local de dados em um banco de dados NoSQL.
* **path\_provider**: Para localizar o diretório adequado para armazenar arquivos.
* **easy\_localization**: Para facilitar a tradução e internacionalização da aplicação.
* **uuid**: Para gerar identificadores únicos (UUIDs).
* **flutter\_launcher\_icons**: Para configurar e gerar o ícone da aplicação.
* **flutter\_local\_notifications**: Para gerenciar notificações locais no app.
* **csv**: Para manipulação de arquivos CSV.
* **pdf e printing**: Para gerar e imprimir documentos PDF.
* **webview\_flutter**: Para exibir conteúdo da web dentro do aplicativo.
* **latlong2**: Para trabalhar com coordenadas geográficas em formatos de latitude e longitude.
* **firebase\_core e firebase\_messaging**: Para integrar o Firebase e gerenciar notificações push.

## 📁 **Estrutura do Projeto**

A estrutura do projeto está organizada da seguinte forma:

```
|-- **components/**: Contém componentes reutilizáveis de UI.
|-- **screens/**: Contém as telas da aplicação.
|-- **services/**: Contém os serviços que lidam com APIs, autenticação e dados locais.
|-- **models/**: Representações dos dados da aplicação.
|-- **utils/**: Contém utilitários auxiliares para funcionalidades diversas.
```

## **Instalação**

### Passo 1: Clone o Repositório

Clone o repositório para o seu computador utilizando o comando:

```bash
git clone <URL_DO_REPOSITORIO>
```

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

Se estiver utilizando um dispositivo Android ou iOS, ele será carregado no emulador ou no dispositivo físico.

## **Configuração do Firebase**

O projeto usa Firebase para notificações e autenticação. Para configurar o Firebase:

1. Crie um novo projeto no [Firebase Console](https://console.firebase.google.com/).
2. Adicione o **Firebase SDK** ao seu aplicativo (Android e iOS).
3. Configure as chaves de autenticação do Firebase no arquivo `firebase_options.dart`.
4. Baixe o arquivo de configuração do Firebase (GoogleService-Info.plist para iOS e google-services.json para Android) e adicione-os nas pastas apropriadas do projeto.

## **Dependências do Projeto**

Aqui está a lista de dependências que o projeto utiliza:

* **flutter\_localizations**: Para suporte a múltiplos idiomas.
* **geolocator**: Para obter a localização do usuário.
* **google\_maps\_flutter**: Para exibir mapas no aplicativo.
* **firebase\_messaging**: Para enviar notificações push.
* **image\_picker**: Para tirar fotos ou selecionar imagens.
* **fl\_chart**: Para gráficos interativos.
* **pdf**: Para gerar relatórios em formato PDF.
* **csv**: Para trabalhar com arquivos CSV.
* **hive**: Banco de dados local NoSQL.
* **permission\_handler**: Para gerenciar permissões de acesso.
* **flutter\_map**: Para trabalhar com mapas interativos.

## **Funcionalidades**

### **Gerenciamento de Beneficiários**

O aplicativo permite que o usuário visualize, adicione e edite informações sobre os beneficiários, incluindo dados pessoais e a área em que estão localizados. Essas informações podem ser salvas localmente ou enviadas para um servidor.

### **Relatórios de Atividades**

A funcionalidade de relatórios permite que o usuário registre atividades, como a criação e envio de relatórios sobre áreas cobertas, tipos de vegetação, recursos naturais e humanos, entre outros.

### **Mapas Interativos**

A aplicação utiliza a biblioteca `flutter_map` para exibir mapas interativos. Os pontos dos beneficiários são mostrados no mapa com marcadores, e ao clicar em um marcador, o usuário pode visualizar mais detalhes sobre aquele beneficiário.

### **Notificações Push**

O Firebase é usado para enviar notificações para os usuários. As notificações podem ser programadas para alertar os usuários sobre novas atividades ou relatórios, como a sincronização de dados offline.

## **Internacionalização**

O projeto usa `easy_localization` para suportar múltiplos idiomas. Atualmente, a aplicação está configurada para suportar o português, mas você pode adicionar mais idiomas facilmente, criando arquivos de tradução em `assets/translations/`.

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
