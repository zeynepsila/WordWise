<?php

namespace Controllers;

use PDO;

class GameController
{
    private $db;

    public function __construct(PDO $db)
    {
        $this->db = $db;
    }

    public function getWord($request, $response, $args)
    {
        $level = $args['level'];

        // Zorluk seviyesi geçerli mi?
        $validLevels = ['beginner', 'intermediate', 'advanced'];
        if (!in_array($level, $validLevels)) {
            return $response->withStatus(400)->withHeader('Content-Type', 'application/json')
                ->write(json_encode(['status' => 'error', 'message' => 'Invalid level']));
        }

        $stmt = $this->db->prepare("SELECT word_en AS word, word_tr AS meaning_tr FROM words WHERE level = ? ORDER BY RAND() LIMIT 1");
        $stmt->execute([$level]);
        $word = $stmt->fetch();

        if (!$word) {
            return $response->withStatus(404)->withHeader('Content-Type', 'application/json')
                ->write(json_encode(['status' => 'error', 'message' => 'No words found for this level']));
        }

        return $response->withHeader('Content-Type', 'application/json')
            ->write(json_encode([
                'status' => 'ok',
                'word_length' => strlen($word['word']),
                'meaning_tr' => $word['meaning_tr']
            ]));
    }

    public function startGame($request, $response)
{
    $data = (array)$request->getParsedBody();
    $level = $data['level'] ?? null;

    $validLevels = ['beginner', 'intermediate', 'advanced'];
    if (!$level || !in_array($level, $validLevels)) {
        return $response->withStatus(400)->withHeader('Content-Type', 'application/json')
            ->write(json_encode(['status' => 'error', 'message' => 'Invalid or missing level']));
    }

    // Kullanıcı ID’sini JWT’den al
    $user = $request->getAttribute('user');
    $userId = $user->sub;

    // Seçilen seviyeye göre rastgele kelime getir
    $stmt = $this->db->prepare("SELECT word_en, word_tr FROM words WHERE level = ? ORDER BY RAND() LIMIT 1");
    $stmt->execute([$level]);
    $wordData = $stmt->fetch();

    if (!$wordData) {
        return $response->withStatus(404)->withHeader('Content-Type', 'application/json')
            ->write(json_encode(['status' => 'error', 'message' => 'No word found for this level']));
    }

    // Oyun kaydını oluştur
    $stmt = $this->db->prepare("INSERT INTO games (user_id, word, level) VALUES (?, ?, ?)");
    $stmt->execute([$userId, $wordData['word_en'], $level]);

    $gameId = $this->db->lastInsertId();

    return $response->withHeader('Content-Type', 'application/json')
        ->write(json_encode([
            'status' => 'ok',
            'message' => 'Game started',
            'game_id' => $gameId,
            'word_length' => strlen($wordData['word_en']),
            'meaning_tr' => $wordData['word_tr']
        ]));
}

