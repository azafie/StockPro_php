# StockPro – Frontend estático
Sistema de gerenciamento de estoque (somente client-side) usando **HTML5, CSS3, Bootstrap 5, Bootstrap Icons e jQuery** via CDN.  
Sem bundlers, sem SPA, sem server-side rendering. Arquivos prontos para hospedar.

---

## 📁 Estrutura
```
/assets/
  /css/
    app.css
  /js/
    app.js
  /img/
    logo.svg
index.html
produtos.html
categorias.html
fornecedores.html
compras.html
vendas.html
clientes.html
movimentacoes.html
inventario.html
relatorios.html
usuarios.html
configuracoes.html
login.html
recuperar.html
404.html
```

**CDNs (usar em todas as páginas):**
```html
<!-- HEAD -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
<link href="assets/css/app.css" rel="stylesheet">

<!-- Antes de </body> -->
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="assets/js/app.js"></script>
```

---

## 🚀 Como rodar localmente
1. Baixe/clon(e) os arquivos.
2. Abra **`login.html`** ou **`index.html`** no navegador (duplo clique).  
   > Não há build. Funciona direto do filesystem.
3. Opcional: sirva com um HTTP estático (para simular produção):
   - Python: `python -m http.server 8080`
   - Node: `npx http-server -p 8080`
4. Acesse `http://localhost:8080`.

---

## 🌗 Tema (dark mode)
- Botão na topbar com `id="themeToggle"`.
- Preferência persistida em `localStorage` (`sp-theme = 'light' | 'dark'`).
- Classe aplicada no `<html>`: `.dark-theme`.
- Paleta e superfícies controladas por **CSS Custom Properties** em `assets/css/app.css`.

---

## 🧭 Layout e Navegação
- **Topbar** fixa (classe `.topbar`) com campo de busca, ícones e menu usuário.
- **Sidebar** sanfona/accordion com **offcanvas** no mobile:  
  - `<992px`: abre/fecha como offcanvas.  
  - `≥992px`: fica fixa à esquerda (CSS ajusta `offcanvas-lg`).
- **Conteúdo** dentro de `<main class="content-wrapper">`.
- **Rodapé** simples com versão e links.

**Ativar item atual da sidebar:**  
em cada página, aponte a classe `.active` no link correspondente (já feito nos HTMLs de exemplo).

---

## 🔌 Slots de INCLUDE (back-end)
Cada página tem um bloco padrão:
```html
<!-- INCLUDE: PAGE_CONTENT_START -->
<!-- (o back-end irá injetar conteúdo aqui via include/partial) -->
<!-- INCLUDE: PAGE_CONTENT_END -->
```
E **placeholders específicos** por página, por exemplo:
- `produtos.html` → `<!-- INCLUDE: PRODUTOS_LIST -->`
- `categorias.html` → `<!-- INCLUDE: CATEGORIAS_LIST -->`
- `fornecedores.html` → `<!-- INCLUDE: FORNECEDORES_LIST -->`
- `compras.html` → `<!-- INCLUDE: COMPRAS_LIST -->`
- `vendas.html` → `<!-- INCLUDE: VENDAS_LIST -->`
- `clientes.html` → `<!-- INCLUDE: CLIENTES_LIST -->`
- `movimentacoes.html` → `<!-- INCLUDE: MOVS_LIST -->`
- `inventario.html` → `<!-- INCLUDE: INVENTARIO_WIZARD -->`
- `relatorios.html` → `<!-- INCLUDE: RELATORIOS -->`
- `usuarios.html` → `<!-- INCLUDE: USERS_LIST -->`
- `configuracoes.html` → `<!-- INCLUDE: SETTINGS -->`

> **Observação:** Os includes são **comentários** HTML para orientar a injeção. No back-end, substitua/insira HTML nesses pontos.

### Exemplos de integração
**PHP (include simples):**
```php
<?php include __DIR__ . '/partials/produtos_list.php'; ?>
```

**Node (Express + EJS):**
```ejs
<!-- INCLUDE: PRODUTOS_LIST -->
<%- include('partials/produtos_list'); %>
```

**Python (Flask + Jinja2):**
```jinja2
{# INCLUDE: PRODUTOS_LIST #}
{% include 'partials/produtos_list.html' %}
```

**Dica:** mantenha o HTML gerado **sem dependências adicionais**; Bootstrap já está disponível.

---

## ✅ Validações & UX
- **jQuery** apenas para:
  - Alternar tema (dark/light).
  - Inicializar tooltips/toasts do Bootstrap.
  - Feedbacks rápidos via `showToast(msg, type)`.
  - Pequenas validações client-side (ex.: campos `required` + classes `is-invalid` se desejar estender).
- **Acessibilidade:**
  - `aria-label` em ícones acionáveis.
  - `aria-expanded` nos botões da sanfona.
  - Foco visível padrão do Bootstrap.
  - Não usar apenas cor para feedback (badges/ícones/texto ajudam).

---

## 🧰 Padrões de Tabela e Form
- Tabelas: `table table-hover table-striped align-middle`, cabeçalho sticky.
- Ações: botões `btn-sm` com ícones `Bootstrap Icons`.
- Form em modais com campos `required` quando aplicável.
- Filtros sempre no topo com `row g-2`.

---

## 🔔 Toast helper
Disponível em `assets/js/app.js`:
```js
showToast('Mensagem aqui', 'success'); // types: primary, success, danger, warning, info...
```
Container automático `#toastContainer` é criado se não existir.

---

## 🎯 Checklist de produção
- [ ] Conferir **links relativos** da sidebar/topbar.
- [ ] Trocar logo em `assets/img/logo.svg` se desejar.
- [ ] Revisar textos dummy (cards, tabelas, modais).
- [ ] Marcar item **.active** da sidebar em cada página.
- [ ] Verificar contraste no **dark mode** para sua paleta/branding.
- [ ] Habilitar HTTPS e cache estático no host (CDNs já otimizam).

---

## 🐞 Dicas & Problemas comuns
1. **Sidebar sobrepondo topbar no mobile**  
   → Garanta a estrutura idêntica dos arquivos (topbar antes do offcanvas) e o CSS de `@media` existente em `app.css`.

2. **Tooltip não aparece**  
   → Elementos precisam do atributo `data-bs-toggle="tooltip"` e o JS do Bootstrap (bundle) deve estar carregado **após** jQuery. `app.js` inicializa automaticamente.

3. **Preferência de tema não persiste**  
   → Verifique se o navegador permite `localStorage` (modo privado restrito) e se o `id="themeToggle"` existe na página.

4. **Tabelas “saltando” no cabeçalho sticky**  
   → A classe do thead já define fundo. Evite colocar o thead fora do `.table-responsive`.

---

## 🧾 Licença
Uso interno/privado livre. Ajuste conforme sua necessidade.
