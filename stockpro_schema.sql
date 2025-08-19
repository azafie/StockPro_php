
-- StockPro · Banco de Dados (PostgreSQL)
-- Versão: v1.0 (DDL + seeds + views)
-- Observação: rode em PostgreSQL 13+

-- ========================================================
-- Tipos ENUM
-- ========================================================
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'product_status') THEN
    CREATE TYPE product_status AS ENUM ('ATIVO','INATIVO');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'partner_status') THEN
    CREATE TYPE partner_status AS ENUM ('ATIVO','INATIVO','PENDENTE');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'movement_type') THEN
    CREATE TYPE movement_type AS ENUM ('ENTRADA','SAIDA','AJUSTE');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'order_status') THEN
    CREATE TYPE order_status AS ENUM ('PENDENTE','CONCLUIDA','FATURADA','CANCELADA');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_role') THEN
    CREATE TYPE user_role AS ENUM ('ADMIN','OPERACIONAL','CONSULTA');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_status') THEN
    CREATE TYPE user_status AS ENUM ('ATIVO','INATIVO');
  END IF;
END $$;

-- ========================================================
-- Tabelas básicas
-- ========================================================
CREATE TABLE IF NOT EXISTS categorias (
  id            BIGSERIAL PRIMARY KEY,
  nome          VARCHAR(120) NOT NULL UNIQUE,
  descricao     TEXT
);

