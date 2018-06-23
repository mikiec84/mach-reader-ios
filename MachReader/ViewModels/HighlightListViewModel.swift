//
//  HighlightListViewModel.swift
//  MachReader
//
//  Created by ShuichiNagao on 2018/06/17.
//  Copyright © 2018 mach-technologies. All rights reserved.
//

import Foundation
import Pring
import Firebase

class HighlightListViewModel {
    private let book: Book
    private var highlightDataSource: DataSource<Highlight>?
    
    init(book: Book) {
        self.book = book
    }
    
    var highlightsCount: Int {
        return highlightDataSource?.count ?? 0
    }

    func loadHighlights(completion: @escaping ((QuerySnapshot?, CollectionChange) -> Void)) {
        guard let userID = User.default?.id else { return }
        // FIXME: same logic is written in Book model...
        // TODO: switch using withOthers option
        highlightDataSource = book.highlights
            .where(\Highlight.userID, isEqualTo: userID)
            .order(by: \Highlight.createdAt)
            .dataSource()
            .on() { (snapshot, changes) in
                completion(snapshot, changes)
            }
            .on(parse: { (_, highlight, done) in
                highlight.comments.get() { (snapshot, comments) in
                    done(highlight)
                }
            })
            .listen()
    }
    
    func highlight(at indexPath: IndexPath) -> Highlight? {
        guard let dataSource = highlightDataSource else { return nil }
        if dataSource.isEmpty { return nil }
        return dataSource[indexPath.item]
    }
    
    func commentText(at indexPath: IndexPath) -> String? {
        guard let comments = highlight(at: indexPath)?.comments else { return nil }
        if comments.isEmpty { return nil }
        var str = ""
        comments.forEach { str.append("\($0.text ?? "")\n") }
        return str
    }
}
