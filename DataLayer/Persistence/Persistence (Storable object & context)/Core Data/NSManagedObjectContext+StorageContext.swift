//
//  NSManagedObjectContext+StorageContext.swift
//  DataLayer
//
//  Created by Nuno Grilo on 20/10/2018.
//
import Foundation
import CoreData

// MARK: - ReadableStorageContext
extension NSManagedObjectContext: ReadableStorageContext {
    
    func loadObject(withId id: AnyObject, completion: @escaping ((Storable?) -> ())) {
        guard let objectID = id as? NSManagedObjectID else {
            print("`id` is not an `NSManagedObjectID`.")
            completion(nil)
            return
        }
        perform { [weak self] in
            completion(self?.object(with: objectID) as? Storable)
        }
    }
    
    func loadObject(withId id: AnyObject) -> Storable? {
        guard let objectID = id as? NSManagedObjectID else {
            return nil
        }
        
        return object(with: objectID) as? Storable
    }
    
    func loadFirstObject<T>(_ storing: Storing<T>, filtering: Filtering<T>?, sorting: Sorting<T>?) -> T? {
        var object: T?
        performAndWait { [weak self] in
            guard let bSelf = self else { return }
            object = bSelf.fetch(storing, filtering: filtering, sorting: sorting, returnsFaults: true).first
        }
        return object
    }
    
    func fetch<T>(_ storing: Storing<T>, filtering: Filtering<T>?, sorting: Sorting<T>?, completion: @escaping (([T]) -> ())) {
        perform { [weak self] in
            guard let bSelf = self else {
                completion([])
                return
            }
            let objects = bSelf.fetch(storing, filtering: filtering, sorting: sorting, returnsFaults: true)
            completion(objects)
        }
    }
    
    func fetch<T>(_ storing: Storing<T>, filtering: Filtering<T>?, sorting: Sorting<T>?, propertiesToFetch properties: [PropertyProtocol]?, returnsFaults: Bool) -> [T] {
        let entityName = storing.entityName
        
        // build fetch request
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
        
        // filtering
        fetchRequest.predicate = filtering?.filter()
        
        // fetch only the specified properties
        if let props = properties {
            fetchRequest.propertiesToFetch = props.map { return $0.key }
        }
        
        // sorting
        if let sort = sorting?.sortDescriptor() {
            let sortDescriptor = NSSortDescriptor(key: sort.key, ascending: sort.ascending)
            fetchRequest.sortDescriptors = [sortDescriptor]
        }
        
        // returning faults
        fetchRequest.returnsObjectsAsFaults = returnsFaults
        
        // fetch
        var objects: [T] = []
        do {
            if let fetched = try self.fetch(fetchRequest) as? [T] {
                objects = fetched
            }
        } catch {
            print("Failed to retrieve objects with error: \(error)")
        }
        
        return objects
    }
    
    func performInContext(block: @escaping () -> (), waitUntilFinished: Bool) {
        if waitUntilFinished {
            performAndWait {
                block()
            }
        } else {
            perform {
                block()
            }
        }
    }
    
    func performInBackground(_ objects: [Storable?], block: @escaping ([Storable?]) -> ()) {
        // get object references (on current thread)
        let refs: [NSManagedObjectID] = objects.compactMap {
            guard let obj = $0 as? NSManagedObject else { return nil }
            return obj.objectID
        }
        
        // on a background thread...
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.perform {
                let cdObjects = refs.compactMap { self?.object(with: $0) }
                // call block with objects valid for this thread
                block(cdObjects as? [Storable] ?? [])
            }
        }
    }
    
    func count<T>(_ storing: Storing<T>, filtering: Filtering<T>?) -> Int {
        let entityName = storing.entityName
        
        // build fetch request
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
        
        // filtering
        fetchRequest.predicate = filtering?.filter()
        
        // count
        let count = try? self.count(for: fetchRequest)
        
        return count ?? 0
    }
}

// MARK: - WritableStorageContext
extension NSManagedObjectContext: WritableStorageContext {
    func create<T>(_ storing: Storing<T>) -> T {
        
        let entityName = storing.entityName
        guard let entityDescription = NSEntityDescription.entity(forEntityName: entityName, in: self) else {
            fatalError("Unable to get entity description for \(entityName)")
        }
        
        var object: T? = nil
        performAndWait {
            object = NSManagedObject(entity: entityDescription, insertInto: self) as? T
        }
        return object!
    }
    
