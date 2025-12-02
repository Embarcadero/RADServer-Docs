# Chapter 14: EdgeModules - Extending RAD Server

Don't forget to [watch the video](https://youtu.be/R_6sEsLeSRI) of this chapter. 

This section contains two demos:

## EdgeModules Example
This demo showcases a GroupProject with a Server project (that runs a barebones RAD Server Instance) and an FMX Client application with a few visual controls. 

### Steps to run the application
1. Run the Server
2. Run the Client
3. Connect the Client EdgeModule pressing the button 
4. Modify the values of the visual controllers

**Examples of endpoints available through the EdgeModule**

This endpoint returns the current values of the visual form in a JSON. 

`http://localhost:8080/edgemodules/MyProcessor/processor/formValues`

This endpoint is not related to the form itself. It simply calculates the sum between the two parameters defined in the URI and returns a JSON with the calculation and some extra information. All the calculations are performed by the client application and RAD Server acts as a proxy.

`http://localhost:8080/edgemodules/MyProcessor/processor/calculate?param1=7&param2=3`

## InterBase ChangeViews
This demo shows how to integrate the InterBase technology ChangeViews with RAD Server using EdgeModules. 

### Included in the demo
- `HighScore` RAD Server instance that integrates the ChangeViews endpoints directly through a resource. This version is meant to be executed only with the RAD Server Developer or RAD Server Lite. 
- `RADServerDemo` barebones RAD Server instalation that will be used to hook the EdgeModule
- `ChangeViewsEMSThingPoint` client application with an EdgeModule that connects to `RADServerDemo`. It uses the same units as the `HighScore` RAD Server instance. 

### Steps before running
This project includes a `SUB.IB` InterBase database that needs to be specified in the `FDConnection` component in `ChangeView.DataConnection` unit. 

### Executing the demo
1. Open the `ChangeViewsDemo.groupproj` in RAD Studio
2. Run `RADServerDemo.bpl`
3. Run `ChangeViewsEMSThingPoint.exe`

### Using the Demo
The demo exposes the following key endpoints:

`highscores/changeview/activate?deviceid={id}` - Activates a ChangeView for a specific device

`highscores/changeview/query?deviceid={id}&query={querytype}` - Runs a query on the active ChangeView

Set `query=count` to just get the number of changes
Set `query=select` to get the changed records


`highscores/changeview/commit?deviceid={id}` - Commits the changes (acknowledges them)
`highscores/changeview/rollback?deviceid={id}` - Rolls back to see the changes again

### Sample Workflow

1. Activate a ChangeView for a device named "testdevice":
```
http://localhost:8080/edgemodules/changeviewsdemo/highscores/changeview/activate?deviceid=testdevice
```

2. Check how many records have changed:
```
http://localhost:8080/edgemodules/changeviewsdemo/highscores/changeview/query?deviceid=testdevice&query=count
```

3. Get the changed records:
```
http://localhost:8080/edgemodules/changeviewsdemo/highscores/changeview/query?deviceid=testdevice&query=select
```

4. Make some changes to the database directly in InterBase
5. Run the count or select query again - the changes won't appear because you're still in the active ChangeView
6. Roll back to see the new changes:
```
http://localhost:8080/edgemodules/changeviewsdemo/highscores/changeview/rollback?deviceid=testdevice
```

7. Run the query again to see the new changes
8. Commit when you're ready to accept the changes:
```
http://localhost:8080/edgemodule/changeviewsdemo/highscores/changeview/commit?deviceid=testdevi
```

> ### Note
> The InterBase ChangeViews demo is only available for Delphi.