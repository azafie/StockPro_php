
-- StockPro · Banco de Dados (MariaDB)
-- Versão: v1.0 (DDL + views + seeds)
-- Compatível com MariaDB 10.5+
-- Charset recomendado: utf8mb4 / utf8mb4_general_ci

-- ===============================================
-- Configuração de sessão (opcional)
-- ===============================================
SET NAMES utf8mb4;
SET time_zone = '+00:00';

-- ===============================================
-- Database (opcional)
-- CREATE DATABASE stockpro DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
-- USE stockpro;

-- ===============================================
-- Tabelas básicas (ENUMs inline)
-- ===============================================

CREATE TABLE IF NOT EXISTS categorias (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  nome VARCHAR(120) NOT NULL,
  descricao TEXT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_categorias_nome (nome)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS locais (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  nome VARCHAR(120) NOT NULL,
  cidade VARCHAR(120) NULL,
  ativo TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (id),
  UNIQUE KEY uq_locais_nome (nome)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS produtos (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  sku VARCHAR(40) NOT NULL,
  nome VARCHAR(200) NOT NULL,
  categoria_id BIGINT UNSIGNED NULL,
  unidade VARCHAR(10) NOT NULL DEFAULT 'un',
  preco DECIMAL(12,2) NOT NULL DEFAULT 0,
  estoque_min INT NOT NULL DEFAULT 0,
  status ENUM('ATIVO','INATIVO') NOT NULL DEFAULT 'ATIVO',
  descricao TEXT NULL,
  criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  atualizado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_produtos_sku (sku),
  KEY idx_produtos_categoria (categoria_id),
  KEY idx_produtos_status (status),
  CONSTRAINT fk_produtos_categoria FOREIGN KEY (categoria_id) REFERENCES categorias(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Busca por nome (FULLTEXT suportado no InnoDB no MariaDB)
ALTER TABLE produtos ADD FULLTEXT KEY ft_produtos_nome (nome);

CREATE TABLE IF NOT EXISTS fornecedores (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  nome VARCHAR(200) NOT NULL,
  contato VARCHAR(120) NULL,
  telefone VARCHAR(40) NULL,
  email VARCHAR(200) NULL,
  cidade VARCHAR(120) NULL,
  status ENUM('ATIVO','INATIVO','PENDENTE') NOT NULL DEFAULT 'ATIVO',
  criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_fornecedores_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS clientes (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  nome VARCHAR(200) NOT NULL,
  email VARCHAR(200) NULL,
  telefone VARCHAR(40) NULL,
  cidade VARCHAR(120) NULL,
  status ENUM('ATIVO','INATIVO','PENDENTE') NOT NULL DEFAULT 'ATIVO',
  criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_clientes_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS usuarios (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  nome VARCHAR(150) NOT NULL,
  email VARCHAR(200) NOT NULL,
  senha_hash TEXT NULL,
  perfil ENUM('ADMIN','OPERACIONAL','CONSULTA') NOT NULL DEFAULT 'OPERACIONAL',
  status ENUM('ATIVO','INATIVO') NOT NULL DEFAULT 'ATIVO',
  ultimo_login TIMESTAMP NULL DEFAULT NULL,
  criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_usuarios_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS configuracoes (
  chave VARCHAR(120) NOT NULL,
  valor TEXT NOT NULL,
  atualizado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (chave)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ===============================================
-- Compras / Vendas e itens
-- ===============================================

CREATE TABLE IF NOT EXISTS compras (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  numero VARCHAR(40) NOT NULL,
  fornecedor_id BIGINT UNSIGNED NOT NULL,
  local_id BIGINT UNSIGNED NULL,
  data_compra DATE NOT NULL DEFAULT (CURRENT_DATE),
  status ENUM('PENDENTE','CONCLUIDA','FATURADA','CANCELADA') NOT NULL DEFAULT 'PENDENTE',
  total DECIMAL(14,2) NOT NULL DEFAULT 0,
  observacoes TEXT NULL,
  criado_por BIGINT UNSIGNED NULL,
  criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_compras_numero (numero),
  KEY idx_compras_fornecedor (fornecedor_id),
  KEY idx_compras_status (status),
  CONSTRAINT fk_compras_fornecedor FOREIGN KEY (fornecedor_id) REFERENCES fornecedores(id),
  CONSTRAINT fk_compras_local FOREIGN KEY (local_id) REFERENCES locais(id) ON DELETE SET NULL,
  CONSTRAINT fk_compras_criado_por FOREIGN KEY (criado_por) REFERENCES usuarios(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS compras_itens (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  compra_id BIGINT UNSIGNED NOT NULL,
  produto_id BIGINT UNSIGNED NOT NULL,
  quantidade INT NOT NULL CHECK (quantidade > 0),
  preco_unit DECIMAL(12,2) NOT NULL CHECK (preco_unit >= 0),
  PRIMARY KEY (id),
  UNIQUE KEY uq_citens_compra_prod (compra_id, produto_id),
  KEY idx_citens_produto (produto_id),
  CONSTRAINT fk_citens_compra FOREIGN KEY (compra_id) REFERENCES compras(id) ON DELETE CASCADE,
  CONSTRAINT fk_citens_produto FOREIGN KEY (produto_id) REFERENCES produtos(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS vendas (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  numero VARCHAR(40) NOT NULL,
  cliente_id BIGINT UNSIGNED NULL,
  local_id BIGINT UNSIGNED NULL,
  data_venda DATE NOT NULL DEFAULT (CURRENT_DATE),
  status ENUM('PENDENTE','CONCLUIDA','FATURADA','CANCELADA') NOT NULL DEFAULT 'PENDENTE',
  total DECIMAL(14,2) NOT NULL DEFAULT 0,
  observacoes TEXT NULL,
  criado_por BIGINT UNSIGNED NULL,
  criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_vendas_numero (numero),
  KEY idx_vendas_cliente (cliente_id),
  KEY idx_vendas_status (status),
  CONSTRAINT fk_vendas_cliente FOREIGN KEY (cliente_id) REFERENCES clientes(id),
  CONSTRAINT fk_vendas_local FOREIGN KEY (local_id) REFERENCES locais(id) ON DELETE SET NULL,
  CONSTRAINT fk_vendas_criado_por FOREIGN KEY (criado_por) REFERENCES usuarios(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS vendas_itens (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  venda_id BIGINT UNSIGNED NOT NULL,
  produto_id BIGINT UNSIGNED NOT NULL,
  quantidade INT NOT NULL CHECK (quantidade > 0),
  preco_unit DECIMAL(12,2) NOT NULL CHECK (preco_unit >= 0),
  PRIMARY KEY (id),
  UNIQUE KEY uq_vitens_venda_prod (venda_id, produto_id),
  KEY idx_vitens_produto (produto_id),
  CONSTRAINT fk_vitens_venda FOREIGN KEY (venda_id) REFERENCES vendas(id) ON DELETE CASCADE,
  CONSTRAINT fk_vitens_produto FOREIGN KEY (produto_id) REFERENCES produtos(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ===============================================
-- Movimentações (Kardex) e Inventário
-- ===============================================

CREATE TABLE IF NOT EXISTS movimentacoes (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  data_mov TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  tipo ENUM('ENTRADA','SAIDA','AJUSTE') NOT NULL,
  produto_id BIGINT UNSIGNED NOT NULL,
  local_id BIGINT UNSIGNED NULL,
  quantidade INT NOT NULL, -- convenção: entrada/ajuste positivas; saída positiva e subtraída nas views
  origem VARCHAR(120) NULL,
  observacoes TEXT NULL,
  ref_tabela VARCHAR(30) NULL,
  ref_id BIGINT NULL,
  criado_por BIGINT UNSIGNED NULL,
  PRIMARY KEY (id),
  KEY idx_mov_produto (produto_id),
  KEY idx_mov_tipo (tipo),
  KEY idx_mov_data (data_mov),
  KEY idx_mov_ref (ref_tabela, ref_id),
  CONSTRAINT fk_mov_produto FOREIGN KEY (produto_id) REFERENCES produtos(id),
  CONSTRAINT fk_mov_local FOREIGN KEY (local_id) REFERENCES locais(id) ON DELETE SET NULL,
  CONSTRAINT fk_mov_criado_por FOREIGN KEY (criado_por) REFERENCES usuarios(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS inventarios (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  local_id BIGINT UNSIGNED NOT NULL,
  data_ref DATE NOT NULL DEFAULT (CURRENT_DATE),
  criado_por BIGINT UNSIGNED NULL,
  observacoes TEXT NULL,
  criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_inventarios_local (local_id),
  CONSTRAINT fk_inventarios_local FOREIGN KEY (local_id) REFERENCES locais(id),
  CONSTRAINT fk_inventarios_criado_por FOREIGN KEY (criado_por) REFERENCES usuarios(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS inventarios_itens (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  inventario_id BIGINT UNSIGNED NOT NULL,
  produto_id BIGINT UNSIGNED NOT NULL,
  qtd_sistema INT NOT NULL,
  qtd_contada INT NOT NULL,
  observacoes TEXT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_inv_item (inventario_id, produto_id),
  CONSTRAINT fk_invitem_inventario FOREIGN KEY (inventario_id) REFERENCES inventarios(id) ON DELETE CASCADE,
  CONSTRAINT fk_invitem_produto FOREIGN KEY (produto_id) REFERENCES produtos(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ===============================================
-- Views
-- ===============================================

DROP VIEW IF EXISTS v_estoque_atual;
CREATE VIEW v_estoque_atual AS
SELECT
  p.id AS produto_id,
  p.sku,
  p.nome,
  COALESCE(m.local_id, 0) AS local_id,
  COALESCE(SUM(
    CASE m.tipo
      WHEN 'ENTRADA' THEN m.quantidade
      WHEN 'AJUSTE'  THEN m.quantidade
      WHEN 'SAIDA'   THEN -m.quantidade
      ELSE 0
    END
  ), 0) AS estoque_atual
FROM produtos p
LEFT JOIN movimentacoes m ON m.produto_id = p.id
GROUP BY p.id, p.sku, p.nome, COALESCE(m.local_id, 0);

DROP VIEW IF EXISTS v_estoque_baixo;
CREATE VIEW v_estoque_baixo AS
SELECT
  p.id AS produto_id, p.sku, p.nome, p.estoque_min,
  COALESCE(SUM(
    CASE m.tipo
      WHEN 'ENTRADA' THEN m.quantidade
      WHEN 'AJUSTE'  THEN m.quantidade
      WHEN 'SAIDA'   THEN -m.quantidade
      ELSE 0
    END
  ),0) AS estoque_total
FROM produtos p
LEFT JOIN movimentacoes m ON m.produto_id = p.id
GROUP BY p.id, p.sku, p.nome, p.estoque_min
HAVING estoque_total < p.estoque_min;

DROP VIEW IF EXISTS v_entradas_saidas_por_dia;
CREATE VIEW v_entradas_saidas_por_dia AS
SELECT
  DATE(m.data_mov) AS dia,
  SUM(CASE WHEN m.tipo='ENTRADA' THEN m.quantidade ELSE 0 END) AS entradas,
  SUM(CASE WHEN m.tipo='SAIDA' THEN m.quantidade ELSE 0 END) AS saidas
FROM movimentacoes m
GROUP BY DATE(m.data_mov)
ORDER BY dia DESC;

-- ===============================================
-- Seeds (dados dummy coerentes com o frontend)
-- ===============================================

INSERT IGNORE INTO categorias (id, nome, descricao) VALUES
  (1, 'Vestuário','Roupas e acessórios'),
  (2, 'Eletrônicos','Equipamentos e periféricos');

INSERT IGNORE INTO locais (id, nome, cidade, ativo) VALUES
  (1, 'Depósito Central','São Paulo', 1),
  (2, 'Loja 01','São Paulo', 1);

INSERT IGNORE INTO produtos (id, sku, nome, categoria_id, unidade, preco, estoque_min, status, descricao) VALUES
  (1, 'SKU-0001','Camiseta DryFit', 1, 'un', 59.90, 20, 'ATIVO','Tecido respirável.'),
  (2, 'SKU-0451','Mouse Óptico', 2, 'un', 89.00, 10, 'ATIVO','Mouse 1600dpi.'),
  (3, 'SKU-0877','HD Externo 1TB', 2, 'un', 299.00, 5, 'INATIVO','HD USB 3.0.');

INSERT IGNORE INTO fornecedores (id, nome, contato, telefone, cidade, status, email) VALUES
  (1, 'Alpha Distribuidora','Carla N.','(11) 99999-8888','São Paulo','ATIVO','contato@alpha.com'),
  (2, 'Beta Import','João P.','(21) 98888-7777','Rio de Janeiro','INATIVO','vendas@beta.com');

INSERT IGNORE INTO clientes (id, nome, email, telefone, cidade, status) VALUES
  (1, 'Loja X','contato@lojax.com','(11) 90000-0000','São Paulo','ATIVO'),
  (2, 'Cliente Final','cliente@email.com','(21) 95555-1111','Rio de Janeiro','PENDENTE');

INSERT IGNORE INTO usuarios (id, nome, email, perfil, status) VALUES
  (1, 'Bruno Lima','bruno@empresa.com','ADMIN','ATIVO'),
  (2, 'Larissa Pires','larissa@empresa.com','OPERACIONAL','ATIVO');

-- Movimentações do dashboard
INSERT INTO movimentacoes (data_mov, tipo, produto_id, local_id, quantidade, origem, observacoes, ref_tabela)
VALUES ('2025-08-19 08:10:00','ENTRADA', 2, 1, 120, 'bruno','NF 1234', 'ajuste');

INSERT INTO movimentacoes (data_mov, tipo, produto_id, local_id, quantidade, origem, observacoes, ref_tabela, ref_id)
VALUES ('2025-08-19 07:45:00','SAIDA', 3, 1, 4, 'bruno','Pedido #9812','vendas',9812);

INSERT INTO movimentacoes (data_mov, tipo, produto_id, local_id, quantidade, origem, observacoes, ref_tabela)
VALUES ('2025-08-18 17:12:00','AJUSTE', 2, 1, -2, 'lucas','Perda','ajuste');

-- Compras/Vendas exemplo
INSERT IGNORE INTO compras (id, numero, fornecedor_id, local_id, data_compra, status, total, observacoes, criado_por)
VALUES (1, '9801', 2, 1, '2025-08-18', 'CONCLUIDA', 4210.00, 'Compra exemplo', 1);

INSERT IGNORE INTO compras_itens (id, compra_id, produto_id, quantidade, preco_unit)
VALUES (1, 1, 3, 7, 601.43);

INSERT IGNORE INTO vendas (id, numero, cliente_id, local_id, data_venda, status, total, observacoes, criado_por)
VALUES (1, '2210', 1, 1, '2025-08-19', 'PENDENTE', 870.00, 'Venda exemplo', 1);

INSERT IGNORE INTO vendas_itens (id, venda_id, produto_id, quantidade, preco_unit)
VALUES (1, 1, 1, 3, 290.00);

-- ===============================================
-- Consultas úteis
-- ===============================================
-- 1) Estoque atual consolidado por produto
-- SELECT sku, nome, SUM(estoque_atual) AS total FROM v_estoque_atual GROUP BY sku, nome ORDER BY nome;
-- 2) Produtos abaixo do mínimo
-- SELECT * FROM v_estoque_baixo ORDER BY nome;
-- 3) Entradas x Saídas últimos 30 dias
-- SELECT * FROM v_entradas_saidas_por_dia WHERE dia >= (CURRENT_DATE - INTERVAL 30 DAY) ORDER BY dia;
