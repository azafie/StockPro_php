<?php
// =============================================
// StockPro - API Endpoint para Gráficos do Dashboard
// Arquivo: api/endpoints/dashboard/graficos.php
// =============================================

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Se for uma requisição OPTIONS, retornar apenas os headers
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Função para gerar resposta de erro
function enviarErro($mensagem, $codigo = 400) {
    http_response_code($codigo);
    echo json_encode([
        'success' => false,
        'message' => $mensagem,
        'data' => null
    ]);
    exit();
}

// Função para gerar resposta de sucesso
function enviarSucesso($dados, $mensagem = 'Dados carregados com sucesso') {
    echo json_encode([
        'success' => true,
        'message' => $mensagem,
        'data' => $dados
    ]);
    exit();
}

// Validar método da requisição
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    enviarErro('Método não permitido', 405);
}

// Obter parâmetros
$tipo = $_GET['tipo'] ?? 'vendas';
$periodo = intval($_GET['periodo'] ?? 7);

// Validar parâmetros
$tiposPermitidos = ['vendas', 'estoque', 'categorias'];
if (!in_array($tipo, $tiposPermitidos)) {
    enviarErro('Tipo de gráfico inválido');
}

if ($periodo < 1 || $periodo > 365) {
    enviarErro('Período inválido');
}

try {
    // Processar baseado no tipo de gráfico
    switch ($tipo) {
        case 'vendas':
            $dados = gerarDadosVendas($periodo);
            break;
        case 'estoque':
            $dados = gerarDadosEstoque($periodo);
            break;
        case 'categorias':
            $dados = gerarDadosCategorias($periodo);
            break;
        default:
            enviarErro('Tipo não implementado');
    }

    enviarSucesso($dados);

} catch (Exception $e) {
    error_log("Erro ao gerar dados do gráfico: " . $e->getMessage());
    enviarErro('Erro interno do servidor', 500);
}

// =============================================
// FUNÇÕES PARA GERAR DADOS DOS GRÁFICOS
// =============================================

function gerarDadosVendas($periodo) {
    $labels = [];
    $vendas = [];
    $totalVendas = 0;
    $maiorVenda = 0;
    $menorVenda = PHP_INT_MAX;

    // Gerar dados para o período especificado
    for ($i = $periodo - 1; $i >= 0; $i--) {
        $data = date('d/m', strtotime("-$i days"));
        $labels[] = $data;
        
        // Simular variação realista de vendas
        $baseVenda = 2000; // Venda base
        $variacao = sin(($periodo - $i) * 0.5) * 800; // Variação senoidal
        $ruido = rand(-300, 300); // Ruído aleatório
        $venda = max(500, $baseVenda + $variacao + $ruido);
        
        $vendas[] = round($venda, 2);
        $totalVendas += $venda;
        $maiorVenda = max($maiorVenda, $venda);
        $menorVenda = min($menorVenda, $venda);
    }

    $mediaVendas = $totalVendas / count($vendas);

    return [
        'labels' => $labels,
        'vendas' => $vendas,
        'estatisticas' => [
            'Total' => 'R$ ' . number_format($totalVendas, 2, ',', '.'),
            'Média' => 'R$ ' . number_format($mediaVendas, 2, ',', '.'),
            'Maior' => 'R$ ' . number_format($maiorVenda, 2, ',', '.'),
            'Menor' => 'R$ ' . number_format($menorVenda, 2, ',', '.')
        ]
    ];
}

function gerarDadosEstoque($periodo) {
    $labels = [];
    $entradas = [];
    $saidas = [];
    $totalEntradas = 0;
    $totalSaidas = 0;

    // Gerar dados para o período especificado
    for ($i = $periodo - 1; $i >= 0; $i--) {
        $data = date('d/m', strtotime("-$i days"));
        $labels[] = $data;
        
        // Simular entradas e saídas
        $entrada = rand(50, 250);
        $saida = rand(30, 200);
        
        $entradas[] = $entrada;
        $saidas[] = $saida;
        $totalEntradas += $entrada;
        $totalSaidas += $saida;
    }

    $saldoLiquido = $totalEntradas - $totalSaidas;

    return [
        'labels' => $labels,
        'entradas' => $entradas,
        'saidas' => $saidas,
        'estatisticas' => [
            'Entradas' => number_format($totalEntradas, 0, ',', '.'),
            'Saídas' => number_format($totalSaidas, 0, ',', '.'),
            'Saldo' => number_format($saldoLiquido, 0, ',', '.'),
            'Período' => $periodo . ' dias'
        ]
    ];
}

function gerarDadosCategorias($periodo) {
    // Categorias fictícias com dados realistas
    $categorias = [
        'Eletrônicos' => rand(250, 400),
        'Vestuário' => rand(150, 300),
        'Casa & Jardim' => rand(80, 150),
        'Esportes' => rand(100, 200),
        'Livros' => rand(50, 120),
        'Beleza' => rand(90, 180),
        'Automóveis' => rand(30, 80)
    ];

    // Ordenar por valor (maior para menor)
    arsort($categorias);

    // Pegar apenas os top 6
    $topCategorias = array_slice($categorias, 0, 6, true);
    
    $labels = array_keys($topCategorias);
    $valores = array_values($topCategorias);
    $total = array_sum($valores);

    // Calcular categoria líder
    $categoriaLider = array_keys($topCategorias)[0];
    $valorLider = $topCategorias[$categoriaLider];
    $percentualLider = round(($valorLider / $total) * 100, 1);

    return [
        'labels' => $labels,
        'valores' => $valores,
        'estatisticas' => [
            'Total' => number_format($total, 0, ',', '.'),
            'Categorias' => count($labels),
            'Líder' => $categoriaLider,
            'Participação' => $percentualLider . '%'
        ]
    ];
}

// Função para simular conexão com banco (para futuro)
function conectarBanco() {
    // TODO: Implementar conexão real com banco de dados
    // return new PDO('mysql:host=localhost;dbname=stockpro', $usuario, $senha);
    return null;
}

// Funções para buscar dados reais (para futuro)
function buscarVendasReais($periodo) {
    // TODO: Query real no banco
    /*
    $sql = "SELECT DATE(data_venda) as data, SUM(valor_total) as total 
            FROM vendas 
            WHERE data_venda >= DATE_SUB(NOW(), INTERVAL ? DAY)
            GROUP BY DATE(data_venda)
            ORDER BY data_venda";
    */
    return null;
}

function buscarEstoqueReal($periodo) {
    // TODO: Query real no banco
    /*
    $sql = "SELECT DATE(data_movimentacao) as data, 
                   tipo_movimentacao,
                   SUM(quantidade) as total
            FROM movimentacoes_estoque 
            WHERE data_movimentacao >= DATE_SUB(NOW(), INTERVAL ? DAY)
            GROUP BY DATE(data_movimentacao), tipo_movimentacao
            ORDER BY data_movimentacao";
    */
    return null;
}

function buscarCategoriasReais() {
    // TODO: Query real no banco
    /*
    $sql = "SELECT c.nome, COUNT(p.id) as total_produtos
            FROM categorias c
            LEFT JOIN produtos p ON c.id = p.categoria_id
            WHERE p.status = 'ATIVO'
            GROUP BY c.id, c.nome
            ORDER BY total_produtos DESC";
    */
    return null;
}

?>