#  Solicitações APP

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![FastAPI](https://img.shields.io/badge/FastAPI-009688?style=for-the-badge&logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com/)
[![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://www.python.org/)
[![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)](https://supabase.com/)
[![Render](https://img.shields.io/badge/Render-46E3B7?style=for-the-badge&logo=render&logoColor=white)](https://render.com/)

Uma solução completa para gestão de chamados urbanos voltada para prefeituras, conectando cidadãos e a administração pública de forma rápida, transparente e eficiente.

---

**HEIMDALL SOLUTIONS**

##  Sobre o Projeto

O **Solicitações APP** foi desenvolvido para modernizar e facilitar a abertura, o acompanhamento e a resolução de demandas públicas municipais. A aplicação combina a flexibilidade do desenvolvimento mobile com uma infraestrutura em nuvem escalável e de baixo custo, eliminando a dependência de servidores físicos e simplificando a manutenção.

---

## Demonstração em Vídeo e Página Web

Confira o funcionamento do aplicativo na prática:

(EM DESENVOLVIMENTO)
[![Assista ao vídeo](https://img.shields.io/badge/YouTube-Demo-red?style=for-the-badge&logo=youtube&logoColor=white)](https://youtube.com)

**LINK DA PÁGINA WEB** [gabrielhencastro.github.io/SolicitacoesLandingPage](https://gabrielhencastro.github.io/SolicitacoesLandingPage) |

##  Tecnologias e Arquitetura

O ecossistema do projeto é dividido em três camadas principais:

###  **Front-End & Mobile**
* **Mobile App:** Desenvolvido em **Flutter & Dart**, oferecendo uma experiência nativa, responsiva e intuitiva para o cidadão.
* **Landing Page Web:** Desenvolvida com **HTML5, CSS3, JavaScript e Bootstrap** para apresentar o projeto e direcionar os usuários.

###  **Back-End & Processamento**
* **FastAPI (Python):** Servidor de API RESTful hospedado na nuvem via **Render**, focado em alta performance e baixo tempo de resposta.
* **Pandas & FPDF:** Módulos dedicados ao processamento denso de dados e geração automatizada de relatórios analíticos em formato PDF para a gestão pública.

###  **Banco de Dados & BaaS**
* **Supabase (PostgreSQL):** Utilizado como Backend-as-a-Service para:
  * Banco de dados relacional em nuvem com alta escalabilidade.
  * Autenticação rápida e segura via SDK nativo do Flutter.
  * Armazenamento de arquivos e imagens anexadas às solicitações (*Storage*).
  * Segurança em ROW LEVEL SECURITY (RLS).

---

##  Funcionalidades Principais

-  **Abertura de Chamados:** Cadastro de ocorrências municipais com foto, descrição e localização.
-  **Autenticação Segura:** Login e cadastro de usuários integrados ao Supabase Auth.
-  **Emissão de Relatórios:** Geração automatizada de relatórios gerenciais em PDF via backend Python.
-  **Arquitetura 100% Serverless/Cloud:** Sem dependência de hardware físico local.

---

##  Repositórios Relacionados

| Componente | Repositório / Status |
| :--- | :--- |
| **API REST (Python / FastAPI)** | [github.com/gabrielhencastro/SolicitacoesApi](https://github.com/gabrielhencastro/SolicitacoesApi) |
| **LANDING PAGE WEB** | [github.com/gabrielhencastro/SolicitacoesLandingPage](https://github.com/gabrielhencastro/SolicitacoesLandingPage) |

---

##  Como Executar o Projeto Mobile

### **Pré-requisitos**
* [Flutter SDK](https://flutter.dev/docs/get-started/install) instalado e configurado.
* [Git](https://git-scm.com/) instalado.
* Conta no [Supabase](https://supabase.com/) configurada.

### **Passos para rodar**

1. **Clone este repositório:**
   ```bash
   git clone [https://github.com/gabrielhencastro/solicitacoes_app.git](https://github.com/gabrielhencastro/solicitacoes_app.git)
   cd solicitacoes_app

2. **Verifique como configurar a API no repositório anteriormente apresentado.**

3. **Configure as variáveis de ambiente:**
- SUPABASE_URL
- PUBLISHABLE_KEY
- URL_API

4. **Rode o app**