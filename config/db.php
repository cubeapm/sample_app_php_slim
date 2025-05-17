<?php

class DB {
    private $db;

    public function connect() {
        $host = 'mysql'; // Docker container name
        $dbname = 'test';
        $user = 'root';
        $pass = 'root';

        $dsn = "mysql:host=$host;dbname=$dbname;charset=utf8mb4";
        $options = [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_OBJ,
        ];

        $this->db = new PDO($dsn, $user, $pass, $options);
        return $this->db;
    }

    public function select($query) {
        $stmt = $this->connect()->query($query);
        return $stmt->fetchAll();
    }
}