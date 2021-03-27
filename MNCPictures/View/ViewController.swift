//
//  ViewController.swift
//  MNCPictures
//
//  Created by Randy Efan Jayaputra on 26/03/21.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var topActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var bottomActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var bottomViewHeightConstraint: NSLayoutConstraint!
    
    private let sectionInsets = UIEdgeInsets(top: 50.0, left: 10.0, bottom: 50.0, right: 10.0)
    private let itemsPerRow: CGFloat = 3
    
    private let cache = NSCache<NSNumber, CellViewModel>()
    let viewModel = ViewModel(client: KlaklikClient())
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topActivityIndicator.alpha = 1.0
        topActivityIndicator.startAnimating()
        bottomView.isHidden = true
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "FilmCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        
        viewModel.fetchDatas(offset: viewModel.offset, limit: viewModel.limit)
        
        viewModel.showLoading = {
            if self.viewModel.offset > 1 {
                self.configureBottomView(isLoading: self.viewModel.isLoading)
            } else {
                if self.viewModel.isLoading {
                    self.topActivityIndicator.startAnimating()
                    self.collectionView.alpha = 0.0
                } else {
                    self.topActivityIndicator.stopAnimating()
                    self.collectionView.alpha = 1.0
                }
            }
        }
        
        viewModel.showError = { error in
            print(error)
        }
        
        viewModel.reloadData = {
            self.collectionView.reloadData()
        }
    }
    
    func configureBottomView(isLoading: Bool) {
        if isLoading {
            self.bottomView.isHidden = false
            self.bottomActivityIndicator.startAnimating()
            self.bottomViewHeightConstraint.constant = 50
            self.bottomActivityIndicator.isHidden = false
        } else {
            self.bottomView.isHidden = true
            self.bottomActivityIndicator.isHidden = true
            self.bottomActivityIndicator.stopAnimating()
            self.bottomViewHeightConstraint.constant = 0
        }
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow

        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        sectionInsets.left
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.cellViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! FilmCell
        
        let itemNumber = NSNumber(value: indexPath.item)
        if let cachedImage = self.cache.object(forKey: itemNumber) {
            cell.imageView.image = cachedImage.image
            cell.title.text = "\(cachedImage.title)"
            cell.viewers.text = "\(cachedImage.viewers) Penonton"
        } else {
            self.cache.setObject(viewModel.cellViewModels[indexPath.item], forKey: itemNumber)
        }
        
        if indexPath.row == viewModel.cellViewModels.count - 1 && !viewModel.isLoading && viewModel.cellViewModels.count < viewModel.total  {
            viewModel.calculateOffset()
            viewModel.fetchDatas(offset: viewModel.offset, limit: viewModel.limit)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! FilmCell
        cell.imageView.image = viewModel.cellViewModels[indexPath.item].image
        cell.title.text = "\(viewModel.cellViewModels[indexPath.item].title)"
        cell.viewers.text = "\(viewModel.cellViewModels[indexPath.item].viewers) Penonton"
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.appDelegate?.getNotification(notificationType: viewModel.cellViewModels[indexPath.item].title)
    }
}

