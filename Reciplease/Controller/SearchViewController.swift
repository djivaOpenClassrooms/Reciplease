//
//  SearchViewController.swift
//  Reciplease
//
//  Created by Djiveradjane Canessane on 17/11/2020.
//

import UIKit

class SearchViewController: UIViewController {
    // MARK: - PROPERTIES

    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var ingredientTextField: UITextField!
    @IBOutlet weak var ingredientsTextView: UITextView!
    let alertManager = ServiceContainer.alertManager
    let recipeQueryNetworkManager = ServiceContainer.recipeQueryNetworkManager

    var ingredients: [String] = []
    var displayableRecipes: [DisplayableRecipe] = []

    // MARK: - FUNCTIONS

    /// Adds ingredient from ingredientTextField to ingredientsTextView
    @IBAction func addIngredient(_ sender: UIButton) {

        // Unwrap ingredientTextField text, else show an error alert
        guard let ingredient = ingredientTextField.text else {
            return showErrorEmptyOrNumberInIngredient()
        }

        // Check ingredient is not empty string, else show an error alert
        guard ingredient != "" else {
            return showErrorEmptyOrNumberInIngredient()
        }

        // Check ingredient do not contains any numerical digit, else show an error alert
        let numbersRange = ingredient.rangeOfCharacter(from: .decimalDigits)
        let hasNumbers = (numbersRange != nil)
        guard !hasNumbers else {
            return showErrorEmptyOrNumberInIngredient()
        }
        ingredients.append(ingredient)
        ingredientsTextView.text += "- \(ingredient.capitalized)\n"
        ingredientTextField.text = nil

    }

    @IBAction func clearIngredients(_ sender: UIButton) {
        ingredients = []
        ingredientsTextView.text = ""
    }

    @IBAction func searchRecipes(_ sender: UIButton) {
        loadingView.isHidden = false

        recipeQueryNetworkManager.getRecipes(for: ingredients) { (result) in
            self.loadingView.isHidden = true

            switch result {
            case .success(let displayableRecipesResult):
                self.displayableRecipes = displayableRecipesResult
                self.performSegue(withIdentifier: "segueToNetworkResult", sender: nil)

            case .failure(let error):
                return self.alertManager.showErrorAlert(
                    title: "Network error",
                    message: error.localizedDescription,
                    viewController: self
                )
            }
        }
    }

    private func showErrorEmptyOrNumberInIngredient() {
        ingredientTextField.text = nil
        return alertManager.showErrorAlert(
            title: "Insert an valid ingredient",
            message: "Please insert an ingredient name, without any numbers.",
            viewController: self
        )
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToNetworkResult" {
            guard let successVC = segue.destination as? RecipeTableViewController else {
                return
            }
            successVC.displayableRecipes = self.displayableRecipes
            successVC.isComingFromSeachVC = true
        }
    }
}