    func saveContext() throws {
        guard hasChanges else { return }
        
        do {
            try save()
        } catch let error as NSError {
            throw error
        }
    }
    
    func saveContextChain(completion: @escaping ()->() ) {
        guard hasChanges else {
            completion()
            return
        }
        
        do {
            try save()
            
            guard let parent = parent else {
                completion()
                return
            }
            parent.perform {
                do {
                    try parent.save()
                    completion()
                } catch let error as NSError {
                    fatalError("Unable to save context chain: \(error)")
                }
            }
        } catch {
            completion()
        }
    }
    
    func updateAll<T>(_ storing: Storing<T>, filtering: Filtering<T>?, completion: @escaping ((T) -> ())) {
        performAndWait {
            let entities = fetch(storing, filtering: filtering, sorting: nil)
            for entity in entities {
                completion(entity)
            }
        }
    }
    
    func delete(_ object: Storable) {
        guard let managedObject = object as? NSManagedObject else {
            assertionFailure("`object` is not an `NSManagedObject`.")
            return
        }
        let objectId = managedObject.objectID
        performAndWait {
            let obj = self.object(with: objectId)
            delete(obj)
        }
    }
    
    func deleteAll<T>(_ storing: Storing<T>) {
        let entityName = storing.entityName
        
        performAndWait { [weak self] in
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try self?.execute(deleteRequest)
            } catch {
                print("Failed to delete all objects of entity name `\(entityName)` with error: \(error)")
            }
        }
    }
    
    func delete(_ entityName: String, matching: NSPredicate) -> Int {
        var count: Int = 0
        performAndWait { [weak self] in
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
            fetchRequest.predicate = matching
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            deleteRequest.resultType = .resultTypeObjectIDs
            
            do {
                let result = try self?.execute(deleteRequest) as? NSBatchDeleteResult
                if let managedObjectIDs = result?.result as? [NSManagedObjectID] {
                    count = managedObjectIDs.count
                }
            } catch {
                print("Failed to delete all objects of entity name `\(entityName)`, matching `\(matching.predicateFormat)` with error: \(error)")
            }
        }
        return count
    }
    
}

