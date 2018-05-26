//
//  MockProtocols.swift
//  AMusicFinder
//
//  Created by Kaka on 26/5/2018.
//  Copyright © 2018 Kaka. All rights reserved.
//

import Foundation

typealias DataTaskResult = (Data?, URLResponse?, Error?) -> ()

/**
 URLSessionProtocol for DI testing
 */
protocol URLSessionProtocol {
    func dataTask(with request: URLRequest, completion: @escaping DataTaskResult) -> URLSessionDataTaskProtocol
}

/**
 URLSessionDataTaskProtocol for DI testing
 */
protocol URLSessionDataTaskProtocol {
    func resume()
}

extension URLSession: URLSessionProtocol {
    func dataTask(with request: URLRequest, completion: @escaping DataTaskResult) -> URLSessionDataTaskProtocol {
        return dataTask(with: request, completionHandler: completion)
    }
}
extension URLSessionDataTask: URLSessionDataTaskProtocol { }
