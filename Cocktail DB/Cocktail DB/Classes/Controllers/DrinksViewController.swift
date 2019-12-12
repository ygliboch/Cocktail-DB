//
//  DrinksViewController.swift
//  Cocktail DB
//
//  Created by Yaroslava Hlibochko on 11.12.2019.
//  Copyright © 2019 Yaroslava Hlibochko. All rights reserved.
//

import UIKit
import Moya
import SDWebImage
import MBProgressHUD

protocol FilterCategoriesDelegate {
    var selectedCategories: [Category] { get set }
    var categories: [Category] { get set }
}

class DrinksViewController: UIViewController {

    //MARK: Properties & IBOutlets
    
    private enum State {
      case loading
      case ready
      case error
    }
    
    private struct Section {
        var category: String
        var drinks: [Drink]
    }
    
    private var state: State = .loading {
      didSet {
        switch state {
        case .ready:
            MBProgressHUD.hide(for: view, animated: true)
            tableView.reloadData()
        case .loading:
            let loadingNotification = MBProgressHUD.showAdded(to: view, animated: true)
            loadingNotification.mode = MBProgressHUDMode.indeterminate
            loadingNotification.bezelView.layer.cornerRadius = 15
        case .error:
            MBProgressHUD.hide(for: view, animated: true)
            showAlert(title: "Something went wrong", message: " Please check your connection")
        }
      }
    }
    
    @IBOutlet weak var tableView: UITableView!
    private let filterButton: UIButton = UIButton()
    private let provider = MoyaProvider<Cocktail>()
    private var lastCategoryIndex: Int = 0
    private var sections: [Section] = []
    
    //from FilterCategoriesDelegate
    internal var categories: [Category] = []
    internal var selectedCategories: [Category] = [] {
        didSet {
            refresh()
            configureFilterButtonIcon()
        }
    }
    
    //MARK: Controller life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureFilterButton()
        
        getAllCategories { (allCategories) in
            self.categories = allCategories
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.addCategory()
        }
    }
    
    //MARK: Business logic
    
    private func configureFilterButton () {
        filterButton.setImage(UIImage(named: "filterIcon"), for: .normal)
        filterButton.addTarget(self, action: #selector(openFilterCotrollerButton), for: .touchUpInside)

        let barButton = UIBarButtonItem(customView: filterButton)
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    private func getAllCategories(complation: @escaping (([Category])->Void)) {
        state = .loading
        provider.request(.categories) { (result) in
            switch result{
            case .success(let response):
                do {
                    let categories = try (response.map(Categories.self).drinks ?? [])
                    complation(categories)
                } catch {
                    self.state = .error
                }
            case .failure(_):
                self.state = .error
            }
        }
    }
    
    //load next category
    private func addCategory() {
        let category = (selectedCategories.isEmpty ?
            categories[lastCategoryIndex].strCategory! :
            selectedCategories[lastCategoryIndex].strCategory!)
        
        getDrinksBy(category: category) { (drinks) in
            self.sections.append(Section(category: category, drinks: drinks))
            self.state = .ready
        }
    }
    
    //load drinks from next category
    private func getDrinksBy(category: String, complation: @escaping(([Drink])->Void)) {
        provider.request(.coctails(category)) { (result) in
            switch result {
            case .success(let response):
                do {
                    let drinks = try response.map(Drinks.self).drinks ?? []
                    complation(drinks)
                } catch {
                    self.state = .error
                }
            case .failure(_):
                self.state = .error
            }
        }
    }
    
    private func refresh() {
        lastCategoryIndex = 0
        sections = []
        state = .loading
        addCategory()
        tableView.scrollToNearestSelectedRow(at: UITableView.ScrollPosition(rawValue: 0)!, animated: true)
        tableView.reloadData()
    }
    
    private func configureFilterButtonIcon() {
        if !selectedCategories.isEmpty {
            filterButton.setImage(UIImage(named: "filterWithIndicator"), for: .normal)
        } else {
            filterButton.setImage(UIImage(named: "filterIcon"), for: .normal)
        }
    }

    @objc func openFilterCotrollerButton() {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let filtersController = mainStoryboard.instantiateViewController(withIdentifier: "FilterController") as! FiltersViewController
        filtersController.delegate = self
        navigationController?.pushViewController(filtersController, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
}

//MARK: Filte Categories Delegate

extension DrinksViewController: FilterCategoriesDelegate {
}

//MARK: TableView

extension DrinksViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard state == .ready else { return 0 }
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard state == .ready else { return 0 }
        return sections[section].drinks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard state == .ready else { return UITableViewCell() }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DrinkCell", for: indexPath) as? DrinkTableViewCell
        cell?.nameLabel.text = sections[indexPath.section].drinks[indexPath.row].strDrink ?? ""
        cell?.photoImageView.sd_setImage(with: URL(string: sections[indexPath.section].drinks[indexPath.row].strDrinkThumb!), completed: nil)
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 30))

        let label = UILabel()
        label.frame = CGRect.init(x: 28, y: 0,
                                  width: headerView.frame.width - 28,
                                  height: headerView.frame.height)
        label.text = sections[section].category.uppercased()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .black

        headerView.addSubview(label)

        headerView.backgroundColor = UIColor(red: 239.0 / 255.0, green: 239.0 / 255.0, blue: 244.0 / 255.0, alpha: 1.0)

        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard state == .ready else { return }
        guard lastCategoryIndex + 1 < (selectedCategories.isEmpty ?
            categories.count :
            selectedCategories.count)
            else { return }
        
        let offsetY = scrollView.contentOffset.y
        let contentHight = scrollView.contentSize.height

        if offsetY > contentHight - scrollView.frame.height * 3 {
            lastCategoryIndex += 1
            state = .loading
            addCategory()
        }
    }
}
