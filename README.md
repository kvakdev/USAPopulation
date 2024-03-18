# USAPopulation

## Architecture description
### To showcase how one can approach have very complicated navigation and scalable architecture I used a MVVM+C pattern with UIKit wrappers and SwiftUI to build views. The benefit of this approach is that navigation is a separate responsibility of the Flow object and views are complitely decoupled. 

### Note: Navigation can also be done in a simpler way using SwiftUI Navigation tools, however it brings coupling.

## Tests
### There are test targets to run unit tests and end to end tests.
### Two targets are used to illustrate how one would separate long running tests from instant unit tests. Ideally one should also add a CI scheme to run both.
### Testability is reached through dependency injection
### ViewModels are tested.
### NetworkClient is tested.
### Parsing of models is tested.
