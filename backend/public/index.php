<?php

use Slim\Factory\AppFactory;
use DI\Container;

require __DIR__ . '/../vendor/autoload.php';

// 📦 Container oluştur
$container = new Container();
AppFactory::setContainer($container);

// 🧠 App oluştur
$app = AppFactory::create();

// 🛡️ Hata middleware
$app->addErrorMiddleware(true, true, true);

// 🧩 Ayarlar, bağımlılıklar, middleware
(require __DIR__ . '/../src/core/settings.php')($app);
(require __DIR__ . '/../src/core/dependencies.php')($app);
(require __DIR__ . '/../src/core/middleware.php')($app);

// 📍 Rotalar
(require __DIR__ . '/../src/routes/auth/routes.php')($app);
(require __DIR__ . '/../src/routes/game/routes.php')($app);
(require __DIR__ . '/../src/routes/admin/routes.php')($app);


// 🚀 Uygulamayı çalıştır
$app->run();
