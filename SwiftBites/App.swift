import SwiftUI
import SwiftData

@main
struct SwiftBitesApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView()
    }
    // SwiftData model container for persistent storage
    .modelContainer(for: [Recipe.self, Category.self, Ingredient.self, RecipeIngredient.self])
  }
}
