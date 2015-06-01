//
//  TweetDetailTableViewController.swift
//  Smashtag
//
//  Created by Remus Lazar on 30.05.15.
//  Copyright (c) 2015 Remus Lazar. All rights reserved.
//

import UIKit

class TweetDetailTableViewController: UITableViewController, UITableViewDelegate {

    // MARK: - Public API

    var tweet: Tweet? {
        didSet {
            tweetInfo.removeAll()
            if let media = tweet?.media where tweet!.media.count > 0 {
                tweetInfo.append(Mention(title: "Images", data: media.map { Mention.Data.Image($0.url, aspectRatio: $0.aspectRatio) }))
            }
            if let hashtags = tweet?.hashtags where tweet!.hashtags.count > 0 {
                tweetInfo.append(Mention(title: "Hashtags", data: hashtags.map { return Mention.Data.Keyword($0.keyword) }))
            }
            if let urls = tweet?.urls where tweet!.urls.count > 0 {
                tweetInfo.append(Mention(title: "URLs", data: urls.map { return Mention.Data.URL($0.keyword) }))
            }
            if let userMentions = tweet?.userMentions where tweet!.userMentions.count > 0 {
                tweetInfo.append(Mention(title: "Users", data: userMentions.map { return Mention.Data.Keyword($0.keyword) }))
            }
            tableView?.reloadData()
        }
    }
    
    // MARK: - Internal data structure
    
    private struct Mention {
        private enum Data {
            case Keyword(String)
            case URL(String)
            case Image(NSURL, aspectRatio: Double)
        }
        let title: String
        let data: [Data]
    }
    
    private var tweetInfo = [Mention]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tweetInfo.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweetInfo[section].data.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tweetInfo[section].title
    }
    
    private struct Storyboard {
        static let TextCellReuseIdentifier = "Text"
        static let ImageCellReuseIdentifier = "Image"
        static let NewSearchSegueIdentifier = "New Search"
        static let ShowImageSegueIdentifier = "Show Image"
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let mention = tweetInfo[indexPath.section]
        let data = mention.data[indexPath.row]
        
        switch(data) {
        case .Keyword(let keyword):
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.TextCellReuseIdentifier,
                forIndexPath: indexPath) as! UITableViewCell
            cell.textLabel?.text = keyword
            return cell
        case .URL(let url):
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.TextCellReuseIdentifier,
                forIndexPath: indexPath) as! UITableViewCell
            cell.textLabel?.text = url
            return cell
        case .Image(let url, _):
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.ImageCellReuseIdentifier,
                forIndexPath: indexPath) as! ImageTableViewCell
            cell.photoURL = url
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let mention = tweetInfo[indexPath.section]
        let data = mention.data[indexPath.row]
        
        switch(data) {
        case .Image(let url, aspectRatio: let ratio):
            return view.bounds.width / CGFloat(ratio)
            
        default: return UITableViewAutomaticDimension
        }
    }

    // MARK: - TableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let mention = tweetInfo[indexPath.section]
        let data = mention.data[indexPath.row]
        
        switch(data) {
        case .Keyword:
            performSegueWithIdentifier(Storyboard.NewSearchSegueIdentifier, sender: tableView.cellForRowAtIndexPath(indexPath))
        case .URL(let url):
            if let url = NSURL(string: url) {
                UIApplication.sharedApplication().openURL(url)
            }
        default: break
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: - Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        var destinationViewController = segue.destinationViewController as? UIViewController
        
        if let dvc = destinationViewController as? UINavigationController {
            destinationViewController = dvc.visibleViewController
        }
        
        if let identifier = segue.identifier {
            switch(identifier) {
            case Storyboard.NewSearchSegueIdentifier:
                if let tweetVC = destinationViewController as? TweetTableViewController,
                    cell = sender as? UITableViewCell
                {
                    if let searchText = cell.textLabel?.text {
                        tweetVC.searchText = searchText
                    }
                }
            case Storyboard.ShowImageSegueIdentifier:
                if let imageVC = destinationViewController as? ImageViewController,
                cell = sender as? UITableViewCell,
                indexPath = tableView.indexPathForCell(cell)
                {
                    let data = tweetInfo[indexPath.section].data[indexPath.row]
                    switch(data) {
                    case .Image(let url, aspectRatio: let aspectRatio):
                        imageVC.imageURL = url
                    default: break
                    }
                }
            default: break
            }
        }
        
    }
    
}
