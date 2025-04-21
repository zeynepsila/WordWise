<?php

namespace Controllers;

use PDO;

class AuthController {
    private $db;
    private $jwtSecret;

    public function __construct(PDO $db, string $jwtSecret)
    {
        $this->db = $db;
        $this->jwtSecret = $jwtSecret;
    }

    public function register($request, $response)
{
    $data = (array)$request->getParsedBody();
    $username = $data['username'] ?? '';
    $password = $data['password'] ?? '';
    $role = $data['role'] ?? 'user'; // 🔥 eklendi

    $validRoles = ['user', 'admin'];
    if (!in_array($role, $validRoles)) {
        $role = 'user'; // invalid değer gelirse güvenli olarak user ata
    }

    if (!$username || !$password) {
        return $response->withStatus(400)->withHeader('Content-Type', 'application/json')
            ->write(json_encode(['status' => 'error', 'message' => 'Missing username or password']));
    }

    // Kullanıcı var mı kontrol
    $stmt = $this->db->prepare("SELECT id FROM users WHERE username = ?");
    $stmt->execute([$username]);
    if ($stmt->fetch()) {
        return $response->withStatus(409)->withHeader('Content-Type', 'application/json')
            ->write(json_encode(['status' => 'error', 'message' => 'Username already exists']));
    }

    // Kullanıcıyı kaydet
    $hash = password_hash($password, PASSWORD_DEFAULT);
    $stmt = $this->db->prepare("INSERT INTO users (username, password_hash, role) VALUES (?, ?, ?)");
    $stmt->execute([$username, $hash, $role]);

    return $response->withHeader('Content-Type', 'application/json')
        ->write(json_encode(['status' => 'ok', 'message' => 'User registered successfully']));
}

    public function login($request, $response)
{
    $data = (array)$request->getParsedBody();
    $username = $data['username'] ?? '';
    $password = $data['password'] ?? '';

    if (!$username || !$password) {
        return $response->withStatus(400)->withHeader('Content-Type', 'application/json')
            ->write(json_encode(['status' => 'error', 'message' => 'Username and password required']));
    }

    // Kullanıcıyı veritabanından bul
    $stmt = $this->db->prepare("SELECT id, password_hash, role FROM users WHERE username = ?");
    $stmt->execute([$username]);
    $user = $stmt->fetch();

    if (!$user || !password_verify($password, $user['password_hash'])) {
        return $response->withStatus(401)->withHeader('Content-Type', 'application/json')
            ->write(json_encode(['status' => 'error', 'message' => 'Invalid credentials']));
    }

    // JWT token oluştur
    $payload = [
        'sub' => $user['id'],
        'username' => $username,
        'role' => $user['role'] ?? 'user',
        'iat' => time(),
        'exp' => time() + (60 * 60 * 24 * 7)
    ];
    

    $jwt = \Firebase\JWT\JWT::encode($payload, $this->jwtSecret, 'HS256');

    return $response->withHeader('Content-Type', 'application/json')
        ->write(json_encode(['status' => 'ok', 'token' => $jwt]));
}


}
