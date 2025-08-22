
<?php
// ========================================================
// api/endpoints/produtos/buscar.php
// ========================================================
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

require_once '../../config/database.php';
require_once '../../classes/Produto.php';
require_once '../../utils/response.php';

try {
    $id = $_GET['id'] ?? null;
    
    if (!$id) {
        Response::badRequest("ID do produto é obrigatório");
    }
    
    $database = new Database();
    $db = $database->getConnection();
    
    $produto = new Produto($db);
    $dados = $produto->buscarPorId($id);
    
    if (!$dados) {
        Response::notFound("Produto não encontrado");
    }
    
    Response::success($dados);
    
} catch(Exception $e) {
    Response::error("Erro ao buscar produto: " . $e->getMessage());
}
?>