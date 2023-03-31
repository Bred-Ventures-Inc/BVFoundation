//
//  Paginator.swift
//
//  Created by Alex Weiner on 1/31/19.
//  Copyright © 2019 PK Fitness Apps. All rights reserved.
//

import Foundation
import SwiftUI

public typealias PaginatedContentIsWithheld = Bool
public typealias PaginatedContent = [AnyObject]
public struct PaginateResult {
    let content: PaginatedContent
    let page: Int
    let contentWithheld: PaginatedContentIsWithheld
    public init(content: PaginatedContent, page: Int, contentWithheld: PaginatedContentIsWithheld = false) {
        self.content = content
        self.page = page
        self.contentWithheld = contentWithheld
    }
}

public protocol PaginatorDelegate {
    func paginatedFetch(page: Int, size: Int) async  -> PaginateResult
    func paginatedContentUpdated(content: PaginatedContent, page: Int)
}

public class Paginator: NSObject, ObservableObject {
    public var delegate: PaginatorDelegate?

    let pageSize: Int
    private var currentPage: Int = -1
    @Published public var reachedLastPage = false
    public var  lastPageIsLimited: PaginatedContentIsWithheld = false
    public var timeBuffer: TimeInterval = 0
    private var lastPagination: Date?

    public init(for delegate: PaginatorDelegate? = nil, pageSize: Int) {
//        self.delegate = delegate
        self.pageSize = pageSize
        super.init()
    }
    
    public func initPagination() { // Starts initial pagination if it hasn't already
        guard currentPage == -1 else {return}
        paginate()
    }
    
    public func restartPagination() {
        currentPage = -1
        reachedLastPage = false
        paginate()
    }

    public func reachedPaginatedItem(at index: Int) {
        if index >= (currentPage + 1) * pageSize {
            //            Log.i("\(index) > \(currentPage+1) * \(pageSize)")
            paginate()
        }
    }

    public func paginate() {
        guard !reachedLastPage else { return }
        guard lastPagination?.age ?? .infinity > timeBuffer else {return}
        guard let delegate = delegate else {return}
        lastPagination = Date()
        currentPage += 1
        let thisPage = currentPage
        Task {
            let result = await delegate.paginatedFetch(page: thisPage, size: self.pageSize)
            self.loadPage(content: result.content, page: result.page, contentWithheld: result.contentWithheld)
        }
    }

    func loadPage(content: PaginatedContent, page: Int, contentWithheld: PaginatedContentIsWithheld) {
        guard let delegate = delegate else {return}
        mainThread {
            if content.isEmpty {
                // Client now knows to hide loading spinners
                self.reachedLastPage = true
                self.lastPageIsLimited = contentWithheld
                //            print("Reached last page! Content limited: \(lastPageIsLimited)")
            }
            delegate.paginatedContentUpdated(content: content, page: page)
        }
    }
}
