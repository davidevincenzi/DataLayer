import CoreData

class Object: NSObject {
    var cd_users: Set<User> = [User()]
}

class User: NSObject {
    var name: String = "name"
}

protocol ObjectProtocol {
    var users: [User] { get }
}

extension Object: ObjectProtocol {
    var users: [User] {
        return Array(cd_users)
    }
}

let object: ObjectProtocol = Object()
let first = object.users.first
