//
//  SearchTram.swift
//  TramOV WatchKit Extension
//
//  Created by Ruben van den Engel on 10/01/2018.
//  Copyright © 2018 Ruben van den Engel. All rights reserved.
//
import WatchKit
import Foundation
import Alamofire
import SwiftyJSON
import EMTLoadingIndicator

class SearchTramController: WKInterfaceController {
  
  private var indicator: EMTLoadingIndicator?
  
  @IBOutlet var loadingicongroup: WKInterfaceGroup!
  @IBOutlet var loadingicon: WKInterfaceImage!
  @IBOutlet var map: WKInterfaceMap!
  @IBOutlet var minuteslabel: WKInterfaceLabel!
  var modus : String?
  override func awake(withContext context: Any?) {
    super.awake(withContext: context)
    modus = context as? String
    
    // Configure interface objects here.
  }
  
  override func willActivate() {
    // This method is called when watch view controller is about to be visible to user
    super.willActivate()
    indicator = EMTLoadingIndicator(interfaceController: self, interfaceImage: loadingicon,
                                    width: 27, height: 27, style: .dot)
    
    let mapLocation = CLLocationCoordinate2D(latitude: 37, longitude: -122)
    let coordinateSpan = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
    self.map.setRegion(MKCoordinateRegion(center: mapLocation, span: coordinateSpan))
    
    if modus == "Thuis" {
      readStationDelft()
    } else if modus == "Werk" {
      readWeidevogellaan()
    }
    
  }
  
  func readStationDelft() {
    loadingicongroup.setHidden(false)
    minuteslabel.setHidden(true)
    indicator?.showWait()
    var times : [String] = []
    Alamofire.request("https://api.9292.nl/0.1/locations/delft/bus-tramhalte-station-delft/departure-times?lang=nl-NL").responseJSON { response in
      if let json = response.result.value {
        let json = JSON(json)
        
        //Latlong
        let lat = json["location"]["latLong"]["lat"].double!
        let lng = json["location"]["latLong"]["long"].double!
        let coordinateSpan = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
        let mapLocation = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        self.map.addAnnotation(mapLocation, with: .red)
        self.map.setRegion(MKCoordinateRegion(center: mapLocation, span: coordinateSpan))
        //Route
        for (_,subJson):(String, JSON) in json["tabs"][0]["departures"] {
          if subJson["destinationName"].string!.starts(with: "Leidschendam") && subJson["realtimeState"].string! != "cancelled" {
            times.append(subJson["time"].string!)
          }
        }
      }
      if times.count > 0 {
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        var firstdate = dateFormatter.string(from: now)
        firstdate = firstdate + " " + times.first!
        print(firstdate)
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let firstdatedate = dateFormatter.date(from: firstdate)
        let components = Set<Calendar.Component>([.minute])
        let diffdates = Calendar.current.dateComponents(components, from: now, to: firstdatedate!)
        self.minuteslabel.setText(String(diffdates.minute!) + " min.")
      } else {
        self.minuteslabel.setText("(Nog) niet bekend")
      }
      self.indicator?.hide()
      self.loadingicongroup.setHidden(true)
      self.minuteslabel.setHidden(false)
    }
  }
  
  func readWeidevogellaan() {
    loadingicongroup.setHidden(false)
    minuteslabel.setHidden(true)
    indicator?.showWait()
    var times : [String] = []
    Alamofire.request("https://api.9292.nl/0.1/locations/den-haag/bus-tramhalte-weidevogellaan/departure-times?lang=nl-NL").responseJSON { response in
      if let json = response.result.value {
        let json = JSON(json)
        
        //Latlong
        let lat = json["location"]["latLong"]["lat"].double!
        let lng = json["location"]["latLong"]["long"].double!
        let coordinateSpan = MKCoordinateSpan(latitudeDelta: 19, longitudeDelta: 19)
        self.map.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude:lat, longitude: lng), span: coordinateSpan))
        
        
        //Route
        for (_,subJson):(String, JSON) in json["tabs"][0]["departures"] {
          if subJson["destinationName"].string!.starts(with: "Delft") && subJson["realtimeState"].string! != "cancelled" {
            times.append(subJson["time"].string!)
          }
        }
      }
      if times.count > 0 {
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        var firstdate = dateFormatter.string(from: now)
        firstdate = firstdate + " " + times.first!
        print(firstdate)
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let firstdatedate = dateFormatter.date(from: firstdate)
        let components = Set<Calendar.Component>([.minute])
        let diffdates = Calendar.current.dateComponents(components, from: now, to: firstdatedate!)
        self.minuteslabel.setText(String(diffdates.minute!) + " min.")
      } else {
        self.minuteslabel.setText("(Nog) niet bekend")
      }
      self.indicator?.hide()
      self.loadingicongroup.setHidden(true)
      self.minuteslabel.setHidden(false)
    }
  }
}
