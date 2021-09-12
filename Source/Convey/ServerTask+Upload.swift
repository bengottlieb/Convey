//
//  PayloadUploadingTask.swift
//  ConveyTest
//
//  Created by Ben Gottlieb on 9/11/21.
//

import Suite

public extension PayloadDownloadingTask where Self: PayloadUploadingTask {
	func upload(decoder: JSONDecoder? = nil, preview: PreviewClosure? = nil) -> AnyPublisher<DownloadPayload, HTTPError> {
		fetch(caching: .skipLocal, decoder: decoder, preview: preview)
	}
}

public extension PayloadUploadingTask {
	func uploadAndDownload(preview: PreviewClosure? = nil) -> AnyPublisher<Data, HTTPError> {
		run(caching: .skipLocal, preview: preview)
	}

	func upload(preview: PreviewClosure? = nil) -> AnyPublisher<Int, HTTPError> {
		submit(caching: .skipLocal, preview: preview)
			.map { $0.response.statusCode }
			.eraseToAnyPublisher()
	}

	var uploadData: Data? {
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