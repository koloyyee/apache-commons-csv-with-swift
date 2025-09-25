# Using Apache Commons CSV in Swift


## Create CommonsCsv project

mkdir CommonsCsv
cd CommonsCsv
swift package init --name CommonsCsv --type executable

## Add CommonsCsv Module and swift-java.config

mkdir -p Sources/CommonsCsv
<!-- touch Sources/CommonsCsv/Csv.swift -->
touch Sources/CommonsCsv/swift-java.config

## Add dependencies

```sh
swift package add-dependency https://github.com/swiftlang/swift-java --branch main
```


### Update Package.swift
```swift
import CompilerPluginSupport
import PackageDescription

import class Foundation.FileManager
import class Foundation.ProcessInfo

// Note: the JAVA_HOME environment variable must be set to point to where
// Java is installed, e.g.,
//   Library/Java/JavaVirtualMachines/openjdk-21.jdk/Contents/Home.
func findJavaHome() -> String {
  if let home = ProcessInfo.processInfo.environment["JAVA_HOME"] {
    return home
  }

  // This is a workaround for envs (some IDEs) which have trouble with
  // picking up env variables during the build process
  let path = "\(FileManager.default.homeDirectoryForCurrentUser.path()).java_home"
  if let home = try? String(contentsOfFile: path, encoding: .utf8) {
    if let lastChar = home.last, lastChar.isNewline {
      return String(home.dropLast())
    }

    return home
  }

  fatalError("Please set the JAVA_HOME environment variable to point to where Java is installed.")
}
let javaHome = findJavaHome()

let javaIncludePath = "\(javaHome)/include"
#if os(Linux)
  let javaPlatformIncludePath = "\(javaIncludePath)/linux"
#elseif os(macOS)
  let javaPlatformIncludePath = "\(javaIncludePath)/darwin"
#else
  // TODO: Handle windows as well
  #error("Currently only macOS and Linux platforms are supported, this may change in the future.")
#endif


let package = Package(
    name: "CommonsCsv",
    platforms: [.macOS(.v15)],
    products: [
        .executable(name: "CommonsCsv", targets: ["CommonsCsv"])
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-java", branch: "main")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "CommonsCsv",
            dependencies: [
              .product(name: "SwiftJava", package: "swift-java"),
              .product(name: "JavaUtilFunction", package: "swift-java"),
              .product(name: "JavaUtil", package: "swift-java"),
              .product(name: "JavaIO", package: "swift-java"),
              .product(name: "JavaNet", package: "swift-java"),
            ],
            exclude: ["swift-java.config"],
            swiftSettings: [
                .unsafeFlags(["-I\(javaIncludePath)", "-I\(javaPlatformIncludePath)"]),
                .swiftLanguageMode(.v5),
            ],
            plugins: [
                .plugin(name: "SwiftJavaPlugin", package: "swift-java")
            ]
        )
    ]
)
```

### Update swift-java.config
```json
{
  "classes" : {
    "org.apache.commons.io.FilenameUtils" : "FilenameUtils",
    "org.apache.commons.io.IOCase" : "IOCase",
    "org.apache.commons.csv.CSVFormat" : "CSVFormat",
    "org.apache.commons.csv.CSVParser" : "CSVParser",
    "org.apache.commons.csv.CSVRecord" : "CSVRecord"
  },
  "dependencies" : [
    "org.apache.commons:commons-csv:1.12.0"
  ]
}
```

## Adding Gradle to the party
add build.gradle either 

`touch build.gradle`
or
`touch build.gradle.kts`

add gradle with 
`gradle wrapper`





## Use SwiftJava Swift packge plugin to **resolve** to resolve the jar to Swift files

Disabling the sandbox

`swift run --disable-sandbox`

Resolve
```sh
swift run swift-java resolve \
  Sources/CommonsCsv/swift-java.config \
  --swift-module CommonsCSV \
  --output-directory .build/plugins/outputs/commonscsv/CommonsCsv/destination/SwiftJavaPlugin/
```


Find all the generate files here at .build/plugins/outputs/commonscsv/CommonsCsv/destination/SwiftJavaPlugin/generated

## Get some data.
Go to https://cdn.wsform.com/wp-content/uploads/2020/06/size.csv


copy size.csv to Resources
`mkdir Resources && touch Resources/size.csv`


## Use Apache Commons CSV in Swift
```swift
// Import our packages 

import Foundation
import SwiftJava
import JavaIO
import SwiftJavaConfigurationShared

@main
struct CommonsCsv {
    static func main() {
        do {
            let swiftJavaClasspath = findSwiftJavaClasspaths()  // scans for .classpath files

            // 1) Start a JVM with appropriate classpath
            let jvm = try JavaVirtualMachine.shared(classpath: swiftJavaClasspath)

            // 2) Set up for using static method
            let CSVFormatClass = try JavaClass<CSVFormat>()
            // 3) Read file as String in Swift
            let csv = try String(contentsOfFile: "Resources/size.csv", encoding: .utf8)
            // 4) StringReader from JavaIO
            let reader = StringReader(csv)
            // 5) Parsing CSV string content
            for record in try CSVFormatClass.RFC4180.parse(reader)!.getRecords()! {
                // 6) Congrats
                print(record.values())
            }
        } catch {
            print("Error: \(error)")
        }
    }
}
``` 

### Now try it with 
```sh
swift run 
# if you have any trouble use 
swift package clean && swift run --disable-sandbox

# Profit
[”Size”, “Abbreviated Size”]
[”Extra Small”, “XS”]
[”Small”, “S”]
[”Medium”, “M”]
[”Large”, “L”]
[”Extra Large”, “XL”]
```
