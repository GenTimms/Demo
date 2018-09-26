//
//  UsersClient.swift
//  Demo
//
//  Created by Genevieve Timms on 23/09/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import Foundation

class UsersClient: Client {

    var session: SessionProtocol = URLSession.shared
    
    func fetch(group: DispatchGroup? = nil, completion: @escaping (Result<[User]>) -> Void) {
        fetchUsers(group: group, completion: completion)
    }
    
    func fetchUsers(group: DispatchGroup?, completion: @escaping (Result<[User]>) -> Void) {
        group?.enter()
        guard let request = PostsEndpoints.users.request else {
            completion(Result.failure(RequestError.invalidRequest))
            return
        }
        
        fetchRequest(request, parse: { (data) -> [User]? in
            if let users = User.createUsers(from: data) {
                return users
            } else {
                return nil
            }
        }, completion: { result in
            completion(result)
            group?.leave()
        })
    }
}