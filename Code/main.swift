//
//  main.swift
//  Boilerplate
//
//  Created by Evan Maloney on 6/25/15.
//  Copyright © 2015 Gilt Groupe. All rights reserved.
//

import Foundation

/*******************************************************************************

    Global functions
 
 */

func readUntilEOF()
    -> String
{
    var data = ""

    while let line = readLine(stripNewline: false) {
        data += line
    }

    return data
}

func readFromPath(path: String)
    -> String
{
    return try! NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding) as String
}

/*******************************************************************************

 Types

 */

enum ArgumentName: String
{
    case DataFile = "dataFile"
    case ManifestFile = "manifestFile"
    case StdinData = "stdinData"
    case TemplateFile = "templateFile"
    case OutputFile = "outputFile"
    case Verbose = "verbose"
    case Help = "help"
}

enum DataSource
{
    case None
    case Stdin
    case File(String)

    func read()
        -> String?
    {
        switch self {
        case .None:
            return nil

        case .Stdin:
            return readUntilEOF()

        case .File(let path):
            return readFromPath(path)
        }
    }
}

enum TemplateSource
{
    case Stdin
    case File(String)

    func read()
        -> String
    {
        switch self {
        case .Stdin:
            return readUntilEOF()

        case .File(let path):
            return readFromPath(path)
        }
    }
}

enum OutputDestination
{
    case Stdout
    case File(String)

    func write(out: String)
    {
        switch self {
        case .Stdout:
            print(out, terminator: "")

        case .File(let path):
            try! (out as NSString).writeToFile(path, atomically: true, encoding: NSUTF8StringEncoding)
        }
    }
}

extension ArgumentDeclaration
{
    static func forName(argument: ArgumentName, type: ArgumentType, shortForm: String, longForm: String)
        -> ArgumentDeclaration
    {
        return ArgumentDeclaration(name: argument.rawValue, type: type, shortForm: shortForm, longForm: longForm)
    }

    static func forName(argument: ArgumentName, type: ArgumentType, shortForm: String)
        -> ArgumentDeclaration
    {
        return ArgumentDeclaration(name: argument.rawValue, type: type, shortForm: shortForm)
    }

    static func forName(argument: ArgumentName, type: ArgumentType, longForm: String)
        -> ArgumentDeclaration
    {
        return ArgumentDeclaration(name: argument.rawValue, type: type, longForm: longForm)
    }
}

extension ArgumentValues
{
    func hasArgument(argument: ArgumentName)
        -> Bool
    {
        return hasArgument(argument.rawValue)
    }

    func isDeclaredArgument(argument: ArgumentName)
        -> Bool
    {
        return isDeclaredArgument(argument.rawValue)
    }

    func declaredArgumentType(argument: ArgumentName)
        -> ArgumentType?
    {
        return declaredArgumentType(argument.rawValue)
    }

    func argumentValue(argument: ArgumentName)
        -> String?
    {
        return argumentValue(argument.rawValue)
    }

    func hasMultipleValues(argument: ArgumentName)
        -> Bool
    {
        return hasMultipleValues(argument.rawValue)
    }

    func allArgumentValues(argument: ArgumentName)
        -> [String]
    {
        return allArgumentValues(argument.rawValue)
    }
}

/*******************************************************************************

 Command-line execution

 */
let dataFile = ArgumentDeclaration.forName(.DataFile, type: .SingleValue, shortForm: "d", longForm: "data")
let stdinData = ArgumentDeclaration.forName(.StdinData, type: .Flag, longForm: "stdin-data")
let templateFile = ArgumentDeclaration.forName(.TemplateFile, type: .SingleValue, shortForm: "t", longForm: "template")
let manifestFile = ArgumentDeclaration.forName(.ManifestFile, type: .SingleValue, shortForm: "m", longForm: "manifest")
let verbose = ArgumentDeclaration.forName(.Verbose, type: .Flag, shortForm: "v", longForm: "verbose")
let help = ArgumentDeclaration.forName(.Help, type: .Flag, shortForm: "h", longForm: "help")
let output = ArgumentDeclaration.forName(.OutputFile, type: .SingleValue, shortForm: "o", longForm: "output")

let proc = ArgumentProcessor(declarations: [dataFile, stdinData, templateFile, verbose, help, output, manifestFile])

let argList = proc.process(Process.arguments)

var manifest: String?
var templateSource = TemplateSource.Stdin
var dataSource = DataSource.None
var destination = OutputDestination.Stdout

if argList.hasArgument(.Help) {
    fatalError("Help feature not yet implemented")
}

if argList.hasArgument(.TemplateFile) {
    templateSource = .File(argList.argumentValue(.TemplateFile)!)

    if argList.hasArgument(.StdinData) {
        dataSource = .Stdin
    }
}
else if argList.hasArgument(.StdinData) {
    fatalError("Can only take data from stdin when a template file is explicitly specified")
}

if argList.hasArgument(.DataFile) {
    dataSource = .File(argList.argumentValue(.DataFile)!)
}

if argList.hasArgument(.OutputFile) {
    destination = .File(argList.argumentValue(.OutputFile)!)
}

if argList.hasArgument(.ManifestFile) {
    manifest = argList.argumentValue(.ManifestFile)
}

let env = MBEnvironment.loadDefaultEnvironment()!
env.addSearchDirectory(NSFileManager.defaultManager().currentDirectoryPath)

let vars = MBVariableSpace.instance()!
vars["ENV"] = NSProcessInfo.processInfo().environment

if let manifest = manifest {
    env.loadMBMLFile(manifest)
}

let template = templateSource.read()

if let data = dataSource.read() {
    let xml = RXMLElement(fromXMLString: data, encoding: NSUTF8StringEncoding)
    env.amendDataModelWithXML(xml)
}

let result = template.evaluateAsString()

destination.write(result!)
