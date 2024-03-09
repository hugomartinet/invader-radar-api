import Fluent
import JWT
import Vapor

struct UserController: RouteCollection {
  func boot(routes: RoutesBuilder) throws {
    let users = routes.grouped("users")
    users.post("signup", use: signup)
    users.post("login", use: login)

  }

  func signup(req: Request) async throws -> HTTPStatus {
    let user = try req.content.decode(User.self)
    guard
      try await User.query(on: req.db)
        .filter(\.$username == user.username)
        .first() == nil
    else {
      throw Abort(.badRequest, reason: "Username already exists")
    }
    user.password = try BCryptDigest().hash(user.password)
    try await user.save(on: req.db)
    return .ok
  }

  func login(req: Request) async throws -> String {
    let loginRequest = try req.content.decode(User.self)
    guard
      let dbUser = try await User.query(on: req.db)
        .filter(\.$username == loginRequest.username)
        .first()
    else {
      throw Abort(.unauthorized)
    }

    if try BCryptDigest().verify(loginRequest.password, created: dbUser.password) {
      let payload = AuthenticationPayload(
        userID: dbUser.id!, username: dbUser.username,
        exp: ExpirationClaim(value: Date().addingTimeInterval(60 * 60)))
      let token = try req.jwt.sign(payload)
      return token
    } else {
      throw Abort(.unauthorized)
    }
  }

}
