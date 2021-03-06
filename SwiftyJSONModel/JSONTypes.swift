//
//  JSONTypes.swift
//  SwiftyJSONModel
//
//  Created by Oleksii on 18/09/16.
//  Copyright © 2016 Oleksii Dykan. All rights reserved.
//

import Foundation
import SwiftyJSON

// MARK: - Protocols
public protocol JSONType {
    var bool: Bool? { get }
    var int: Int? { get }
    var double: Double? { get }
    var string: String? { get }
    var array: [Self]? { get }
    var dictionary: [String: Self]? { get }
    
    init(bool: Bool)
    init(int: Int)
    init(double: Double)
    init(string: String)
    init(array: [Self])
    init(dictionary: [String: Self])
    
    func value() throws -> Bool
    func value() throws -> Int
    func value() throws -> Double
    func value() throws -> String
    func arrayValue() throws -> [Self]
    func dictionaryValue() throws -> [String: Self]
}

public protocol JSONInitializable {
    init(json: JSON) throws
}

public protocol JSONRepresentable {
    var jsonValue: JSON { get }
}

public protocol PropertiesContaining {
    associatedtype PropertyKey: RawRepresentable, Hashable
}

public protocol JSONObjectInitializable: PropertiesContaining, JSONInitializable {
    init(object: JSONObject<PropertyKey>) throws
}

public protocol JSONObjectRepresentable: PropertiesContaining, JSONRepresentable {
    var dictValue: [PropertyKey: JSONRepresentable?] { get }
}

public protocol JSONModelType: JSONObjectInitializable, JSONObjectRepresentable {}


// MARK: - JSONInitializable extensions
extension JSON: JSONInitializable, JSONRepresentable {
    public init(json: JSON) { self = json }
    public var jsonValue: JSON { return self }
}

extension String: JSONInitializable, JSONRepresentable {
    public init(json: JSON) throws { self = try json.value() }
    public var jsonValue: JSON { return JSON(string: self) }
}

extension Bool: JSONInitializable, JSONRepresentable {
    public init(json: JSON) throws { self = try json.value() }
    public var jsonValue: JSON { return JSON(bool: self) }
}

extension Int: JSONInitializable, JSONRepresentable {
    public init(json: JSON) throws { self = try json.value() }
    public var jsonValue: JSON { return JSON(int: self) }
}

extension Double: JSONInitializable, JSONRepresentable {
    public init(json: JSON) throws { self = try json.value() }
    public var jsonValue: JSON { return JSON(double: self) }
}


// MARK: - Handy extensions
struct JSONArray<T: JSONRepresentable>: JSONRepresentable {
    let array: [T]
    
    init(_ array: [T]) {
        self.array = array
    }
    
    var jsonValue: JSON {
        return JSON(array.map({ $0.jsonValue }))
    }
}

public extension Array where Element: JSONRepresentable {
    public var jsonRepresantable: JSONRepresentable {
        return JSONArray<Element>(self)
    }
}

struct JSONDict<T: JSONRepresentable>: JSONRepresentable {
    let dict: [String: T]
    
    init(_ dict: [String: T]) {
        self.dict = dict
    }
    
    var jsonValue: JSON {
        var result: [String: JSON] = [:]
        dict.forEach({ result[$0] = $1.jsonValue })
        return JSON(dictionary: result)
    }
}

public extension Dictionary where Key == String, Value: JSONRepresentable {
    public var jsonRepresantable: JSONRepresentable {
        return JSONDict<Value>(self)
    }
}

public extension Date {
    public func json(with transformer: DateTransformer) -> String {
        return transformer.string(form: self)
    }
}

// MARK: - JSONType
public extension JSONType {
    public func value() throws -> Bool {
        guard let boolValue = bool else { throw JSONModelError.invalidElement }
        return boolValue
    }
    
    public func value() throws -> Int {
        guard let intValue = int else { throw JSONModelError.invalidElement }
        return intValue
    }
    
    public func value() throws -> Double {
        guard let doubleValue = double else { throw JSONModelError.invalidElement }
        return doubleValue
    }
    
    public func value() throws -> String {
        guard let stringValue = string else { throw JSONModelError.invalidElement }
        return stringValue
    }
    
    public func arrayValue() throws -> [Self] {
        guard let arrayValue = array else { throw JSONModelError.invalidElement }
        return arrayValue
    }
    
    public func dictionaryValue() throws -> [String: Self] {
        guard let dictValue = dictionary else { throw JSONModelError.invalidElement }
        return dictValue
    }
}

public protocol JSONString: RawRepresentable, JSONInitializable, JSONRepresentable {
    init?(rawValue: String)
    var rawValue: String { get }
}

public extension JSONString {
    public init(json: JSON) throws {
        guard let object = Self.init(rawValue: try String(json: json) ) else {
            throw JSONModelError.invalidElement
        }
        self = object
    }
    
    public var jsonValue: JSON {
        return rawValue.jsonValue
    }
}

extension JSON: JSONType {
    public init(bool: Bool) { self.init(bool) }
    public init(int: Int) { self.init(int) }
    public init(double: Double) { self.init(double) }
    public init(string: String) { self.init(string) }
    public init(array: [JSON]) { self.init(array) }
    public init(dictionary: [String: JSON]) { self.init(dictionary) }
}

// MARK: - JSON Models
public extension JSONObjectInitializable where PropertyKey.RawValue == String {
    init(json: JSON) throws {
        let jsonObject = try JSONObject<PropertyKey>(json: json)
        try self.init(object: jsonObject)
    }
}

public extension JSONObjectRepresentable where PropertyKey.RawValue == String {
    var jsonValue: JSON {
        return JSONObject<PropertyKey>(dictValue).jsonValue
    }
}

