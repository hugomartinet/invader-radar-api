import Fluent
import Vapor

func routes(_ app: Application) throws {
  app.get { _ async in
    "Hello, world!"
  }
  try app.register(collection: InvaderController())
  try app.register(collection: UserController())
  try app.register(collection: UserInvaderController())
}
