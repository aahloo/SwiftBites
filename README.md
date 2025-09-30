# SwiftBites 🍽️

A modern recipe management app built with SwiftUI and SwiftData, featuring persistent data storage, recipe categorization, and ingredient management.

## 📱 Overview

SwiftBites is a comprehensive recipe management application that allows users to create, organize, and manage their favorite recipes. Built with SwiftUI and SwiftData, the app provides a seamless experience for recipe discovery, ingredient tracking, and culinary organization.

### Key Features

- ✨ **Recipe Management**: Create, edit, and delete recipes with detailed information
- 📸 **Photo Support**: Attach images to recipes using PhotosPicker
- 🏷️ **Categorization**: Organize recipes by categories (Italian, Middle Eastern, etc.)
- 🥕 **Ingredient Database**: Maintain a reusable ingredient library
- 🔍 **Search & Filter**: Find recipes and ingredients quickly
- 📊 **Sorting Options**: Sort recipes by name, serving size, or cooking time
- 💾 **Persistent Storage**: Data automatically saves using SwiftData
- 📱 **Native iOS Design**: Built with SwiftUI for modern iOS experience

## 🏗️ Architecture Overview

### SwiftData Migration

This project has been migrated from a mock data system to a full SwiftData implementation, providing:

- **Persistent Storage**: Data survives app restarts
- **Relational Database**: Proper foreign key relationships
- **Automatic Synchronization**: UI updates automatically when data changes
- **Core Data Integration**: Leverages Apple's mature persistence framework
- **Type Safety**: Compile-time safety for database operations

## 🗄️ SwiftData Models

### Core Models

#### `Ingredient`
```swift
@Model
final class Ingredient {
    var id: UUID
    var name: String
    @Relationship(deleteRule: .cascade, inverse: \RecipeIngredient.ingredient)
    var recipeIngredients: [RecipeIngredient] = []
}
```
- **Purpose**: Base ingredient entity (e.g., "Tomatoes", "Cheese")
- **Relationships**: One-to-many with RecipeIngredient
- **Delete Rule**: Cascade - removes all recipe usages when deleted

#### `Category`
```swift
@Model
final class Category {
    var id: UUID
    var name: String
    @Relationship(deleteRule: .nullify, inverse: \Recipe.category)
    var recipes: [Recipe] = []
}
```
- **Purpose**: Recipe categorization (e.g., "Italian", "Desserts")
- **Relationships**: One-to-many with Recipe
- **Delete Rule**: Nullify - recipes remain but lose category assignment

#### `Recipe`
```swift
@Model
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
}
```
- **Purpose**: Complete recipe information
- **Relationships**: Many-to-one with Category, one-to-many with RecipeIngredient
- **Delete Rules**: Nullify category, cascade recipe ingredients

#### `RecipeIngredient`
```swift
@Model
final class RecipeIngredient {
    var id: UUID
    var quantity: String
    @Relationship(deleteRule: .nullify)
    var ingredient: Ingredient?
    @Relationship(deleteRule: .nullify)
    var recipe: Recipe?
}
```
- **Purpose**: Junction table for recipe-ingredient relationships with quantities
- **Relationships**: Many-to-one with both Recipe and Ingredient
- **Delete Rule**: Nullify - preserves ingredients when recipes are deleted

### Data Service

#### `DataService`
```swift
final class DataService {    
    static func ingredientExists(name: String, context: ModelContext, excluding: Ingredient?) -> Bool
    static func categoryExists(name: String, context: ModelContext, excluding: Category?) -> Bool
    static func recipeExists(name: String, context: ModelContext, excluding: Recipe?) -> Bool
}
```
- **Purpose**: Utility service for data operations and Helper methods for checking duplicates

## 📱 User Interface Components

### Main Navigation

#### `ContentView` (Main.swift)
- **Purpose**: Root view with tab-based navigation
- **Tabs**: Recipes, Categories, Ingredients
- **Responsibilities**: SwiftData sample data initialization

### Recipe Management

#### `RecipesView`
- **Purpose**: Recipe listing with search and sort functionality
- **Features**: Search by name/summary, sort by multiple criteria
- **Data Source**: `@Query private var allRecipes: [Recipe]`
- **Navigation**: Links to RecipeForm for editing

