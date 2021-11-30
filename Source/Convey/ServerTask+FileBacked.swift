//
//  ServerTask+FileBased.swift
//  
//
//  Created by Ben Gottlieb on 11/30/21.
//

import Foundation
import Suite

public extension ServerTask where Self: FileBackedTask & PayloadDownloadingTask {
	func fileCachedDownload(using decoder: JSONDecoder? = nil) throws -> DownloadPayload? {
		guard let data = fileCachedData else { return nil }
		let decoder = decoder ?? server.defaultDecoder
		return try decoder.decode(DownloadPayload.self, from: data)
	}
}

public extension ServerTask {
	var fileCachedData: Data? {
		get {
			guard let fileProvider = self as? FileBackedTask else { return nil }
			guard let file = fileProvider.fileURL else { return nil }
			
			return try? Data(contentsOf: file)
		}
		
		nonmutating set {
			guard let fileProvider = self as? FileBackedTask else { return }
			guard let file = fileProvider.fileURL else { return }
			
			if let data = newValue {
				do {
					try data.write(to: file)
				} catch {
					let message = "Failed to store backing file for \(self)"
					logg(error: error, message)
				}
			} else {
				try? FileManager.default.removeItem(at: file)
			}
		}
	}
}
