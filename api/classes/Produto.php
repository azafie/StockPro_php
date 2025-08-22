
<?php
// ========================================================
// api/classes/Produto.php (EXPANDIDA)
// ========================================================
class Produto {
    private $conn;
    private $table_name = "produtos";

    public function __construct($db) {
        $this->conn = $db;
    }

    // Listar produtos com filtros, paginação e busca
    public function listar($filtros = [], $limite = 100, $offset = 0) {
        $query = "SELECT p.*, c.nome as categoria_nome,
                  COALESCE(SUM(
                    CASE m.tipo
                      WHEN 'ENTRADA' THEN m.quantidade
                      WHEN 'AJUSTE'  THEN m.quantidade
                      WHEN 'SAIDA'   THEN -m.quantidade
                      ELSE 0
                    END
                  ), 0) as estoque_atual
                  FROM " . $this->table_name . " p 
                  LEFT JOIN categorias c ON p.categoria_id = c.id
                  LEFT JOIN movimentacoes m ON m.produto_id = p.id";
        
        $where = [];
        $params = [];

        // Filtro de status
        if (!empty($filtros['status']) && $filtros['status'] !== 'Todos') {
            $where[] = "p.status = :status";
            $params[':status'] = strtoupper($filtros['status']);
        }

        // Filtro de categoria
        if (!empty($filtros['categoria_id']) && $filtros['categoria_id'] !== 'Todas') {
            $where[] = "p.categoria_id = :categoria_id";
            $params[':categoria_id'] = $filtros['categoria_id'];
        }

        // Busca por nome ou SKU
        if (!empty($filtros['busca'])) {
            $where[] = "(p.nome LIKE :busca OR p.sku LIKE :busca OR p.descricao LIKE :busca)";
            $params[':busca'] = '%' . $filtros['busca'] . '%';
        }

        if (!empty($where)) {
            $query .= " WHERE " . implode(" AND ", $where);
        }

        $query .= " GROUP BY p.id, p.sku, p.nome, p.categoria_id, p.unidade, p.preco, p.estoque_min, p.status, p.descricao, p.criado_em, p.atualizado_em, c.nome";
        $query .= " ORDER BY p.nome";
        $query .= " LIMIT :limite OFFSET :offset";

        $stmt = $this->conn->prepare($query);
        
        // Bind dos parâmetros de filtro
        foreach ($params as $key => $value) {
            $stmt->bindValue($key, $value);
        }
        
        // Bind dos parâmetros de paginação
        $stmt->bindValue(':limite', $limite, PDO::PARAM_INT);
        $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
        
        $stmt->execute();
        return $stmt->fetchAll();
    }

    // Contar total de produtos (para paginação)
    public function contar($filtros = []) {
        $query = "SELECT COUNT(DISTINCT p.id) as total FROM " . $this->table_name . " p 
                  LEFT JOIN categorias c ON p.categoria_id = c.id";
        
        $where = [];
        $params = [];

        if (!empty($filtros['status']) && $filtros['status'] !== 'Todos') {
            $where[] = "p.status = :status";
            $params[':status'] = strtoupper($filtros['status']);
        }

        if (!empty($filtros['categoria_id']) && $filtros['categoria_id'] !== 'Todas') {
            $where[] = "p.categoria_id = :categoria_id";
            $params[':categoria_id'] = $filtros['categoria_id'];
        }

        if (!empty($filtros['busca'])) {
            $where[] = "(p.nome LIKE :busca OR p.sku LIKE :busca OR p.descricao LIKE :busca)";
            $params[':busca'] = '%' . $filtros['busca'] . '%';
        }

        if (!empty($where)) {
            $query .= " WHERE " . implode(" AND ", $where);
        }

        $stmt = $this->conn->prepare($query);
        $stmt->execute($params);
        return $stmt->fetch()['total'];
    }

