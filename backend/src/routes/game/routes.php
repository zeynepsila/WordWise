<?php

use Slim\App;
use Middleware\AuthMiddleware;

require_once __DIR__ . '/functions.php';

return function (App $app) {
    $container = $app->getContainer();
    $jwtSecret = $container->get('settings')['jwt_secret'];

    // Kullanıcı giriş yapmış mı kontrolü ekleniyor
    $app->get('/get-word/{level}', function ($request, $response, $args) use ($container) {
        return handleGetWord($request, $response, $container, $args);
    })->add(new AuthMiddleware($jwtSecret));

    $app->post('/start-game', function ($request, $response) use ($container) {
        return handleStartGame($request, $response, $container);
    })->add(new AuthMiddleware($jwtSecret));

    $app->post('/guess', function ($request, $response) use ($container) {
        return handleGuess($request, $response, $container);
    })->add(new AuthMiddleware($jwtSecret));
    
    $app->get('/stats', function ($request, $response) use ($container) {
    return handleGetStats($request, $response, $container);
    })->add(new AuthMiddleware($jwtSecret));

    $app->get('/game-status/{id}', function ($request, $response, $args) use ($container) {
        return handleGetGameStatus($request, $response, $container, $args);
    })->add(new AuthMiddleware($jwtSecret));

    $app->get('/my-games', function ($request, $response) use ($container) {
        return handleGetUserGames($request, $response, $container);
    })->add(new AuthMiddleware($jwtSecret));

    $app->get('/guesses/{id}', function ($request, $response, $args) use ($container) {
        return handleGetGuessesByGameId($request, $response, $container, $args);
    })->add(new AuthMiddleware($jwtSecret));
    
    $app->get('/my-stats', function ($request, $response) use ($container) {
        return handleGetUserStats($request, $response, $container);
    })->add(new AuthMiddleware($jwtSecret));
    
    
};
