//
//  TypesTest.swift
//  openfeatureTests
//
//  Created by Dmitry Eryshov on 17.10.2024.
//

import Testing
@testable import KameleoonOpenfeature
import kameleoonClient
import OpenFeature

struct DataConverterTest {

    @Test("toKameleoon_nilContext_returnsEmpty")
    func toKameleoon_nilContext_returnsEmpty() {
        #expect(DataConverter.toKameleoon(from:  nil).isEmpty)
    }
    
    @Test("toKameleoon_conversionData_returnsConversion", arguments: [true, false])
    func toKameleoon_conversionData_returnsConversion(_ addRevenue: Bool) {
        // Arrange
        let goalId = Int64(Int.random(in: 0...Int.max))
        let revenue = Double.random(in: 0...1)
        var conversionDictionary: [String: Value] = [ConversionType.goalId: .of(goalId)]
        if addRevenue {
            conversionDictionary[ConversionType.revenue] = .of(revenue)
        }
        let context = MutableContext(attributes: [DataType.conversion: .structure(conversionDictionary)])
        let expectedConversion = Conversion(goalId: Int(goalId), revenue: addRevenue ? revenue : 0.0)
        
        // Act
        let result = DataConverter.toKameleoon(from: context)
        
        // Assert
        #expect(result.count == 1)
        #expect(expectedConversion == result.first as? Conversion)
    }
    
    @Test(
        "toKameleoon_customDataData_returnsCustomData",
        arguments: [[], [""], ["v1"], ["v1", "v1"], ["v1", "v2", "v3"]]
    )
    func toKameleoon_customDataData_returnsCustomData(_ values: [String]) {
        // Arrange
        let index = Int.random(in: 0...Int.max)
        var customDataDictionary: [String: Value] = [CustomDataType.index: .integer(Int64(index))]
        if values.count == 1 {
            customDataDictionary[CustomDataType.values] = .string(values[0])
        } else if values.count > 1 {
            customDataDictionary[CustomDataType.values] = .list(values.map { .of($0) })
        }
        let context = MutableContext(attributes: [DataType.customData: .structure(customDataDictionary)])
        let expectedCustomData = CustomData(id: index, values: values)
        
        // Act
        let result = DataConverter.toKameleoon(from: context)
        
        // Assert
        #expect(result.count == 1)
        #expect(expectedCustomData == result.first as? CustomData)
    }
    
    @Test("toKameleoonData_AllTypes_ReturnsAllData")
    func toKameleoonData_AllTypes_ReturnsAllData() {
        // Act
        let goalId1 = Int64(Int.random(in: 0...Int.max))
        let goalId2 = Int64(Int.random(in: 0...Int.max))
        let index1 = Int64(Int.random(in: 0...Int.max))
        let index2 = Int64(Int.random(in: 0...Int.max))

        let allDataDictionary: [String: Value] = [
            DataType.conversion: .list([
                .structure([ConversionType.goalId: .of(goalId1)]),
                .structure([ConversionType.goalId: .of(goalId2)])
            ]),
            DataType.customData: .list(
                [
                    .structure([
                            CustomDataType.index: .of(index1),
                            CustomDataType.values: .string("aaa")
                    ]),
                    .structure([CustomDataType.index: .of(index2)])
                ]
            )
        ]

        let context = MutableContext(attributes: allDataDictionary)

        // Act
        let result = DataConverter.toKameleoon(from: context)

        // Assert
        #expect(result.count == 4)
        let conversions = result.compactMap { $0 as? Conversion }
        #expect(conversions[0].goalId == goalId1)
        #expect(conversions[1].goalId == goalId2)
        let customData = result.compactMap { $0 as? CustomData }
        #expect(customData[0].id == index1)
        #expect(customData[1].id == index2)
    }
    
    @Test(
        "toOpenFeature_returnsCorrectValue",
        arguments: [
            (nil as Any?, Value.null),
            (Value.integer(1), .integer(1)),
            (42, Value.integer(42)),
            (3.14, Value.double(3.14)),
            (true, Value.boolean(true)),
            ("test", .string("test")),
            ([1,2,3], Value.list([.of(Int64(1)),.of(Int64(2)),.of(Int64(3))])),
            (["key": "value"], Value.structure(["key": .of("value")]))
        ]
    )
    func toOpenFeature_returnsCorrectValue(value: Any?, expected: Value) {
        // Act
        let result = DataConverter.toOpenfeature(from: value)
        
        // Assert
        #expect(expected == result)
    }
}
