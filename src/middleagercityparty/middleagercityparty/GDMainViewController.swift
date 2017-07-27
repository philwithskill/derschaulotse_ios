//
//  GDTabViewController.swift
//  middleagercityparty
//
//  Created by Philipp Faßheber on 31/10/16.
//  Copyright © 2016 Philipp Faßheber. All rights reserved.
//

import UIKit

protocol NavigationBarButtonDelegateProtocol {
    
    func didTapNavigationBarButton()
}

class GDMainViewController : UIViewController, GDBottomNavigationDatasourceProtocol{
    
    enum ColorScheme {
        case middleagercityparty
        case geekdevelopment
    }
    
    lazy private var segueBottomNavigation = "bottomNavigationControllerSegue"
    
    lazy private var segueShowsViewController = "segueShowsViewController"
    
    lazy private var navigationItems : [GDNavigationItem] = [GDNavigationItem]()
    
    lazy private var currentScheme : ColorScheme = ColorScheme.middleagercityparty
    
    private var showsViewController : GDShowsViewController!
    
    private var placesViewController : GDPlacesViewController!
    
    private var imprintViewController : GDImprintViewController!
    
    private var currentViewController : UIViewController!
    
    private var viewControllerInTransition : UIViewController?
    
    private var bottomNavigationController : GDBottomNavigationController?
    
    private var datasource : AbstractDatasource!
    
    private var navigationBarButtonDelegate : NavigationBarButtonDelegateProtocol?
    
    private var barButtonItems : UIBarButtonItem?
    
