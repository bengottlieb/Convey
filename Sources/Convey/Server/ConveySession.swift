//
//  File.swift
//  
//
//  Created by Ben Gottlieb on 10/16/23.
//

import Foundation

class ConveySession: NSObject {
	var session: URLSession!
	
	init(task: ServerTask) {
		super.init()

		let config = task.server.configuration
		config.allowsCellularAccess = true
		config.allowsConstrainedNetworkAccess = true

		session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
	}
	
	func data(for url: URL) async throws -> ServerReturned {
		try await data(for: URLRequest(url: url))
	}
	
	func data(for request: URLRequest) async throws -> ServerReturned {
		try await data(from: request)
	}
}

extension ConveySession: URLSessionDelegate {
	public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
		if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
			if let serverTrust = challenge.protectionSpace.serverTrust {
				let credential = URLCredential(trust: serverTrust)
				completionHandler(URLSession.AuthChallengeDisposition.useCredential, credential)
				return
			}
		}
		completionHandler(.useCredential, challenge.proposedCredential)
	}
}