    public function guessLetter($request, $response)
    {
        $data = (array)$request->getParsedBody();
        $guess = strtolower($data['letter'] ?? '');
        $gameId = $data['game_id'] ?? null;

        if (!$guess || !$gameId || strlen($guess) !== 1) {
            return $response->withStatus(400)->withHeader('Content-Type', 'application/json')
                ->write(json_encode(['status' => 'error', 'message' => 'Invalid letter or game_id']));
        }

        $user = $request->getAttribute('user');
        $userId = $user->sub;

        // Oyunu getir
        $stmt = $this->db->prepare("SELECT * FROM games WHERE id = ? AND user_id = ?");
        $stmt->execute([$gameId, $userId]);
        $game = $stmt->fetch();

        if (!$game) {
            return $response->withStatus(404)->withHeader('Content-Type', 'application/json')
                ->write(json_encode(['status' => 'error', 'message' => 'Game not found']));
        }

        if ($game['is_won']) {
            return $response->withHeader('Content-Type', 'application/json')
                ->write(json_encode(['status' => 'info', 'message' => 'Game already won']));
        }

        if ($game['attempts_left'] <= 0) {
            return $response->withHeader('Content-Type', 'application/json')
                ->write(json_encode(['status' => 'info', 'message' => 'No attempts left']));
        }

        // Aynı harf daha önce tahmin edilmiş mi?
        $stmt = $this->db->prepare("SELECT COUNT(*) FROM guesses WHERE game_id = ? AND letter = ?");
        $stmt->execute([$gameId, $guess]);
        if ($stmt->fetchColumn() > 0) {
            return $response->withStatus(409)->withHeader('Content-Type', 'application/json')
                ->write(json_encode(['status' => 'error', 'message' => 'Letter already guessed']));
        }

        $word = strtolower($game['word']);
        $isCorrect = strpos($word, $guess) !== false;

        // Tahmini kaydet
        $stmt = $this->db->prepare("INSERT INTO guesses (game_id, user_id, letter, is_correct) VALUES (?, ?, ?, ?)");
        $stmt->execute([$gameId, $userId, $guess, $isCorrect]);

        // Doğru tahmin edilen harfleri topla
        $stmt = $this->db->prepare("SELECT letter FROM guesses WHERE game_id = ? AND is_correct = 1");
        $stmt->execute([$gameId]);
        $correctGuesses = array_column($stmt->fetchAll(), 'letter');

        $allLettersGuessed = true;
        foreach (str_split($word) as $char) {
            if (!in_array($char, $correctGuesses)) {
                $allLettersGuessed = false;
                break;
            }
        }

        // Oyunu güncelle
        $newAttemptsLeft = $isCorrect ? $game['attempts_left'] : $game['attempts_left'] - 1;
        $stmt = $this->db->prepare("UPDATE games SET attempts_left = ?, is_won = ? WHERE id = ?");
        $stmt->execute([$newAttemptsLeft, $allLettersGuessed ? 1 : $game['is_won'], $gameId]);

        return $response->withHeader('Content-Type', 'application/json')
            ->write(json_encode([
                'status' => $isCorrect ? 'ok' : 'fail',
                'correct' => $isCorrect,
                'remaining_attempts' => $newAttemptsLeft,
                'is_won' => $allLettersGuessed
            ]));
    }

    public function getStats($request, $response)
    {
        $user = $request->getAttribute('user');
        $userId = $user->sub;
    
        // Toplam oyun sayısı
        $stmt = $this->db->prepare("SELECT COUNT(*) as total FROM games WHERE user_id = ?");
        $stmt->execute([$userId]);
        $totalGames = $stmt->fetchColumn();
    
        // Kazanılan oyun sayısı
        $stmt = $this->db->prepare("SELECT COUNT(*) as won FROM games WHERE user_id = ? AND is_won = 1");
        $stmt->execute([$userId]);
        $wonGames = $stmt->fetchColumn();
    
        // Son 5 oyun
        $stmt = $this->db->prepare("SELECT word, level, is_won, played_at FROM games WHERE user_id = ? ORDER BY played_at DESC LIMIT 5");
        $stmt->execute([$userId]);
        $recentGames = $stmt->fetchAll();
    
        return $response->withHeader('Content-Type', 'application/json')
            ->write(json_encode([
                'status' => 'ok',
                'total_games' => (int)$totalGames,
                'games_won' => (int)$wonGames,
                'success_rate' => $totalGames > 0 ? round(($wonGames / $totalGames) * 100, 2) : 0,
                'recent_games' => $recentGames
            ]));
    }
    
    public function getGameStatus($request, $response, $args)
{
    $gameId = $args['id'];
    $user = $request->getAttribute('user');
    $userId = $user->sub;

    // Oyunu getir
    $stmt = $this->db->prepare("SELECT * FROM games WHERE id = ? AND user_id = ?");
    $stmt->execute([$gameId, $userId]);
    $game = $stmt->fetch();

    if (!$game) {
        return $response->withStatus(404)->withHeader('Content-Type', 'application/json')
            ->write(json_encode(['status' => 'error', 'message' => 'Game not found']));
    }

    $word = strtolower($game['word']);

    // Doğru tahminleri al
    $stmt = $this->db->prepare("SELECT letter FROM guesses WHERE game_id = ? AND is_correct = 1");
    $stmt->execute([$gameId]);
    $correctGuesses = array_column($stmt->fetchAll(), 'letter');

    // Kelimenin güncel görünümünü oluştur (_a__e gibi)
    $display = [];
    foreach (str_split($word) as $char) {
        $display[] = in_array($char, $correctGuesses) ? $char : '_';
    }

    // Türkçesini bul
    $stmt = $this->db->prepare("SELECT word_tr FROM words WHERE word_en = ?");
    $stmt->execute([$word]);
    $row = $stmt->fetch();
    $meaningTr = $row['word_tr'] ?? '';

    return $response->withHeader('Content-Type', 'application/json')
        ->write(json_encode([
            'status' => 'ok',
            'word' => $word,
            'word_progress' => implode('', $display),
            'correct_guesses' => $correctGuesses,
            'remaining_attempts' => (int)$game['attempts_left'],
            'is_won' => (bool)$game['is_won'],
            'meaning_tr' => $meaningTr // ✅ EKLENDİ
        ]));
}


