//
//  NetworkPublishers.swift
//  ConveyTest
//
//  Created by Ben Gottlieb on 5/16/22.
//

#if canImport(Combine)
import Foundation
import Combine

@available(iOS 13.0, watchOS 6.0, OSX 10.15, *)
public extension Publisher where Output == (data: Data, response: URLResponse) {
   func assumeHTTP() -> AnyPublisher<(data: Data, response: HTTPURLResponse), HTTPError> {
      tryMap { data, response in
         guard let http = response as? HTTPURLResponse else { throw HTTPError.nonHTTPResponse(response.url, data) }
         return (data, http)
      }
      .mapError { error in
         if error is HTTPError {
            return error as? HTTPError ?? HTTPError.unknownError(nil, 0, nil)
            } else if error.isOffline {
                return .offline
            } else {
               return HTTPError.networkError(nil, error)
         }
      }
      .eraseToAnyPublisher()
   }
}

@available(iOS 13.0, watchOS 6.0, OSX 10.15, *)
public extension Publisher where Output == (data: Data, response: HTTPURLResponse), Failure == HTTPError {
   func responseData() -> AnyPublisher<Data, HTTPError> {
      tryMap { data, response in
         switch response.statusCode {
         case 0...199: return data            // informational, rarely seen
         case 200...299: return data            // success, of some sort
         case 300...399: throw HTTPError.redirectError(response.url, response.statusCode, data)
         case 400...499: throw HTTPError.requestFailed(response.url, response.statusCode, data)
         case 500...599: throw HTTPError.serverError(response.url, response.statusCode, data)
         default: throw HTTPError.unknownError(response.url, response.statusCode, data)
         }
      }
      .mapError { $0 as! HTTPError }
      .eraseToAnyPublisher()
   }
}

@available(iOS 13.0, watchOS 6.0, OSX 10.15, *)
public extension Publisher where Output == Data, Failure == HTTPError {
   func decoding<Item, Coder>(type: Item.Type, decoder: Coder) -> AnyPublisher<Item, HTTPError> where Item: Decodable, Coder: TopLevelDecoder, Self.Output == Coder.Input {
      decode(type: type, decoder: decoder)
         .mapError { error in
            if error is DecodingError {
               return HTTPError.decodingError(nil, error as! DecodingError)
            } else {
               return error as? HTTPError ?? .unknownError(nil, 0, nil)         // we're already restricting errors to HTTPError
            }
         }
         .eraseToAnyPublisher()
   }
}

#endif
