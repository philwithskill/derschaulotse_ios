//
//  GDTabBarController.swift
//  middleagercityparty
//
//  Created by Philipp Faßheber on 31/10/16.
//  Copyright © 2016 Philipp Faßheber. All rights reserved.
//

import UIKit

class GDBottomNavigationController : UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var datasource : GDBottomNavigationDatasourceProtocol?
 
    @IBOutlet weak var collectionView: UICollectionView!
    
    lazy private var cells : [Int : GDNavigationItemCell] = [Int :  GDNavigationItemCell]()
    
    private var selectedCell : GDNavigationItemCell?
    
    private var cellInTransition : GDNavigationItemCell?
    
    /**
     Flag to control if bottom navigation is interactable or not.
    */
    lazy var isBlocked : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeCollectionView()
    }
    
    private func initializeCollectionView() {
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.scrollDirection = .horizontal
    }
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return datasource?.numberOfItems(forBottomNavigation: self) ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell : GDNavigationItemCell
        if let item = datasource?.navigationItemAt(index: indexPath.section, forBottomNavigation: self) {
            if indexPath.section == 0 {
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellSelected",
                                                          for: indexPath) as! GDNavigationItemCell
                
                cell.position = .top
                selectedCell = cell
            } else {
                
                //The icon is aligned right. The alignment is relative to the cells width. Check the constraint "traillingMargin" to modify alignment.
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellRight",
                                                          for: indexPath) as! GDNavigationItemCell
                
                cell.position = .right
            }
            cell.navigationItem = item
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellSelected",
                                                      for: indexPath) as! GDNavigationItemCell
        }
        
        cells[indexPath.section] = cell //memory bla bla
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isBlocked {
            return
        }
        
        if let item = datasource?.navigationItemAt(index: indexPath.section, forBottomNavigation: self) {
            if let cell = cells[indexPath.section] {
                if cell == selectedCell {
                    return
                }
                
                if cellInTransition != nil {
                    NSLog("Skip transition because currently transitioning to \(cellInTransition?.navigationItem?.text)")
                    return
                }
                
                cellInTransition = cell
                
                if cell.position == GDNavigationItemCell.Position.left {
                    // hide neighbours to the right
                    for index in (indexPath.section + 1)...(cells.count - 1) {
                        if let rightSidedCell = cells[index] {
                            if rightSidedCell == selectedCell {
                                continue
                            } else {
                                rightSidedCell.moveToRight(completion: nil)
                            }
                        }
                    }
                    
                    //we did this not in the loop, because its possible that selected is not in range of the loop. This saves a boolean flag to prevent from hiding it twice
                    selectedCell?.hideToRight(completion: nil)
                } else {
                    // hide neighbours to the left
                    for index in 0...(indexPath.section - 1) {
                        if let leftSidedCell = cells[index] {
                            if leftSidedCell == selectedCell {
                                continue
                            } else {
                                leftSidedCell.moveToLeft(completion: nil)
                            }
                        }
                    }
                    
                    //we did this not in the loop, because its possible that selected is not in range of the loop. This saves a boolean flag to prevent from hiding it twice
                    selectedCell?.hideToLeft(completion: nil)

                }
                
                cell.select(completion: { (Bool) -> () in
                    self.selectedCell = cell
                    self.cellInTransition = nil
                })

                item.didSelect?()
            }
        }
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size : CGSize
        let height = self.view.bounds.size.height
        var width = self.view.bounds.size.width
        
        if let count = datasource?.numberOfItems(forBottomNavigation: self) {
            if count <= 4 {
                width = width / CGFloat(count)
            } else {
                width = width / CGFloat(4)
            }
        }
        
        size = CGSize(width: width, height: height)
        return size
    }
}