CREATE TABLE IF NOT EXISTS locais (
  id            BIGSERIAL PRIMARY KEY,
  nome          VARCHAR(120) NOT NULL UNIQUE,
  cidade        VARCHAR(120),
  ativo         BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS produtos (
  id            BIGSERIAL PRIMARY KEY,
  sku           VARCHAR(40) NOT NULL UNIQUE,
  nome          VARCHAR(200) NOT NULL,
  categoria_id  BIGINT REFERENCES categorias(id) ON DELETE SET NULL,
  unidade       VARCHAR(10) NOT NULL DEFAULT 'un',
  preco         NUMERIC(12,2) NOT NULL DEFAULT 0,
  estoque_min   INTEGER NOT NULL DEFAULT 0,
  status        product_status NOT NULL DEFAULT 'ATIVO',
  descricao     TEXT,
  criado_em     TIMESTAMP NOT NULL DEFAULT now(),
  atualizado_em TIMESTAMP NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_produtos_categoria ON produtos(categoria_id);
CREATE INDEX IF NOT EXISTS idx_produtos_status ON produtos(status);

CREATE TABLE IF NOT EXISTS fornecedores (
  id            BIGSERIAL PRIMARY KEY,
  nome          VARCHAR(200) NOT NULL,
  contato       VARCHAR(120),
  telefone      VARCHAR(40),
  email         VARCHAR(200),
  cidade        VARCHAR(120),
  status        partner_status NOT NULL DEFAULT 'ATIVO',
  criado_em     TIMESTAMP NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_fornecedores_status ON fornecedores(status);

CREATE TABLE IF NOT EXISTS clientes (
  id            BIGSERIAL PRIMARY KEY,
  nome          VARCHAR(200) NOT NULL,
  email         VARCHAR(200),
  telefone      VARCHAR(40),
  cidade        VARCHAR(120),
  status        partner_status NOT NULL DEFAULT 'ATIVO',
  criado_em     TIMESTAMP NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_clientes_status ON clientes(status);

CREATE TABLE IF NOT EXISTS usuarios (
  id            BIGSERIAL PRIMARY KEY,
  nome          VARCHAR(150) NOT NULL,
  email         VARCHAR(200) NOT NULL UNIQUE,
  senha_hash    TEXT,
  perfil        user_role NOT NULL DEFAULT 'OPERACIONAL',
  status        user_status NOT NULL DEFAULT 'ATIVO',
  ultimo_login  TIMESTAMP,
  criado_em     TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS configuracoes (
  chave         VARCHAR(120) PRIMARY KEY,
  valor         TEXT NOT NULL,
  atualizado_em TIMESTAMP NOT NULL DEFAULT now()
);

-- ========================================================
-- Pedidos de Compra / Itens
-- ========================================================
CREATE TABLE IF NOT EXISTS compras (
  id            BIGSERIAL PRIMARY KEY,
  numero        VARCHAR(40) NOT NULL UNIQUE,
  fornecedor_id BIGINT NOT NULL REFERENCES fornecedores(id),
  local_id      BIGINT REFERENCES locais(id) ON DELETE SET NULL,
  data_compra   DATE NOT NULL DEFAULT CURRENT_DATE,
  status        order_status NOT NULL DEFAULT 'PENDENTE',
  total         NUMERIC(14,2) NOT NULL DEFAULT 0,
  observacoes   TEXT,
  criado_por    BIGINT REFERENCES usuarios(id) ON DELETE SET NULL,
  criado_em     TIMESTAMP NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_compras_fornecedor ON compras(fornecedor_id);
CREATE INDEX IF NOT EXISTS idx_compras_status ON compras(status);

CREATE TABLE IF NOT EXISTS compras_itens (
  id            BIGSERIAL PRIMARY KEY,
  compra_id     BIGINT NOT NULL REFERENCES compras(id) ON DELETE CASCADE,
  produto_id    BIGINT NOT NULL REFERENCES produtos(id),
  quantidade    INTEGER NOT NULL CHECK (quantidade > 0),
  preco_unit    NUMERIC(12,2) NOT NULL CHECK (preco_unit >= 0),
  UNIQUE (compra_id, produto_id)
);
CREATE INDEX IF NOT EXISTS idx_citens_produto ON compras_itens(produto_id);

-- ========================================================
-- Pedidos de Venda / Itens
-- ========================================================
CREATE TABLE IF NOT EXISTS vendas (
  id            BIGSERIAL PRIMARY KEY,
  numero        VARCHAR(40) NOT NULL UNIQUE,
  cliente_id    BIGINT REFERENCES clientes(id),
  local_id      BIGINT REFERENCES locais(id) ON DELETE SET NULL,
  data_venda    DATE NOT NULL DEFAULT CURRENT_DATE,
  status        order_status NOT NULL DEFAULT 'PENDENTE',
  total         NUMERIC(14,2) NOT NULL DEFAULT 0,
  observacoes   TEXT,
  criado_por    BIGINT REFERENCES usuarios(id) ON DELETE SET NULL,
  criado_em     TIMESTAMP NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_vendas_cliente ON vendas(cliente_id);
CREATE INDEX IF NOT EXISTS idx_vendas_status ON vendas(status);

CREATE TABLE IF NOT EXISTS vendas_itens (
  id            BIGSERIAL PRIMARY KEY,
  venda_id      BIGINT NOT NULL REFERENCES vendas(id) ON DELETE CASCADE,
  produto_id    BIGINT NOT NULL REFERENCES produtos(id),
  quantidade    INTEGER NOT NULL CHECK (quantidade > 0),
  preco_unit    NUMERIC(12,2) NOT NULL CHECK (preco_unit >= 0),
  UNIQUE (venda_id, produto_id)
);
CREATE INDEX IF NOT EXISTS idx_vitens_produto ON vendas_itens(produto_id);

-- ========================================================
-- Movimentações de Estoque (Kardex)
-- ========================================================
CREATE TABLE IF NOT EXISTS movimentacoes (
  id            BIGSERIAL PRIMARY KEY,
  data_mov      TIMESTAMP NOT NULL DEFAULT now(),
  tipo          movement_type NOT NULL,
  produto_id    BIGINT NOT NULL REFERENCES produtos(id),
  local_id      BIGINT REFERENCES locais(id) ON DELETE SET NULL,
  quantidade    INTEGER NOT NULL, -- usar sinal positivo e negativo conforme tipo
  origem        VARCHAR(120),     -- usuário/origem
  observacoes   TEXT,
  ref_tabela    VARCHAR(30),      -- 'compras','vendas','ajuste'
  ref_id        BIGINT,
  criado_por    BIGINT REFERENCES usuarios(id) ON DELETE SET NULL
);
CREATE INDEX IF NOT EXISTS idx_mov_produto ON movimentacoes(produto_id);
CREATE INDEX IF NOT EXISTS idx_mov_tipo ON movimentacoes(tipo);
CREATE INDEX IF NOT EXISTS idx_mov_data ON movimentacoes(data_mov);

-- ========================================================
-- Inventário (contagens)
-- ========================================================
CREATE TABLE IF NOT EXISTS inventarios (
  id            BIGSERIAL PRIMARY KEY,
  local_id      BIGINT NOT NULL REFERENCES locais(id),
  data_ref      DATE NOT NULL DEFAULT CURRENT_DATE,
  criado_por    BIGINT REFERENCES usuarios(id) ON DELETE SET NULL,
  observacoes   TEXT,
  criado_em     TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS inventarios_itens (
  id            BIGSERIAL PRIMARY KEY,
  inventario_id BIGINT NOT NULL REFERENCES inventarios(id) ON DELETE CASCADE,
  produto_id    BIGINT NOT NULL REFERENCES produtos(id),
  qtd_sistema   INTEGER NOT NULL,
  qtd_contada   INTEGER NOT NULL,
  observacoes   TEXT
);
CREATE UNIQUE INDEX IF NOT EXISTS idx_inv_item_unique ON inventarios_itens(inventario_id, produto_id);

-- ========================================================
-- Funções auxiliares
-- ========================================================

-- Retorna estoque atual por produto/local
CREATE OR REPLACE VIEW v_estoque_atual AS
SELECT
  p.id AS produto_id,
  p.sku,
  p.nome,
  COALESCE(m.local_id, 0) AS local_id,
  SUM(
    CASE m.tipo
      WHEN 'ENTRADA' THEN m.quantidade
      WHEN 'AJUSTE'  THEN m.quantidade
      WHEN 'SAIDA'   THEN -m.quantidade
    END
  )::INTEGER AS estoque_atual
FROM produtos p
LEFT JOIN movimentacoes m ON m.produto_id = p.id
GROUP BY p.id, p.sku, p.nome, COALESCE(m.local_id, 0);

-- Produtos abaixo do mínimo (soma em todos os locais)
CREATE OR REPLACE VIEW v_estoque_baixo AS
SELECT
  p.id AS produto_id, p.sku, p.nome, p.estoque_min,
  COALESCE(SUM(CASE m.tipo WHEN 'ENTRADA' THEN m.quantidade WHEN 'AJUSTE' THEN m.quantidade WHEN 'SAIDA' THEN -m.quantidade END), 0)::INTEGER AS estoque_total
FROM produtos p
LEFT JOIN movimentacoes m ON m.produto_id = p.id
GROUP BY p.id, p.sku, p.nome, p.estoque_min
HAVING COALESCE(SUM(CASE m.tipo WHEN 'ENTRADA' THEN m.quantidade WHEN 'AJUSTE' THEN m.quantidade WHEN 'SAIDA' THEN -m.quantidade END), 0) < p.estoque_min;

-- Entradas x Saídas por dia (todos os produtos/locais)
CREATE OR REPLACE VIEW v_entradas_saidas_por_dia AS
WITH base AS (
  SELECT date_trunc('day', data_mov)::date AS dia,
         SUM(CASE WHEN tipo='ENTRADA' THEN quantidade ELSE 0 END) AS entradas,
         SUM(CASE WHEN tipo='SAIDA' THEN quantidade ELSE 0 END) AS saidas
  FROM movimentacoes
  GROUP BY 1
)
SELECT * FROM base ORDER BY dia DESC;

-- ========================================================
-- SEEDS (dados fictícios coerentes com o frontend)
-- ========================================================
INSERT INTO categorias (nome, descricao) VALUES
  ('Vestuário','Roupas e acessórios')
ON CONFLICT (nome) DO NOTHING;

INSERT INTO categorias (nome, descricao) VALUES
  ('Eletrônicos','Equipamentos e periféricos')
ON CONFLICT (nome) DO NOTHING;

INSERT INTO locais (nome, cidade) VALUES
  ('Depósito Central','São Paulo'),
  ('Loja 01','São Paulo')
ON CONFLICT (nome) DO NOTHING;

INSERT INTO produtos (sku, nome, categoria_id, unidade, preco, estoque_min, status, descricao)
SELECT 'SKU-0001','Camiseta DryFit', c1.id, 'un', 59.90, 20, 'ATIVO','Tecido respirável.'
FROM categorias c1 WHERE c1.nome='Vestuário'
ON CONFLICT (sku) DO NOTHING;

INSERT INTO produtos (sku, nome, categoria_id, unidade, preco, estoque_min, status, descricao)
SELECT 'SKU-0451','Mouse Óptico', c2.id, 'un', 89.00, 10, 'ATIVO','Mouse 1600dpi.'
FROM categorias c2 WHERE c2.nome='Eletrônicos'
ON CONFLICT (sku) DO NOTHING;

INSERT INTO produtos (sku, nome, categoria_id, unidade, preco, estoque_min, status, descricao)
SELECT 'SKU-0877','HD Externo 1TB', c2.id, 'un', 299.00, 5, 'INATIVO','HD USB 3.0.'
FROM categorias c2 WHERE c2.nome='Eletrônicos'
ON CONFLICT (sku) DO NOTHING;

INSERT INTO fornecedores (nome, contato, telefone, cidade, status, email) VALUES
  ('Alpha Distribuidora','Carla N.','(11) 99999-8888','São Paulo','ATIVO','contato@alpha.com'),
  ('Beta Import','João P.','(21) 98888-7777','Rio de Janeiro','INATIVO','vendas@beta.com')
ON CONFLICT DO NOTHING;

INSERT INTO clientes (nome, email, telefone, cidade, status) VALUES
  ('Loja X','contato@lojax.com','(11) 90000-0000','São Paulo','ATIVO'),
  ('Cliente Final','cliente@email.com','(21) 95555-1111','Rio de Janeiro','PENDENTE')
ON CONFLICT DO NOTHING;

INSERT INTO usuarios (nome, email, perfil, status) VALUES
  ('Bruno Lima','bruno@empresa.com','ADMIN','ATIVO'),
  ('Larissa Pires','larissa@empresa.com','OPERACIONAL','ATIVO')
ON CONFLICT (email) DO NOTHING;

-- Movimentações iniciais (coerentes com o dashboard de exemplo)
-- Entrada +120 Mouse Óptico (SKU-0451) em 2025-08-19 08:10, NF 1234
INSERT INTO movimentacoes (data_mov, tipo, produto_id, local_id, quantidade, origem, observacoes, ref_tabela)
SELECT TIMESTAMP '2025-08-19 08:10:00','ENTRADA', p.id, l.id, 120, 'bruno','NF 1234','ajuste'
FROM produtos p, locais l
WHERE p.sku='SKU-0451' AND l.nome='Depósito Central'
LIMIT 1;

-- Saída -4 HD Externo 1TB (SKU-0877) em 2025-08-19 07:45, Pedido #9812
INSERT INTO movimentacoes (data_mov, tipo, produto_id, local_id, quantidade, origem, observacoes, ref_tabela, ref_id)
SELECT TIMESTAMP '2025-08-19 07:45:00','SAIDA', p.id, l.id, 4, 'bruno','Pedido #9812','vendas',9812
FROM produtos p, locais l
WHERE p.sku='SKU-0877' AND l.nome='Depósito Central'
LIMIT 1;

-- Ajuste -2 Teclado Mecânico (não existe no seed, adaptando para Mouse Óptico como exemplo de ajuste)
INSERT INTO movimentacoes (data_mov, tipo, produto_id, local_id, quantidade, origem, observacoes, ref_tabela)
SELECT TIMESTAMP '2025-08-18 17:12:00','AJUSTE', p.id, l.id, -2, 'lucas','Perda','ajuste'
FROM produtos p, locais l
WHERE p.sku='SKU-0451' AND l.nome='Depósito Central'
LIMIT 1;

-- Compras/Vendas de exemplo (números do frontend)
INSERT INTO compras (numero, fornecedor_id, local_id, data_compra, status, total, observacoes, criado_por)
SELECT '9801', f.id, l.id, DATE '2025-08-18', 'CONCLUIDA', 4210.00, 'Compra exemplo', u.id
FROM fornecedores f, locais l, usuarios u
WHERE f.nome='Beta Import' AND l.nome='Depósito Central' AND u.email='bruno@empresa.com'
ON CONFLICT (numero) DO NOTHING;

INSERT INTO compras_itens (compra_id, produto_id, quantidade, preco_unit)
SELECT c.id, p.id, 7, 601.43
FROM compras c, produtos p
WHERE c.numero='9801' AND p.sku='SKU-0877'
ON CONFLICT DO NOTHING;

INSERT INTO vendas (numero, cliente_id, local_id, data_venda, status, total, observacoes, criado_por)
SELECT '2210', cl.id, l.id, DATE '2025-08-19', 'PENDENTE', 870.00, 'Venda exemplo', u.id
FROM clientes cl, locais l, usuarios u
WHERE cl.nome='Loja X' AND l.nome='Depósito Central' AND u.email='bruno@empresa.com'
ON CONFLICT (numero) DO NOTHING;

INSERT INTO vendas_itens (venda_id, produto_id, quantidade, preco_unit)
SELECT v.id, p.id, 3, 290.00
FROM vendas v, produtos p
WHERE v.numero='2210' AND p.sku='SKU-0001'
ON CONFLICT DO NOTHING;

-- ========================================================
-- Índices extras úteis
-- ========================================================
CREATE INDEX IF NOT EXISTS idx_produtos_nome_trgm ON produtos USING GIN (nome gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_mov_ref ON movimentacoes(ref_tabela, ref_id);

-- Obs: para usar gin_trgm_ops é necessário a extensão pg_trgm:
-- CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- ========================================================
-- Consultas de exemplo (não obrigatórias)
-- ========================================================
-- 1) Estoque atual consolidado por produto
-- SELECT sku, nome, SUM(estoque_atual) as total FROM v_estoque_atual GROUP BY sku, nome ORDER BY nome;

-- 2) Produtos abaixo do mínimo
-- SELECT * FROM v_estoque_baixo ORDER BY nome;

-- 3) Entradas x Saídas nos últimos 30 dias
-- SELECT * FROM v_entradas_saidas_por_dia WHERE dia >= CURRENT_DATE - INTERVAL '30 days' ORDER BY dia;
