import SwiftUI
import PhotosUI
import Foundation
import SwiftData

struct RecipeForm: View {
  enum Mode: Hashable {
    case add
      
    /* Parameter type from MockRecipe to SwiftData Recipe */
    // SwiftData persistent model with automatic relationships
    case edit(Recipe)
  }

  var mode: Mode

  init(mode: Mode) {
    self.mode = mode
    switch mode {
    case .add:
      title = "Add Recipe"
      _name = .init(initialValue: "")
      _summary = .init(initialValue: "")
      _serving = .init(initialValue: 1)
      _time = .init(initialValue: 5)
      _instructions = .init(initialValue: "")
        
      /* Property name from ingredients to recipeIngredients for clarity */
      // More specific name reflecting junction table relationship
      _recipeIngredients = .init(initialValue: [])
    case .edit(let recipe):
      title = "Edit \(recipe.name)"
      _name = .init(initialValue: recipe.name)
      _summary = .init(initialValue: recipe.summary)
      _serving = .init(initialValue: recipe.serving)
      _time = .init(initialValue: recipe.time)
      _instructions = .init(initialValue: recipe.instructions)
      _recipeIngredients = .init(initialValue: recipe.ingredients)
      _categoryId = .init(initialValue: recipe.category?.id)
      _imageData = .init(initialValue: recipe.imageData)
    }
  }

  private let title: String
  @State private var name: String
  @State private var summary: String
  @State private var serving: Int
  @State private var time: Int
  @State private var instructions: String
    
  /* Category ID type from Category.ID to UUID for accessibility */
  // Direct UUID to avoid internal protection level issues
  @State private var categoryId: UUID?
  
  /* Property type from MockRecipeIngredient to SwiftData RecipeIngredient */
  // SwiftData junction table models with automatic relationship management
  @State private var recipeIngredients: [RecipeIngredient]
  @State private var imageItem: PhotosPickerItem?
  @State private var imageData: Data?
  @State private var isIngredientsPickerPresented =  false
  @State private var error: Error?
  @Environment(\.dismiss) private var dismiss
  
  /* Environment from custom storage to SwiftData ModelContext */
  // SwiftData ModelContext for direct database operations
  @Environment(\.modelContext) private var modelContext
  
  /* SwiftData @Query for categories instead of accessing storage.categories */
  // @Query automatically fetches categories from SwiftData
  @Query private var categories: [Category]

  // MARK: - Body

