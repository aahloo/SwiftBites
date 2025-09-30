import Foundation
import SwiftData
import SwiftUI

/*  DataService is a lightweight utility class that replaces the previous heavyweight Storage class manager using SwiftData features:
    - Data persistence → SwiftData ModelContext
    - Data queries → @Query property wrappers
    - CRUD operations → Direct ModelContext calls in views
    - Sample data → DataService.loadSampleData()
    - Validation → DataService helper methods
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
  
  static func loadSampleData(context: ModelContext) {
      
    // Check if data already exists
    let descriptor = FetchDescriptor<Ingredient>()
    if let existingIngredients = try? context.fetch(descriptor), !existingIngredients.isEmpty {
      return // Data already loaded
    }
    
    // Create ingredients
    let pizzaDough = Ingredient(name: "Pizza Dough")
    let tomatoSauce = Ingredient(name: "Tomato Sauce")
    let mozzarellaCheese = Ingredient(name: "Mozzarella Cheese")
    let freshBasilLeaves = Ingredient(name: "Fresh Basil Leaves")
    let extraVirginOliveOil = Ingredient(name: "Extra Virgin Olive Oil")
    let salt = Ingredient(name: "Salt")
    let chickpeas = Ingredient(name: "Chickpeas")
    let tahini = Ingredient(name: "Tahini")
    let lemonJuice = Ingredient(name: "Lemon Juice")
    let garlic = Ingredient(name: "Garlic")
    let cumin = Ingredient(name: "Cumin")
    let water = Ingredient(name: "Water")
    let paprika = Ingredient(name: "Paprika")
    let parsley = Ingredient(name: "Parsley")
    let spaghetti = Ingredient(name: "Spaghetti")
    let eggs = Ingredient(name: "Eggs")
    let parmesanCheese = Ingredient(name: "Parmesan Cheese")
    let pancetta = Ingredient(name: "Pancetta")
    let blackPepper = Ingredient(name: "Black Pepper")
    let driedChickpeas = Ingredient(name: "Dried Chickpeas")
    let onions = Ingredient(name: "Onions")
    let cilantro = Ingredient(name: "Cilantro")
    let coriander = Ingredient(name: "Coriander")
    let bakingPowder = Ingredient(name: "Baking Powder")
    let chickenThighs = Ingredient(name: "Chicken Thighs")
    let yogurt = Ingredient(name: "Yogurt")
    let cardamom = Ingredient(name: "Cardamom")
    let cinnamon = Ingredient(name: "Cinnamon")
    let turmeric = Ingredient(name: "Turmeric")
    
    let ingredients = [
      pizzaDough, tomatoSauce, mozzarellaCheese, freshBasilLeaves, extraVirginOliveOil,
      salt, chickpeas, tahini, lemonJuice, garlic, cumin, water, paprika, parsley,
      spaghetti, eggs, parmesanCheese, pancetta, blackPepper, driedChickpeas,
      onions, cilantro, coriander, bakingPowder, chickenThighs, yogurt,
      cardamom, cinnamon, turmeric
    ]
    
    // Insert ingredients
    for ingredient in ingredients {
      context.insert(ingredient)
    }
    
    // Create categories
    let italian = Category(name: "Italian")
    let middleEastern = Category(name: "Middle Eastern")
    
    context.insert(italian)
    context.insert(middleEastern)
    
    // Create recipes
    let margherita = Recipe(
      name: "Classic Margherita Pizza",
      summary: "A simple yet delicious pizza with tomato, mozzarella, basil, and olive oil.",
      category: italian,
      serving: 4,
      time: 50,
      instructions: "Preheat oven, roll out dough, apply sauce, add cheese and basil, bake for 20 minutes.",
      imageData: UIImage(named: "margherita")?.pngData()
    )
    
    let spaghettiCarbonara = Recipe(
      name: "Spaghetti Carbonara",
      summary: "A classic Italian pasta dish made with eggs, cheese, pancetta, and pepper.",
      category: italian,
      serving: 4,
      time: 30,
      instructions: "Cook spaghetti. Fry pancetta until crisp. Whisk eggs and Parmesan, add to pasta with pancetta, and season with black pepper.",
      imageData: UIImage(named: "spaghettiCarbonara")?.pngData()
    )
    
    let hummus = Recipe(
      name: "Classic Hummus",
      summary: "A creamy and flavorful Middle Eastern dip made from chickpeas, tahini, and spices.",
      category: middleEastern,
      serving: 6,
      time: 10,
      instructions: "Blend chickpeas, tahini, lemon juice, garlic, and spices. Adjust consistency with water. Garnish with olive oil, paprika, and parsley.",
      imageData: UIImage(named: "hummus")?.pngData()
    )
    
    let falafel = Recipe(
      name: "Classic Falafel",
      summary: "A traditional Middle Eastern dish of spiced, fried chickpea balls, often served in pita bread.",
      category: middleEastern,
      serving: 4,
      time: 60,
      instructions: "Soak chickpeas overnight. Blend with onions, garlic, herbs, and spices. Form into balls, add baking powder, and fry until golden.",
      imageData: UIImage(named: "falafel")?.pngData()
    )
    
    let shawarma = Recipe(
      name: "Chicken Shawarma",
      summary: "A popular Middle Eastern dish featuring marinated chicken, slow-roasted to perfection.",
      category: middleEastern,
      serving: 4,
      time: 120,
      instructions: "Marinate chicken with yogurt, spices, garlic, lemon juice, and olive oil. Roast until cooked. Serve with pita and sauces.",
      imageData: UIImage(named: "chickenShawarma")?.pngData()
    )
    
    context.insert(margherita)
    context.insert(spaghettiCarbonara)
    context.insert(hummus)
    context.insert(falafel)
    context.insert(shawarma)
    
    // Create recipe ingredients relationships
    let margheritaIngredients = [
      RecipeIngredient(ingredient: pizzaDough, quantity: "1 ball", recipe: margherita),
      RecipeIngredient(ingredient: tomatoSauce, quantity: "1/2 cup", recipe: margherita),
      RecipeIngredient(ingredient: mozzarellaCheese, quantity: "1 cup, shredded", recipe: margherita),
      RecipeIngredient(ingredient: freshBasilLeaves, quantity: "A handful", recipe: margherita),
      RecipeIngredient(ingredient: extraVirginOliveOil, quantity: "2 tablespoons", recipe: margherita),
      RecipeIngredient(ingredient: salt, quantity: "Pinch", recipe: margherita)
    ]
    
    let carbonaraIngredients = [
      RecipeIngredient(ingredient: spaghetti, quantity: "400g", recipe: spaghettiCarbonara),
      RecipeIngredient(ingredient: eggs, quantity: "4", recipe: spaghettiCarbonara),
      RecipeIngredient(ingredient: parmesanCheese, quantity: "1 cup, grated", recipe: spaghettiCarbonara),
      RecipeIngredient(ingredient: pancetta, quantity: "200g, diced", recipe: spaghettiCarbonara),
      RecipeIngredient(ingredient: blackPepper, quantity: "To taste", recipe: spaghettiCarbonara)
    ]
    
    let hummusIngredients = [
      RecipeIngredient(ingredient: chickpeas, quantity: "1 can (15 oz)", recipe: hummus),
      RecipeIngredient(ingredient: tahini, quantity: "1/4 cup", recipe: hummus),
      RecipeIngredient(ingredient: lemonJuice, quantity: "3 tablespoons", recipe: hummus),
      RecipeIngredient(ingredient: garlic, quantity: "1 clove, minced", recipe: hummus),
      RecipeIngredient(ingredient: extraVirginOliveOil, quantity: "2 tablespoons", recipe: hummus),
      RecipeIngredient(ingredient: cumin, quantity: "1/2 teaspoon", recipe: hummus),
      RecipeIngredient(ingredient: salt, quantity: "To taste", recipe: hummus),
      RecipeIngredient(ingredient: water, quantity: "2-3 tablespoons", recipe: hummus),
      RecipeIngredient(ingredient: paprika, quantity: "For garnish", recipe: hummus),
      RecipeIngredient(ingredient: parsley, quantity: "For garnish", recipe: hummus)
    ]
    
    let falafelIngredients = [
      RecipeIngredient(ingredient: driedChickpeas, quantity: "1 cup", recipe: falafel),
      RecipeIngredient(ingredient: onions, quantity: "1 medium, chopped", recipe: falafel),
      RecipeIngredient(ingredient: garlic, quantity: "3 cloves, minced", recipe: falafel),
      RecipeIngredient(ingredient: cilantro, quantity: "1/2 cup, chopped", recipe: falafel),
      RecipeIngredient(ingredient: parsley, quantity: "1/2 cup, chopped", recipe: falafel),
      RecipeIngredient(ingredient: cumin, quantity: "1 tsp", recipe: falafel),
      RecipeIngredient(ingredient: coriander, quantity: "1 tsp", recipe: falafel),
      RecipeIngredient(ingredient: salt, quantity: "1 tsp", recipe: falafel),
      RecipeIngredient(ingredient: bakingPowder, quantity: "1/2 tsp", recipe: falafel)
    ]
    
    let shawarmaIngredients = [
      RecipeIngredient(ingredient: chickenThighs, quantity: "1 kg, boneless", recipe: shawarma),
      RecipeIngredient(ingredient: yogurt, quantity: "1 cup", recipe: shawarma),
      RecipeIngredient(ingredient: garlic, quantity: "3 cloves, minced", recipe: shawarma),
      RecipeIngredient(ingredient: lemonJuice, quantity: "3 tablespoons", recipe: shawarma),
      RecipeIngredient(ingredient: cumin, quantity: "1 tsp", recipe: shawarma),
      RecipeIngredient(ingredient: coriander, quantity: "1 tsp", recipe: shawarma),
      RecipeIngredient(ingredient: cardamom, quantity: "1/2 tsp", recipe: shawarma),
      RecipeIngredient(ingredient: cinnamon, quantity: "1/2 tsp", recipe: shawarma),
      RecipeIngredient(ingredient: turmeric, quantity: "1/2 tsp", recipe: shawarma),
      RecipeIngredient(ingredient: salt, quantity: "To taste", recipe: shawarma),
      RecipeIngredient(ingredient: blackPepper, quantity: "To taste", recipe: shawarma),
      RecipeIngredient(ingredient: extraVirginOliveOil, quantity: "2 tablespoons", recipe: shawarma)
    ]
    
    let allRecipeIngredients = margheritaIngredients + carbonaraIngredients + hummusIngredients + falafelIngredients + shawarmaIngredients
    
    for recipeIngredient in allRecipeIngredients {
      context.insert(recipeIngredient)
    }
    
    // Save the context
    try? context.save()
      
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
