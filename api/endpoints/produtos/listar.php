
<?php
// ========================================================
// api/endpoints/produtos/listar.php
// ========================================================
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

require_once '../../config/database.php';
require_once '../../classes/Produto.php';
require_once '../../utils/response.php';

try {
    $database = new Database();
    $db = $database->getConnection();
    
    $produto = new Produto($db);
    
    // Parâmetros de filtro
    $filtros = [
        'busca' => $_GET['busca'] ?? '',
        'categoria_id' => $_GET['categoria_id'] ?? '',
        'status' => $_GET['status'] ?? ''
    ];
    
    // Parâmetros de paginação
    $limite = (int)($_GET['limite'] ?? 100);
    $pagina = (int)($_GET['pagina'] ?? 1);
    $offset = ($pagina - 1) * $limite;
    
    $produtos = $produto->listar($filtros, $limite, $offset);
    $total = $produto->contar($filtros);
    
    $resultado = [
        'produtos' => $produtos,
        'total' => $total,
        'pagina_atual' => $pagina,
        'total_paginas' => ceil($total / $limite)
    ];
    
    Response::success($resultado);
    
} catch(Exception $e) {
    Response::error("Erro ao listar produtos: " . $e->getMessage());
}
?>