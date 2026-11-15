# Most Common Go libraries

## Web Development & HTTP

### Routers & Web Frameworks:

Gin - The most popular minimalist framework for building REST APIs and single-page application backends Top 10 Golang Frameworks in 2025 - GeeksforGeeks
Echo - Lightweight web framework with custom error handling and middleware support
Chi - HTTP router compatible with standard library, excellent route grouping
Fiber - Express.js-inspired framework built on Fasthttp

### HTTP Utilities:

Gorilla Mux - Powerful URL router and dispatcher (though less popular now)

## Database & Storage

### SQL Libraries:

sqlx - Extensions to database/sql with better scanning and named parameters
SQLBoiler - Type-safe ORM that generates code from database schema
GORM - Full-featured ORM with associations, hooks, and migrations

### Database Drivers:

pq - PostgreSQL driver
mysql - MySQL driver
sqlite3 - SQLite driver

### Migrations:

sql-migrate - SQL schema migration tool
goose - Database migration tool

## CLI Development

### Command Line Libraries:

Cobra - Powerful library for creating CLI applications (used by kubectl, Hugo)
urfave/cli - Simple, fast CLI library
flag - Built-in Go package for basic flag parsing

## Configuration & Environment

### Configuration Management:

Viper - Configuration solution supporting JSON, YAML, ENV variables
koanf - Lightweight configuration library supporting multiple formats
caarlos0/env - Simple library for loading environment variables into structs

## Logging & Observability

### Logging:

Logrus - Structured logger with hooks and formatters
zap - Ultra-fast, structured logging library by Uber
slog - New structured logging package in Go standard library (Go 1.21+)

### Monitoring & Tracing:

Prometheus client - Metrics collection and exposition
OpenTelemetry - Observability framework for metrics, logs, and traces
opencensus-go - Deprecated but still used for metrics and tracing

## Testing

### Testing Libraries:

testify - Toolkit with assertions, mocks, and test suites
go-cmp - Package for comparing Go values in tests
gofakeit - Library for generating fake data in tests

## Data Processing & Utilities

### Data Types:

google/uuid - UUID generation and parsing
shopspring/decimal - Decimal type for financial calculations
samber/lo - Lodash-style utility functions using generics

### JSON & Serialization:

json-iterator - High-performance JSON library
mapstructure - Decoding generic map values to native structures

## Messaging & Communication

### Message Brokers:

Watermill - Event-driven applications library with support for Kafka, GCP Pub/Sub, NATS, RabbitMQ
sarama - Kafka client library
NATS - Simple, secure, and performant messaging system

### gRPC:

protoc - Protocol buffer compiler for gRPC services

## Error Handling

### Error Libraries:

errors - Enhanced error handling (pkg/errors, now part of standard library)
hashicorp/go-multierror - Accumulating multiple errors

## Security & Validation

### Validation:

validator - Struct and field validation based on tags
go-playground/validator - Popular validation library

### Authentication:

jwt-go - JSON Web Token implementation
oauth2 - OAuth 2.0 client implementation

## File & Data Processing

### File Operations:

afero - Filesystem abstraction layer
embed - Built-in package for embedding files (Go 1.16+)

## Development Tools

### Code Generation:

oapi-codegen - OpenAPI client and server code generator
stringer - Tool for generating String methods for enum types

### Build & Task Automation:

Task - Modern alternative to Make
Mage - Make-like build tool using Go

## Most Essential Libraries for Beginners
For someone starting with Go CLI tools, I'd recommend focusing on these core libraries first:

Cobra - For CLI structure and commands
Viper - For configuration management
testify - For testing
sqlx or GORM - For database operations
Logrus or zap - For logging
validator - For input validation
