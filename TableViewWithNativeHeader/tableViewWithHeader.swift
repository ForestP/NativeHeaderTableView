//
//  tableViewWithHeader.swift
//  TableViewWithNativeHeader
//
//  Created by Forest Plasencia on 7/10/18.
//  Copyright © 2018 Forest Plasencia. All rights reserved.
//

import Foundation
import UIKit

class tableViewWithHeader {
    
    fileprivate var containerView: UIView!
    fileprivate var title: String!
    fileprivate var bigHeaderView: UIView! {
        didSet {
            self.createSmallHeader()
            self.createBigLabel()
        }
    }
    fileprivate var heightAnchor: NSLayoutConstraint!
    
    fileprivate var bigLabel: UILabel!
    
    fileprivate var smallHeaderView: UIView! {
        didSet {
            self.createSmallLabel()
        }
    }
    fileprivate var smallLabel: UILabel!
    
    fileprivate let maxHeaderHeight: CGFloat = 112
    fileprivate let minHeaderHeight: CGFloat = 64
    fileprivate var previousScrollOffset: CGFloat = 0
    
    lazy var tableView : UITableView = {
        let tableView = self.createViewBigHeader()
        return tableView
    }()
    
    init(_ containerView: UIView, title: String) {
        self.containerView = containerView
        self.title = title
    }
    
    func scrollViewScrolled(_ scrollView: UIScrollView) {
        let absoluteTop: CGFloat = 0;
        let absoluteBottom: CGFloat = scrollView.contentSize.height - scrollView.frame.size.height
        
        let scrollDiff = scrollView.contentOffset.y - self.previousScrollOffset
        
        let isScrollingDown = scrollDiff > 0 && scrollView.contentOffset.y > absoluteTop
        let isScrollingUp = scrollDiff < 0 && scrollView.contentOffset.y < absoluteBottom
        
        var newHeight = self.heightAnchor.constant
        if canAnimateHeader(scrollView) {
            if isScrollingDown {
                newHeight = max(self.minHeaderHeight, self.heightAnchor.constant - abs(scrollDiff))
            } else if isScrollingUp && scrollView.contentOffset.y <= 0 {
                newHeight = min(self.maxHeaderHeight, self.heightAnchor.constant + abs(scrollDiff))
            }
        }
        
        if newHeight != self.heightAnchor.constant {
            self.heightAnchor.constant = newHeight
            self.setScrollPosition(position: self.previousScrollOffset)
        }
        
        self.updateSubviews()
        self.previousScrollOffset = scrollView.contentOffset.y
    }
    
    func scrollViewDidStopScrolling() {
        let range = self.maxHeaderHeight - self.minHeaderHeight
        let midPoint = self.minHeaderHeight + (range / 2)
        
        if self.heightAnchor.constant > midPoint {
            self.expandHeader()
        } else {
            self.collapseHeader()
        }
    }
    
    fileprivate func collapseHeader() {
        self.containerView.layoutIfNeeded()
        UIView.animate(withDuration: 0.05) {
            self.heightAnchor.constant = self.minHeaderHeight
            self.containerView.layoutIfNeeded()
        }
        self.smallLabel.alpha = 1
    }
    fileprivate func expandHeader() {
        self.containerView.layoutIfNeeded()
        UIView.animate(withDuration: 0.05) {
            self.heightAnchor.constant = self.maxHeaderHeight
            self.containerView.layoutIfNeeded()
        }
        self.smallLabel.alpha = 0
    }
    
    fileprivate func canAnimateHeader(_ scrollView: UIScrollView) -> Bool {
        let scrollViewMaxHeight = scrollView.frame.height + self.heightAnchor.constant - minHeaderHeight
        return scrollView.contentSize.height > scrollViewMaxHeight
    }
    
    fileprivate func setScrollPosition(position: CGFloat) {
        self.tableView.contentOffset = CGPoint(x: self.tableView.contentOffset.x, y: position)
    }
    
    fileprivate func updateSubviews() {
        let range = self.maxHeaderHeight - self.minHeaderHeight
        let openAmount = self.heightAnchor.constant - self.minHeaderHeight
        let percentage = openAmount * 10 / range
        
        self.smallLabel.alpha = 1 - percentage
    }
    
    fileprivate func createViewBigHeader() -> UITableView {
        let view = UIView()
        view.backgroundColor = UIColor(red: (248/255), green: (248/255), blue: (248/255), alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.addSubview(view)
        
        view.leftAnchor.constraint(equalTo: self.containerView.leftAnchor, constant: 0).isActive = true
        view.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 0).isActive = true
        view.rightAnchor.constraint(equalTo: self.containerView.rightAnchor, constant: 0).isActive = true
        self.heightAnchor = view.heightAnchor.constraint(equalToConstant: 112)
        self.heightAnchor.isActive = true
        
        self.bigHeaderView = view
        
        return self.createTableView(view: view)
    }
    
    fileprivate func createBigLabel() {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        self.bigHeaderView.addSubview(label)
        label.font = UIFont.systemFont(ofSize: 30, weight: .heavy)
        label.text = self.title
        label.textColor = .black
        
        label.leftAnchor.constraint(equalTo: self.bigHeaderView.leftAnchor, constant: 20).isActive = true
        label.bottomAnchor.constraint(equalTo: self.bigHeaderView.bottomAnchor, constant: -8).isActive = true
        label.rightAnchor.constraint(equalTo: self.bigHeaderView.rightAnchor, constant: -20).isActive = true
        label.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
        self.bigLabel = label
    }
    
    fileprivate func createTableView(view: UIView) -> UITableView {
        let tv =  UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.addSubview(tv)
        
        tv.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 0).isActive = true
        tv.topAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        tv.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: 0).isActive = true
        tv.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0).isActive = true
        
        return tv
    }
    
    fileprivate func createSmallHeader() {
        let view = UIView()
        view.backgroundColor = UIColor(red: (248/255), green: (248/255), blue: (248/255), alpha: 0.8)
        let blur = UIBlurEffect(style: .prominent)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.frame = view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurView)
        view.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.addSubview(view)
        
        view.leftAnchor.constraint(equalTo: self.containerView.leftAnchor, constant: 0).isActive = true
        view.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 0).isActive = true
        view.rightAnchor.constraint(equalTo: self.containerView.rightAnchor, constant: 0).isActive = true
        view.heightAnchor.constraint(equalToConstant: 64).isActive = true
        
        self.smallHeaderView = view
    }
    
    fileprivate func createSmallLabel() {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        self.smallHeaderView.addSubview(label)
        label.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
        label.text = self.title
        label.textColor = .black
        
        label.centerXAnchor.constraint(equalTo: self.smallHeaderView.centerXAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: self.smallHeaderView.bottomAnchor, constant: -8).isActive = true
        label.heightAnchor.constraint(equalToConstant: 19).isActive = true
        label.alpha = 0
        
        self.smallLabel = label
    }
    
}
