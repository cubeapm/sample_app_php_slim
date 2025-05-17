<?php

use Slim\Factory\AppFactory;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;
use GuzzleHttp\Client;
use Predis\Client as RedisClient;

require __DIR__ . "/../vendor/autoload.php";
require_once __DIR__ . "/../config/db.php";

$redis = new RedisClient([
    'scheme' => 'tcp',
    'host' => 'redis',
    'port' => 6379,
]);

$app = AppFactory::create();
$app->addRoutingMiddleware();

$app->get('/', function (Request $request, Response $response, $args) {
    $response->getBody()->write("Hello");
    return $response;
});

$app->get('/param/{param}', function (Request $request, Response $response, array $args) {
    $param = $args['param'];
    $data = ['param' => $param];
    $response->getBody()->write(json_encode($data));
    return $response->withHeader('Content-Type', 'application/json');
});

$app->get('/exception', function (Request $request, Response $response, $args) {
    throw new \Exception("Sample exception");
});

$app->get('/redis', function (Request $request, Response $response, $args) use ($redis) {
    $redis->set('foo', 'bar');
    $response->getBody()->write('Redis called');

    return $response;
});

$app->get('/mysql', function (Request $request, Response $response) {
    $db = new DB();
    $data = $db->select("SELECT * FROM user");

    $response->getBody()->write(json_encode($data));
    return $response
        ->withHeader('Content-Type', 'application/json')
        ->withStatus(200);
});

$errorMiddleware = $app->addErrorMiddleware(true, true, true);

$app->run();
