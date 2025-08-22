
# 📊 **StockPro - Sistema de Gestão de Estoque**

**StockPro** é um sistema de gerenciamento de estoque feito **sem o uso de frameworks**, utilizando apenas **PHP**, **HTML5**, **CSS3** e **JavaScript**. O objetivo é criar uma aplicação simples, eficiente e sustentável, que seja fácil de manter e escalar ao longo do tempo. A escolha por tecnologias modernas e bem estabelecidas garante que o sistema seja **sustentável** e compatível com as melhores práticas da indústria.

---

## 🚀 **Funcionalidades**

- **CRUD de Produtos**:
  - Adicionar, editar e excluir produtos
  - Exibição de lista de produtos com informações detalhadas (SKU, nome, categoria, preço, estoque e status)
  - Filtros e busca por nome, código, categoria e status

- **Interface Intuitiva**:
  - Modal para criação e edição de produtos
  - Máscaras de moeda para preço
  - Badges de status (Ativo/Inativo) para identificação rápida

- **Persistência de Dados**:
  - **localStorage** (temporário) para manter os dados entre as sessões do navegador

- **Arquitetura Modular**:
  - Código separado por responsabilidades, facilitando manutenção e expansão
  - Baseada em **JavaScript (ES6+), HTML5, CSS3**, e uso do **Bootstrap** para a interface.

---

## 🛠️ **Tecnologias Utilizadas**

- **Frontend**:
    - **HTML5** (sem uso de frameworks)
    - **CSS3** (com **Bootstrap** para layout responsivo, sem uso de frameworks pesados)
    - **JavaScript (ES6+)**
    - **jQuery 3.7.1** (para manipulação de DOM e eventos)

- **Backend (Futuro)**:
    - **PHP** (sem frameworks pesados, apenas código puro)
    - **MySQL/PostgreSQL** (dependendo da configuração futura)

- **Armazenamento**:
    - **localStorage** para persistência temporária dos dados (para testes e protótipos)

---

## ⚙️ **Arquitetura do Sistema**

O sistema é projetado de maneira simples e eficiente, sem a necessidade de frameworks pesados. A arquitetura é modular, e os dados são armazenados localmente enquanto a integração com o backend está planejada para o futuro.

### **Estrutura Atual**:

```
┌─────────────────────────────────────────────────────────────┐
│                        FRONTEND (Cliente)                    │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   HTML/CSS   │  │  JavaScript  │  │   Bootstrap  │      │
│  │   (Views)    │  │   (Lógica)   │  │     (UI)     │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│                                                               │
│  ┌────────────────────────────────────────────────────┐     │
│  │                  StockPro Core                      │     │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────────┐    │     │
│  │  │   core   │  │   utils  │  │   produtos    │    │     │
│  │  │    .js   │  │    .js   │  │  _core.js    │    │     │
│  │  └──────────┘  └──────────┘  └──────────────┘    │     │
│  └────────────────────────────────────────────────────┘     │
│                                                               │
│  ┌────────────────────────────────────────────────────┐     │
│  │                    UI Modules                       │     │
│  │  ┌──────────────┐  ┌──────────────┐               │     │
│  │  │  produtos    │  │   (futuro)   │               │     │
│  │  │   _ui.js     │  │  categorias  │               │     │
│  │  └──────────────┘  └──────────────┘               │     │
│  └────────────────────────────────────────────────────┘     │
│                                                               │
│  ┌────────────────────────────────────────────────────┐     │
│  │              Armazenamento Local                    │     │
│  │                 (localStorage)                      │     │
│  │  ┌──────────────────────────────────────────┐    │     │
│  │  │  Key: stockpro_produtos                   │    │     │
│  │  │  Value: JSON Array de Produtos            │    │     │
│  │  └──────────────────────────────────────────┘    │     │
└─────────────────────────────────────────────────────────────┘

                            ⬇️ (Futura Integração)

┌─────────────────────────────────────────────────────────────┐
│                        BACKEND (Servidor)                    │
├─────────────────────────────────────────────────────────────┤
│  ┌────────────────┐  ┌─────────────┐  ┌──────────────┐    │
│  │   API REST     │  │   PHP/Node  │  │   MySQL/     │    │
│  │   (Futuro)     │  │   (Futuro)  │  │   PostgreSQL │    │
│  └────────────────┘  └─────────────┘  └──────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

---

## 🛠️ **Instalação e Execução**

### **Passos para rodar localmente**:

1. Clone o repositório:
    ```bash
    git clone https://github.com/seu-usuario/stockpro.git
    ```

2. Navegue até a pasta do projeto:
    ```bash
    cd stockpro
    ```

3. Abra o arquivo `index.html` em seu navegador:
    - O sistema não necessita de servidor PHP no momento. Porém, para futuras versões, será necessário um servidor local com PHP.

---

## 📝 **Próximos Passos**

### **Fase 1: Módulos Básicos** 🎯
- Implementação de **Categorias** para os produtos.
- **Movimentações de Estoque**: Entrada e saída de produtos.
- **Fornecedores**: Cadastro de fornecedores e vinculação com produtos.

### **Fase 2: Backend e API** 🔌
- Criar a **API REST** para comunicação com o backend:
  - **GET** para listar produtos
  - **POST** para criar produtos
  - **PUT** para editar produtos
  - **DELETE** para excluir produtos

### **Fase 3: Recursos Avançados** 🚀
- Adicionar **gráficos** e relatórios.
- Implementar **login** e **permissões** para usuários.
- **Exportação e Importação** de dados (Excel, CSV).

---

## 🔧 **Comandos Úteis**

- Para verificar os produtos armazenados no **localStorage**, use o seguinte comando no **Console do navegador**:
    ```javascript
    JSON.parse(localStorage.getItem('stockpro_produtos'))
    ```

- Para adicionar um novo produto via console, use:
    ```javascript
    window.StockPro.produtos.criar({
        codigo: 'SKU-001',
        nome: 'Produto Teste',
        preco: 100.00,
        status: 'ATIVO'
    })
    ```

- Para limpar os dados armazenados:
    ```javascript
    localStorage.clear()
    ```

---

## 🐛 **Problemas Conhecidos**

1. **Paginação não implementada**: Todos os produtos são exibidos de uma vez.
2. **Validação de estoque negativo não realizada**: Permite estoque negativo.
3. **Sem backup automático**: Os dados são salvos apenas no **localStorage**, o que pode ser perdido se o cache for limpo.

---

## 📅 **Versões Futuras**

- **Versão 2.0**: Implementação do **backend** (API REST).
- **Versão 3.0**: Dashboard com gráficos, relatórios e funcionalidades avançadas.

---

## 💬 **Contato e Suporte**

**Projeto:** StockPro - Sistema de Gestão de Estoque  
**Versão:** 1.0.0  
**Última Atualização:** Janeiro 2025  
**Status:** Em desenvolvimento ativo  

--- 

**FIM DO RELATÓRIO**
