<?php

use Psr\Container\ContainerInterface;

return function ($app) {
    $container = $app->getContainer();

    $container->set(PDO::class, function (ContainerInterface $c) {
        $settings = $c->get('settings')['db'];
        $dsn = "mysql:host={$settings['host']};dbname={$settings['dbname']};charset=utf8mb4";
        return new PDO($dsn, $settings['user'], $settings['pass'], [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        ]);
    });
};
