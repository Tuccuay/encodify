//
//  EncodePagerViewController.swift
//  encodify
//
//  Created by 洪朔 on 2024/12/20.
//  Copyright © 2024年 Tuccuay. All rights reserved.
//

import UIKit
import SnapKit

class EncodePagerViewController: UIViewController {
    
    // MARK: - Properties
    
    private let methods: [EncodeMethod] = [.base64, .unicode, .morse, .uri, .hex, .binary, .rot13]
    
    private var currentMethodIndex = 0
    private var isEncodeMode = true
    
    // MARK: - UI Components
    
    private lazy var headerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemBackground
        return view
    }()
    
    private lazy var modeSegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Encode", "Decode"])
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(modeChanged(_:)), for: .valueChanged)
        
        // Modern styling
        control.backgroundColor = UIColor.secondarySystemGroupedBackground
        control.selectedSegmentTintColor = UIColor.encodifyTintColor
        control.setTitleTextAttributes([
            .foregroundColor: UIColor.label,
            .font: UIFont.preferredFont(forTextStyle: .headline)
        ], for: .normal)
        control.setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: UIFont.preferredFont(forTextStyle: .headline)
        ], for: .selected)
        
        return control
    }()
    
    private lazy var methodCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MethodCell.self, forCellWithReuseIdentifier: MethodCell.identifier)
        
        return collectionView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.applyContentCardStyle()
        return view
    }()
    
    private lazy var encodeDecodeViewController = EncodeDecodeViewController()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupInitialState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
    
    // MARK: - Setup
    
    private func setupNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Encode & Decode"
        
        // Add clear and share buttons
        let clearButton = UIBarButtonItem(
            image: UIImage(systemName: "trash"),
            style: .plain,
            target: self,
            action: #selector(clearAll)
        )
        
        let shareButton = UIBarButtonItem(
            image: UIImage(systemName: "square.and.arrow.up"),
            style: .plain,
            target: self,
            action: #selector(shareOutput)
        )
        
        navigationItem.rightBarButtonItems = [shareButton, clearButton]
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.systemGroupedBackground
        
        // Add header area
        view.addSubview(headerView)
        headerView.addSubview(modeSegmentedControl)
        headerView.addSubview(methodCollectionView)
        
        // Add content area
        view.addSubview(contentView)
        
        // Add child view controller
        addChild(encodeDecodeViewController)
        contentView.addSubview(encodeDecodeViewController.view)
        encodeDecodeViewController.didMove(toParent: self)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        headerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(120)
        }
        
        modeSegmentedControl.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(32)
        }
        
        methodCollectionView.snp.makeConstraints { make in
            make.top.equalTo(modeSegmentedControl.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(8)
        }
        
        contentView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
        
        encodeDecodeViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupInitialState() {
        updateCurrentMethod()
    }
    
    private func updateCurrentMethod() {
        let currentMethod = methods[currentMethodIndex]
        
        encodeDecodeViewController.configure(with: currentMethod, isEncodeMode: isEncodeMode)
        methodCollectionView.reloadData()
        
        // Scroll to current selected method
        let indexPath = IndexPath(item: currentMethodIndex, section: 0)
        methodCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        
        // All methods support both encoding and decoding
        modeSegmentedControl.setEnabled(true, forSegmentAt: 1)
    }
    
    // MARK: - Actions
    
    @objc private func modeChanged(_ sender: UISegmentedControl) {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        
        isEncodeMode = sender.selectedSegmentIndex == 0
        updateCurrentMethod()
    }
    
    @objc private func clearAll() {
        encodeDecodeViewController.clearAll()
    }
    
    @objc private func shareOutput() {
        encodeDecodeViewController.shareOutput()
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegate

extension EncodePagerViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return methods.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MethodCell.identifier, for: indexPath) as! MethodCell
        
        let method = methods[indexPath.item]
        let isSelected = indexPath.item == currentMethodIndex
        
        cell.configure(with: method.displayName, isSelected: isSelected)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        
        currentMethodIndex = indexPath.item
        updateCurrentMethod()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let method = methods[indexPath.item]
        
        // Calculate text width
        let font = UIFont.preferredFont(forTextStyle: .callout)
        let textSize = (method.displayName as NSString).size(withAttributes: [.font: font])
        let width = textSize.width + 32 // Left and right margins
        
        return CGSize(width: max(width, 80), height: 36)
    }
}

// MARK: - Method Cell

class MethodCell: UICollectionViewCell {
    static let identifier = "MethodCell"
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .callout)
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
        
        // Rounded corners and styling
        contentView.layer.cornerRadius = 18
        contentView.layer.cornerCurve = .continuous
    }
    
    func configure(with title: String, isSelected: Bool) {
        titleLabel.text = title
        
        if isSelected {
            contentView.backgroundColor = UIColor.encodifyTintColor
            titleLabel.textColor = .white
        } else {
            contentView.backgroundColor = UIColor.secondarySystemGroupedBackground
            titleLabel.textColor = UIColor.label
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }
}
