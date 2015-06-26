//
//  ArgParser.swift
//  CleanroomCLI
//
//  Created by Evan Maloney on 6/25/15.
//  Copyright © 2015 Gilt Groupe. All rights reserved.
//

import Foundation

/**
Represents the various forms a command line argument might take.
*/
public enum ArgumentType
{
    /**
    Represents an argument that takes no follow-on values. A flag can be 
    thought of as a boolean value; if it is present, the value represented 
    by the flag is `true`; if the flag is not present, the value is `false`.
    */
    case Flag

    /**
    Represents an argument that takes a single follow-on value.
    */
    case SingleValue

    /**
    Represents an argument that takes a multiple follow-on values.
    */
    case MultiValue
}

public struct ArgumentDeclaration
{
    public let name: String
    public let type: ArgumentType
    public let shortForm: String?
    public let longForm: String?

    public init(name: String, type: ArgumentType)
    {
        if name.characters.count == 1 {
            self.init(name: name, type: type, shortForm: name, longForm: nil)
        } else {
            self.init(name: name, type: type, shortForm: nil, longForm: name)
        }
    }

    public init(name: String, type: ArgumentType, shortForm: String)
    {
        self.init(name: name, type: type, shortForm: shortForm, longForm: nil)
    }

    public init(name: String, type: ArgumentType, longForm: String)
    {
        self.init(name: name, type: type, shortForm: nil, longForm: longForm)
    }

    public init(type: ArgumentType, shortForm: String)
    {
        self.init(name: shortForm, type: type, shortForm: shortForm, longForm: nil)
    }

    public init(type: ArgumentType, longForm: String)
    {
        self.init(name: longForm, type: type, shortForm: nil, longForm: longForm)
    }

    public init(type: ArgumentType, shortForm: String, longForm: String)
    {
        self.init(name: longForm, type: type, shortForm: shortForm, longForm: longForm)
    }

    public init(name: String, type: ArgumentType, shortForm: String, longForm: String)
    {
        self.init(name: name, type: type, shortForm: shortForm as String?, longForm: longForm as String?)
    }

    private init(name: String, type: ArgumentType, shortForm: String?, longForm: String?)
    {
        precondition(shortForm != nil || longForm != nil, "Either a short form or a long form must be provided")

        if shortForm != nil {
            precondition(shortForm!.characters.count == 1, "The short form of an argument must be one character long")
        }

        if longForm != nil {
            precondition(longForm!.characters.count >= 1, "The long form of an argument must be greater than one character long")
        }

        self.name = name
        self.type = type
        self.shortForm = shortForm
        self.longForm = longForm
    }
}

public struct ArgumentValue
{
    let argument: String
    let values: [String]
    let declaration: ArgumentDeclaration?

    var name: String {
        return declaration?.name ?? argument
    }
}

public protocol ArgumentValues
{
    /**
    The command as invoked from the command name.
    */
    var command: String { get }

    /**
    The names of the arguments for which `hasArgument()` would return `true`.
    */
    var names: [String] { get }

    /**
    Determines if the argument with the given name was present in the argument
    list.

    :param:     name The name of the argument.

    :returns:   `true` if the argument `name` was present in the argument list,
                `false` otherwise.
    */
    func hasArgument(name: String) -> Bool

    /**
    Determines whether the argument with the specified name was explicitly
    declared.
    
    :param:     name The name of the argument.
    
    :returns:   `true` if `name` represents an declared argument; undeclared
                arguments are usually treated as unrecognized by the developer.
    */
    func isDeclaredArgument(name: String) -> Bool

    /**
    Returns the `ArgumentType` associated with the argument with the given name.

    :param:     name The name of the argument whose `ArgumentType` is sought.
    
    :returns:   The `ArgumentType`, or `nil` if `isDeclaredArgument()` would
                return `false` for `name`.
    */
    func declaredArgumentType(name: String) -> ArgumentType?

    /**
    Returns the string value of the argument with the given name.

    If `declaredArgumentType()` would return `Flag` for `name`, then this
    function will return `nil`.

    :param:     name The name of the argument whose string value is sought.

    :returns:   The string value of the argument `name`.
    */
    func argumentValue(name: String) -> String?

    /**
    Determines whether the argument with the specified name has multiple
    values.

    :param:     name The name of the argument.

    :returns:   `true` if the argument `name` has multiple values, `false`
                otherwise.
    */
    func hasMultipleValues(name: String) -> Bool

    /**
    Returns an array containing all string values for the argument with the
    given name.

    :param:     name The name of the argument whose string values are sought.

    :returns:   All string values for the argument `name`.
    */
    func allArgumentValues(name: String) -> [String]
}

