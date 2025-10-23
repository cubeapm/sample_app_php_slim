# Elastic Instrumentation

This branch contains code for Elastic instrumentation.

By default, hitting an API endpoint will generate a trace, which is sent to CubeAPM. This behavior is controlled via settings in [docker-compose.yml](docker-compose.yml) and [Dockerfile](Dockerfile).

Refer the project README below for more details.

## Troubleshooting

If the app does not show up in CubeAPM after integration is done, add the below configuration to check Elastic agent logs.

```shell
# Set Elastic agent log level to debug if needed to see detailed logs
#elastic_apm.log_level=debug
```

---

# Php slim Instrumentation

This is a sample app to demonstrate how to instrument Php slim app with **Datadog**, **Elastic**, **New Relic** and **OpenTelemetry**. It contains source code for the Php app which interacts with various services like Redis, MySQL etc. to demonstrate tracing for these services. This repository has a docker compose file to set up all these services conveniently.

The code is organized into multiple branches. The main branch has the Php app without any instrumentation. Other branches then build upon the main branch to add specific instrumentations as below:

| Branch                                                                                         | Instrumentation | Code changes for instrumentation                                                                                |
| ---------------------------------------------------------------------------------------------- | --------------- | --------------------------------------------------------------------------------------------------------------- |
| [main](https://github.com/cubeapm/sample_app_php_slim/tree/main)         | None            | -                                                                                                               |
| [datadog](https://github.com/cubeapm/sample_app_php_slim/tree/datadog) | Datadog       | [main...datadog](https://github.com/cubeapm/sample_app_php_slim/compare/main...datadog) |
| [elastic](https://github.com/cubeapm/sample_app_php_slim/tree/elastic)         | Elastic   | [main...elastic](https://github.com/cubeapm/sample_app_php_slim/compare/main...elastic)         |
| [newrelic](https://github.com/cubeapm/sample_app_php_slim/tree/newrelic) | New Relic       | [main...newrelic](https://github.com/cubeapm/sample_app_php_slim/compare/main...newrelic) |
| [otel](https://github.com/cubeapm/sample_app_php_slim/tree/otel)         | OpenTelemetry   | [main...otel](https://github.com/cubeapm/sample_app_php_slim/compare/main...otel)         |

# Setup

Clone this repository and go to the project directory. Then run the following commands

```
docker compose up --build
```

Php app will now be available at `http://localhost:8000`.

The app has various API endpoints to demonstrate integrations with Redis, MySQL etc. Check out [public/index.php](public/index.php) for the API endpoints.

# Contributing

Please feel free to raise PR for any enhancements - additional service integrations, library version updates, documentation updates, etc.
