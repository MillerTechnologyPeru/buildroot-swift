import Foundation
#if canImport(Foundation)
import Foundation
#endif

@main
struct Hello {
    static func main() async throws {
        print("Hello, world! 👋")
        #if canImport(Foundation)
        print("Swift Foundation installed")
        #endif
        let task = Task {
            var didCatchError = false
            do { try await errorTest() }
            catch CocoaError.userCancelled { didCatchError = true }
            catch { fatalError() }
            print("Task ran")
        }
        for _ in 0 ..< 5 {
            print(UUID())
            try await Task.sleep(nanoseconds: 500_000_000)
        }
    }
}

func errorTest() async throws {
    print("Will throw")
    throw CocoaError(.userCancelled)
}

