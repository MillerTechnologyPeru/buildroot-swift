#if canImport(Foundation)
import Foundation
#endif
import CxxDemo
import CxxStdlib

@main
struct Hello {
    static func main() async throws {
        print("Hello, world! 👋")
        #if canImport(Foundation)
        print("Swift Foundation installed")
        #endif
        // C++ interop
        let sum = demo.add(40, 2)
        precondition(sum == 42)
        print("C++ add(40, 2) = \(sum)")
        let name: std.string = "Swift"
        print(String(demo.greeting(name)))
        let task = Task {
            var didCatchError = false
            do { try await errorTest() }
            catch CocoaError.userCancelled { didCatchError = true }
            catch { fatalError() }
            print("Task ran")
        }
        for _ in 0 ..< 5 {
            print(UUID())
            print(Date())
            try await Task.sleep(nanoseconds: 500_000_000)
        }
    }
}

func errorTest() async throws {
    print("Will throw")
    throw CocoaError(.userCancelled)
}
