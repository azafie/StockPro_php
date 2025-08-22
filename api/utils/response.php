<?php
// ========================================================
//  api/utils/Response.php - CORRIGIDO
// ========================================================
class Response {
    public static function json($data, $status = 200) {
        http_response_code($status);
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode($data, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
        exit;
    }

    public static function success($data = null, $message = "Sucesso") {
        self::json([
            'success' => true,
            'message' => $message,
            'data' => $data
        ], 200);
    }

    public static function error($message = "Erro interno", $status = 500) {
        self::json([
            'success' => false,
            'message' => $message,
            'data' => null
        ], $status);
    }
    
    public static function badRequest($message = "Requisição inválida") {
        self::json([
            'success' => false,
            'message' => $message,
            'data' => null
        ], 400);
    }
    
    public static function notFound($message = "Não encontrado") {
        self::json([
            'success' => false,
            'message' => $message,
            'data' => null
        ], 404);
    }
}
?>