<?php

return function ($app) {
    $container = $app->getContainer();

    $container->set('settings', function () {
        return [
            'db' => [
                'host' => 'localhost',
                'dbname' => 'word_guessing_game',
                'user' => 'root',
                'pass' => ''
            ],
            'jwt_secret' => 'mySuperSecretKey'
        ];
    });
};
