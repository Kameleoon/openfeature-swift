//
//  KameleoonProvider.swift
//  openfeature
//
//  Created by Dmitry Eryshov on 17.10.2024.
//

import Foundation
import kameleoonClient
import Combine
import OpenFeature

public final class KameleoonProvider: FeatureProvider {
    public var hooks: [any Hook] { [] }
    public var metadata: ProviderMetadata { KameleoonMetadata() }
    private let eventHandler = EventHandler(.notReady)
    
    private let resolver: Resolver
    
    /// Instance of Kameleoon SDK client
    let client: KameleoonClient
    
    /// Public initialization of KameleoonProvider
    ///
    /// Ensure that proper error handling is implemented to catch potential exceptions
    ///
    /// - Parameters:
    ///    - siteCode: The unique identifier of your project.
    ///    - visitorCode: The unique identifer of a visitor (optional).
    ///    - config: Configuration object of Kameleoon SDK
    /// - Throws: `OpenFeatureError.providerFatarError` if initialization is failed
    public convenience init(
        siteCode: String,
        visitorCode: String? = nil,
        config: KameleoonClientConfig? = nil
    ) throws {
        do {
            let client = try KameleoonClientFactory.create(
                siteCode: siteCode,
                visitorCode: visitorCode,
                config: config
            )
            let resolver = KameleoonResolver(client: client)
            self.init(client: client, resolver: resolver)
        } catch {
            throw OpenFeatureError.providerFatarError(message: error.localizedDescription)
        }
    }
    
    /// Internal initialization of KameleoonProvider. Required for testing purpose.
    ///
    /// - Parameters:
    ///    - client: The instance of Kameleoon SDK client
    ///    - resolver: Resolver object where all evaluation takes a place
    internal init(client: KameleoonClient, resolver: Resolver) {
        self.client = client
        self.resolver = resolver
    }

    /// Evaluate a boolean flag.
    ///
    /// - Parameters:
    ///    - key: The key of the flag to evaluate.
    ///    - defaultValue: The default value to return if the flag is not found or evaluation failed.
    ///    - evaluationContext: The context for the evaluation.
    /// - Returns: The evaluation result.
    public func getBooleanEvaluation(
        key: String,
        defaultValue: Bool,
        context: EvaluationContext?
    ) throws -> ProviderEvaluation<Bool> {
        resolver.resolve(key: key, defaultValue: defaultValue, context: context)
    }
    
    /// Evaluate a string flag.
    ///
    /// - Parameters:
    ///    - key: The key of the flag to evaluate.
    ///    - defaultValue: The default value to return if the flag is not found or evaluation failed.
    ///    - evaluationContext: The context for the evaluation.
    /// - Returns: The evaluation result.
    public func getStringEvaluation(
        key: String,
        defaultValue: String,
        context: EvaluationContext?
    ) throws -> ProviderEvaluation<String> {
        resolver.resolve(key: key, defaultValue: defaultValue, context: context)
    }
    
    /// Evaluate a integer flag.
    ///
    /// - Parameters:
    ///    - key: The key of the flag to evaluate.
    ///    - defaultValue: The default value to return if the flag is not found or evaluation failed.
    ///    - evaluationContext: The context for the evaluation.
    /// - Returns: The evaluation result.
    public func getIntegerEvaluation(
        key: String,
        defaultValue: Int64,
        context: EvaluationContext?
    ) throws -> ProviderEvaluation<Int64> {
        resolver.resolve(key: key, defaultValue: defaultValue, context: context)
    }
    
    /// Evaluate a double flag.
    ///
    /// - Parameters:
    ///    - key: The key of the flag to evaluate.
    ///    - defaultValue: The default value to return if the flag is not found or evaluation failed.
    ///    - evaluationContext: The context for the evaluation.
    /// - Returns: The evaluation result.
    public func getDoubleEvaluation(
        key: String,
        defaultValue: Double,
        context: EvaluationContext?
    ) throws -> ProviderEvaluation<Double> {
        resolver.resolve(key: key, defaultValue: defaultValue, context: context)
    }
    
    /// Evaluate a object flag.
    ///
    /// - Parameters:
    ///    - key: The key of the flag to evaluate.
    ///    - defaultValue: The default value to return if the flag is not found or evaluation failed.
    ///    - evaluationContext: The context for the evaluation.
    /// - Returns: The evaluation result.
    public func getObjectEvaluation(
        key: String,
        defaultValue: Value,
        context: EvaluationContext?
    ) throws -> ProviderEvaluation<Value> {
        let result: ProviderEvaluation<Any> = resolver.resolve(key: key, defaultValue: defaultValue, context: context)
        return ProviderEvaluation(
            value: DataConverter.toOpenfeature(from: result.value),
            flagMetadata: result.flagMetadata,
            variant: result.variant,
            reason: result.reason,
            errorCode: result.errorCode,
            errorMessage: result.errorMessage
        )
    }
    
    /// Called by OpenFeatureAPI whenever the new Provider is registered
    public func initialize(initialContext: EvaluationContext?) {
        client.runWhenReady { [weak self] ready in
            guard let self, ready else {
                self?.eventHandler.send(.error)
                return
            }
            self.client.addData(DataConverter.toKameleoon(from: initialContext))
            self.eventHandler.send(.ready)
        }
    }
    
    /// Called by OpenFeatureAPI whenever a new EvaluationContext is set by the application
    public func onContextSet(oldContext: EvaluationContext?, newContext: EvaluationContext) {
        client.addData(DataConverter.toKameleoon(from: newContext))
    }
    
    
    public func observe() -> AnyPublisher<OpenFeature.ProviderEvent, Never> {
        return eventHandler.observe()
    }
}

struct KameleoonMetadata: ProviderMetadata {
    var name: String? = "Kameleoon Provider"
}
