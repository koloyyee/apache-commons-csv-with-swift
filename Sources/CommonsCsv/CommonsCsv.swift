// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import SwiftJava
import JavaIO
import SwiftJavaConfigurationShared

@main
struct CommonsCsv {
    static func main() {
        do {
            let swiftJavaClasspath = findSwiftJavaClasspaths()
            let jvm = try JavaVirtualMachine.shared(classpath: swiftJavaClasspath)

             let CSVFormatClass = try JavaClass<CSVFormat>()
            let csv = try String(contentsOfFile: "Resources/size.csv", encoding: .utf8)
            let reader = StringReader(csv)
             for record in try CSVFormatClass.RFC4180.parse(reader)!.getRecords()! {
                print(record.values())
             }

        
        } catch {
            print("Error: \(error)")
        }
    }
}