    private var refreshesDatabase = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initDatasource()
        initializeTitle()
        initShowsViewController()
        initPlacesViewController()
        initImprintViewController()
        initNavigationBarButtonItems()
        refreshDatabase()
        registerObserver()
    }
    
    deinit {
        unregisterObserver()
    }
    
    func didBecomeActive() {
        refreshDatabase()
    }
    
    private func refreshDatabase() {
        if refreshesDatabase {
            return
        }
        
        refreshesDatabase = true
        let source = datasource as! GDJsonDatasource
        let updater = GDModelUpdater(source: source, currentDatabase: GDMidleagerDatabase().database())
        updater.updateServer = GDUrls.updateServer
        
        updater.onUpdated = { (newDatabase: JSONObject) in
            NSLog("onUpdated")
            self.refreshesDatabase = false
        }
        
        updater.onUpdateIgnored = {
            NSLog("onUpdateIgnored")
            self.refreshesDatabase = false
        }
        
        updater.onUpdateFailed = {
            NSLog("onUpdateFailed")
            self.refreshesDatabase = false
        }
        
        updater.update()
    }
    
    // MARK: Initializers
    
    private func initNavigationBarButtonItems() {
        barButtonItems = UIBarButtonItem(image: #imageLiteral(resourceName: "icon_more"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(didTapNavigationBarButtonItem))
        
        navigationItem.rightBarButtonItem = barButtonItems
    }
    
    private func deInitBarButtonItems() {
        navigationItem.rightBarButtonItem = nil
    }
    
    
    private func initDatasource() {
        let datasource = GDJsonDatasource()
        try! datasource.startTransaction()
        try! datasource.refresh(fromJson: GDMidleagerDatabase().database())
        try! datasource.commit()
        self.datasource = datasource
    }
    
    private func initializeTitle() {
        self.title = NSLocalizedString("Schaulotse", comment: "")
    }
    
    private func initializeNavigationItems() {
        navigationItems.append(createShowsNavigationItem())
        navigationItems.append(createPlacesNavigationItem())
        navigationItems.append(createImprintNavigationItem())
    }
    
    private func createShowsNavigationItem() -> GDNavigationItem {
        let item = GDNavigationItem()
        item.iconName = "icon_stage"
        item.text = NSLocalizedString("Shows", comment: "")
        item.didSelect = { () -> () in
            self.initNavigationBarButtonItems()
            self.switchToMiddleagerCityPartyColorScheme()
            self.display(viewController: self.showsViewController)
            self.navigationBarButtonDelegate = self.showsViewController
        }
        
        return item
    }
    
    private func createPlacesNavigationItem() -> GDNavigationItem {
        let item = GDNavigationItem()
        item.iconName = "icon_place"
        item.text = NSLocalizedString("Places", comment: "")
        item.didSelect = { () -> () in
            self.switchToMiddleagerCityPartyColorScheme()
            self.display(viewController: self.placesViewController)
            self.navigationBarButtonDelegate = self.placesViewController
        }
        
        return item
    }
    
    private func createImprintNavigationItem() -> GDNavigationItem{
        let item = GDNavigationItem()
        item.iconName = "icon_imprint"
        item.text = NSLocalizedString("Imprint", comment: "")
        item.didSelect = { () -> () in
            self.initNavigationBarButtonItems()
            self.switchToGeekdevelopmentColorScheme()
            self.display(viewController: self.imprintViewController)
            self.navigationBarButtonDelegate = self.imprintViewController
        }
        
        return item
    }
    
    private func initShowsViewController() {
        let source = GDTimeDatasource()
        source.datasource = self.datasource
        showsViewController.datasource = source
        
        let dayDatasource = GDDayDatasource()
        dayDatasource.datasource = self.datasource
        showsViewController.dayDatasource = dayDatasource
        
        navigationBarButtonDelegate = showsViewController
    }
    
    private func initPlacesViewController() {
        let board = UIStoryboard(name: "Main", bundle: nil)
        placesViewController = board.instantiateViewController(withIdentifier: "GDPlacesViewController") as! GDPlacesViewController
        
        let placeDatasource = GDPlaceDatasource()
        placeDatasource.datasource = self.datasource
        placesViewController.datasource = placeDatasource
    }
    
    private func initImprintViewController() {
        let board = UIStoryboard(name: "Main", bundle: nil)
        imprintViewController = board.instantiateViewController(withIdentifier: "GDImprintViewController") as! GDImprintViewController
    }
    
    // MARK: Change ViewControllers
    
    private func display(viewController: UIViewController) {
        if viewController == currentViewController {
            NSLog("Skip transition. Already displaying %@", viewController)
            return
        }
        
        if viewControllerInTransition != nil {
            NSLog("Skip transition. Currently translating to \(viewControllerInTransition)")
            return
        }
        
        //keep bottom navigation in sync. Block every interaction until transition finished.
        bottomNavigationController?.isBlocked = true
        
        viewControllerInTransition = viewController
        
        viewController.view.frame = currentViewController.view.frame
        
        currentViewController.willMove(toParentViewController: nil)
        addChildViewController(viewController)
        transition(from: currentViewController, to: viewController, duration: 0.3, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {() -> () in }, completion:{(Bool) -> () in
            self.currentViewController.removeFromParentViewController()
            viewController.didMove(toParentViewController: self)
            self.currentViewController = viewController
            self.viewControllerInTransition = nil
            
            //unblock bottom navigation
            self.bottomNavigationController?.isBlocked = false
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueBottomNavigation {
            initializeNavigationItems()
            let viewController = segue.destination as! GDBottomNavigationController
            viewController.datasource = self
            self.bottomNavigationController = viewController
        } else if segue.identifier == segueShowsViewController {
            showsViewController = segue.destination as! GDShowsViewController
            currentViewController = showsViewController
        }
    }
    
    // MARK: GDBottomNavigationDatasourceProtocol
    
    func numberOfItems(forBottomNavigation: GDBottomNavigationController) -> Int {
        return navigationItems.count
    }
    
    func navigationItemAt(index: Int, forBottomNavigation: GDBottomNavigationController) -> GDNavigationItem {
        return navigationItems[index]
    }
    
    // MARK: Color Schemes
    
    private func switchToMiddleagerCityPartyColorScheme() {
        if currentScheme == ColorScheme.middleagercityparty {
            return
        }
        currentScheme = ColorScheme.middleagercityparty
        switchScheme(to: GDColors.middleagercityparty)
    }
    
    private func switchToGeekdevelopmentColorScheme() {
        if currentScheme == ColorScheme.geekdevelopment {
            return
        }
        currentScheme = ColorScheme.geekdevelopment
        switchScheme(to: GDColors.geekdevelopment)
    }
    
    private func switchScheme(to : UIColor) {
        UIView.animate(withDuration: 0.150, animations: { () -> () in
            self.bottomNavigationController?.collectionView.backgroundColor = to
            self.navigationController?.navigationBar.barTintColor = to
            self.navigationController?.navigationBar.layoutIfNeeded() // see: http://stackoverflow.com/a/39543669/973349
        })
    }
    
    // MARK: Navigation Bar Button Handling.
    func didTapNavigationBarButtonItem() {
        navigationBarButtonDelegate?.didTapNavigationBarButton()
    }
    
    // MARK: Observing
    
    private func registerObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: NotificationUtil.nameApplicationDidBecomeActive, object: nil)
    }
    
    private func unregisterObserver() {
        NotificationCenter.default.removeObserver(observer: self)
        
    }
}
