<?php
// ========================================================
//  api/endpoints/produtos/editar.php - CORRIGIDO
// ========================================================
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: PUT, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Se for OPTIONS, retornar apenas os headers
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once '../../config/database.php';
require_once '../../classes/Produto.php';
require_once '../../utils/Response.php';

if ($_SERVER['REQUEST_METHOD'] !== 'PUT') {
    Response::error("Método não permitido", 405);
}

try {
    // Pegar dados do PUT
    $input = json_decode(file_get_contents('php://input'), true);
    
    // Debug - remover em produção
    error_log("Dados recebidos para edição: " . print_r($input, true));
    
    // Validações
    if (empty($input['id'])) {
        Response::badRequest("ID do produto é obrigatório");
    }
    
    if (empty($input['sku'])) {
        Response::badRequest("Campo 'sku' é obrigatório");
    }
    
    if (empty($input['nome'])) {
        Response::badRequest("Campo 'nome' é obrigatório");
    }
    
    if (!isset($input['preco'])) {
        Response::badRequest("Campo 'preco' é obrigatório");
    }
    
    // Preparar dados - CORRIGIDO: verificar se unidade existe
    $id = (int)$input['id'];
    $dados = [
        'sku' => trim($input['sku']),
        'nome' => trim($input['nome']),
        'categoria_id' => !empty($input['categoria_id']) ? (int)$input['categoria_id'] : null,
        'unidade' => isset($input['unidade']) ? trim($input['unidade']) : 'un', // CORRIGIDO
        'preco' => (float)str_replace(',', '.', str_replace(['R$', ' '], '', $input['preco'])),
        'estoque_min' => isset($input['estoque_min']) ? (int)$input['estoque_min'] : 0,
        'status' => 'ATIVO', // default
        'descricao' => isset($input['descricao']) ? trim($input['descricao']) : ''
    ];
    
    // Determinar status baseado em 'ativo' ou 'status'
    if (isset($input['ativo'])) {
        $dados['status'] = ($input['ativo'] === true || $input['ativo'] === 'true' || $input['ativo'] == 1) ? 'ATIVO' : 'INATIVO';
    }
    
    if (!empty($input['status'])) {
        $dados['status'] = strtoupper($input['status']) === 'ATIVO' ? 'ATIVO' : 'INATIVO';
    }
    
    // Conectar ao banco
    $database = new Database();
    $db = $database->getConnection();
    
    if (!$db) {
        Response::error("Erro de conexão com o banco de dados", 500);
    }
    
    // Atualizar produto
    $produto = new Produto($db);
    $resultado = $produto->atualizar($id, $dados);
    
    if ($resultado) {
        Response::success(null, "Produto atualizado com sucesso");
    } else {
        Response::error("Erro ao atualizar produto", 500);
    }
    
} catch (Exception $e) {
    error_log("Erro ao atualizar produto: " . $e->getMessage());
    Response::error($e->getMessage(), 500);
}
?>