  var body: some View {
    GeometryReader { geometry in
      Form {
        imageSection(width: geometry.size.width)
        nameSection
        summarySection
        categorySection
        servingAndTimeSection
        ingredientsSection
        instructionsSection
        deleteButton
      }
    }
    .scrollDismissesKeyboard(.interactively)
    .navigationTitle(title)
    .navigationBarTitleDisplayMode(.inline)
    .alert(error: $error)
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button("Save", action: save)
          .disabled(name.isEmpty || instructions.isEmpty)
      }
    }
    .onChange(of: imageItem) { _, _ in
      Task {
        self.imageData = try? await imageItem?.loadTransferable(type: Data.self)
      }
    }
    .sheet(isPresented: $isIngredientsPickerPresented, content: ingredientPicker)
  }

  // MARK: - Views

  private func ingredientPicker() -> some View {
    IngredientsView { selectedIngredient in
      let recipeIngredient = RecipeIngredient(ingredient: selectedIngredient, quantity: "")
      recipeIngredients.append(recipeIngredient)
    }
  }

  @ViewBuilder
  private func imageSection(width: CGFloat) -> some View {
    Section {
      imagePicker(width: width)
      removeImage
    }
  }

  @ViewBuilder
  private func imagePicker(width: CGFloat) -> some View {
    PhotosPicker(selection: $imageItem, matching: .images) {
      if let imageData, let uiImage = UIImage(data: imageData) {
        Image(uiImage: uiImage)
          .resizable()
          .scaledToFill()
          .frame(width: width)
          .clipped()
          .listRowInsets(EdgeInsets())
          .frame(maxWidth: .infinity, minHeight: 200, idealHeight: 200, maxHeight: 200, alignment: .center)
      } else {
        Label("Select Image", systemImage: "photo")
      }
    }
  }

  @ViewBuilder
  private var removeImage: some View {
    if imageData != nil {
      Button(
        role: .destructive,
        action: {
          imageData = nil
        },
        label: {
          Text("Remove Image")
            .frame(maxWidth: .infinity, alignment: .center)
        }
      )
    }
  }

  @ViewBuilder
  private var nameSection: some View {
    Section("Name") {
      TextField("Margherita Pizza", text: $name)
    }
  }

  @ViewBuilder
  private var summarySection: some View {
    Section("Summary") {
      TextField(
        "Delicious blend of fresh basil, mozzarella, and tomato on a crispy crust.",
        text: $summary,
        axis: .vertical
      )
      .lineLimit(3...5)
    }
  }

  @ViewBuilder
  private var categorySection: some View {
    Section {
      Picker("Category", selection: $categoryId) {
        Text("None").tag(nil as UUID?)
        ForEach(categories) { category in
          Text(category.name).tag(category.id as UUID?)
        }
      }
    }
  }

  @ViewBuilder
  private var servingAndTimeSection: some View {
    Section {
      Stepper("Servings: \(serving)p", value: $serving, in: 1...100)
      Stepper("Time: \(time)m", value: $time, in: 5...300, step: 5)
    }
    .monospacedDigit()
  }

  @ViewBuilder
  private var ingredientsSection: some View {
    Section("Ingredients") {
      if recipeIngredients.isEmpty {
        ContentUnavailableView(
          label: {
            Label("No Ingredients", systemImage: "list.clipboard")
          },
          description: {
            Text("Recipe ingredients will appear here.")
          },
          actions: {
            Button("Add Ingredient") {
              isIngredientsPickerPresented = true
            }
          }
        )
      } else {
        ForEach(recipeIngredients) { recipeIngredient in
          HStack(alignment: .center) {
            Text(recipeIngredient.ingredient?.name ?? "Unknown")
              .bold()
              .layoutPriority(2)
            Spacer()
            TextField("Quantity", text: .init(
              get: {
                recipeIngredient.quantity
              },
              set: { quantity in
                if let index = recipeIngredients.firstIndex(where: { $0.id == recipeIngredient.id }) {
                  recipeIngredients[index].quantity = quantity
                }
              }
            ))
            .layoutPriority(1)
          }
        }
        .onDelete(perform: deleteIngredients)

        Button("Add Ingredient") {
          isIngredientsPickerPresented = true
        }
      }
    }
  }

  @ViewBuilder
  private var instructionsSection: some View {
    Section("Instructions") {
      TextField(
        """
        1. Preheat the oven to 475°F (245°C).
        2. Roll out the dough on a floured surface.
        3. ...
        """,
        text: $instructions,
        axis: .vertical
      )
      .lineLimit(8...12)
    }
  }

  @ViewBuilder
  private var deleteButton: some View {
    if case .edit(let recipe) = mode {
      Button(
        role: .destructive,
        action: {
          delete(recipe: recipe)
        },
        label: {
          Text("Delete Recipe")
            .frame(maxWidth: .infinity, alignment: .center)
        }
      )
    }
  }

  // MARK: - Data

  func delete(recipe: Recipe) {
    guard case .edit(let recipe) = mode else {
      fatalError("Delete unavailable in add mode")
    }
      
    /* Manual deletion of RecipeIngredient relationships */
    // Must manually delete RecipeIngredient junction objects before recipe deletion
    for ingredient in recipe.ingredients {
      // Delete associated recipe ingredients (preserves underlying Ingredient objects)
      modelContext.delete(ingredient)
    }
    // Direct ModelContext operations instead of Storage methods
    modelContext.delete(recipe)
    try? modelContext.save()
    dismiss()
  }

  func deleteIngredients(offsets: IndexSet) {
    withAnimation {
      recipeIngredients.remove(atOffsets: offsets)
    }
  }

  func save() {
      
    /* Category lookup uses @Query result instead of storage.categories */
    // Uses @Query categories for SwiftData relationship assignment
    let category = categories.first(where: { $0.id == categoryId })

    do {
      switch mode {
      case .add:
        if try DataService.recipeExists(name: name, context: modelContext) {
          throw DataService.DataError.recipeExists
        }
        let newRecipe = Recipe(
          name: name,
          summary: summary,
          category: category,
          serving: serving,
          time: time,
          instructions: instructions,
          imageData: imageData
        )
          
        /* Direct SwiftData model creation and insertion */
        // Create Recipe model, insert, then handle relationships separately
        modelContext.insert(newRecipe)
        
        /* Manual relationship setup for RecipeIngredient junction table */
        // Must explicitly set recipe relationship and insert each RecipeIngredient
        for recipeIngredient in recipeIngredients { // Create and insert recipe ingredients
          recipeIngredient.recipe = newRecipe
          modelContext.insert(recipeIngredient)
        }
        
        try modelContext.save()
      case .edit(let recipe):
        if try DataService.recipeExists(name: name, context: modelContext, excluding: recipe) {
          throw DataService.DataError.recipeExists
        }
        
        // Update recipe properties
        recipe.name = name
        recipe.summary = summary
        recipe.category = category
        recipe.serving = serving
        recipe.time = time
        recipe.instructions = instructions
        recipe.imageData = imageData
        
        // Remove existing recipe ingredients
        for oldIngredient in recipe.ingredients {
          modelContext.delete(oldIngredient)
        }
        
        // Add new recipe ingredients
        for recipeIngredient in recipeIngredients {
          recipeIngredient.recipe = recipe
          modelContext.insert(recipeIngredient)
        }
        
        try modelContext.save()
      }
      dismiss()
    } catch {
      self.error = error
    }
  }
}
