//
//  ServerTask+Extension.swift
//  ConveyTest
//
//  Created by Ben Gottlieb on 8/19/22.
//

import Foundation

public extension ServerTask {
	var server: Server { Server.serverInstance ?? Server.setupDefault() }

	func postprocess(data: Data, response: HTTPURLResponse) { }

	var url: URL {
		let nonParameterized = (self as? CustomURLTask)?.customURL ?? server.url(forTask: self)
		if let parameters = (self as? ParameterizedTask)?.parameters, !parameters.isEmpty {
			var components = URLComponents(url: nonParameterized, resolvingAgainstBaseURL: true)
			
			if let params = parameters as? [String: String] {
				components?.queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }
			} else if let params = parameters as? [URLQueryItem] {
				components?.queryItems = params
			}

			if let newURL = components?.url { return newURL }
		}

		return nonParameterized
	}

	var cachedData: Data? {
		DataCache.instance.fetchLocal(for: url)?.data
	}
}

public extension PayloadDownloadingTask {
	func postprocess(payload: DownloadPayload) { }
}

public extension JSONUploadingTask {
	var dataToUpload: Data? {
		do {
			guard let json = jsonToUpload else { return nil }
			return try JSONSerialization.data(withJSONObject: json, options: [])
		} catch {
			print("Error preparing upload: \(error)")
			return nil
		}
	}
}

public extension PayloadUploadingTask {
	var dataToUpload: Data? {
		guard let payload = uploadPayload else { return nil }
		let encoder = (self as? CustomJSONEncoderTask)?.jsonEncoder ?? server.defaultEncoder
		
		do {
			return try encoder.encode(payload)
		} catch {
			server.handle(error: error, from: self)
			return nil
		}
	}
}