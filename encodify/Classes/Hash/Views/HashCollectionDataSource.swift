//
//  HashCollectionDataSource.swift
//  encodify
//
//  Created by 洪朔 on 2024/12/20.
//  Copyright © 2024年 Tuccuay. All rights reserved.
//

import UIKit

/// 哈希计算界面的数据源管理器
@MainActor
class HashCollectionDataSource {
    
    // MARK: - Types
    
    enum SectionType: Int, CaseIterable {
        case inputArea = 0
        case calculateButton = 1
        case formatSelector = 2
        case hashResults = 3
    }
    
    struct Item: Hashable, Sendable {
        let id = UUID()
        let type: ItemType
        
        enum ItemType: Sendable {
            case inputArea
            case calculateButton
            case formatSelector
            case hashGroup(Int) // section index
            case hashAlgorithm(Int, Int) // section index, row index
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        static func == (lhs: Item, rhs: Item) -> Bool {
            lhs.id == rhs.id
        }
    }
    
    // MARK: - Properties
    
    private weak var collectionView: UICollectionView?
    private var dataSource: UICollectionViewDiffableDataSource<SectionType, Item>!
    private var isUpdatingDataSource = false
    
    weak var delegate: HashCollectionDataSourceDelegate?
    
    // MARK: - Initialization
    
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        configureDataSource()
    }
    
    // MARK: - Data Source Configuration
    
    private func configureDataSource() {
        guard let collectionView = collectionView else { return }
        
        dataSource = UICollectionViewDiffableDataSource<SectionType, Item>(collectionView: collectionView) { [weak self] collectionView, indexPath, item in
            return self?.cell(for: collectionView, at: indexPath, item: item) ?? UICollectionViewCell()
        }
        
        // Configure supplementary views
        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            return self?.supplementaryView(for: collectionView, kind: kind, at: indexPath)
        }
    }
    
    private func cell(for collectionView: UICollectionView, at indexPath: IndexPath, item: Item) -> UICollectionViewCell {
        switch item.type {
        case .inputArea:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InputAreaCell", for: indexPath) as! InputAreaCell
            delegate?.configureInputAreaCell(cell)
            return cell
            
        case .calculateButton:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalculateButtonCell", for: indexPath) as! CalculateButtonCell
            delegate?.configureCalculateButtonCell(cell)
            return cell
            
        case .formatSelector:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FormatSelectorCell", for: indexPath) as! FormatSelectorCell
            delegate?.configureFormatSelectorCell(cell)
            return cell
            
        case .hashAlgorithm(let sectionIndex, let rowIndex):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HashAlgorithmCell", for: indexPath) as! HashAlgorithmCell
            delegate?.configureHashAlgorithmCell(cell, sectionIndex: sectionIndex, rowIndex: rowIndex)
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }
    
    private func supplementaryView(for collectionView: UICollectionView, kind: String, at indexPath: IndexPath) -> UICollectionReusableView? {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeaderView", for: indexPath) as! SectionHeaderView
            
            if indexPath.section == SectionType.hashResults.rawValue {
                headerView.configure(title: "Hash Results", subtitle: "Tap to copy • Long press to view full screen")
            }
            return headerView
        } else if kind == UICollectionView.elementKindSectionFooter {
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionFooterView", for: indexPath) as! SectionFooterView
            
            if indexPath.section == SectionType.hashResults.rawValue {
                footerView.configureSummary()
            } else {
                footerView.clear()
            }
            return footerView
        }
        
        return nil
    }
    
    // MARK: - Public Methods
    
    func updateSnapshot(with hashGroups: [HashGroup]) {
        guard !isUpdatingDataSource else { return }
        guard Thread.isMainThread else {
            Task { @MainActor in
                self.updateSnapshot(with: hashGroups)
            }
            return
        }
        
        isUpdatingDataSource = true
        
        var snapshot = NSDiffableDataSourceSnapshot<SectionType, Item>()
        
        // Add input area section
        snapshot.appendSections([.inputArea])
        snapshot.appendItems([Item(type: .inputArea)], toSection: .inputArea)
        
        // Add calculate button section
        snapshot.appendSections([.calculateButton])
        snapshot.appendItems([Item(type: .calculateButton)], toSection: .calculateButton)
        
        // Add format selector section
        snapshot.appendSections([.formatSelector])
        snapshot.appendItems([Item(type: .formatSelector)], toSection: .formatSelector)
        
        // Add hash results section with all algorithms
        snapshot.appendSections([.hashResults])
        var hashItems: [Item] = []
        
        for (sectionIndex, group) in hashGroups.enumerated() {
            for (rowIndex, _) in group.algorithms.enumerated() {
                hashItems.append(Item(type: .hashAlgorithm(sectionIndex, rowIndex)))
            }
        }
        
        snapshot.appendItems(hashItems, toSection: .hashResults)
        
        dataSource.apply(snapshot, animatingDifferences: true) { [weak self] in
            self?.isUpdatingDataSource = false
        }
    }
    
    func reloadHashResults() {
        guard !isUpdatingDataSource else { return }
        guard Thread.isMainThread else {
            Task { @MainActor in
                self.reloadHashResults()
            }
            return
        }
        
        isUpdatingDataSource = true
        
        var snapshot = dataSource.snapshot()
        
        if snapshot.sectionIdentifiers.contains(.hashResults) {
            let hashItems = snapshot.itemIdentifiers(inSection: .hashResults)
            snapshot.reloadItems(hashItems)
        }
        
        dataSource.apply(snapshot, animatingDifferences: false) { [weak self] in
            self?.isUpdatingDataSource = false
        }
    }
}

// MARK: - Delegate Protocol

@MainActor
protocol HashCollectionDataSourceDelegate: AnyObject {
    func configureInputAreaCell(_ cell: InputAreaCell)
    func configureCalculateButtonCell(_ cell: CalculateButtonCell)
    func configureFormatSelectorCell(_ cell: FormatSelectorCell)
    func configureHashAlgorithmCell(_ cell: HashAlgorithmCell, sectionIndex: Int, rowIndex: Int)
}
