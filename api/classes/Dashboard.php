<?php
// ========================================================
// api/classes/Dashboard.php - SQL CORRIGIDO
// ========================================================

class Dashboard {
    private $conn;

    public function __construct($db) {
        $this->conn = $db;
    }

    /**
     * Obtém as estatísticas principais do dashboard
     */
    public function obterEstatisticas() {
        try {
            $stats = [];

            // Total de produtos
            $query = "SELECT COUNT(*) as total FROM produtos WHERE status = 'ATIVO'";
            $stmt = $this->conn->prepare($query);
            $stmt->execute();
            $stats['total_produtos'] = (int)$stmt->fetch()['total'];

            // Estoque total (soma de todas as movimentações)
            $query = "SELECT COALESCE(SUM(
                        CASE m.tipo
                          WHEN 'ENTRADA' THEN m.quantidade
                          WHEN 'AJUSTE'  THEN m.quantidade
                          WHEN 'SAIDA'   THEN -m.quantidade
                          ELSE 0
                        END
                      ), 0) as estoque_total
                      FROM movimentacoes m
                      INNER JOIN produtos p ON p.id = m.produto_id
                      WHERE p.status = 'ATIVO'";
            $stmt = $this->conn->prepare($query);
            $stmt->execute();
            $stats['estoque_total'] = (int)$stmt->fetch()['estoque_total'];

            // Produtos abaixo do mínimo - QUERY CORRIGIDA
            $query = "SELECT COUNT(*) as total FROM (
                        SELECT 
                          p.id,
                          p.estoque_min,
                          COALESCE(SUM(
                            CASE m.tipo
                              WHEN 'ENTRADA' THEN m.quantidade
                              WHEN 'AJUSTE'  THEN m.quantidade
                              WHEN 'SAIDA'   THEN -m.quantidade
                              ELSE 0
                            END
                          ), 0) as estoque_atual
                        FROM produtos p
                        LEFT JOIN movimentacoes m ON m.produto_id = p.id
                        WHERE p.status = 'ATIVO'
                        GROUP BY p.id, p.estoque_min
                        HAVING estoque_atual < p.estoque_min
                      ) as subquery";
            $stmt = $this->conn->prepare($query);
            $stmt->execute();
            $stats['produtos_baixo_minimo'] = (int)$stmt->fetch()['total'];

            // Pedidos pendentes (compras + vendas) - COM VERIFICAÇÃO DE TABELAS
            $query = "SELECT 
                        COALESCE((SELECT COUNT(*) FROM compras WHERE status = 'PENDENTE'), 0) +
                        COALESCE((SELECT COUNT(*) FROM vendas WHERE status = 'PENDENTE'), 0) as pedidos_pendentes";
            $stmt = $this->conn->prepare($query);
            $stmt->execute();
            $stats['pedidos_pendentes'] = (int)$stmt->fetch()['pedidos_pendentes'];

            return $stats;

        } catch (Exception $e) {
            throw new Exception("Erro ao obter estatísticas: " . $e->getMessage());
        }
    }

    /**
     * Obtém alertas de produtos com estoque baixo
     */
    public function obterAlertasEstoque($limite = 10) {
        try {
            $query = "SELECT 
                        p.id,
                        p.sku,
                        p.nome,
                        p.estoque_min,
                        COALESCE(SUM(
                          CASE m.tipo
                            WHEN 'ENTRADA' THEN m.quantidade
                            WHEN 'AJUSTE'  THEN m.quantidade
                            WHEN 'SAIDA'   THEN -m.quantidade
                            ELSE 0
                          END
                        ), 0) as estoque_atual
                      FROM produtos p
                      LEFT JOIN movimentacoes m ON m.produto_id = p.id
                      WHERE p.status = 'ATIVO'
                      GROUP BY p.id, p.sku, p.nome, p.estoque_min
                      HAVING estoque_atual <= p.estoque_min
                      ORDER BY estoque_atual ASC, p.nome
                      LIMIT ?";

            $stmt = $this->conn->prepare($query);
            $stmt->execute([$limite]);
            
            return $stmt->fetchAll();

        } catch (Exception $e) {
            // Se der erro, retorna array vazio para não quebrar o sistema
            error_log("Erro ao obter alertas: " . $e->getMessage());
            return [];
        }
    }

    /**
     * Obtém as últimas movimentações
     */
    public function obterUltimasMovimentacoes($limite = 10) {
        try {
            $query = "SELECT 
                        m.id,
                        m.data_mov,
                        m.tipo,
                        m.quantidade,
                        m.origem,
                        m.observacoes,
                        p.sku,
                        p.nome as produto_nome,
                        COALESCE(u.nome, m.origem) as usuario_nome
                      FROM movimentacoes m
                      INNER JOIN produtos p ON p.id = m.produto_id
                      LEFT JOIN usuarios u ON u.id = m.criado_por
                      ORDER BY m.data_mov DESC, m.id DESC
                      LIMIT ?";

            $stmt = $this->conn->prepare($query);
            $stmt->execute([$limite]);
            
            $movimentacoes = $stmt->fetchAll();

            // Formatar os dados para o frontend
            foreach ($movimentacoes as &$mov) {
                $mov['data_formatada'] = date('d/m/Y H:i', strtotime($mov['data_mov']));
                $mov['quantidade_formatada'] = $mov['tipo'] === 'SAIDA' ? '-' . $mov['quantidade'] : '+' . $mov['quantidade'];
            }

            return $movimentacoes;

        } catch (Exception $e) {
            // Se der erro, retorna array vazio para não quebrar o sistema
            error_log("Erro ao obter movimentações: " . $e->getMessage());
            return [];
        }
    }

    /**
     * Obtém dados para o gráfico (últimos N dias)
     */
    public function obterDadosGrafico($dias = 30) {
        try {
            $query = "SELECT 
                        DATE(m.data_mov) as data,
                        SUM(CASE WHEN m.tipo = 'ENTRADA' THEN m.quantidade ELSE 0 END) as entradas,
                        SUM(CASE WHEN m.tipo = 'SAIDA' THEN m.quantidade ELSE 0 END) as saidas,
                        SUM(CASE WHEN m.tipo = 'AJUSTE' THEN m.quantidade ELSE 0 END) as ajustes
                      FROM movimentacoes m
                      WHERE m.data_mov >= DATE_SUB(CURDATE(), INTERVAL ? DAY)
                      GROUP BY DATE(m.data_mov)
                      ORDER BY data ASC";

            $stmt = $this->conn->prepare($query);
            $stmt->execute([$dias]);
            
            $dados = $stmt->fetchAll();

            // Formatar datas para o frontend
            foreach ($dados as &$item) {
                $item['data_formatada'] = date('d/m', strtotime($item['data']));
                $item['entradas'] = (int)$item['entradas'];
                $item['saidas'] = (int)$item['saidas'];
                $item['ajustes'] = (int)$item['ajustes'];
            }

            return $dados;

        } catch (Exception $e) {
            // Se der erro, retorna array vazio para não quebrar o sistema
            error_log("Erro ao obter dados do gráfico: " . $e->getMessage());
            return [];
        }
    }
}
?>