import SwiftUI
import SwiftData

/// The main view that appears when the app is launched.
struct ContentView: View {
  @Environment(\.modelContext) private var modelContext // SwiftData ModelContext for database operations

  var body: some View {
    TabView {
      RecipesView()
        .tabItem {
          Label("Recipes", systemImage: "frying.pan")
        }

      CategoriesView()
        .tabItem {
          Label("Categories", systemImage: "tag")
        }

      IngredientsView()
        .tabItem {
          Label("Ingredients", systemImage: "carrot")
        }
    }
    .onAppear {
      DataService.loadSampleData(context: modelContext) // DataService now uses SwiftData ModelContext and loads sample data if needed
    }
  }
}
