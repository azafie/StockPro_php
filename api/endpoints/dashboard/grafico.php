
<?php
// ========================================================
// api/endpoints/dashboard/grafico.php
// ========================================================

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

require_once '../../config/database.php';
require_once '../../classes/Dashboard.php';
require_once '../../utils/response.php';

try {
    $database = new Database();
    $db = $database->getConnection();
    
    $dashboard = new Dashboard($db);
    $dados = $dashboard->obterDadosGrafico(30);
    
    Response::success($dados);
    
} catch(Exception $e) {
    Response::error("Erro ao buscar dados do gráfico: " . $e->getMessage());
}
?>