#### `RecipeCell`
- **Purpose**: Individual recipe display component
- **Features**: Recipe image, name, summary, metadata tags
- **Navigation**: Taps navigate to edit mode

#### `RecipeForm`
- **Purpose**: Add/edit recipe interface
- **Features**: Photo picker, category selection, ingredient management
- **Modes**: Add new recipe or edit existing recipe
- **Validation**: Prevents duplicate recipe names

### Category Management

#### `CategoriesView`
- **Purpose**: Category listing with search functionality
- **Features**: Search categories, navigate to forms
- **Data Source**: `@Query private var allCategories: [Category]`
- **Layout**: Vertical scrolling list of CategorySection components

#### `CategorySection`
- **Purpose**: Category display with associated recipes
- **Features**: Horizontal recipe scrolling, edit navigation
- **Layout**: Category header with horizontal recipe list

#### `CategoryForm`
- **Purpose**: Add/edit category interface
- **Features**: Name input, validation, delete functionality
- **Validation**: Prevents duplicate category names
- **Delete Behavior**: Nullifies category in associated recipes

### Ingredient Management

#### `IngredientsView`
- **Purpose**: Ingredient listing with search and selection
- **Features**: Search ingredients, swipe-to-delete, selection mode
- **Data Source**: `@Query private var allIngredients: [Ingredient]`
- **Modes**: Normal browsing or selection for recipes

#### `IngredientForm`
- **Purpose**: Add/edit ingredient interface
- **Features**: Name input, validation, delete functionality
- **Validation**: Prevents duplicate ingredient names

## 🔄 Data Flow & Migration

### Before: Mock Storage System
- **Storage**: In-memory arrays (`ingredients`, `categories`, `recipes`)
- **Persistence**: None - data lost on app restart
- **Relationships**: Manual object references
- **Environment**: Custom `@Environment(\.storage)` injection
- **CRUD**: Storage class methods with manual validation

### After: SwiftData System
- **Storage**: Core Data via SwiftData models
- **Persistence**: Automatic database persistence
- **Relationships**: Declarative `@Relationship` attributes
- **Environment**: Standard `@Environment(\.modelContext)`
- **CRUD**: Direct ModelContext operations with helper validation

### Migration Benefits
- ✅ **Data Persistence**: Survives app restarts
- ✅ **Relationship Integrity**: Automatic foreign key management
- ✅ **Performance**: Efficient database queries vs array operations
- ✅ **Scalability**: Handles large datasets efficiently
- ✅ **Memory Management**: Lazy loading and automatic memory management
- ✅ **Reactive UI**: `@Query` automatically updates views

## 📋 Features in Detail

### Recipe Creation
- **Rich Text Support**: Detailed instructions with formatting
- **Photo Integration**: Capture or select photos from library
- **Serving & Time**: Numeric inputs with stepper controls
- **Ingredient Selection**: Browse and select from ingredient database
- **Quantity Management**: Specify quantities for each ingredient

### Search & Discovery
- **Recipe Search**: Search by name or description
- **Ingredient Search**: Find specific ingredients quickly
- **Category Search**: Filter categories by name
- **Sort Options**: Multiple sorting criteria for recipes

### Data Management
- **Relationship Handling**: Proper cascade and nullify delete rules
- **Validation**: Prevents duplicate names across all entities
- **Error Handling**: User-friendly error messages
- **Data Integrity**: Automatic relationship maintenance

### FUTURE UPDATES
- **User Customization and Profiles: Enable users to create profiles where they can save their favorite recipes, dietary preferences, and any allergies, with the ability     to filter out recipes that don't match the user's dietary needs automatically
- **Meal Planning and Grocery Lists: Integrate a meal planner that helps users organize their meals for the week.
    Based on the meal plan, the app can automatically generate a grocery list of ingredients needed. This feature not only adds value by simplifying meal preparation but     also encourages users to explore more recipes within the app.

---

**SwiftBites** - *Organize your culinary creativity with persistent, relational recipe management* 🍽️✨
