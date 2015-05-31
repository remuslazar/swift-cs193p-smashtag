//
//  TweetDetailTableViewController.swift
//  Smashtag
//
//  Created by Remus Lazar on 30.05.15.
//  Copyright (c) 2015 Remus Lazar. All rights reserved.
//

import UIKit

class TweetDetailTableViewController: UITableViewController {

    // MARK: - Public API

    var tweet: Tweet? {
        didSet {
            tweetInfo.removeAll()
            if let hashtags = tweet?.hashtags where tweet!.hashtags.count > 0 {
                tweetInfo.append(Mention(title: "Hashtags", data: hashtags.map { return Mention.Data.Keyword($0.keyword) }))
            }
            if let userMentions = tweet?.userMentions where tweet!.userMentions.count > 0 {
                tweetInfo.append(Mention(title: "Users", data: userMentions.map { return Mention.Data.Keyword($0.keyword) }))
            }
            if let urls = tweet?.urls where tweet!.urls.count > 0 {
                tweetInfo.append(Mention(title: "URLs", data: urls.map { return Mention.Data.Keyword($0.keyword) }))
            }
            if let media = tweet?.media where tweet!.media.count > 0 {
                tweetInfo.append(Mention(title: "Images", data: media.map { Mention.Data.Image($0.url, aspectRatio: $0.aspectRatio) }))
            }
            tableView?.reloadData()
        }
    }
    
    // MARK: - Internal data structure
    
    private struct Mention {
        private enum Data {
            case Keyword(String)
            case Image(NSURL, aspectRatio: Double)
        }
        let title: String
        let data: [Data]
    }
    
    private var tweetInfo = [Mention]()
    
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
        case .Image(let url, _):
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.ImageCellReuseIdentifier,
                forIndexPath: indexPath) as! UITableViewCell
            // todo: implement image cell
            cell.textLabel?.text = url.description
            return cell
            
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
}
