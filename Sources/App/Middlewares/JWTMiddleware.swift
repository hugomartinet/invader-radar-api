import JWT
import Vapor

struct JWTMiddleware: AsyncMiddleware {
  func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
    guard let bearer = request.headers.bearerAuthorization else {
      throw Abort(.unauthorized)
    }
    let token = bearer.token
    do {
      let payload = try request.jwt.verify(token, as: AuthenticationPayload.self)
      request.auth.login(payload)
    } catch {
      throw Abort(.unauthorized)
    }
    return try await next.respond(to: request)
  }
}

struct AuthenticationPayload: JWTPayload, Authenticatable {
  var userID: UUID
  var username: String
  var exp: ExpirationClaim

  func verify(using signer: JWTSigner) throws {
    try exp.verifyNotExpired()
  }
}