//// MARK: - CommonStorageContextOperations
//extension NSManagedObjectContext: CommonStorageContextOperations {
//
//    // MARK: Private Document
//
//    func localPrivateDocumentsCount(roomID: String) -> Int {
//        let privateDocuments = fetch(.privateDocument, filtering: .roomID(equalTo: roomID, isLocal: true), sorting: nil)
//        return privateDocuments.count
//    }
//
//    func createPrivateDocument(name: String?, mimeType: String, revision: RevisionProtocol, room: RoomProtocol, labels: [PrivateDocumentLabelProtocol]?) -> PrivateDocumentProtocol {
//        let privateDocument = create(.privateDocument)
//        privateDocument.revision = revision
//        privateDocument.created = Date()
//        privateDocument.modified = privateDocument.created
//        privateDocument.remoteID = NSUUID().uuidString
//        privateDocument.room_id = room.remoteID
//        privateDocument.room = room
//        privateDocument.name = name
//        privateDocument.mime_type = mimeType
//        privateDocument.uploaded_by = ""
//        privateDocument.isLocalObject = true
//
//        if let labels = labels, labels.count > 0 {
//            privateDocument.labels = labels
//            privateDocument.isLocalModifiedObject = true
//        }
//
//        return privateDocument
//    }
//
//    // MARK: Private Document Label
//
//    func createPrivateDocumentLabel(name: String, room: RoomProtocol) -> PrivateDocumentLabelProtocol {
//        let label = create(.privateDocumentLabel)
//        label.name = name
//        label.created = Date()
//        label.modified = label.created
//        label.room_id = room.remoteID
//        label.remoteID = NSUUID().uuidString
//        label.isLocalObject = true
//        label.room = room
//        return label
//    }
//
//    // MARK: Revision
//
//    func createFirstRevision() -> RevisionProtocol {
//        let revision = create(.revision)
//        revision.created = Date()
//        revision.remoteID = NSUUID().uuidString
//        return revision
//    }
//
//    // MARK: User
//
//    func myUser(email: String?) -> UserProtocol? {
//        guard let email = email else { return nil }
//
//        let users = fetch(.user, filtering: .email(equalTo: email), sorting: nil)
//        return users.first
//    }
//
//    func myUserRemoteID(email: String?) -> String? {
//        return myUser(email: email)?.remoteID
//    }
//
//    // MARK: Member
//
//    func myMember(email: String?, roomID: String?) -> MemberProtocol? {
//        guard
//            let email = email,
//            let roomID = roomID else { return nil }
//
//        let members = fetch(.member, filtering: .emailAndRoom(email: email, roomID: roomID), sorting: nil)
//        return members.first
//    }
//
//    // MARK: Comment
//    func createComment(thread: CommentThreadProtocol, member: MemberProtocol) -> CommentProtocol {
//        let newComment = create(.comment)
//        newComment.thread = thread
//        newComment.created = nil
//        newComment.localText = nil
//        newComment.text = nil
//        newComment.unread = false
//        newComment.syncStateEnum = .new
//        newComment.remoteID = UUID().uuidString
//        newComment.member = member
//
//        return newComment
//    }
//
//    // MARK: Comment Thread
//
//    func createCommentThread(topic: TopicProtocol, roomID: String) -> CommentThreadProtocol {
//        let newThread = create(.commentThread)
//        newThread.created = nil
//        newThread.remoteID = UUID().uuidString
//        newThread.topic = topic
//        newThread.room_id = roomID
//
//        return newThread
//    }
//
//    func createCommentThread(topicDocument: TopicDocumentProtocol, documentPage: Int, roomID: String) -> CommentThreadProtocol {
//        let newThread = create(.commentThread)
//        newThread.created = nil
//        newThread.remoteID = UUID().uuidString
//        newThread.document = topicDocument
//        newThread.meeting_document_page = NSNumber(value: documentPage)
//        newThread.room_id = roomID
//
//        return newThread
//    }
//
//    // MARK: Hint
//
//    func createHint(id: NSNumber, alreadyShown: Bool) -> HintProtocol {
//        let hint = create(.hint)
//        hint.id = id
//        hint.has_been_shown = alreadyShown as NSNumber
//
//        return hint
//    }
//
//    // MARK: User State
//
//    func findAllNonExpiredUserStates<T: UserStateType>(type: T, value: String?, returnsFaults: Bool) -> [UserStateProtocol] {
//        let filtering = Filtering<UserStateProtocol>.userStateFiltering(names: [type.userStateName],
//                                                                        expiry: Date(),
//                                                                        value: value)
//        let userStates = fetch(.userState, filtering: filtering, sorting: nil, returnsFaults: returnsFaults)
//        return userStates
//    }
//
//}

extension NSManagedObjectContext: StorageContextObserver {
    
    
    func addObjectsObserver<T>(type: T.Type, observationType: StorageContextObservationType, callback: @escaping ([T], [T], [T]) -> Void) -> Any {
        return addObserver(type: type, forName: notificationName(for: observationType), callback: callback)
    }
    
    func removeObjectsObserver(_ observer: Any, observationType: StorageContextObservationType) {
        NotificationCenter.default.removeObserver(observer, name: notificationName(for: observationType), object: nil)
    }
    
    private func addObserver<T>(type: T.Type, forName notificationName: NSNotification.Name, callback: @escaping (_ insertedObjects: [T], _ updatedObjects: [T], _ deletedObjects: [T]) -> Void) -> Any {
        return NotificationCenter.default.addObserver(forName: notificationName,
                                                      object: self,
                                                      queue: nil) { (notification) in
                                                        var filteredInsertedObjects = [T]()
                                                        if let insertedObjects = notification.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject> {
                                                            for object in insertedObjects {
                                                                if let matchingItem = object as? T {
                                                                    filteredInsertedObjects.append(matchingItem)
                                                                }
                                                            }
                                                        }
                                                        
                                                        var filteredUpdatedObjects = [T]()
                                                        if let updatedObjects = notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject> {
                                                            for object in updatedObjects {
                                                                if let matchingItem = object as? T {
                                                                    filteredUpdatedObjects.append(matchingItem)
                                                                }
                                                            }
                                                        }
                                                        
                                                        var filteredDeletedObjects = [T]()
                                                        if let deletedObjects = notification.userInfo?[NSDeletedObjectsKey] as? Set<NSManagedObject> {
                                                            for object in deletedObjects {
                                                                if let matchingItem = object as? T {
                                                                    filteredDeletedObjects.append(matchingItem)
                                                                }
                                                            }
                                                        }
                                                        
                                                        if filteredInsertedObjects.count > 0 ||
                                                            filteredUpdatedObjects.count > 0 ||
                                                            filteredDeletedObjects.count > 0 {
                                                            callback(filteredInsertedObjects, filteredUpdatedObjects, filteredDeletedObjects)
                                                        }
        }
    }
    
