//
//  KameleoonResolverTest.swift
//  KameleoonOpenfeatureTests
//
//  Created by Dmitry Eryshov on 18.10.2024.
//

import Testing
@testable import KameleoonOpenfeature
import kameleoonClient
import OpenFeature

class KameleoonResolverTest {
    
    private var clientMock: KameleoonClientMock = KameleoonClientMock()
    
    private func setupClientMock(variation: Types.Variation? = nil, error: KameleoonError.Feature? = nil) {
        clientMock.variation = variation
        clientMock.error = error
    }

    // Parameterized test for resolve with no match variable
    @Test(
        "resolve_NoMatchVariable_ReturnsErrorForFlagNotFound",
        arguments: [
            (
                Types.Variation(key: "on", id: -1, experimentId: -1, variables: [:]),
                false,
                "The variation 'on' has no variables"
            ),
            (
                Types.Variation(
                    key: "var",
                    id: -1,
                    experimentId: -1,
                    variables: ["key": Types.Variable(key: "", type: "", value: nil as Any?)]
                ),
                true,
                "The value for provided variable key 'variableKey' isn't found in variation 'var'"
            )
          ]
    )
    func resolve_NoMatchVariable_ReturnsErrorForFlagNotFound(
        variation: Types.Variation,
        addVariableKey: Bool,
        errorMessage: String
    ) {
        // Arrange
        setupClientMock(variation: variation)

        let resolver = KameleoonResolver(client: clientMock)
        let key = "testFlag"
        let defaultValue = 42
        var attributes = [String: Value]()
        if addVariableKey {
            attributes["variableKey"] = Value.string("variableKey")
        }
        let context = MutableContext(attributes: attributes)

        // Act
        let result = resolver.resolve(key: key, defaultValue: defaultValue, context: context)

        // Assert
        #expect(result.value == defaultValue)
        #expect(result.errorCode == ErrorCode.flagNotFound)
        #expect(result.errorMessage == errorMessage)
        #expect(result.variant == variation.key)
    }

    // Parameterized test for mismatch types
    @Test(
        "testResolve_MismatchType_ReturnsErrorTypeMismatch",
        arguments: [
            Types.Variable(key: "key", type: "BOOLEAN", value: true),
            Types.Variable(key: "key", type: "STRING", value: "test"),
            Types.Variable(key: "key", type: "NUMBER", value: 10.0),
        ]
    )
    func testResolve_MismatchType_ReturnsErrorTypeMismatch(variable: Types.Variable) {
        // Arrange
        let variation = Types.Variation(key: "on", id: -1, experimentId: -1, variables: ["key": variable])
        setupClientMock(variation: variation)

        let resolver = KameleoonResolver(client: clientMock)
        let key = "testFlag"
        let defaultValue = 42

        // Act
        let result = resolver.resolve(key: key, defaultValue: defaultValue, context: nil)

        // Assert
        #expect(result.value == defaultValue)
        #expect(result.errorCode == ErrorCode.typeMismatch)
        #expect(result.errorMessage == "The type of value received is different from the requested value.")
        #expect(result.variant == variation.key)
    }

    // Parameterized test for Kameleoon exceptions
    @Test(
        "testResolve_KameleoonException_ReturnsErrorProperError",
        arguments: [
            KameleoonError.Feature.notFound("featureException"),
            KameleoonError.Feature.environmentDisabled("featureException", nil)
        ]
    )
    func testResolve_KameleoonException_ReturnsErrorProperError(error: KameleoonError.Feature) {
        // Arrange
        setupClientMock(error: error)

        let resolver = KameleoonResolver(client: clientMock)
        let flagKey = "testFlag"
        let defaultValue = 42

        // Act
        let result = resolver.resolve(key: flagKey, defaultValue: defaultValue, context: nil)

        // Assert
        #expect(result.value == defaultValue)
        #expect(result.errorCode == ErrorCode.flagNotFound)
        #expect(result.errorMessage == error.localizedDescription)
        #expect(result.variant == nil)
    }

    // Parameterized test for returning result details
    @Test(
        "testResolve_ReturnsResultDetails",
        arguments: [
            (
                nil,
                ["k": Types.Variable(key: "k", type: "NUMBER", value: 10)],
                10 as Any,
                9 as Any,
                Int.self as any Equatable.Type
            ),
            (nil, ["k1": Types.Variable(key: "k1", type: "STRING", value: "str")], "str", "st", String.self),
            (nil, ["k2": Types.Variable(key: "k2", type: "BOOLEAN", value: true)], true, false, Bool.self),
            (nil, ["k3": Types.Variable(key: "k3", type: "NUMBER", value: 10.0)], 10.0, 11.0, Double.self),
            ("varKey", ["varKey": Types.Variable(key: "varKey", type: "NUMBER", value: 10.0)], 10.0, 11.0, Double.self)
        ]
    )
    func testResolve_ReturnsResultDetails(
        variableKey: String?,
        variables: [String: Types.Variable],
        expectedValue: Any,
        defaultValue: Any,
        type: any Equatable.Type
    ) {
        // Arrange
        let variation = Types.Variation(key: "on", id: -1, experimentId: -1, variables: variables)
        setupClientMock(variation: variation)
        
        let resolver = KameleoonResolver(client: clientMock)
        let key = "testFlag"
        var attributes: [String: Value] = [:]
        if let key = variableKey {
            attributes["variableKey"] = Value.string(key)
        }
        let context = MutableContext(attributes: attributes)
        
        // Act
        let result = resolver.resolve(key: key, defaultValue: defaultValue, context: context)
        
        // Assert
        #expect(isEqual(type: type, a: result.value as! (any Equatable), b: expectedValue as! (any Equatable)) == true)
        #expect(result.errorCode == nil)
        #expect(result.errorMessage == nil)
        #expect(result.variant == variation.key)
    }
    
    private func isEqual<T>(type: T.Type, a: Any, b: Any) -> Bool where T: Equatable {
        guard let a = a as? T, let b = b as? T else { return false }
        return a == b
    }
}
