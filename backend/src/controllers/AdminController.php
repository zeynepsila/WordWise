<?php

namespace Controllers;

use PDO;

class AdminController
{
    private $db;

    public function __construct(PDO $db)
    {
        $this->db = $db;
    }

    // ✅ Tüm kelimeleri getir
    public function getAllWords($request, $response)
    {
        $stmt = $this->db->query("SELECT id, word_en, word_tr, level FROM words ORDER BY id DESC");
        $words = $stmt->fetchAll();

        return $response->withHeader('Content-Type', 'application/json')
            ->write(json_encode([
                'status' => 'ok',
                'data' => $words
            ]));
    }

    public function addWord($request, $response)
{
    $data = (array)$request->getParsedBody();
    $word_en = trim($data['word_en'] ?? '');
    $word_tr = trim($data['word_tr'] ?? '');
    $level = $data['level'] ?? '';

    $validLevels = ['beginner', 'intermediate', 'advanced'];

    if (!$word_en || !$word_tr || !in_array($level, $validLevels)) {
        return $response->withStatus(400)->withHeader('Content-Type', 'application/json')
            ->write(json_encode([
                'status' => 'error',
                'message' => 'Missing or invalid word data'
            ]));
    }

    $stmt = $this->db->prepare("INSERT INTO words (word_en, word_tr, level) VALUES (?, ?, ?)");
    $stmt->execute([$word_en, $word_tr, $level]);

    return $response->withHeader('Content-Type', 'application/json')
        ->write(json_encode([
            'status' => 'ok',
            'message' => 'Word added successfully'
        ]));
}

    public function updateWord($request, $response, $args)
{
    $id = $args['id'];
    $data = (array)$request->getParsedBody();
    $word_en = trim($data['word_en'] ?? '');
    $word_tr = trim($data['word_tr'] ?? '');
    $level = $data['level'] ?? '';

    $validLevels = ['beginner', 'intermediate', 'advanced'];

    if (!$word_en || !$word_tr || !in_array($level, $validLevels)) {
        return $response->withStatus(400)->withHeader('Content-Type', 'application/json')
            ->write(json_encode([
                'status' => 'error',
                'message' => 'Missing or invalid data'
            ]));
    }

    $stmt = $this->db->prepare("UPDATE words SET word_en = ?, word_tr = ?, level = ? WHERE id = ?");
    $stmt->execute([$word_en, $word_tr, $level, $id]);

    return $response->withHeader('Content-Type', 'application/json')
        ->write(json_encode([
            'status' => 'ok',
            'message' => 'Word updated successfully'
        ]));
}

    public function deleteWord($request, $response, $args)
    {
        $id = $args['id'];

        $stmt = $this->db->prepare("DELETE FROM words WHERE id = ?");
        $stmt->execute([$id]);

        return $response->withHeader('Content-Type', 'application/json')
            ->write(json_encode([
                'status' => 'ok',
                'message' => 'Word deleted successfully'
            ]));
    }

    public function getAllUsers($request, $response)
{
    $stmt = $this->db->query("SELECT id, username, role FROM users ORDER BY id DESC");
    $users = $stmt->fetchAll();

    return $response->withHeader('Content-Type', 'application/json')
        ->write(json_encode([
            'status' => 'ok',
            'data' => $users
        ]));
}

    public function deleteUser($request, $response, $args)
    {
        $id = $args['id'];

        // Kendini silmeye karşı önlem
        $authUser = $request->getAttribute('user');
        if ((int)$authUser->sub === (int)$id) {
            return $response->withStatus(403)->withHeader('Content-Type', 'application/json')
                ->write(json_encode([
                    'status' => 'error',
                    'message' => 'You cannot delete yourself'
                ]));
        }

        $stmt = $this->db->prepare("DELETE FROM users WHERE id = ?");
        $stmt->execute([$id]);

        return $response->withHeader('Content-Type', 'application/json')
            ->write(json_encode([
                'status' => 'ok',
                'message' => 'User deleted successfully'
            ]));
    }


}
