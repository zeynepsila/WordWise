<?php

use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;
use Controllers\GameController;

function handleGetWord(Request $request, Response $response, $container, $args): Response
{
    $controller = new GameController($container->get(PDO::class));
    return $controller->getWord($request, $response, $args);
}

function handleStartGame($request, $response, $container)
{
    $controller = new GameController($container->get(PDO::class));
    return $controller->startGame($request, $response);
}

function handleGuess($request, $response, $container)
{
    $controller = new GameController($container->get(PDO::class));
    return $controller->guessLetter($request, $response);
}

function handleGetStats($request, $response, $container)
{
    $controller = new GameController($container->get(PDO::class));
    return $controller->getStats($request, $response);
}

function handleGetGameStatus($request, $response, $container, $args): Response
{
    $controller = new GameController($container->get(PDO::class));
    return $controller->getGameStatus($request, $response, $args);
}

function handleGetUserGames($request, $response, $container): Response
{
    $controller = new GameController($container->get(PDO::class));
    return $controller->getUserGames($request, $response);
}

function handleGetGuessesByGameId($request, $response, $container, $args): Response
{
    $controller = new GameController($container->get(PDO::class));
    return $controller->getGuessesByGameId($request, $response, $args);
}

function handleGetUserStats($request, $response, $container): Response
{
    $controller = new GameController($container->get(PDO::class));
    return $controller->getUserStats($request, $response);
}
