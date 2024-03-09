import Fluent
import Vapor

final class Invader: Model, Content {
  static let schema = "invaders"

  @ID(key: .id)
  var id: UUID?

  @Field(key: "name")
  var name: String

  @Field(key: "latitude")
  var latitude: Float

  @Field(key: "longitude")
  var longitude: Float

  init() {}

  init(name: String, latitude: Float, longitude: Float) {
    self.id = UUID()
    self.name = name
    self.latitude = latitude
    self.longitude = longitude
  }
}