    // Buscar por ID
    public function buscarPorId($id) {
        $query = "SELECT p.*, c.nome as categoria_nome,
                  COALESCE(SUM(
                    CASE m.tipo
                      WHEN 'ENTRADA' THEN m.quantidade
                      WHEN 'AJUSTE'  THEN m.quantidade
                      WHEN 'SAIDA'   THEN -m.quantidade
                      ELSE 0
                    END
                  ), 0) as estoque_atual
                  FROM " . $this->table_name . " p 
                  LEFT JOIN categorias c ON p.categoria_id = c.id
                  LEFT JOIN movimentacoes m ON m.produto_id = p.id
                  WHERE p.id = :id
                  GROUP BY p.id";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':id', $id);
        $stmt->execute();
        return $stmt->fetch();
    }

    // Verificar se SKU já existe
    public function verificarSku($sku, $id_excluir = null) {
        $query = "SELECT COUNT(*) as total FROM " . $this->table_name . " WHERE sku = :sku";
        $params = [':sku' => $sku];

        if ($id_excluir) {
            $query .= " AND id != :id";
            $params[':id'] = $id_excluir;
        }

        $stmt = $this->conn->prepare($query);
        $stmt->execute($params);
        return $stmt->fetch()['total'] > 0;
    }

    // Criar produto
    public function criar($dados) {
        // Verificar SKU único
        if ($this->verificarSku($dados['sku'])) {
            throw new Exception("SKU já existe");
        }

        $query = "INSERT INTO " . $this->table_name . " 
                  (sku, nome, categoria_id, unidade, preco, estoque_min, status, descricao) 
                  VALUES (:sku, :nome, :categoria_id, :unidade, :preco, :estoque_min, :status, :descricao)";

        $stmt = $this->conn->prepare($query);
        
        $stmt->bindParam(':sku', $dados['sku']);
        $stmt->bindParam(':nome', $dados['nome']);
        $stmt->bindParam(':categoria_id', $dados['categoria_id']);
        $stmt->bindParam(':unidade', $dados['unidade']);
        $stmt->bindParam(':preco', $dados['preco']);
        $stmt->bindParam(':estoque_min', $dados['estoque_min']);
        $stmt->bindParam(':status', $dados['status']);
        $stmt->bindParam(':descricao', $dados['descricao']);

        if ($stmt->execute()) {
            return $this->conn->lastInsertId();
        }
        throw new Exception("Erro ao criar produto");
    }

    // Atualizar produto
    public function atualizar($id, $dados) {
        // Verificar SKU único (excluindo o próprio produto)
        if ($this->verificarSku($dados['sku'], $id)) {
            throw new Exception("SKU já existe");
        }

        $query = "UPDATE " . $this->table_name . " 
                  SET sku = :sku, nome = :nome, categoria_id = :categoria_id, 
                      unidade = :unidade, preco = :preco, estoque_min = :estoque_min, 
                      status = :status, descricao = :descricao
                  WHERE id = :id";

        $stmt = $this->conn->prepare($query);
        
        $stmt->bindParam(':id', $id);
        $stmt->bindParam(':sku', $dados['sku']);
        $stmt->bindParam(':nome', $dados['nome']);
        $stmt->bindParam(':categoria_id', $dados['categoria_id']);
        $stmt->bindParam(':unidade', $dados['unidade']);
        $stmt->bindParam(':preco', $dados['preco']);
        $stmt->bindParam(':estoque_min', $dados['estoque_min']);
        $stmt->bindParam(':status', $dados['status']);
        $stmt->bindParam(':descricao', $dados['descricao']);

        if (!$stmt->execute()) {
            throw new Exception("Erro ao atualizar produto");
        }
        return true;
    }

    // Deletar produto (soft delete)
    public function deletar($id) {
        $query = "UPDATE " . $this->table_name . " SET status = 'INATIVO' WHERE id = :id";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':id', $id);
        
        if (!$stmt->execute()) {
            throw new Exception("Erro ao deletar produto");
        }
        return true;
    }
}
?>