//
//  StorageContext.swift
//  DataLayer
//
//  Created by Nuno Grilo on 20/10/2018.
//
import Foundation


/**
 * Provides an high-level API for doing persistence operations in context.
 */

// MARK: - Storage Contexts
/// Full-featured storage context.
//sourcery: AutoMockable
protocol StorageContext: ReadableStorageContext, WritableStorageContext/*, CommonStorageContextOperations*/, StorageContextObserver {
}

protocol HasStorageContext {
    var storageContext: StorageContext { get }
}

//sourcery: AutoMockable
/// Read operations, on context.
protocol ReadableStorageContext {
//    /// Asynchronously load an object with the specified ID.
//    func loadObject(withId id: AnyObject, completion: @escaping ((Storable?) -> ()))
//    
//    /// Synchronously load an object with the specified ID.
//    func loadObject(withId id: AnyObject) -> Storable?
    
    /// Synchronously load the first object that are conformed to the `Storable` protocol (uses returnsFaults = true).
    func loadFirstObject<T>(_ storing: Storing<T>, filtering: Filtering<T>?, sorting: Sorting<T>?) -> T?
    
    /// Asynchronously return a list of objects that are conformed to the `Storable` protocol (uses returnsFaults = true)
    func fetch<T>(_ storing: Storing<T>, filtering: Filtering<T>?, sorting: Sorting<T>?, completion: @escaping (([T]) -> ()))
    
    /// Synchronously return a list of objects that are conformed to the `Storable` protocol
    func fetch<T>(_ storing: Storing<T>, filtering: Filtering<T>?, sorting: Sorting<T>?, propertiesToFetch: [PropertyProtocol]?, returnsFaults: Bool) -> [T]
    
    /// Perform an task in context, optionally waiting to complete.
    func performInContext(block: @escaping () -> (), waitUntilFinished: Bool)
    
    /// Perform a task in context, without waiting for the task to finish.
    func performInContext(block: @escaping () -> ())
    
    /// Synchronously return the count of matching objects
    func count<T>(_ storing: Storing<T>, filtering: Filtering<T>?) -> Int
}

extension ReadableStorageContext {
    func loadFirstObject<T>(_ storing: Storing<T>, filtering: Filtering<T>? = nil, sorting: Sorting<T>? = nil) -> T? {
        return loadFirstObject(storing, filtering: filtering, sorting: sorting)
    }
    
    /// Asynchronously return first object matching conditions.
    func loadFirstObject<T>(_ storing: Storing<T>, filtering: Filtering<T>? = nil, sorting: Sorting<T>? = nil, completion: @escaping ((T?) -> ())) {
        fetch(storing, filtering: filtering, sorting: sorting) { (list) in
            completion(list.first)
        }
    }
    
    func fetch<T>(_ storing: Storing<T>, filtering: Filtering<T>? = nil, sorting: Sorting<T>? = nil, propertiesToFetch: [PropertyProtocol]? = nil, returnsFaults: Bool = true) -> [T] {
        return fetch(storing, filtering: filtering, sorting: sorting, propertiesToFetch: propertiesToFetch, returnsFaults: returnsFaults)
    }
    
    func performInContext(block: @escaping () -> ()) {
        performInContext(block: block, waitUntilFinished: false)
    }
    
    func count<T>(_ storing: Storing<T>, filtering: Filtering<T>? = nil) -> Int {
        return count(storing, filtering: filtering)
    }
}

//sourcery: AutoMockable
/// Write operations, on context.
protocol WritableStorageContext {
    /// Create a new object with default values that conforms to `Storable` protocol.
    func create<T>(_ storing: Storing<T>) -> T
    
    /// Save context
    func saveContext() throws
    
    /// Save context and its parent
    func saveContextChain(completion: @escaping ()->() )
    
    /// Load and update multiple objects that conform to the `Storable` protocol.
    func updateAll<T>(_ storing: Storing<T>, filtering: Filtering<T>?, completion: @escaping ((T) -> ()))
    
    /// Delete an object that is conformed to the `Storable` protocol
    func delete(_ object: Storable)
    
    /// Delete all objects that are conformed to the `Storable` protocol
    func deleteAll<T>(_ storing: Storing<T>)
    
    /// Delete objects with the specified entity name matching predicate.
    func delete(_ entityName: String, matching: NSPredicate) -> Int
}


// MARK: - Storing
/// Query options.
struct Storing<T> {
    var type: T.Type {
        return T.self
    }
    var entityName: String
    
    var localPrimaryProperty: PropertyProtocol?
    var remotePrimaryProperty: PropertyProtocol?
    var isDeletedProperty: PropertyProtocol
    var lastModifiedProperty: PropertyProtocol?
    var updateableProperties: [PropertyProtocol]
    
