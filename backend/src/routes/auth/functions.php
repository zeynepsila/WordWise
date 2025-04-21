<?php

use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;
use Controllers\AuthController;

function handleRegister(Request $request, Response $response, $container): Response
{
    $controller = new AuthController(
        $container->get(PDO::class),
        $container->get('settings')['jwt_secret']
    );

    return $controller->register($request, $response);
}

function handleLogin(Request $request, Response $response, $container): Response
{
    $controller = new AuthController(
        $container->get(PDO::class),
        $container->get('settings')['jwt_secret']
    );

    return $controller->login($request, $response);
}

