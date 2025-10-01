import SwiftUI
import SwiftData

struct CategoriesView: View {
    
  /* Environment from custom storage to SwiftData ModelContext */
  // SwiftData ModelContext for database operations
  @Environment(\.modelContext) private var modelContext
  @State private var query = ""
  
  /* Data source from storage arrays to SwiftData @Query */
  // @Query automatically fetches and updates from SwiftData
  @Query private var allCategories: [Category]
  
  /* Filtered categories using #Predicate for efficient database-level filtering */
  // #Predicate enables database-level filtering instead of in-memory operations
  private var categories: [Category] {
    if query.isEmpty {
      return allCategories
    }
    
    let predicate = #Predicate<Category> { category in
      category.name.localizedStandardContains(query)
    }
    
    let descriptor = FetchDescriptor<Category>(predicate: predicate)
    return (try? modelContext.fetch(descriptor)) ?? []
  }

  // MARK: - Body

  var body: some View {
    NavigationStack {
      content
        .navigationTitle("Categories")
        .toolbar {
          /* Reference to allCategories instead of storage.categories */
          // Uses @Query result for empty state check
          if !allCategories.isEmpty {
            NavigationLink(value: CategoryForm.Mode.add) {
              Label("Add", systemImage: "plus")
            }
          }
        }
        .navigationDestination(for: CategoryForm.Mode.self) { mode in
          CategoryForm(mode: mode)
        }
        .navigationDestination(for: RecipeForm.Mode.self) { mode in
          RecipeForm(mode: mode)
        }
    }
  }

  // MARK: - Views

  @ViewBuilder
  private var content: some View {
    /* Empty state check uses @Query result instead of storage */
    // Uses allCategories from @Query for consistent state management
    if allCategories.isEmpty {
      empty
    } else {
      /* Passes filtered categories instead of storage array */
      // Uses computed categories property for cleaner separation
      list(for: categories)
    }
  }

  private var empty: some View {
    ContentUnavailableView(
      label: {
        Label("No Categories", systemImage: "list.clipboard")
      },
      description: {
        Text("Categories you add will appear here.")
      },
      actions: {
        NavigationLink("Add Category", value: CategoryForm.Mode.add)
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
  }

  private func list(for categories: [Category]) -> some View {
    ScrollView(.vertical) {
      if categories.isEmpty {
        noResults
      } else {
        LazyVStack(spacing: 10) {
          ForEach(categories, content: CategorySection.init)
        }
      }
    }
    .searchable(text: $query)
  }
}
