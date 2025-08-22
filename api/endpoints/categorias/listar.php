
<?php
// ========================================================
// api/endpoints/categorias/listar.php
// ========================================================

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

require_once '../../config/database.php';
require_once '../../classes/Categoria.php';
require_once '../../utils/response.php';

try {
    $database = new Database();
    $db = $database->getConnection();
    
    $categoria = new Categoria($db);
    $categorias = $categoria->listar();
    
    Response::success($categorias);
    
} catch(Exception $e) {
    Response::error("Erro ao listar categorias: " . $e->getMessage());
}
?>