import Fluent

struct CreateUserInvaderPivot: AsyncMigration {
  func prepare(on database: Database) async throws {
    let userInvaderFlagType = try await database.enum("user_invader_flag")
      .case("FLASHED")
      .case("DESTROYED")
      .create()

    try await database.schema("user_invader")
      .id()
      .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
      .field("invader_id", .uuid, .required, .references("invaders", "id", onDelete: .cascade))
      .field("flag", userInvaderFlagType)
      .create()
  }

  func revert(on database: Database) async throws {
    try await database.schema("user_invader").delete()

    try await database.enum("user_invader_flag").delete()

  }
}