    init(entityName: String, localPrimaryProperty: PropertyProtocol? = defaultLocalPrimaryProperty(), remotePrimaryProperty: PropertyProtocol? = defaultRemotePrimaryProperty(), isDeletedProperty: PropertyProtocol = defaultIsDeletedProperty(), lastModifiedProperty: PropertyProtocol? = defaultLastModifiedProperty(), updateableProperties: [PropertyProtocol]) {
        self.entityName = entityName
        self.localPrimaryProperty = localPrimaryProperty
        self.remotePrimaryProperty = remotePrimaryProperty
        self.isDeletedProperty = isDeletedProperty
        self.lastModifiedProperty = lastModifiedProperty
        self.updateableProperties = updateableProperties
    }
}


// MARK: - Filtering
/// Filtering options.
struct Filtering<T> {
    let filter: () -> NSPredicate
}

// Evaluation
extension Filtering {
    func evaluate(with element: T) -> Bool {
        return filter().evaluate(with: element)
    }
}

// Compound operations
extension Filtering {
    enum CompoundOperation {
        case and
        case or
    }
    
    static func compoundFilters<T>(_ filters: [Filtering<T>], operation: CompoundOperation = .and) -> Filtering<T> {
        return Filtering<T> {
            switch operation {
            case .and:
                return NSCompoundPredicate(andPredicateWithSubpredicates: filters.map{ $0.filter() } )
            case .or:
                return NSCompoundPredicate(orPredicateWithSubpredicates: filters.map{ $0.filter() } )
            }
        }
    }
}


// MARK: - Sorting
struct Sorting<T> {
    let sortDescriptor: () -> SortingDescriptor
}

struct SortingDescriptor {
    var key: String
    var ascending: Bool = true
}


// MARK: - EntityName
struct EntityName {}


// MARK: - Property
protocol PropertyProtocol {
    var key: String { get }
}

struct Property<T, U>: PropertyProtocol {
    let key: String
}


//// MARK: - Common context operations
////sourcery: AutoMockable
///// Common operations on storage context
//protocol CommonStorageContextOperations {
//
//    // MARK: Private Document
//
//    func localPrivateDocumentsCount(roomID: String) -> Int
//
//    func createPrivateDocument(name: String?, mimeType: String, revision: RevisionProtocol, room: RoomProtocol, labels: [PrivateDocumentLabelProtocol]?) -> PrivateDocumentProtocol
//
//    // MARK: Private Document Label
//
//    func createPrivateDocumentLabel(name: String, room: RoomProtocol) -> PrivateDocumentLabelProtocol
//
//    // MARK: Revision
//
//    func createFirstRevision() -> RevisionProtocol
//
//    // MARK: User
//
//    func myUser(email: String?) -> UserProtocol?
//
//    func myUserRemoteID(email: String?) -> String?
//
//    // MARK: Member
//
//    func myMember(email: String?, roomID: String?) -> MemberProtocol?
//
//    // MARK: Comment
//    func createComment(thread: CommentThreadProtocol, member: MemberProtocol) -> CommentProtocol
//
//    // MARK: Comment Thread
//
//    func createCommentThread(topic: TopicProtocol, roomID: String) -> CommentThreadProtocol
//
//    func createCommentThread(topicDocument: TopicDocumentProtocol, documentPage: Int, roomID: String) -> CommentThreadProtocol
//
//    // MARK: Hint
//
//    func createHint(id: NSNumber, alreadyShown: Bool) -> HintProtocol
//
//    // MARK: User State
//
//    func findAllNonExpiredUserStates<T: UserStateType>(type: T, value: String?, returnsFaults: Bool) -> [UserStateProtocol]
//
//}


// MARK: - Observing
//sourcery: AutoMockable
/// Observe operations on storage context.
protocol StorageContextObserver {
    func addObjectsObserver<T>(type: T.Type, observationType: StorageContextObservationType, callback: @escaping ([T], [T], [T]) -> Void) -> Any
    func removeObjectsObserver(_ observer: Any, observationType: StorageContextObservationType)
}

extension StorageContextObserver {
    func addObjectsObserver<T>(type: T.Type, callback: @escaping ([T], [T], [T]) -> Void) -> Any {
        return addObjectsObserver(type: type, observationType: StorageContextObservationType.change, callback: callback)
    }
    
    func removeObjectsObserver(_ observer: Any) {
        removeObjectsObserver(observer, observationType: StorageContextObservationType.change)
    }
}

enum StorageContextObservationType {
    case change
    case save
}
