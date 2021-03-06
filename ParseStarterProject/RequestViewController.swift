//
//  RequestViewController.swift
//  UberAlles
//
//  Created by Julian Nicholls on 21/09/2015.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import MapKit
import Parse

class RequestViewController: UIViewController, CLLocationManagerDelegate {

    var requestLocation = CLLocationCoordinate2DMake(0, 0)
    var requestUsername = ""

    @IBOutlet weak var map: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setMapCentre()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pickupPressed(sender: AnyObject) {
        var query = PFQuery(className: "RiderRequest")

        query.whereKey("username", equalTo: requestUsername)

        query.findObjectsInBackgroundWithBlock({
            (objects, error) -> Void in

            if error == nil {
                for object in objects! {
                    query = PFQuery(className: "RiderRequest")

                    query.getObjectInBackgroundWithId(object.objectId!, block: {
                        (object, error) -> Void in

                        if error != nil {
                            print(error!.localizedDescription)
                        }
                        else if let request = object {
                            request["driverResponded"] = PFUser.currentUser()?.username
                            request.saveInBackground()

                            let reqLocation = CLLocation(latitude: self.requestLocation.latitude, longitude: self.requestLocation.longitude)

                            CLGeocoder().reverseGeocodeLocation(reqLocation, completionHandler: {
                                (placemarks, error) -> Void in

                                if error != nil {
                                    print("Geocoding failed: \(error!.localizedDescription)")
                                }
                                else {
                                    let mkp     = MKPlacemark(placemark: placemarks![0] as CLPlacemark)
                                    let mapItem = MKMapItem(placemark: mkp)

                                    mapItem.name = self.requestUsername

                                    let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]

                                    mapItem.openInMapsWithLaunchOptions(launchOptions)
                                }
                            })
                        }
                    })
                }
            }
            else {
                print(error!.localizedDescription)
            }
        })

    }

    func setMapCentre() -> Void {
        let centre = CLLocationCoordinate2DMake(requestLocation.latitude, requestLocation.longitude)

        let dLat:  CLLocationDegrees = 0.01
        let dLong: CLLocationDegrees = 0.01
        let span:  MKCoordinateSpan  = MKCoordinateSpanMake(dLat, dLong)

        let region: MKCoordinateRegion = MKCoordinateRegionMake(centre, span)

        map.setRegion(region, animated: true)

        let pin = MKPointAnnotation()
        pin.coordinate = centre
        pin.title = "\(requestUsername) Location"
        map.addAnnotation(pin)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
