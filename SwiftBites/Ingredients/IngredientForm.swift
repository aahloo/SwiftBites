import SwiftUI
import SwiftData

struct IngredientForm: View {
    
  enum Mode: Hashable {
    case add
    /* Parameter type from MockIngredient to SwiftData Ingredient */
    // SwiftData persistent model
    case edit(Ingredient)
  }

  var mode: Mode

  init(mode: Mode) {
    self.mode = mode
    switch mode {
    case .add:
      _name = .init(initialValue: "")
      title = "Add Ingredient"
    case .edit(let ingredient):
      _name = .init(initialValue: ingredient.name)
      title = "Edit \(ingredient.name)"
    }
  }

  private let title: String
  @State private var name: String
  @State private var error: Error?
    
  /* Environment from custom storage to SwiftData ModelContext */
  // SwiftData ModelContext for direct database operations
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss
  @FocusState private var isNameFocused: Bool

  // MARK: - Body

  var body: some View {
    Form {
      Section {
        TextField("Name", text: $name)
          .focused($isNameFocused)
      }
      if case .edit(let ingredient) = mode {
        Button(
          role: .destructive,
          action: {
            delete(ingredient: ingredient)
          },
          label: {
            Text("Delete Ingredient")
              .frame(maxWidth: .infinity, alignment: .center)
          }
        )
      }
    }
    .onAppear {
      isNameFocused = true
    }
    .onSubmit {
      save()
    }
    .navigationTitle(title)
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button("Save", action: save)
          .disabled(name.isEmpty)
      }
    }
  }

  // MARK: - Data

  private func delete(ingredient: Ingredient) {
      
    /* Direct ModelContext operations instead of Storage methods */
    // modelContext.delete() + save() for SwiftData persistence
    modelContext.delete(ingredient)
    try? modelContext.save()
    dismiss()
      
  }

  private func save() {
      
    do {
      switch mode {
      case .add:
          
        /* Validation separated from CRUD operations */
        // DataService validation + separate ModelContext operations
        if try DataService.ingredientExists(name: name, context: modelContext) {
          throw DataService.DataError.ingredientExists
        }
          
        /* Direct SwiftData model creation and insertion */
        // Create Ingredient model and insert via ModelContext
        let newIngredient = Ingredient(name: name)
        modelContext.insert(newIngredient)
        try modelContext.save()
      case .edit(let ingredient):
        if try DataService.ingredientExists(name: name, context: modelContext, excluding: ingredient) {
          throw DataService.DataError.ingredientExists
        }
          
        /* Direct model property modification instead of Storage method */
        // Direct property assignment with SwiftData automatic persistence
        ingredient.name = name
        try modelContext.save()
      }
      dismiss()
    } catch {
      self.error = error
    }
  }
    
}
