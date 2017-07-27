//
//  GDPlacesViewController.swift
//  middleagercityparty
//
//  Created by Philipp Faßheber on 31/10/16.
//  Copyright © 2016 Philipp Faßheber. All rights reserved.
//

import UIKit
import MapKit

class GDPlacesViewController : UIViewController, MKMapViewDelegate, NavigationBarButtonDelegateProtocol{
    
    @IBOutlet weak var mapView: MKMapView!
    
    var datasource : GDViewControllerDatasource<GDPlace>? {
        willSet {
            //remove
            dontObserveDatasource()
        }
        
        didSet {
            observeDatasource()
        }
    }
    
    private var needsToInitializeMap = true
    
    
    private var annotations = [PlaceAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerObserver()
        needsToInitializeMap = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        /*
            Map needs to initialize here. Otherwise zooming on initialization will calculate zoomstate wrong.
            Prevent map from initializing and zooming every time the view did appear
        */
        if needsToInitializeMap {
            initMapView()
        } else {
           conditionalDisplayMyLocationButton(mapView)
        }
    }
    
    func didBecomeActive() {
        refreshMapView()
    }
    
    private func initMapView() {
        needsToInitializeMap = false
        annotations = datasource!.elements.map { PlaceAnnotation(place: $0)}
        mapView.addAnnotations(annotations)
        mapView.delegate = self
        refreshMapView()
    }
    
    private func initPlacesNavigationBarButtonItems() {
        let barButtonItems = UIBarButtonItem(image: #imageLiteral(resourceName: "icon_my_location"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(didTapNavigationBarButton))
        
        parent!.navigationItem.rightBarButtonItem = barButtonItems
    }
    
    private func deInitPlacesNavigationBarButtonItems() {
        if let parent = self.parent {
            parent.navigationItem.rightBarButtonItem = nil
        }
    }
    
    private func reInitMapView() {
        if !needsToInitializeMap {
            mapView.removeAnnotations(self.mapView.annotations)
            initMapView()
        }
    }
    
    
    private func refreshMapView() {
        zoomMapToAllMarkers()
    }
    
    private func buildCoordinates(_ places: [GDPlace]) -> [CLLocationCoordinate2D] {
        var coordinates = [CLLocationCoordinate2D]()
        places.forEach { (place) in
            if place.lat != nil && place.lon != nil {
                let coordinate = CLLocationCoordinate2D(latitude: place.lat!, longitude: place.lon!)
                coordinates.append(coordinate)
            } else {
                NSLog("Missing coordinate for place \(place.name) lat \(place.lat) + lon \(place.lon)")
            }
        }
        
        return coordinates
    }
    
    private func zoomMapToAllMarkers() {
        deInitPlacesNavigationBarButtonItems()
        
        let coordinates = datasource!.elements.map {CLLocationCoordinate2D(latitude: $0.lat!, longitude: $0.lon!) }
        let points = coordinates.map { MKMapPointForCoordinate($0)}
        let rects = points.map { MKMapRect(origin: $0, size: MKMapSize(width: 0.1, height: 0.1))}
        let rect = rects.reduce(MKMapRectNull, MKMapRectUnion)
        let rectWithInset = MKMapRectInset(rect, -1000.0, 0.0)
        let region = MKCoordinateRegionForMapRect(rectWithInset)
        
        mapView.setRegion(region, animated: true)
        
    }
    
    // MARK: Map View Delegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let placeAnnotation = annotation as! PlaceAnnotation
        
        var reusedView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin")
        if reusedView == nil {
            reusedView = MKAnnotationView.init(annotation: annotation, reuseIdentifier: "pin")
            reusedView?.canShowCallout = true
            
            //display navigation button in callout
            let button = UIButton(type: .detailDisclosure)
            button.tintColor = GDColors.green
            button.setImage(#imageLiteral(resourceName: "icon_navigation"), for: UIControlState.normal)
            reusedView?.rightCalloutAccessoryView = button
        } else {
            reusedView?.annotation = placeAnnotation
        }
        
        reusedView?.image = placeAnnotation.image
        return reusedView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let anno = view.annotation as! PlaceAnnotation
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        AnnotationUtil.toMapItem(anno).openInMaps(launchOptions: launchOptions)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        conditionalDisplayMyLocationButton(mapView)
    }
    
    private func conditionalDisplayMyLocationButton(_ mapView: MKMapView) {
        let visibleRect = mapView.visibleMapRect
        let visibleAnnotations = mapView.annotations(in: visibleRect) as! Set<PlaceAnnotation>
        
        if visibleAnnotations.count < annotations.count {
            initPlacesNavigationBarButtonItems()
        } else {
            deInitPlacesNavigationBarButtonItems()
        }
    }
    
    // MARK: Observing
    
    private func registerObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: NotificationUtil.nameApplicationDidBecomeActive, object: nil)
    }
    
    private func unregisterObserver() {
        NotificationCenter.default.removeObserver(observer: self)
        
    }
    
    private func observeDatasource() {
        let observer = GDSourceObserver<GDPlace>()
        observer.updated = { (elements: [GDPlace]) in
            OperationQueue.main.addOperation {
                self.reInitMapView()
            }
        }
        datasource?.observer = observer
    }
    
    private func dontObserveDatasource() {
        datasource?.observer.updated = nil
    }
    
    // MARK: NavigationBarButtonDelegateProtocol
    
    func didTapNavigationBarButton() {
        reInitMapView()
    }
}
