//
//  DataConverter.swift
//  KameleoonOpenfeature
//
//  Created by Dmitry Eryshov on 18.10.2024.
//

import Foundation
import kameleoonClient
import OpenFeature

struct DataConverter {
    private init() {}
    
    /// Dictionary which contains conversion methods by keys
    private static let conversionMethods: [String: ((Value) -> KameleoonData?)] = [
        DataType.conversion: { makeConversion(value: $0) },
        DataType.customData: { makeCustomData(value: $0) }
    ]
    
    /// The method for converting ``EvaluationContext`` data to Kameleoon SDK data types.
    static func toKameleoon(from context: EvaluationContext?) -> [KameleoonData] {
        guard let contextMap = context?.asMap() else { return [] }

        return contextMap.flatMap { key, value -> [KameleoonData] in
            guard let conversionMethod = conversionMethods[key] else { return [] }
            let values = value.asList() ?? [value]
            return values.compactMap { conversionMethod($0) }
        }
    }
    
    /// The method for converting Kameleoon objects to OpenFeature Value instances.
    static func toOpenfeature(from context: Any?) -> Value {
        switch context {
            case let dict as [String: Any]:
                let entries = dict.compactMap { ($0, toOpenfeature(from: $1)) }
                return .structure(Dictionary(uniqueKeysWithValues: entries))
            case let arr as [Any]:
                return .list(arr.compactMap{ toOpenfeature(from: $0) })
            case let value as Value:
                return value
            case let int as Int:
                return .integer(Int64(int))
            default:
                return Value.of(context)
        }
    }
    
    /// Make Kameleoon ``CustomData`` from ``Value``
    static func makeCustomData(value: Value) -> CustomData? {
        guard let valueCustomData = value.asStructure(),
              let index = valueCustomData[CustomDataType.index]?.asInteger()
        else { return nil }
        
        let customDataValues: [String] = {
            guard let str = valueCustomData[CustomDataType.values]?.asString() else {
                return valueCustomData[CustomDataType.values]?.asList()?.compactMap { $0.asString() } ?? []
            }
            return [str]
        }()
        
        return CustomData(id: Int(index), values: customDataValues)
    }
    
    /// Make Kameleoon ``Conversion`` from ``Value``
    static func makeConversion(value: Value) -> Conversion? {
        guard let structConversion = value.asStructure(),
              let goalId = structConversion[ConversionType.goalId]?.asInteger()
        else { return nil }

        let revenue = structConversion[ConversionType.revenue]?.asDouble() ?? 0.0

        return Conversion(goalId: Int(goalId), revenue: revenue)
    }
}
