import Fluent
import Vapor

final class User: Model, Content {
  static let schema = "users"

  @ID(key: .id)
  var id: UUID?

  @Field(key: "username")
  var username: String

  @Field(key: "password")
  var password: String

  init() {}

  init(username: String, password: String) {
    self.username = username
    self.password = password
  }
}
