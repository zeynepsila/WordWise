<?php

use Slim\App;
use Middleware\AuthMiddleware;
use Middleware\AdminOnlyMiddleware;

require_once __DIR__ . '/functions.php';

return function (App $app) {
    $container = $app->getContainer();
    $jwtSecret = $container->get('settings')['jwt_secret'];

    // Admin tüm kelimeleri görebilir
    $app->get('/admin/words', function ($request, $response) use ($container) {
        return handleGetAllWords($request, $response, $container);
    })->add(new AdminOnlyMiddleware())->add(new AuthMiddleware($jwtSecret));

    $app->post('/admin/word/add', function ($request, $response) use ($container) {
        return handleAddWord($request, $response, $container);
    })->add(new AdminOnlyMiddleware())->add(new AuthMiddleware($jwtSecret));
    
    $app->post('/admin/word/update/{id}', function ($request, $response, $args) use ($container) {
        return handleUpdateWord($request, $response, $container, $args);
    })->add(new AdminOnlyMiddleware())->add(new AuthMiddleware($jwtSecret));
    
    $app->delete('/admin/word/delete/{id}', function ($request, $response, $args) use ($container) {
        return handleDeleteWord($request, $response, $container, $args);
    })->add(new AdminOnlyMiddleware())->add(new AuthMiddleware($jwtSecret));
    
    $app->get('/admin/users', function ($request, $response) use ($container) {
        return handleGetAllUsers($request, $response, $container);
    })->add(new AdminOnlyMiddleware())->add(new AuthMiddleware($jwtSecret));

    // Kullanıcı sil
    $app->delete('/admin/user/delete/{id}', function ($request, $response, $args) use ($container) {
        return handleDeleteUser($request, $response, $container, $args);
    })->add(new AdminOnlyMiddleware())->add(new AuthMiddleware($jwtSecret));


};
