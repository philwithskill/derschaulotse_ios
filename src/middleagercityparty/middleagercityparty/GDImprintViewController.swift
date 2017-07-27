//
//  GDImprintViewController.swift
//  middleagercityparty
//
//  Created by Philipp Faßheber on 31/10/16.
//  Copyright © 2016 Philipp Faßheber. All rights reserved.
//

import UIKit
import WebKit

class GDImprintViewController : UIViewController, WKScriptMessageHandler, NavigationBarButtonDelegateProtocol {
    
    private let callbackHandlerName = "schaulotse"
    
    private let separator = ":"
    
    private let sectionAbout = "about"
    
    private let sectionYourIdea = "your_idea"
    
    private let sectionContact = "contact"

    private let sectionHome = "home"
    
    private var imprintWebView: WKWebView!
    
    lazy private var reachability = Reachability.init(hostname: GDUrls.derSchaulotse)
    
    lazy private var displaysLocalImprint : Bool = false
    
    @IBOutlet weak var container: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        observeNetwork()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        initImprintWebView()
    }
    
    deinit {
        reachability?.stopNotifier()
    }
    
    private func initImprintWebView() {
        if imprintWebView != nil {
            return
        }
        
        let contentController = WKUserContentController()
        contentController.add(self, name: callbackHandlerName)
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = contentController

        let rect = CGRect(x: container.bounds.origin.x, y: container.bounds.origin.y, width: container.bounds.width, height: container.bounds.height)
        imprintWebView = WKWebView(frame: rect, configuration: configuration)
    
        container.addSubview(imprintWebView)
        
        refreshWebView()
    }
    
    private func refreshWebView() {
        
        var url = Bundle.main.url(forResource: "derschaulotse", withExtension: "html")
        displaysLocalImprint = true
        if let isReachable = reachability?.isReachable {
            if isReachable {
                url = URL(string: GDUrls.derSchaulotse)
                displaysLocalImprint = false
            }
        }
        
        if url != nil && imprintWebView != nil {
            let request = URLRequest(url: url!)
            imprintWebView.load(request)
        }
    }
    
    private func observeNetwork() {
        reachability = Reachability.init(hostname: GDUrls.derSchaulotse)
        
        reachability?.whenReachable = { NetworkReachable in
            self.refreshWebView()
        }
        
        do {
            try reachability?.startNotifier()
        } catch {
            NSLog("Could not observe.")
        }
    }
    
    private func scrollTo(_ section: String) {
        imprintWebView.evaluateJavaScript("$(\"html, body\").animate({ scrollTop: $('#" + section + "').offset().top }, 500);")
    }
    
    // MARK: WKScriptMessageHandler
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == callbackHandlerName {
            let messageString = message.body as! String
            let url = URL(string: messageString)
            if url != nil && UIApplication.shared.canOpenURL(url!) {
                //command iOS is aware of
                UIApplication.shared.openURL(url!)
            } else {
                //custom command, lets handle it
//                let commandWithParameters = messageString.characters.split{$0 == ":"}.map(String.init)
//                
//                if commandWithParameters.count == 0 {
//                    NSLog("Unkown message \(message.body)")
//                    return
//                }
//                
//                let command = commandWithParameters[0]
            }
        }
    }
    
    // MARK: NavigationBarButtonDelegateProtocol
    
    func didTapNavigationBarButton() {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        alert.view.tintColor = GDColors.geekdevelopment
        
        let about = UIAlertAction(title: "About", style: UIAlertActionStyle.default) { (action) in
            self.scrollTo(self.sectionAbout)
        }
        
        let yourIdea = UIAlertAction(title: "Your Idea", style: UIAlertActionStyle.default) { (action) in
            self.scrollTo(self.sectionYourIdea)
        }
        
        let contact = UIAlertAction(title: "Contact", style: UIAlertActionStyle.default) { (action) in
            self.scrollTo(self.sectionContact)
        }
        
        let home = UIAlertAction(title: "Home", style: UIAlertActionStyle.default) { (action) in
            self.scrollTo(self.sectionHome)
        }
        
        let cancel = UIAlertAction(title: "Abbrechen", style: UIAlertActionStyle.cancel) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(about)
        alert.addAction(yourIdea)
        alert.addAction(contact)
        alert.addAction(home)
        alert.addAction(cancel)
        
        present(alert, animated:true, completion: nil)
    }
}