    public function getUserGames($request, $response)
    {
        $user = $request->getAttribute('user');
        $userId = $user->sub;

        $stmt = $this->db->prepare("SELECT id, word, level, is_won, attempts_left, played_at FROM games WHERE user_id = ? ORDER BY played_at DESC");
        $stmt->execute([$userId]);
        $games = $stmt->fetchAll();

        return $response->withHeader('Content-Type', 'application/json')
            ->write(json_encode([
                'status' => 'ok',
                'games' => $games
            ]));
    }
    public function getGuessesByGameId($request, $response, $args)
    {
        $gameId = $args['id'];
        $user = $request->getAttribute('user');
        $userId = $user->sub;
    
        // Oyun gerçekten bu kullanıcıya mı ait?
        $stmt = $this->db->prepare("SELECT id FROM games WHERE id = ? AND user_id = ?");
        $stmt->execute([$gameId, $userId]);
        if (!$stmt->fetch()) {
            return $response->withStatus(404)->withHeader('Content-Type', 'application/json')
                ->write(json_encode(['status' => 'error', 'message' => 'Game not found or unauthorized']));
        }
    
        // Tahminleri getir
        $stmt = $this->db->prepare("SELECT letter, is_correct, guessed_at FROM guesses WHERE game_id = ? ORDER BY guessed_at ASC");
        $stmt->execute([$gameId]);
        $guesses = $stmt->fetchAll();
    
        return $response->withHeader('Content-Type', 'application/json')
            ->write(json_encode([
                'status' => 'ok',
                'guesses' => $guesses
            ]));
    }
    
    public function getUserStats($request, $response)
{
    $user = $request->getAttribute('user');
    $userId = $user->sub;

    // Toplam oyun sayısı
    $stmt = $this->db->prepare("SELECT COUNT(*) FROM games WHERE user_id = ?");
    $stmt->execute([$userId]);
    $totalGames = (int)$stmt->fetchColumn();

    // Kazanılan oyun sayısı
    $stmt = $this->db->prepare("SELECT COUNT(*) FROM games WHERE user_id = ? AND is_won = 1");
    $stmt->execute([$userId]);
    $wonGames = (int)$stmt->fetchColumn();

    // Ortalama kalan deneme hakkı
    $stmt = $this->db->prepare("SELECT AVG(attempts_left) FROM games WHERE user_id = ?");
    $stmt->execute([$userId]);
    $avgAttemptsLeft = round((float)$stmt->fetchColumn(), 2);

    // Ortalama doğru tahmin (guesses tablosundan)
    $stmt = $this->db->prepare("SELECT AVG(correct_count) FROM (
        SELECT COUNT(*) AS correct_count FROM guesses
        WHERE user_id = ? AND is_correct = 1
        GROUP BY game_id
    ) AS correct_stats");
    $stmt->execute([$userId]);
    $avgCorrectGuesses = round((float)$stmt->fetchColumn(), 2);

    return $response->withHeader('Content-Type', 'application/json')
        ->write(json_encode([
            'status' => 'ok',
            'total_games' => $totalGames,
            'games_won' => $wonGames,
            'success_rate' => $totalGames > 0 ? round(($wonGames / $totalGames) * 100, 2) : 0,
            'avg_attempts_left' => $avgAttemptsLeft,
            'avg_correct_guesses' => $avgCorrectGuesses
        ]));
}


}
