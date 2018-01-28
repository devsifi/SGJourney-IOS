# SGJourney for iOS Devices

In order to build/run this project, a Config.swift file is required
You will also need an API key for the following services:
* SG DataMall API

```swift
struct Config {
    static var SGJourneyAPI = "/* URL TO SGJourney API */"
    static var DataMallAPI = (
        url: "http://datamall2.mytransport.sg",
        key: "/* DATAMALL API KEY */"
    )
    
    static var NearbyRadius : Double = /* RADIUS IN METERS */
}
```
