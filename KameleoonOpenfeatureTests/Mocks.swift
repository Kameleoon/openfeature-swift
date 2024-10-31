//
//  Mocks.swift
//  KameleoonOpenfeatureTests
//
//  Created by Dmitry Eryshov on 21.10.2024.
//

@testable import KameleoonOpenfeature
import kameleoonClient
import OpenFeature

class KameleoonClientMock: KameleoonClient {
    var variation: Types.Variation!
    var error: KameleoonError.Feature!
    var addedKameleoonData: [KameleoonData] = []
    func getVariation(featureKey: String, track: Bool) throws -> kameleoonClient.Types.Variation {
        guard error == nil else { throw error }
        return variation
    }
    
    var ready: Bool = true
    var visitorCode: String = ""
    
    func runWhenReady(timeoutMilliseconds: Int, callback: @escaping (Bool) -> Void) {}
    func runWhenReady(callback: @escaping (Bool) -> Void) { callback(ready) }
    func addData(_ data: [any kameleoonClient.KameleoonData]) {
        addedKameleoonData.append(contentsOf: data)
    }
    func trackConversion(goalId: Int, revenue: Double) {}
    func trackConversion(goalId: Int, revenue: Double?) {}
    func flush(instant: Bool) {}
    func getVariations(onlyActive: Bool, track: Bool) throws -> [String: kameleoonClient.Types.Variation] { [:] }
    func isFeatureActive(featureKey: String, track: Bool) throws -> Bool { true }
    func getFeatureVariationKey(featureKey: String) throws -> String { "" }
    func getFeatureVariable(featureKey: String, variableKey: String) throws -> Any? { nil }
    func getFeatureVariationVariables(featureKey: String, variationKey: String) throws -> [String : Any] { [:]}
    func getRemoteData<T>(key: String, completionHandler: @escaping (T) -> Void) throws where T : Decodable {}
    func getRemoteData<T>(key: String, completion: @escaping (Result<T, any Error>) -> Void) where T : Decodable {}
    func getVisitorWarehouseAudience(
        warehouseKey: String,
        customDataIndex: Int,
        completionHandler: @escaping ((kameleoonClient.CustomData?) -> Void)
    ) throws {}
    func getVisitorWarehouseAudience(
        warehouseKey: String,
        customDataIndex: Int,
        completion: @escaping ((Result<kameleoonClient.CustomData, any Error>) -> Void)
    ) {}
    func updateConfigurationHandler(_ handler: (() -> Void)?) {}
    func getFeatureList() -> [String] { [] }
    func getActiveFeatureList() -> [String] { [] }
    func getActiveFeatures() -> [String : kameleoonClient.Types.Variation] { [:] }
    func setLegalConsent(_ legalConsent: Bool) {}
}

class KameleoonResolverMock<T>: Resolver {
    var value: T
    
    init(value: T) {
        self.value = value
    }
    
    func resolve<U>(key: String, defaultValue: U, context: EvaluationContext?) -> ProviderEvaluation<U> {
        guard let castedValue = value as? U else {
            return ProviderEvaluation(value: defaultValue)
        }
        return ProviderEvaluation(value: castedValue)
    }
}
