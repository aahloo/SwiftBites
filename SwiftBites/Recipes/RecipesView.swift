import SwiftUI
import SwiftData

struct RecipesView: View {
    
  /* Environment from custom storage to SwiftData ModelContext */
  // SwiftData ModelContext for database operations
  @Environment(\.modelContext) private var modelContext
    
  @State private var query = ""
    
  /* SortDescriptor references SwiftData Recipe instead of MockRecipe */
  // Uses SwiftData Recipe properties for sorting
  @State private var sortOrder = SortDescriptor(\Recipe.name)
  
  /* Data source from storage arrays to SwiftData @Query */
  // @Query automatically fetches and updates from SwiftData with #Predicate filtering
  @Query private var allRecipes: [Recipe]
  
  /* Filtered recipes using #Predicate for efficient database-level filtering */
  // #Predicate enables database-level filtering instead of in-memory operations
  private var filteredRecipes: [Recipe] {
    if query.isEmpty {
      return allRecipes
    }
    
    let predicate = #Predicate<Recipe> { recipe in
      recipe.name.localizedStandardContains(query) || recipe.summary.localizedStandardContains(query)
    }
    
    let descriptor = FetchDescriptor<Recipe>(predicate: predicate)
    return (try? modelContext.fetch(descriptor)) ?? []
  }
  
  /* Combined filtering and sorting in computed property */
  // Single computed property handles both operations efficiently
  private var recipes: [Recipe] {
    return filteredRecipes.sorted(using: sortOrder)
  }

  // MARK: - Body

  var body: some View {
    NavigationStack {
      content
        .navigationTitle("Recipes")
        .toolbar {
            
          /* Reference to allRecipes instead of storage.recipes */
          // Uses @Query result for empty state check
          if !allRecipes.isEmpty {
            sortOptions
            ToolbarItem(placement: .topBarTrailing) {
              NavigationLink(value: RecipeForm.Mode.add) {
                Label("Add", systemImage: "plus")
              }
            }
          }
        }
        .navigationDestination(for: RecipeForm.Mode.self) { mode in
          RecipeForm(mode: mode)
        }
    }
  }

  // MARK: - Views

  @ToolbarContentBuilder
  var sortOptions: some ToolbarContent {
    ToolbarItem(placement: .topBarLeading) {
      Menu("Sort", systemImage: "arrow.up.arrow.down") {
        Picker("Sort", selection: $sortOrder) {
            
          /* SortDescriptor key paths reference SwiftData Recipe properties */
          // Uses SwiftData Recipe model properties for sorting
          Text("Name")
            .tag(SortDescriptor(\Recipe.name))

          Text("Serving (low to high)")
            .tag(SortDescriptor(\Recipe.serving, order: .forward))

          Text("Serving (high to low)")
            .tag(SortDescriptor(\Recipe.serving, order: .reverse))

          Text("Time (short to long)")
            .tag(SortDescriptor(\Recipe.time, order: .forward))

          Text("Time (long to short)")
            .tag(SortDescriptor(\Recipe.time, order: .reverse))
        }
          
      }
      .pickerStyle(.inline)
    }
  }

  @ViewBuilder
  private var content: some View {
      
    /* Empty state check uses @Query result instead of storage */
    // Uses allRecipes from @Query for consistent state management
    if allRecipes.isEmpty {
      empty
    } else {
        
      /* Passes computed recipes instead of inline filtered/sorted array */
      // Uses computed recipes property combining filter and sort
      list(for: recipes)
        
    }
      
  }

  var empty: some View {
    ContentUnavailableView(
      label: {
        Label("No Recipes", systemImage: "list.clipboard")
      },
      description: {
        Text("Recipes you add will appear here.")
      },
      actions: {
        NavigationLink("Add Recipe", value: RecipeForm.Mode.add)
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

  private func list(for recipes: [Recipe]) -> some View {
    ScrollView(.vertical) {
      if recipes.isEmpty {
        noResults
      } else {
        LazyVStack(spacing: 10) {
          ForEach(recipes, content: RecipeCell.init)
        }
      }
    }
    .searchable(text: $query)
  }
}
