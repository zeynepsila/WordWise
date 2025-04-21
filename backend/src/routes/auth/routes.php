<?php

use Slim\App;

require_once __DIR__ . '/functions.php';

return function (App $app) {
    $container = $app->getContainer();

    $app->post('/register', function ($request, $response) use ($container) {
        return handleRegister($request, $response, $container);
    });

    $app->post('/login', function ($request, $response) use ($container) {
        return handleLogin($request, $response, $container);
    });
    
};



