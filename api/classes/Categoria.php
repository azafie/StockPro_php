<?php
// ========================================================
// api/classes/Categoria.php
// ========================================================

class Categoria {
    private $conn;
    private $table_name = "categorias";

    public function __construct($db) {
        $this->conn = $db;
    }

    /**
     * Lista todas as categorias
     */
    public function listar() {
        try {
            $query = "SELECT id, nome, descricao FROM " . $this->table_name . " ORDER BY nome";
            $stmt = $this->conn->prepare($query);
            $stmt->execute();
            return $stmt->fetchAll();
        } catch (Exception $e) {
            throw new Exception("Erro ao listar categorias: " . $e->getMessage());
        }
    }

    /**
     * Busca categoria por ID
     */
    public function buscarPorId($id) {
        try {
            $query = "SELECT id, nome, descricao FROM " . $this->table_name . " WHERE id = ?";
            $stmt = $this->conn->prepare($query);
            $stmt->execute([$id]);
            return $stmt->fetch();
        } catch (Exception $e) {
            throw new Exception("Erro ao buscar categoria: " . $e->getMessage());
        }
    }

    /**
     * Cria nova categoria
     */
    public function criar($dados) {
        try {
            $query = "INSERT INTO " . $this->table_name . " (nome, descricao) VALUES (?, ?)";
            $stmt = $this->conn->prepare($query);
            
            if ($stmt->execute([$dados['nome'], $dados['descricao'] ?? null])) {
                return $this->conn->lastInsertId();
            }
            throw new Exception("Erro ao criar categoria");
        } catch (Exception $e) {
            throw new Exception("Erro ao criar categoria: " . $e->getMessage());
        }
    }

    /**
     * Atualiza categoria
     */
    public function atualizar($id, $dados) {
        try {
            $query = "UPDATE " . $this->table_name . " SET nome = ?, descricao = ? WHERE id = ?";
            $stmt = $this->conn->prepare($query);
            
            if (!$stmt->execute([$dados['nome'], $dados['descricao'] ?? null, $id])) {
                throw new Exception("Erro ao atualizar categoria");
            }
            return true;
        } catch (Exception $e) {
            throw new Exception("Erro ao atualizar categoria: " . $e->getMessage());
        }
    }

    /**
     * Deleta categoria
     */
    public function deletar($id) {
        try {
            // Verificar se há produtos usando esta categoria
            $query = "SELECT COUNT(*) as total FROM produtos WHERE categoria_id = ?";
            $stmt = $this->conn->prepare($query);
            $stmt->execute([$id]);
            $result = $stmt->fetch();
            
            if ($result['total'] > 0) {
                throw new Exception("Não é possível deletar. Há produtos usando esta categoria.");
            }
            
            $query = "DELETE FROM " . $this->table_name . " WHERE id = ?";
            $stmt = $this->conn->prepare($query);
            
            if (!$stmt->execute([$id])) {
                throw new Exception("Erro ao deletar categoria");
            }
            return true;
        } catch (Exception $e) {
            throw new Exception("Erro ao deletar categoria: " . $e->getMessage());
        }
    }
}
?>