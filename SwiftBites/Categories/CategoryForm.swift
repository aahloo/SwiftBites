import SwiftUI
import SwiftData

struct CategoryForm: View {
    
  enum Mode: Hashable {
    case add
    case edit(Category)
  }

  var mode: Mode

  init(mode: Mode) {
      
    self.mode = mode
    switch mode {
    case .add:
      _name = .init(initialValue: "")
      title = "Add Category"
    case .edit(let category):
      _name = .init(initialValue: category.name)
      title = "Edit \(category.name)"
    }
      
  }

  private let title: String
  @State private var name: String
  @State private var error: Error?
  
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
      if case .edit(let category) = mode {
        Button(
          role: .destructive,
          action: {
            delete(category: category)
          },
          label: {
            Text("Delete Category")
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
    .alert(error: $error)
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

  private func delete(category: Category) {
        
    // Set category to nil for all recipes in this category
    for recipe in category.recipes {
      recipe.category = nil
    }
      
    /* Direct ModelContext operations instead of Storage methods */
    // modelContext.delete() + save() for SwiftData persistence
    modelContext.delete(category)
    try? modelContext.save()
    dismiss()
      
  }

  private func save() {
      
    do {
      switch mode {
      case .add:
          
        /* Validation separated from CRUD operations */
        // DataService validation + separate ModelContext operations
        if try DataService.categoryExists(name: name, context: modelContext) {
          throw DataService.DataError.categoryExists
        }
          
        /* Direct SwiftData model creation and insertion */
        // Create Category model and insert via ModelContext
        let newCategory = Category(name: name)
        modelContext.insert(newCategory)
        try modelContext.save()
      case .edit(let category):
          
        /* Validation with exclusion for edit operations */
        // DataService validation + direct model property modification
        if try DataService.categoryExists(name: name, context: modelContext, excluding: category) {
          throw DataService.DataError.categoryExists
        }
          
        /* Direct model property modification instead of Storage method */
        // Direct property assignment with SwiftData automatic persistence
        category.name = name
        try modelContext.save()
      }
      dismiss()
    } catch {
      self.error = error
    }
  }
    
}
