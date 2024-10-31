//
//  Types.swift
//  openfeature
//
//  Created by Dmitry Eryshov on 17.10.2024.
//

import Foundation
import OpenFeature

/// DataType is used to add different Kameleoon data types using ``EvaluationContext``
public struct DataType {
    public static let variableKey = "variableKey"
    public static let conversion = "conversion"
    public static let customData = "customData"
    
    /// Makes ``Value`` based on ``Conversion`` parameters
    public static func makeConversion(goalId: Int, revenue: Double = 0.0) -> Value {
        Value.structure([
            ConversionType.goalId: .integer(Int64(goalId)),
            ConversionType.revenue: .double(revenue),
        ])
    }
    
    /// Makes ``Value`` based on ``CustomData`` parameters
    public static func makeCustomData(id: Int, values: [String]) -> Value {
        Value.structure([
            CustomDataType.index: .integer(Int64(id)),
            CustomDataType.values: .list(values.map { .string($0) }),
        ])
    }
    
    /// Makes ``Value`` based on ``CustomData`` parameters
    public static func makeCustomData(id: Int, values: String...) -> Value {
        makeCustomData(id: id, values: values)
    }
}
/// CustomDataType is used to  ``CustomData`` using ``EvaluationContext``
public struct CustomDataType {
    public static let index = "index"
    public static let values = "values"
}

/// ConversionType is used to  ``Conversion`` using ``EvaluationContext``
public struct ConversionType {
    public static let goalId = "goalId"
    public static let revenue = "revenue"
}
