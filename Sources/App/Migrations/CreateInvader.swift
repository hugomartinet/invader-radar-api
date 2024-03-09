import Fluent

struct CreateInvader: AsyncMigration {
  func prepare(on database: Database) async throws {
    try await database.schema("invaders")
      .id()
      .field("name", .string, .required)
      .field("latitude", .float, .required)
      .field("longitude", .float, .required)
      .create()
  }

  func revert(on database: Database) async throws {
    try await database.schema("invaders").delete()
  }
}
