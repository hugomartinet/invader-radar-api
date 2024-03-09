import Fluent
import JWT
import Vapor

struct InvaderController: RouteCollection {
  func boot(routes: RoutesBuilder) throws {
    let invaders = routes.grouped("invaders")

    // Apply JWT middleware to protect these routes
    let protected = invaders.grouped(JWTMiddleware())

    protected.get(use: index)
    protected.post(use: create)
    protected.group(":invaderID") { invader in
      invader.delete(use: delete)
    }
  }

  func index(req: Request) async throws -> [Invader] {
    let bounds = try req.query.get(CoordinateBounds.self)
    return try await Invader.query(on: req.db)
      .filter(\.$latitude >= (bounds.minLat ?? 0))
      .filter(\.$latitude <= (bounds.maxLat ?? Float(Int.max)))
      .filter(\.$longitude >= (bounds.minLong ?? 0))
      .filter(\.$longitude <= (bounds.maxLong ?? Float(Int.max)))
      .all()
  }

  func create(req: Request) async throws -> Invader {
    let invader = try req.content.decode(Invader.self)
    try await invader.save(on: req.db)
    return invader
  }

  func delete(req: Request) async throws -> HTTPStatus {
    guard let invader = try await Invader.find(req.parameters.get("invaderID"), on: req.db) else {
      throw Abort(.notFound)
    }
    try await invader.delete(on: req.db)
    return .noContent
  }
}

struct CoordinateBounds: Content {
  let minLat: Float?
  let maxLat: Float?
  let minLong: Float?
  let maxLong: Float?
}
