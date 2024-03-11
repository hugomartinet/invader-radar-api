import Fluent
import Vapor

final class UserInvader: Model, Content {
  static let schema = "user_invader"

  @ID(key: .id)
  var id: UUID?

  @Parent(key: "user_id")
  var user: User

  @Parent(key: "invader_id")
  var invader: Invader

  enum Flag: String, Codable {
    case flashed = "FLASHED"
    case destroyed = "DESTROYED"
  }

  @Enum(key: "flag")
  var flag: Flag

  init() {}

  init(userID: User.IDValue, invaderID: Invader.IDValue, flag: Flag) {
    self.$user.id = userID
    self.$invader.id = invaderID
    self.flag = flag
  }
}
