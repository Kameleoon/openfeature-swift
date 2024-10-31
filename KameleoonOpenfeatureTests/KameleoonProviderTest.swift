//
//  KameleoonProviderTest.swift
//  KameleoonOpenfeatureTests
//
//  Created by Dmitry Eryshov on 18.10.2024.
//

import Testing
@testable import KameleoonOpenfeature
import kameleoonClient
import OpenFeature

class KameleoonProviderTest {
    
    private struct Const {
        static let siteCode = "siteCode"
        static let featureKey = "featureKey"
    }
    
    private var clientMock = KameleoonClientMock()
    
    @Test("init_invalidSiteCode_throwsFeatureProviderException")
    func init_invalidSiteCode_throwsFeatureProviderException() {
        // Act & Assert
        #expect { try KameleoonProvider(siteCode: "") } throws: { error in
            let expectedError =
                OpenFeatureError.providerFatarError(message: KameleoonError.siteCodeIsEmpty.localizedDescription)
            #expect(error as! OpenFeatureError == expectedError)
            return true
        }
    }

    @Test("getMetadata_returnsCorrectMetadata")
    func getMetadata_returnsCorrectMetadata() {
        // Arrange
        let provider = try! KameleoonProvider(siteCode: Const.siteCode)
        
        // Act & Assert
        #expect(provider.metadata.name == "Kameleoon Provider")
    }

    @Test("getBooleanEvaluation_returnsCorrectValue")
    func getBooleanEvaluation_returnsCorrectValue() {
        // Arrange
        let resolverMock = KameleoonResolverMock(value: true)
        let provider = KameleoonProvider(client: clientMock, resolver: resolverMock)
        
        // Act
        let result = try! provider.getBooleanEvaluation(key: Const.featureKey, defaultValue: false, context: nil)
        
        // Assert
        #expect(result.value == resolverMock.value)
    }
    
    @Test("getDoubleEvaluation_returnsCorrectValue")
    func getDoubleEvaluation_returnsCorrectValue() {
        // Arrange
        let resolverMock = KameleoonResolverMock(value: 2.5)
        let provider = KameleoonProvider(client: clientMock, resolver: resolverMock)
        
        // Act
        let result = try! provider.getDoubleEvaluation(key: Const.featureKey, defaultValue: 0.5, context: nil)
        
        // Assert
        #expect(result.value == resolverMock.value)
    }
    
    @Test("getIntegerEvaluation_returnsCorrectValue")
    func getIntegerEvaluation_returnsCorrectValue() {
        // Arrange
        let resolverMock = KameleoonResolverMock(value: Int64(2))
        let provider = KameleoonProvider(client: clientMock, resolver: resolverMock)
        
        // Act
        let result = try! provider.getIntegerEvaluation(key: Const.featureKey, defaultValue: Int64(1), context: nil)
        
        // Assert
        #expect(result.value == resolverMock.value)
    }
    
    @Test("getStringEvaluation_returnsCorrectValue")
    func getStringEvaluation_returnsCorrectValue() {
        // Arrange
        let resolverMock = KameleoonResolverMock(value: "2")
        let provider = KameleoonProvider(client: clientMock, resolver: resolverMock)
        
        // Act
        let result = try! provider.getStringEvaluation(key: Const.featureKey, defaultValue: "1", context: nil)
        
        // Assert
        #expect(result.value == resolverMock.value)
    }
    
    @Test("getObjectEvaluation_returnsCorrectValue")
    func getObjectEvaluation_returnsCorrectValue() {
        // Arrange
        let resolverMock = KameleoonResolverMock(value: "expected")
        let provider = KameleoonProvider(client: clientMock, resolver: resolverMock)
        
        // Act
        let result = try! provider.getObjectEvaluation(
            key: Const.featureKey,
            defaultValue: .string("default"),
            context: nil
        )
        
        // Assert
        #expect(result.value ?? .null == Value.of(resolverMock.value))
    }
    
    @Test("onContextChanged_dataAddedSuccessfully")
    func testResolve_addDataCalled() {
        // Arrange
        let resolverMock = KameleoonResolverMock(value: "")
        let provider = KameleoonProvider(client: clientMock, resolver: resolverMock)
        let attributes: [String: Value] = [
            DataType.conversion: .list([
                .structure([ConversionType.goalId: .of(Int64(1))]),
            ]),
            DataType.customData: .list([
                .structure([CustomDataType.index: .of(Int64(1))]),
            ])
        ]
        let context = MutableContext(attributes: attributes)
        let expectedData = [Conversion(goalId: 1), CustomData(id: 1, values: [])]
        
        // Act
        provider.onContextSet(oldContext: nil, newContext: context)
        
        // Assert
        #expect(clientMock.addedKameleoonData.count == 2)
        let conversion = clientMock.addedKameleoonData.filter { $0 is Conversion }.first as! Conversion
        let customData = clientMock.addedKameleoonData.filter { $0 is CustomData }.first as! CustomData
        #expect(conversion == expectedData[0] as! Conversion)
        #expect(customData == expectedData[1] as! CustomData)
    }
    

    @Test("notReadyProviderStatus")
    func notReadyProviderStatus() {
        // Arrange
        let provider = KameleoonProvider(client: clientMock, resolver: KameleoonResolverMock(value: ""))

        // Assert
        _ = provider.observe().sink { #expect($0 == .notReady) }
    }
    
    @Test("readyProviderStatus")
    func readyProviderStatus() {
        // Arrange
        let provider = KameleoonProvider(client: clientMock, resolver: KameleoonResolverMock(value: ""))

        // Act
        provider.initialize(initialContext: nil)
        
        // Assert
        _ = provider.observe().sink { #expect($0 == .ready) }
    }
}
