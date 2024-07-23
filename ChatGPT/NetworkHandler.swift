//
//  NetworkHandler.swift
//  ChatGPT
//
//  Created by Enrique Ricalde on 7/23/24.
//

import Combine
import Foundation

let key = ""

struct Message: Codable {
    var content: String
    var role: String

    enum CodingKeys: String, CodingKey {
        case content
        case role
    }
}

struct Response: Codable {
    struct Choices: Codable {
        var message: Message
        var index: Int32
        var finishReason: String

        enum CodingKeys: String, CodingKey {
            case message
            case index
            case finishReason = "finish_reason"
        }
    }

    struct Usage: Codable {
        var completionTokens: Int32
        var promptTokens: Int32
        var totalTokens: Int32

        enum CodingKeys: String, CodingKey {
            case completionTokens = "completion_tokens"
            case promptTokens = "prompt_tokens"
            case totalTokens = "total_tokens"
        }
    }

    struct GPTError: Codable {
        var message: String
        var type: String
        var code: String

        enum CodingKeys: String, CodingKey {
            case message
            case type
            case code
        }
    }

    var choices: [Choices]?
    var created: Int32?
    var id: String?
    var model: String?
    var object: String?
    var usage: Usage?
    var error: GPTError?

    enum CodingKeys: String, CodingKey {
        case choices
        case created
        case id
        case model
        case object
        case usage
        case error
    }
}

struct Request: Codable {
    var model: String
    var messages: [Message]

    enum CodingKeys: String, CodingKey {
        case model
        case messages
    }

    init(prompt: String) {
        model =  "gpt-4o-mini"
        messages = [
            .init(content: prompt, role: "user")
        ]
    }
}

struct NetworkHandler {
    enum NetworkError: Error {
        case networkError
        case parseError
    }
    func send(prompt: String) throws -> AnyPublisher<Response, NetworkError> {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "Authorization" : "Bearer \(key)"
        ]
        request.httpBody = try JSONEncoder().encode(Request(prompt: prompt))
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .mapError({ networkError in
                print(networkError)
                return NetworkError.networkError
            })
            .map {
                return $0.data
            }
            .decode(type: Response.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .mapError({ parsingError in
                print(parsingError)
                return NetworkError.parseError
            })
            .eraseToAnyPublisher()
    }
}
