# Switching between Core Data and Realm implementations:
    
Just make sure to include in the build, **one and only one** of the files listed below:
    - Persistence/Persistence (Storable object & context)/**Core Data**/ `CoreData+Extensions`
    - Persistence/Persistence (Storable object & context)/**Realm**/ `Realm+Extensions`