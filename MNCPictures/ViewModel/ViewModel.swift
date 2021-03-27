//
//  ViewModel.swift
//  MNCPictures
//
//  Created by Randy Efan Jayaputra on 27/03/21.
//

import UIKit

class CellViewModel {
    let image: UIImage
    let title: String
    let viewers: String
    
    init(image: UIImage, title: String, viewers: String) {
        self.image = image
        self.title = title
        self.viewers = viewers
    }
}

class ViewModel {
    private let client: ClientAPI
    private var content: Contents = [] {
        didSet {
            fetchData()
        }
    }
    
    var cellViewModels: [CellViewModel] = []
    var total: Int = 0
    var offset: Int = 0
    var limit: Int = 15
    
    var isLoading: Bool = false {
        didSet {
            showLoading?()
        }
    }
    
    var showLoading: (() -> Void)?
    var reloadData: (() -> Void)?
    var showError: ((Error) -> Void)?
    
    init(client: ClientAPI) {
        self.client = client
    }
    
    func fetchDatas(offset: Int, limit: Int) {
        if let client = client as? KlaklikClient {
            self.isLoading = true
            let endpoint = KlaklikEndpoint.listFilm(offset: offset, limit: limit)
            client.fetch(with: endpoint) { (either) in
                switch either {
                case .success(let result):
                    self.total = result.DATA[0].total
                    self.content = result.DATA[0].content
                case .error(let error):
                    self.showError?(error)
                }
            }
        }
    }
    
    func calculateOffset() {
        let existing = cellViewModels.count
        let sisa = total - existing
        if sisa > 15 {
            offset += 15
        } else {
            offset += sisa
        }
    }
    
    private func fetchData() {
        let group = DispatchGroup()
        self.content.forEach { (result) in
            DispatchQueue.global(qos: .background).async(group: group) {
                group.enter()
                guard let imageData = try? Data(contentsOf: result.thumbnail) else {
                    self.showError?(APIError.imageDownload)
                    return
                }
                
                guard let image = UIImage(data: imageData) else {
                    self.showError?(APIError.imageConvert)
                    return
                }
                
                self.cellViewModels.append(CellViewModel(image: image, title: result.title, viewers: result.view))
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            self.isLoading = false
            self.reloadData?()
        }
    }
    
}
