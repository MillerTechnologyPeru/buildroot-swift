#if canImport(Foundation)
import Foundation
#endif
import CxxDemo
import CxxStdlib
#if canImport(SystemPackage)
import SystemPackage
#endif
#if canImport(Crypto)
import Crypto
#endif
#if canImport(Collections)
import Collections
#endif
#if canImport(Atomics)
import Atomics
#endif
#if canImport(Numerics)
import Numerics
#endif
#if canImport(HTTPTypes)
import HTTPTypes
#endif

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
        // Installed Swift library packages
        #if canImport(SystemPackage)
        let path = FilePath("/usr/bin/swift-hello")
        print("SystemPackage FilePath: \(path)")
        #endif
        #if canImport(Crypto)
        let digest = SHA256.hash(data: Data("Swift".utf8))
        print("Crypto SHA256 byte count: \(Array(digest).count)")
        #endif
        #if canImport(Collections)
        var deque: Deque<Int> = [1, 2, 3]
        deque.prepend(0)
        print("Collections Deque: \(Array(deque))")
        #endif
        #if canImport(Atomics)
        let counter = ManagedAtomic<Int>(0)
        counter.wrappingIncrement(by: 41, ordering: .relaxed)
        counter.wrappingIncrement(ordering: .relaxed)
        print("Atomics counter: \(counter.load(ordering: .relaxed))")
        #endif
        #if canImport(Numerics)
        let z = Complex<Double>(3, 4)
        print("Numerics Complex length: \(z.length)")
        #endif
        #if canImport(HTTPTypes)
        let request = HTTPRequest(method: .get, scheme: "https", authority: "swift.org", path: "/")
        print("HTTPTypes request path: \(request.path ?? "nil")")
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
            print(Date())
            try await Task.sleep(nanoseconds: 500_000_000)
        }
    }
}

func errorTest() async throws {
    print("Will throw")
    throw CocoaError(.userCancelled)
}
