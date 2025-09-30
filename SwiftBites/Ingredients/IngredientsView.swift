import SwiftUI
import SwiftData

struct IngredientsView: View {
    
  /* Closure parameter type from MockIngredient to SwiftData Ingredient */
  // Uses SwiftData persistent model
  typealias Selection = (Ingredient) -> Void

  let selection: Selection?

  init(selection: Selection? = nil) {
    self.selection = selection
  }

  /* Environment from custom storage to SwiftData ModelContext */
  // SwiftData ModelContext for database operations
  @Environment(\.modelContext) private var modelContext
    
  @Environment(\.dismiss) private var dismiss
  @State private var query = ""
  
  /* Data source from storage arrays to SwiftData @Query */
  // @Query automatically fetches and updates from SwiftData
  @Query private var allIngredients: [Ingredient]
  
  /* Filtering moved to computed property for efficiency */
  // Computed property filters @Query results without extra database calls
  private var ingredients: [Ingredient] {
    if query.isEmpty {
      return allIngredients
    } else {
      return allIngredients.filter { $0.name.localizedStandardContains(query) }
    }
  }

  // MARK: - Body

  var body: some View {
    NavigationStack {
      content
        .navigationTitle("Ingredients")
        .toolbar {
            
          /* Reference to allIngredients instead of storage.ingredients */
          // Uses @Query result for empty state check
          if !allIngredients.isEmpty {
            NavigationLink(value: IngredientForm.Mode.add) {
              Label("Add", systemImage: "plus")
            }
          }
        }
        .navigationDestination(for: IngredientForm.Mode.self) { mode in
          IngredientForm(mode: mode)
        }
    }
  }

  // MARK: - Views

  @ViewBuilder
  private var content: some View {
      
    /* Empty state check uses @Query result instead of storage */
    // Uses allIngredients from @Query for consistent state management
    if allIngredients.isEmpty {
      empty
    } else {
      /* Passes filtered ingredients instead of storage array */
      // Uses computed ingredients property for cleaner separation
      list(for: ingredients)
    }
      
  }

  private var empty: some View {
    ContentUnavailableView(
      label: {
        Label("No Ingredients", systemImage: "list.clipboard")
      },
      description: {
        Text("Ingredients you add will appear here.")
      },
      actions: {
        NavigationLink("Add Ingredient", value: IngredientForm.Mode.add)
          .buttonBorderShape(.roundedRectangle)
          .buttonStyle(.borderedProminent)
      }
    )
  }

  private var noResults: some View {
    ContentUnavailableView(
      label: {
        Text("Couldn't find \"\(query)\"")
      }
    )
    .listRowSeparator(.hidden)
  }

  private func list(for ingredients: [Ingredient]) -> some View {
    List {
      if ingredients.isEmpty {
        noResults
      } else {
        ForEach(ingredients) { ingredient in
          row(for: ingredient)
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
              Button("Delete", systemImage: "trash", role: .destructive) {
                delete(ingredient: ingredient)
              }
            }
        }
      }
    }
    .searchable(text: $query)
    .listStyle(.plain)
  }

  @ViewBuilder
  private func row(for ingredient: Ingredient) -> some View {
    if let selection {
      Button(
        action: {
          selection(ingredient)
          dismiss()
        },
        label: {
          title(for: ingredient)
        }
      )
    } else {
      NavigationLink(value: IngredientForm.Mode.edit(ingredient)) {
        title(for: ingredient)
      }
    }
  }

  private func title(for ingredient: Ingredient) -> some View {
    Text(ingredient.name)
      .font(.title3)
  }

  // MARK: - Data

  private func delete(ingredient: Ingredient) {
      
    /* Direct ModelContext operations instead of Storage methods */
    // modelContext.delete() + save() for SwiftData persistence
    modelContext.delete(ingredient)
    try? modelContext.save()
  }
    
}
