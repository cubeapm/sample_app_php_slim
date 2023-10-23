<?php

use Slim\Factory\AppFactory;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;
use Predis\Client;

require __DIR__ . "/../vendor/autoload.php";

$app = AppFactory::create();

$app->get('/', function (Request $request, Response $response, $args) {
    $response->getBody()->write("Hello");
    return $response;
});

$app->get('/redis', function (Request $request, Response $response, $args) {
    $redis = new Client();
    $redis->set('foo', 'bar');
    $value = $redis->get('foo');
    $response->getBody()->write('Redis called - Value retrieved from Redis: ' . $value);

    return $response;
});

$app->run();