private struct ArgumentValueList: ArgumentValues
{
    let command: String
    let names: [String]
    let namesToValues: [String: ArgumentValue]

    init(command: String, values: [ArgumentValue])
    {
        var names = [String]()
        var namesToValues = [String: ArgumentValue]()
        for val in values {
            names += [val.name]
            namesToValues[val.name] = val
        }
        self.command = command
        self.names = names
        self.namesToValues = namesToValues
    }

    func hasArgument(name: String)
        -> Bool
    {
        return namesToValues[name] != nil
    }

    func isDeclaredArgument(name: String)
        -> Bool
    {
        guard let val = namesToValues[name] else {
            return false
        }

        return val.declaration != nil
    }

    func declaredArgumentType(name: String)
        -> ArgumentType?
    {
        return namesToValues[name]?.declaration?.type
    }

    func argumentValue(name: String)
        -> String?
    {
        guard let val = namesToValues[name] else {
            return nil
        }

        return val.values.first
    }

    func hasMultipleValues(name: String) -> Bool
    {
        guard let val = namesToValues[name] else {
            return false
        }

        return val.values.count > 1
    }

    func allArgumentValues(name: String) -> [String]
    {
        guard let val = namesToValues[name] else {
            return []
        }

        return val.values
    }
}

public struct ArgumentProcessor
{
    public static let DefaultArgShortFormPrefix = "-"
    public static let DefaultArgLongFormPrefix  = "--"

//    public let declarations: [ArgumentDeclaration]
//    public let shortFormPrefix: String
//    public let longFormPrefix: String

    private let namesToDeclarations: [String: ArgumentDeclaration]
    private let argsToDeclarations: [String: ArgumentDeclaration]

    public init(declarations: [ArgumentDeclaration])
    {
        self.init(declarations: declarations, shortFormPrefix: self.dynamicType.DefaultArgShortFormPrefix, longFormPrefix: self.dynamicType.DefaultArgLongFormPrefix)
    }
    
    public init(declarations: [ArgumentDeclaration], shortFormPrefix: String, longFormPrefix: String)
    {
        let names = declarations.map { $0.name }
        precondition(longFormPrefix.characters.count > shortFormPrefix.characters.count, "The length of the longFormPrefix must be longer than that of the shortFormPrefix")
        precondition(names.count == Set(names).count, "Argument names must be unique")

        var namesToDecls = [String: ArgumentDeclaration]()
        var argsToDecls = [String: ArgumentDeclaration]()
        for decl in declarations {
            namesToDecls[decl.name] = decl
            if let short = decl.shortForm {
                let key = "\(shortFormPrefix)\(short)"
                precondition(argsToDecls[key] == nil, "Multiple arguments declared for \(key)")
                argsToDecls[key] = decl
            }
            if let long = decl.longForm {
                let key = "\(longFormPrefix)\(long)"
                precondition(argsToDecls[key] == nil, "Multiple arguments declared for \(key)")
                argsToDecls[key] = decl
            }
        }
        self.namesToDeclarations = namesToDecls
        self.argsToDeclarations = argsToDecls
    }

    public func process(arguments: [String])
        -> ArgumentValues
    {
        precondition(arguments.count > 0, "Command-line arguments are expected to contain at least one element, the invoked command itself.")

        var command: String?
        var values = [ArgumentValue]()
        var collectArgumentsFor: ArgumentDeclaration?
        var collected = [String]()

        for arg in arguments {
            if command == nil {
                command = arg
                continue
            }

            //
            // make sure we obey any argument collection rules
            //
            if let collectFor = collectArgumentsFor
                where collectFor.type == .SingleValue && collected.count == 2
            {
                values += [ArgumentValue(argument: collected[0], values: [collected[1]], declaration: collectFor)]
                collectArgumentsFor = nil
                collected = []
            }

            if let decl = argsToDeclarations[arg] {
                if let collectFor = collectArgumentsFor {
                    values += [ArgumentValue(argument: collected[0], values: Array(collected[1..<collected.endIndex]), declaration: collectFor)]
                    collectArgumentsFor = nil
                    collected = []
                }

                if decl.type == .Flag {
                    values += [ArgumentValue(argument: arg, values: [], declaration: decl)]
                }
                else {
                    collected += [arg]
                    collectArgumentsFor = decl
                }
            }
            else if collectArgumentsFor != nil {
                collected += [arg]
            }
            else {
                values += [ArgumentValue(argument: arg, values: [], declaration: nil)]
            }
        }

        if let collectFor = collectArgumentsFor {
            values += [ArgumentValue(argument: collected[0], values: Array(collected[1..<collected.endIndex]), declaration: collectFor)]
        }

        return ArgumentValueList(command: command!, values: values)
    }
}

