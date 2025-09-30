import Foundation
import SwiftData

@Model // @Model class with automatic Core Data persistence and relationship management
final class Ingredient {
    
  var id: UUID
  var name: String
  
  // SwiftData relationship with automatic cascade deletion
  @Relationship(deleteRule: .cascade, inverse: \RecipeIngredient.ingredient)
  var recipeIngredients: [RecipeIngredient] = []
  
  init(id: UUID = UUID(), name: String = "") {
    self.id = id
    self.name = name
  }
    
}

@Model // Persistent category model; automatic bidirectional relationship with nullification on delete
final class Category {
    
  var id: UUID
  var name: String
  
  @Relationship(deleteRule: .nullify, inverse: \Recipe.category)
  var recipes: [Recipe] = []
  
  init(id: UUID = UUID(), name: String = "") {
    self.id = id
    self.name = name
  }
    
}

@Model // Persistent recipe model; true relational model with automatic relationship management
final class Recipe {
    
  var id: UUID
  var name: String
  var summary: String
  var serving: Int
  var time: Int
  var instructions: String
  var imageData: Data?
  
  @Relationship(deleteRule: .nullify)
  var category: Category?
  
  @Relationship(deleteRule: .cascade, inverse: \RecipeIngredient.recipe)
  var ingredients: [RecipeIngredient] = []
  
  init(
    id: UUID = UUID(),
    name: String = "",
    summary: String = "",
    category: Category? = nil,
    serving: Int = 1,
    time: Int = 5,
    ingredients: [RecipeIngredient] = [],
    instructions: String = "",
    imageData: Data? = nil
  ) {
    self.id = id
    self.name = name
    self.summary = summary
    self.category = category
    self.serving = serving
    self.time = time
    self.instructions = instructions
    self.imageData = imageData
  }
    
}

@Model // RecipeIngredient join model for many-to-many foreign key relationship between Recipe and Ingredient
final class RecipeIngredient {
    
  var id: UUID
  var quantity: String
  
  @Relationship(deleteRule: .nullify)
  var ingredient: Ingredient?
  
  @Relationship(deleteRule: .nullify)
  var recipe: Recipe?
  
  init(id: UUID = UUID(), ingredient: Ingredient? = nil, quantity: String = "", recipe: Recipe? = nil) {
    self.id = id
    self.ingredient = ingredient
    self.quantity = quantity
    self.recipe = recipe
  }
    
}
