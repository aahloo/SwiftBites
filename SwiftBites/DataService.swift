import Foundation
import SwiftData
import SwiftUI

/*  DataService is a lightweight utility class that provides validation helpers for SwiftData models:
    - Data persistence → SwiftData ModelContext
    - Data queries → @Query property wrappers  
    - CRUD operations → Direct ModelContext calls in views
    - Validation → DataService helper methods for duplicate checking
 */
final class DataService {
    
  enum DataError: LocalizedError {
    case ingredientExists
    case categoryExists
    case recipeExists
    
    var errorDescription: String? {
      switch self {
      case .ingredientExists:
        return "Ingredient with the same name exists"
      case .categoryExists:
        return "Category with the same name exists"
      case .recipeExists:
        return "Recipe with the same name exists"
      }
    }
  }
  
  
  // MARK: - Helper methods for checking duplicates
  
  static func ingredientExists(name: String, context: ModelContext, excluding: Ingredient? = nil) throws -> Bool {
      
    let descriptor = FetchDescriptor<Ingredient>(
      predicate: #Predicate<Ingredient> { ingredient in
        ingredient.name == name
      }
    )
    let results = try context.fetch(descriptor)
    
    if let excluding = excluding {
      return results.contains { $0.id != excluding.id }
    } else {
      return !results.isEmpty
    }
      
  }
  
  static func categoryExists(name: String, context: ModelContext, excluding: Category? = nil) throws -> Bool {
      
    let descriptor = FetchDescriptor<Category>(
      predicate: #Predicate<Category> { category in
        category.name == name
      }
    )
    let results = try context.fetch(descriptor)
    
    if let excluding = excluding {
      return results.contains { $0.id != excluding.id }
    } else {
      return !results.isEmpty
    }
      
  }
  
  static func recipeExists(name: String, context: ModelContext, excluding: Recipe? = nil) throws -> Bool {
      
    let descriptor = FetchDescriptor<Recipe>(
      predicate: #Predicate<Recipe> { recipe in
        recipe.name == name
      }
    )
    let results = try context.fetch(descriptor)
    
    if let excluding = excluding {
      return results.contains { $0.id != excluding.id }
    } else {
      return !results.isEmpty
    }
  }
    
}
