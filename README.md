# Geonome

### Description

Hi, my name Christian Stevanus and this is Geonome, a mini app that I worked on for about a week as a take home technical test from Setel.
Genome is an application that will detect if a device is located inside of a geofence area.
The application will send notification or update status if the device is inside or outside the geofence area, 
that's why in this app it's called geotification, because it's sending notification :)

### Requirements

Xcode 11

### Environment

iOS 13.7+

### Configuration

1. The `Geonome` target should be used for running the project.

2. You can test the detection feature on the simulator with the help of dummy data
<img width="227" alt="Dummy data" src="https://user-images.githubusercontent.com/34307518/101279952-a5eb2400-37f8-11eb-83bc-9b8f09096944.png">

3. First of all you need to add or create geofance area using "+" button on the trailing of navigation bar
<img width="266" alt="Screen Shot 2020-12-06 at 22 00 57" src="https://user-images.githubusercontent.com/34307518/101283703-a8f10f00-380e-11eb-939b-f63df242bc20.png">

4. To begin simulating the locations in the GPX file, build and run the project. When the app launches the main view controller, go back to Xcode, select the Location icon in the Debug bar and choose SimulatedLocations
<img width="489" alt="simulated" src="https://user-images.githubusercontent.com/34307518/101279955-aaafd800-37f8-11eb-9f5a-b24ac664d9f6.png">


### Application overview
Apps             |  Description
:-------------------------:|:-------------------------:
<img width="30%" alt="1  start location" src="https://user-images.githubusercontent.com/34307518/101170758-778f0c80-3671-11eb-80fb-3f54060f4393.png">   |  Give permission to the app to be able to track your location
<img width="30%" alt="2  define area" src="https://user-images.githubusercontent.com/34307518/101170753-752cb280-3671-11eb-8f09-6257278ce72c.png">   |  Add the desired geotification area. input required data, including the area name and radius as desired
<img width="30%" alt="3  Success add geo" src="https://user-images.githubusercontent.com/34307518/101170756-765ddf80-3671-11eb-9233-466dc4344bde.png">   |  When successful, the application will render a circle overlay on the map view, with the radius according to what was previously input
<img width="30%" alt="callout" src="https://user-images.githubusercontent.com/34307518/101177019-e5d7cd00-3679-11eb-807c-6b1fe6c10058.png">  |  Tap annotation to see a callout that contains a description including the area name and radius. You can also clear the geotification area by tapping the "X" icon on the callout you are currently viewing
<img width="30%" alt="4  outside area" src="https://user-images.githubusercontent.com/34307518/101170740-7362ef00-3671-11eb-8488-6fd37bd51d2a.png">  |  The application will detect if you are outside the geotification area. detection status can be seen in the title of this page (Nav Bar Title)
<img width="30%" alt="5  inside area" src="https://user-images.githubusercontent.com/34307518/101170747-74941c00-3671-11eb-80f2-e1177c56b6dc.png">  |  Vice versa, the status on the title of this page will change to "inside ..." when you are in the geotification area
<img width="30%" alt="6  notification" src="https://user-images.githubusercontent.com/34307518/101170718-6cd47780-3671-11eb-9db7-ad6479ca3eb1.png">  |  By using a local notification, the application will send a status notification, when the application is in the background


## Contact

[chris.stev30@gmail.com]
