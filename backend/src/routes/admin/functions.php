<?php

use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;
use Controllers\AdminController;

function handleGetAllWords(Request $request, Response $response, $container): Response
{
    $controller = new AdminController($container->get(PDO::class));
    return $controller->getAllWords($request, $response);
}

function handleAddWord(Request $request, Response $response, $container): Response
{
    $controller = new AdminController($container->get(PDO::class));
    return $controller->addWord($request, $response);
}

function handleUpdateWord(Request $request, Response $response, $container, $args): Response
{
    $controller = new AdminController($container->get(PDO::class));
    return $controller->updateWord($request, $response, $args);
}
function handleDeleteWord(Request $request, Response $response, $container, $args): Response
{
    $controller = new AdminController($container->get(PDO::class));
    return $controller->deleteWord($request, $response, $args);
}

function handleGetAllUsers(Request $request, Response $response, $container): Response
{
    $controller = new AdminController($container->get(PDO::class));
    return $controller->getAllUsers($request, $response);
}

function handleDeleteUser(Request $request, Response $response, $container, $args): Response
{
    $controller = new AdminController($container->get(PDO::class));
    return $controller->deleteUser($request, $response, $args);
}
