import Fluent
import FluentPostgresDriver
import JWT
import NIOSSL
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
  // uncomment to serve files from /Public folder
  // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

  app.databases.use(
    DatabaseConfigurationFactory.postgres(
      configuration: .init(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? 5435,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor",
        database: Environment.get("DATABASE_NAME") ?? "vapor",
        tls: .prefer(try .init(configuration: .clientDefault)))
    ), as: .psql)

  app.migrations.add(CreateInvader())
  app.migrations.add(CreateUser())

  // Configure JWT
  guard let secretKey = Environment.get("SECRET_KEY") else {
    throw Abort(.internalServerError, reason: "SECRET_KEY environment variable not found")
  }
  app.jwt.signers.use(.hs256(key: secretKey))

  // register routes
  try routes(app)
}
