<?php

return [
    "backend" => [
        "type" => "\\Pimcore\\Cache\\Backend\\Redis2",
        "custom" => "true",
        "options" => [
            "server" => "127.0.0.1",
            "port" => "6379",
            "persistent" => "1",
            "database" => "1",
            "use_lua" => "1"
        ]
    ]
];
