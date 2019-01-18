//
//  Realm+StorageContext.swift
//  DataLayer
//
//  Created by Nuno Grilo on 18/01/2019.
//

import Foundation
import RealmSwift

extension Realm: ReadableStorageContext {
    
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
    
    func loadFirstObject<T>(_ storing: Storing<T>, filtering: Filtering<T>?, sorting: Sorting<T>?) -> T? {
        return fetch(storing, filtering: filtering, sorting: sorting, returnsFaults: true).first
    }
    
    func fetch<T>(_ storing: Storing<T>, filtering: Filtering<T>?, sorting: Sorting<T>?, completion: @escaping (([T]) -> ())) {
        let objects =  fetch(storing, filtering: filtering, sorting: sorting, returnsFaults: true)
        completion(objects)
    }
    
    func fetch<T>(_ storing: Storing<T>, filtering: Filtering<T>?, sorting: Sorting<T>?, propertiesToFetch properties: [PropertyProtocol]?, returnsFaults: Bool) -> [T] {
        guard let TType = T.self as? Object.Type else { return [] }
        var results = objects(TType)
        
        // filtering
        if let predicate = filtering?.filter() {
            results = results.filter(predicate)
        }
        
        // `propertiesToFetch`: ignored on Realm
        
        // sorting
        if let sort = sorting?.sortDescriptor() {
            results = results.sorted(byKeyPath: sort.key, ascending: sort.ascending)
        }
        
        // `returnsFaults`: ignored on Realm
        
        return Array(results) as? [T] ?? []
    }
    
    func performInContext(block: @escaping () -> (), waitUntilFinished: Bool) {
        // TODO: check if we can do this async also (for `waitUntilFinished`)
        do {
            try write {
                block()
            }
        } catch {
            #warning ("do something to catch the error")
        }
    }
    
    func count<T>(_ storing: Storing<T>, filtering: Filtering<T>?) -> Int {
        guard let TType = T.self as? Object.Type else { return 0 }
        var results = objects(TType)
        
        if let predicate = filtering?.filter() {
            results = results.filter(predicate)
        }
        
        return results.count
    }
}

// MARK: - WritableStorageContext
extension Realm: WritableStorageContext {
    func create<T>(_ storing: Storing<T>) -> T {
        guard let TObject = T.self as? Object.Type else { fatalError("Unable to create object of type \(T.self)") }
        do {
            var object: T!
            try write {
                let objectRealm = TObject.init()
                add(objectRealm)
                if let obj = objectRealm as? T {
                    object = obj
                } else {
                    fatalError("Unable to create object of type \(T.self)")
                }
            }
            return object
        } catch {
            fatalError("Unable to create object of type \(T.self)")
        }
    }
    
    func saveContext() throws {
        do {
            try commitWrite()
        } catch let error as NSError {
//            var severity: MessageSeverity = .error
//            let message = Message("Could not save Realm", severity: severity, additionalInfo: ["Error": error.description])
//            globalDependencies.messageReporter.send(message)
            throw error
        }
    }
    
    func saveContextChain(completion: @escaping ()->() ) {
       try? commitWrite()
    }
    
    func updateAll<T>(_ storing: Storing<T>, filtering: Filtering<T>?, completion: @escaping ((T) -> ())) {
        let entities = fetch(storing, filtering: filtering, sorting: nil)
        for entity in entities {
            completion(entity)
        }
    }
    
    func delete(_ object: Storable) {
        guard let managedObject = object as? Object else {
            assertionFailure("`object` is not an `NSManagedObject`.")
            return
        }
        if isInWriteTransaction == false {
            beginWrite()
        }
        delete(managedObject)
    }
    
    func deleteAll<T>(_ storing: Storing<T>) {
        if isInWriteTransaction == false {
            beginWrite()
        }
        
        if let objects = fetch(storing, filtering: nil, sorting: nil, returnsFaults: true) as? [Object] {
            delete(objects)
        }
    }
    
    func delete(_ entityName: String, matching: NSPredicate) -> Int {
        #warning ("TODO")
        return 0
//        var count: Int = 0
//        performAndWait { [weak self] in
//            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
//            fetchRequest.predicate = matching
//            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
//            deleteRequest.resultType = .resultTypeObjectIDs
//
//            do {
//                let result = try self?.execute(deleteRequest) as? NSBatchDeleteResult
//                if let managedObjectIDs = result?.result as? [NSManagedObjectID] {
//                    count = managedObjectIDs.count
//                }
//            } catch {
//                print("Failed to delete all objects of entity name `\(entityName)`, matching `\(matching.predicateFormat)` with error: \(error)")
//            }
//        }
//        return count
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

extension Realm: StorageContextObserver {
    
    
    func addObjectsObserver<T>(type: T.Type, observationType: StorageContextObservationType, callback: @escaping ([T], [T], [T]) -> Void) -> Any {
        return addObserver(type: type, forName: notificationName(for: observationType), callback: callback)
    }
    
    func removeObjectsObserver(_ observer: Any, observationType: StorageContextObservationType) {
        NotificationCenter.default.removeObserver(observer, name: notificationName(for: observationType), object: nil)
    }
    
    private func addObserver<T>(type: T.Type, forName notificationName: NSNotification.Name, callback: @escaping (_ insertedObjects: [T], _ updatedObjects: [T], _ deletedObjects: [T]) -> Void) -> Any {
        #warning ("TODO")
        return false
//        return NotificationCenter.default.addObserver(forName: notificationName,
//                                                      object: self,
//                                                      queue: nil) { (notification) in
//                                                        var filteredInsertedObjects = [T]()
//                                                        if let insertedObjects = notification.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject> {
//                                                            for object in insertedObjects {
//                                                                if let matchingItem = object as? T {
//                                                                    filteredInsertedObjects.append(matchingItem)
//                                                                }
//                                                            }
//                                                        }
//
//                                                        var filteredUpdatedObjects = [T]()
//                                                        if let updatedObjects = notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject> {
//                                                            for object in updatedObjects {
//                                                                if let matchingItem = object as? T {
//                                                                    filteredUpdatedObjects.append(matchingItem)
//                                                                }
//                                                            }
//                                                        }
//
//                                                        var filteredDeletedObjects = [T]()
//                                                        if let deletedObjects = notification.userInfo?[NSDeletedObjectsKey] as? Set<NSManagedObject> {
//                                                            for object in deletedObjects {
//                                                                if let matchingItem = object as? T {
//                                                                    filteredDeletedObjects.append(matchingItem)
//                                                                }
//                                                            }
//                                                        }
//
//                                                        if filteredInsertedObjects.count > 0 ||
//                                                            filteredUpdatedObjects.count > 0 ||
//                                                            filteredDeletedObjects.count > 0 {
//                                                            callback(filteredInsertedObjects, filteredUpdatedObjects, filteredDeletedObjects)
//                                                        }
//        }
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

//extension Realm: SyncStorageContext { }
extension Realm: StorageContext { }
