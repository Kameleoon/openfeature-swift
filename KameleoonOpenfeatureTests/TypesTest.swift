//
//  TypesTest.swift
//  KameleoonOpenfeature
//
//  Created by Dmitry Eryshov on 18.10.2024.
//

import Testing
import kameleoonClient
import OpenFeature
@testable import KameleoonOpenfeature
 
struct TypesTest {

    @Test("Check DataType")
    func dataType() throws {
        // Assert
        #expect(DataType.conversion == "conversion")
        #expect(DataType.customData == "customData")
    }
    
    @Test("Check CustomDataType")
    func customDataType() throws {
        // Assert
        #expect(CustomDataType.index == "index")
        #expect(CustomDataType.values == "values")
    }
    
    @Test("Check ConversionType")
    func conversionType() throws {
        // Assert
        #expect(ConversionType.goalId == "goalId")
        #expect(ConversionType.revenue == "revenue")
    }
    
    @Test("Check makeCustomData")
    func makeCustomData() throws {
        // Arrange
        let id = 0
        let values = ["true"]
        let expected = Value.structure([
            CustomDataType.index: .integer(Int64(id)),
            CustomDataType.values: .list(values.map { .string($0) }),
        ])
        
        // Act
        let actual = DataType.makeCustomData(id: id, values: values)
        
        
        // Assert
        #expect(expected == actual)
    }
    
    @Test("Check makeConversion ")
    func makeConversion() throws {
        // Arrange
        let goalId = 10
        let revenue = 10.5
        let expected = Value.structure([
            ConversionType.goalId: .integer(Int64(goalId)),
            ConversionType.revenue: .double(revenue),
        ])
        
        // Act
        let actual = DataType.makeConversion(goalId: goalId, revenue: revenue)
        
        
        // Assert
        #expect(expected == actual)
    }
}

