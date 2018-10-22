import CoreData

class Object: NSManagedObject {
    @NSManaged var users: Set<User>
}

class User: NSManagedObject {
    @NSManaged var name: String
}

protocol List {
    var value: NSArray { get }
}

protocol ObjectProtocol {
    var users: List { get }
}

extension Set: List {
    var value: NSArray {
        return NSArray()
    }
}

extension Object: ObjectProtocol {
    
}

let object: ObjectProtocol = Object()
let first = object.users.value

