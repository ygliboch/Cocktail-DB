//
//  FiltersViewController.swift
//  Cocktail DB
//
//  Created by Yaroslava Hlibochko on 12.12.2019.
//  Copyright © 2019 Yaroslava Hlibochko. All rights reserved.
//

import UIKit

class FiltersViewController: UIViewController {

    //MARK: Properties & IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var applyFilterButton: UIButton!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    internal var delegate: FilterCategoriesDelegate?
    private var categories: [Category] = []
    private var selectedCategories: [Category] = []
    
    private var newSelectedCategories: [Category] = [] {
        didSet {
            newSelectedCategories.containsSameElements(as: selectedCategories) ?
                hideApplyButton() :
                showApplyButton()
        }
    }
    
    //MARK: ViewController life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        selectedCategories = delegate?.selectedCategories ?? []
        categories = delegate?.categories ?? []
        newSelectedCategories = selectedCategories
        configureApplyButton()
    }
    
    //MARK: Business logic
    
    private func configureApplyButton() {
        applyFilterButton.clipsToBounds = true
        applyFilterButton.alpha = 0
        applyFilterButton.layer.cornerRadius = 10
        applyFilterButton.layer.borderWidth = 1
        applyFilterButton.layer.borderColor = UIColor.black.cgColor
    }
    
    private func showApplyButton() {
        guard applyFilterButton.alpha == 0 else { return }
        
        tableViewBottomConstraint.constant += 16 + applyFilterButton.frame.height
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
            self.applyFilterButton.alpha = 1
        }
    }
    
    private func hideApplyButton() {
        guard applyFilterButton.alpha != 0 else { return }
        
        tableViewBottomConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
            self.applyFilterButton.alpha = 0
        }
    }
    
    @IBAction func applyFilter(_ sender: Any) {
        delegate?.selectedCategories = newSelectedCategories
        navigationController?.popViewController(animated: true)
    }
    
}

//MARK: TableView

extension FiltersViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath) as? FilterTableViewCell
        cell?.categoryLabel.text = categories[indexPath.row].strCategory ?? ""
        cell?.selectionStyle = .none
        if newSelectedCategories.contains(categories[indexPath.row]) {
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        }
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        newSelectedCategories.append(categories[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let index = newSelectedCategories.lastIndex { (category) -> Bool in
            return category == categories[indexPath.row]
        }
        guard index != nil else { return }
        newSelectedCategories.remove(at: index!)
    }
}

