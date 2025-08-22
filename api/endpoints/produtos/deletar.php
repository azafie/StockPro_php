
<?php
// ========================================================
//  api/endpoints/produtos/deletar.php
// ========================================================
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: DELETE");
header("Access-Control-Allow-Headers: Content-Type");

require_once '../../config/database.php';
require_once '../../classes/Produto.php';
require_once '../../utils/response.php';

if ($_SERVER['REQUEST_METHOD'] !== 'DELETE') {
    Response::error("Método não permitido", 405);
}

try {
    $id = $_GET['id'] ?? null;
    
    if (!$id) {
        Response::badRequest("ID do produto é obrigatório");
    }
    
    $database = new Database();
    $db = $database->getConnection();
    
    $produto = new Produto($db);
    $produto->deletar($id);
    
    Response::success(null, "Produto removido com sucesso");
    
} catch(Exception $e) {
    Response::error($e->getMessage());
}
?>
