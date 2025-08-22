<?php
// ========================================================
//  api/endpoints/produtos/criar.php - CORRIGIDO
// ========================================================
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Se for OPTIONS, retornar apenas os headers
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once '../../config/database.php';
require_once '../../classes/Produto.php';
require_once '../../utils/Response.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    Response::error("Método não permitido", 405);
}

try {
    // Tentar pegar dados de diferentes formas
    $input = json_decode(file_get_contents('php://input'), true);
    
    // Se não conseguiu via JSON, tentar $_POST
    if (empty($input)) {
        $input = $_POST;
    }
    
    // Debug - remover em produção
    error_log("Dados recebidos: " . print_r($input, true));
    
    // Validações
    if (empty($input['sku'])) {
        Response::badRequest("Campo 'sku' é obrigatório");
    }
    
    if (empty($input['nome'])) {
        Response::badRequest("Campo 'nome' é obrigatório");
    }
    
    if (!isset($input['preco'])) {
        Response::badRequest("Campo 'preco' é obrigatório");
    }
    
    // Limpar e preparar dados
    $dados = [
        'sku' => trim($input['sku']),
        'nome' => trim($input['nome']),
        'categoria_id' => !empty($input['categoria_id']) ? (int)$input['categoria_id'] : null,
        'unidade' => !empty($input['unidade']) ? trim($input['unidade']) : 'un',
        'preco' => (float)str_replace(',', '.', str_replace(['R$', ' '], '', $input['preco'])),
        'estoque_min' => isset($input['estoque_min']) ? (int)$input['estoque_min'] : 0,
        'status' => (isset($input['ativo']) && ($input['ativo'] === true || $input['ativo'] === 'true' || $input['ativo'] == 1)) ? 'ATIVO' : 'INATIVO',
        'descricao' => isset($input['descricao']) ? trim($input['descricao']) : ''
    ];
    
    // Se status foi enviado diretamente, usar ele
    if (!empty($input['status'])) {
        $dados['status'] = strtoupper($input['status']) === 'ATIVO' ? 'ATIVO' : 'INATIVO';
    }
    
    $database = new Database();
    $db = $database->getConnection();
    
    if (!$db) {
        Response::error("Erro de conexão com o banco de dados", 500);
    }
    
    $produto = new Produto($db);
    $id = $produto->criar($dados);
    
    if ($id) {
        Response::success(['id' => $id], "Produto criado com sucesso");
    } else {
        Response::error("Erro ao criar produto", 500);
    }
    
} catch (Exception $e) {
    error_log("Erro ao criar produto: " . $e->getMessage());
    Response::error($e->getMessage(), 500);
}
?>