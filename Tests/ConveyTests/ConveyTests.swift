import XCTest
@testable import Convey


@available(macOS 12.1, *)
final class ConveyTests: XCTestCase {
	class override func setUp() {
		Server.setupDefault()
	}
    func testGET() async throws {
		 let data: Data = try await SimpleGETTask(url: URL(string: "https://apple.com")!).send()
		 XCTAssert(data.isNotEmpty, "Failed to GET data")
    }
	
	func testPOST() async throws {
		let payload = "Hello, Test!"
		let data: Data = try await SimplePOSTTask(url: URL(string: "https://reqbin.com/echo/post/json")!, payload: payload).send()
		let result = try JSONDecoder().decode(SimpleResponse.self, from: data)
		XCTAssert(result.success == "true", "Failed to POST data")
	}

    static var allTests = [
		("testGet", testGET),
		("testPost", testPOST),
    ]
}

struct SimpleResponse: Codable {
	let success: String
}
