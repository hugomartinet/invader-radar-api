import Fluent
import JWT
import Vapor

struct UserInvaderController: RouteCollection {
  func boot(routes: RoutesBuilder) throws {
    let userInvaders = routes.grouped("user-invaders")

    // Apply JWT middleware to protect these routes
    let protected = userInvaders.grouped(JWTMiddleware())

    protected.get(use: index)
    protected.post(use: create)
    protected.group(":userInvaderID") { userInvader in
      userInvader.delete(use: delete)
    }
  }

  func index(req: Request) async throws -> [UserInvader] {
    guard let auth = req.auth.get(AuthenticationPayload.self) else {
      throw Abort(.unauthorized)
    }

    return try await UserInvader.query(on: req.db)
      .filter(\.$user.$id == auth.userID)
      .all()
  }

  struct CreateUserInvaderRequest: Content {
    var invaderID: UUID
    var flag: UserInvader.Flag
  }

  func create(req: Request) async throws -> UserInvader {
    guard let auth = req.auth.get(AuthenticationPayload.self) else {
      throw Abort(.unauthorized)
    }

    let reqContent = try req.content.decode(CreateUserInvaderRequest.self)

    guard let user = try await User.find(auth.userID, on: req.db) else {
      throw Abort(.badRequest)
    }
    guard let invader = try await Invader.find(reqContent.invaderID, on: req.db) else {
      throw Abort(.badRequest)
    }

    let userInvader = UserInvader(
      userID: try user.requireID(), invaderID: try invader.requireID(), flag: reqContent.flag)
    try await userInvader.save(on: req.db)
    return userInvader
  }

  func delete(req: Request) async throws -> HTTPStatus {
    guard let auth = req.auth.get(AuthenticationPayload.self) else {
      throw Abort(.unauthorized)
    }

    guard
      let userInvader = try await UserInvader.find(req.parameters.get("userInvaderID"), on: req.db)
    else {
      throw Abort(.notFound)
    }
    guard userInvader.$user.id == auth.userID else {
      throw Abort(.notFound)
    }

    try await userInvader.delete(on: req.db)
    return .noContent
  }
}
