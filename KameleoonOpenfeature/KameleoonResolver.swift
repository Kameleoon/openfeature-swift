//
//  KameleoonResolver.swift
//  openfeature
//
//  Created by Dmitry Eryshov on 17.10.2024.
//

import Foundation
import kameleoonClient
import OpenFeature

/// Resolver protocol which contains method for evaluations based on provided data
protocol Resolver {
    func resolve<T>(key: String, defaultValue: T, context: EvaluationContext?) -> ProviderEvaluation<T>
}

/// KameleoonResolver makes evaluations based on provided data, conforms to Resolver interface
struct KameleoonResolver: Resolver {

    let client: KameleoonClient
    
    /// Main method for getting resolution details based on provided data.
    func resolve<T>(key: String, defaultValue: T, context: EvaluationContext?) -> ProviderEvaluation<T> {
        do {
            // Get a variation (main SDK method)
            let variation = try client.getVariation(featureKey: key)

            // Get variant (variation key)
            let variant = variation.key

            // Get variableKey if it's provided in context or any first in variation.
            let variableKey = getVariableKey(context: context, variables: variation.variables)

            // Try to get value by variable key
            guard let value = variation.variables[variableKey] else {
                return makeProviderEvaluation(
                    value: defaultValue,
                    variant: variant,
                    errorCode: .flagNotFound,
                    errorMessage: makeErrorDescription(variant: variant, variableKey: variableKey)
                )
            }

            // Check if the variable value has a required type
            guard let castedValue = value.value as? T else {
                return makeProviderEvaluation(
                    value: defaultValue,
                    variant: variant,
                    errorCode: .typeMismatch,
                    errorMessage: "The type of value received is different from the requested value."
                )
            }
            
            return makeProviderEvaluation(value: castedValue, variant: variant)
        } catch let error as KameleoonError.Feature {
            return makeProviderEvaluation(
                value: defaultValue, variant: nil, errorCode: .flagNotFound, errorMessage: error.localizedDescription)
        } catch {
            return makeProviderEvaluation(
                value: defaultValue, variant: nil, errorCode: .general, errorMessage: error.localizedDescription)
        }
    }

    /// Helper method to get the variable key from the context or variables map.
    private func getVariableKey(context: EvaluationContext?, variables: [String: Types.Variable]) -> String {
        context?.getValue(key: DataType.variableKey)?.asString() ?? variables.keys.sorted().first ?? ""
    }

    /// Helper method to create a ResolutionDetails object with error details.
    private func makeProviderEvaluation<T>(
        value: T,
        variant: String? = nil,
        errorCode: ErrorCode? = nil,
        errorMessage: String? = nil
    ) -> ProviderEvaluation<T> {
        return ProviderEvaluation(value: value, variant: variant,  errorCode: errorCode, errorMessage: errorMessage)
    }

    /// Helper method to create an error description.
    private func makeErrorDescription(variant: String, variableKey: String) -> String {
        variableKey.isEmpty ?
            "The variation '\(variant)' has no variables" :
            "The value for provided variable key '\(variableKey)' isn't found in variation '\(variant)'"
    }
}
