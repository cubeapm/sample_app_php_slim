<?php

use Slim\Factory\AppFactory;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;
use GuzzleHttp\Client;
use Predis\Client as RedisClient;

require __DIR__ . "/../vendor/autoload.php";
require_once __DIR__ . "/../config/db.php";

$redis = new RedisClient();

$app = AppFactory::create();
$app->addRoutingMiddleware();

$app->get('/', function (Request $request, Response $response, $args) {
    $response->getBody()->write("Hello");
    return $response;
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
    $sql = "SELECT * FROM friends";

    try {
        $db = new DB();
        $conn = $db->connect();

        $stmt = $conn->query($sql);
        $friends = $stmt->fetchAll(PDO::FETCH_OBJ);

        $db = null;
        $response->getBody()->write(json_encode($friends));
        return $response
            ->withHeader('content-type', 'application/json')
            ->withStatus(200);
    } catch (PDOException $e) {
        $error = array(
            "message" => $e->getMessage()
        );

        $response->getBody()->write(json_encode($error));
        return $response
            ->withHeader('content-type', 'application/json')
            ->withStatus(500);
    }
});

$errorMiddleware = $app->addErrorMiddleware(true, true, true);

$app->run();
