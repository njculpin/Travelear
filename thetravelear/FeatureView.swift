//
//  FeatureView.swift
//  Travelear
//
//  Created by Nick Culpin on 12/24/19.
//  Copyright © 2019 thetravelear. All rights reserved.
//

import Foundation

class FeatureView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var cellId = "cellId"
    
    var items = ["Unlock all soundscapes","Listen offline"]
    
    private var pageControl = UIPageControl(frame: .zero)
    
    var listCollectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.decelerationRate = UIScrollView.DecelerationRate.fast
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = .black
        cv.isPagingEnabled = true
        return cv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews(){
        addSubview(listCollectionView)
        listCollectionView.fillSuperview()
        listCollectionView.backgroundColor = .white
        listCollectionView.dataSource = self
        listCollectionView.delegate = self
        listCollectionView.register(FeatureCell.self, forCellWithReuseIdentifier: cellId)
        listCollectionView.isAccessibilityElement = false
        configurePageControl()
        Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(self.scrollAutomatically), userInfo: nil, repeats: true)
    }
    
    func configurePageControl() {
        pageControl.currentPage = 0
        pageControl.tintColor = UIColor.TravRed()
        pageControl.pageIndicatorTintColor = UIColor.gray
        pageControl.currentPageIndicatorTintColor = UIColor.TravRed()
        pageControl.numberOfPages = items.count
        addSubview(pageControl)
        pageControl.anchor(nil, left: leftAnchor, bottom: listCollectionView.bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 2, bottomConstant: 2, rightConstant: 2, widthConstant: 0, heightConstant: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let Cell = listCollectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! FeatureCell
            Cell.productLabel.text = items[indexPath.row]
            return Cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: listCollectionView.bounds.size.width, height: listCollectionView.bounds.size.height)
    }
    
    internal func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(listCollectionView.contentOffset.x / listCollectionView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
    }
    
    @objc func scrollAutomatically(_ timer1: Timer) {
        for cell in listCollectionView.visibleCells {
            let indexPath: IndexPath? = listCollectionView.indexPath(for: cell)
            if ((indexPath?.row)! < items.count - 1){
                let pageNumber = round(listCollectionView.contentOffset.x / listCollectionView.frame.size.width)
                pageControl.currentPage = Int(pageNumber)
                let indexPath1: IndexPath?
                indexPath1 = IndexPath.init(row: (indexPath?.row)! + 1, section: (indexPath?.section)!)
                listCollectionView.scrollToItem(at: indexPath1!, at: .right, animated: true)
            }
            else{
                let pageNumber = round(listCollectionView.contentOffset.x / listCollectionView.frame.size.width)
                pageControl.currentPage = Int(pageNumber)
                let indexPath1: IndexPath?
                indexPath1 = IndexPath.init(row: 0, section: (indexPath?.section)!)
                listCollectionView.scrollToItem(at: indexPath1!, at: .left, animated: true)
            }

        }
    }
}
