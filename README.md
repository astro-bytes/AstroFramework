# Package Deal
Submodules that contain reusable base components in different areas of a project; namely Entities, UseCases, Gateways, and UI.

### Type Erasure
 There are some components that will type erase since swift still has a problem when values need to be equatable or hashable and so on. [Reference to Stack-over Flow](https://stackoverflow.com/questions/76449655/swift-is-there-still-a-use-case-for-type-erasure-since-the-introduction-of-prim)

## Modules
- [Gateway Basics](#GatewayBasics)

## Gateway Basics
This module contains basic protocols and default implementations for a gateway layer.

### Repository
A Design pattern known as the "Repository Pattern." 
The Repository Pattern is a structural pattern that provides a way to access and manage data stored in a data store (such as a database) in a standardized manner. 
It abstracts the data access layer and provides a set of methods to interact with the underlying data.


There are two types of Repositories:
1. Read Only - Which reads data from a [DataStore](#DataStore), typically a REST API:
  - Pulls every time the repository is initialized into memory.
  - Pulls from that source at specific intervals, generally when the cache is expired. In the background before the value is needed, this is intended to decrease wait times.
  - Able to force update on command when cache is not yet expired.
2. Read and Write - Which reads/writes from/to a [DataStore](#DataStore), typically a Remote DB.
  - Does everything that the Read-Only Repository.
  - Able to subscribe to updates from source - Publishes the new current value on update. ie Remote DB value changes then repository value is changed
  - Send request to change a value in the source:
    - Failure to change value should not impede local cached values from changing and updating to the right value.
    - Success does not send more than one emitted publication of the new value out the door.

### Requirements
#### Get Data
- The data follows the Publisher/Subscriber Pattern
  - Publisher is able to be subscribed to
  - When underlying data changes a update is sent to subscribers
- The data can be in three states: Loading, Success, Failure:
  - Loading: the data has not yet been initialized from the source or is in the process of being loaded from the source
  - Success: the data is valid from the cache or straight from the source
  - Failure: the cached value is presented (given the cache is valid), and error is presented
- The data can be refreshed, when the data is refreshed the publisher emits the new current value
- Refreshing the repository can be both synchronous and asynchronous 
  - When Asynchronous: after the data is updated the current value is returned
  - When Synchronous: no value is given back and the user is expected to use the subscription to get the new current value

#### Set Data
- 

### Data Store

### Cache