    private func notificationName(for observationType: StorageContextObservationType) -> NSNotification.Name {
        let notificationName: NSNotification.Name
        switch observationType {
        case .change:
            notificationName = .NSManagedObjectContextObjectsDidChange
        case .save:
            notificationName = .NSManagedObjectContextDidSave
        }
        return notificationName
    }
}

//extension NSManagedObjectContext: SyncStorageContext { }
extension NSManagedObjectContext: StorageContext { }



//import Foundation
//import CoreData
//
//extension NSManagedObjectContext: ReadableStorageContext {
//
//    func loadObject(withId id: AnyObject, completion: @escaping ((Storable?) -> ())) {
//        guard let objectID = id as? NSManagedObjectID else {
//            print("`id` is not an `NSManagedObjectID`.")
//            completion(nil)
//            return
//        }
//        perform { [weak self] in
//            completion(self?.object(with: objectID) as? Storable)
//        }
//    }
//
//    func loadObject(withId id: AnyObject) -> Storable? {
//        guard let objectID = id as? NSManagedObjectID else {
//            return nil
//        }
//
//        return object(with: objectID) as? Storable
//    }
//
//    func fetch<T>(_ storing: Storing<T>, filtering: Filtering<T>?, sorting: Sorting<T>?, completion: @escaping (([T]) -> ())) {
//        perform { [weak self] in
//            guard let bSelf = self else {
//                completion([])
//                return
//            }
//            let objects = bSelf.fetch(storing, filtering: filtering, sorting: sorting)
//            completion(objects)
//        }
//    }
//
//    func fetch<T>(_ storing: Storing<T>, filtering: Filtering<T>?, sorting: Sorting<T>?) -> [T] {
//        let entityName = storing.entityName
//
//        // build fetch request
//        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
//
//        // filtering
//        fetchRequest.predicate = filtering?.filter()
//
//        // sorting
//        if let sort = sorting?.sortDescriptor() {
//            let sortDescriptor = NSSortDescriptor(key: sort.key, ascending: sort.ascending)
//            fetchRequest.sortDescriptors = [sortDescriptor]
//        }
//
//        // fetch
//        var objects: [T] = []
//        do {
//            if let fetched = try self.fetch(fetchRequest) as? [T] {
//                objects = fetched
//            }
//        } catch {
//            print("Failed to retrieve objects with error: \(error)")
//        }
//
//        return objects
//    }
//}
//
//extension NSManagedObjectContext: WritableStorageContext {
//    func create<T>(_ storing: Storing<T>, completion: @escaping ((T) -> Void)) throws {
//
//        let entityName = storing.entityName
//
//        guard let entityDescription = NSEntityDescription.entity(forEntityName: entityName, in: self) else {
//            throw DataLayerError.persistence("Unable to get entity description for \(entityName)")
//        }
//
//        perform {
//            let newObject = NSManagedObject(entity: entityDescription, insertInto: self) as! T
//            completion(newObject)
//        }
//    }
//
//    func saveContext() throws {
//        performAndWait {
//            if hasChanges {
//                try? save()
//            }
//        }
//    }
//
//    func update(block: @escaping () -> ()) throws {
//        perform {
//            block()
//        }
//    }
//
//    func delete(_ object: Storable) throws {
//        guard let managedObject = object as? NSManagedObject else {
//            throw DataLayerError.persistence("`object` is not an `NSManagedObject`.")
//        }
//        let objectId = managedObject.objectID
//        performAndWait {
//            let obj = self.object(with: objectId)
//            delete(obj)
//        }
//    }
//
//    func deleteAll<T>(_ storing: Storing<T>) throws {
//        let entityName = storing.entityName
//
//        performAndWait { [weak self] in
//            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
//            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
//
//            do {
//                try self?.execute(deleteRequest)
//            } catch {
//                print("Failed to delete all objects of entity name `\(entityName)` with error: \(error)")
//            }
//        }
//    }
//
//}
