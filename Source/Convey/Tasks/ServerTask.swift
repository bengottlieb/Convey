//
//  ServerTask.swift
//  ServerTask
//
//  Created by Ben Gottlieb on 9/11/21.
//

import Combine
import Foundation

public typealias PreviewClosure = (Data, HTTPURLResponse) -> Void

public protocol ServerTask {
	var path: String { get }
	func postprocess(data: Data, response: HTTPURLResponse)
	var httpMethod: String { get }
	var server: Server { get }
}

public protocol ParameterizedTask: ServerTask {
	var parameters: [String: String]? { get }
}

public protocol FileBackedTask: ServerTask {
	var fileURL: URL? { get }
}

public protocol CustomURLTask: ServerTask {
	var customURL: URL? { get }
}

public protocol CustomURLRequestTask: ServerTask {
	var customURLRequest: AnyPublisher<URLRequest?, Error> { get }
}

public protocol DataUploadingTask: ServerTask {
	var dataToUpload: Data? { get }
}

public protocol JSONUploadingTask: DataUploadingTask {
	var jsonToUpload: [String: Any]? { get }
}

public protocol CustomJSONEncoderTask: ServerTask {
	var jsonEncoder: JSONEncoder? { get }
}

public protocol CustomHTTPMethodTask: ServerTask {
	var customHTTPMethod: String { get }
}

public protocol EchoingTask: ServerTask { }

public protocol ServerCacheableTask { }
public protocol ServerGETTask { }
public protocol ServerPUTTask { }
public protocol ServerPOSTTask { }
public protocol ServerPATCHTask{ }
public protocol ServerDELETETask { }


// the protocols below all have associated types
public protocol PayloadDownloadingTask: ServerTask {
	associatedtype DownloadPayload: Decodable
	func postprocess(payload: DownloadPayload)
}

public protocol PayloadUploadingTask: DataUploadingTask {
	associatedtype UploadPayload: Encodable
	var uploadPayload: UploadPayload? { get }
}


