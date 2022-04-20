//
//  ViewController.swift
//  DiffableTable
//
//  Created by Brio Taliaferro on 20.04.22.
//

import UIKit
import Combine

struct Item: Hashable {
    let number: String
    let id = UUID()
    
    static func generate() -> Item {
        let number = Int.random(in: 1...200)
        return Item(number: "\(number)")
    }
}

class ViewController: UITableViewController {
    
    let identifier = "Cell"
    @Published var items = [Item]()
    private var bag = Set<AnyCancellable>()

    private lazy var datasource = makeDataSource()
    var addButt : UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        addButt = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(more))
        navigationItem.rightBarButtonItem = addButt
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(fewer))

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: identifier)
        tableView.dataSource = datasource
        
        $items
            .removeDuplicates()
            .sink { [weak self] list in
                guard let self = self else {return}
                var snapshot = self.datasource.snapshot()
                snapshot.deleteAllItems()
                snapshot.appendSections([0])
                snapshot.appendItems(list, toSection: 0)
                self.datasource.apply(snapshot, animatingDifferences: true)
            }
            .store(in: &bag)
        
        
        $items
            .removeDuplicates()
            .sink { [weak self] list in
                if list.count >= 5 {
                    self?.addButt.isEnabled = false
                } else {
                    self?.addButt.isEnabled = true
                }
            }
            .store(in: &bag)

    }
    
    func makeDataSource() -> UITableViewDiffableDataSource<Int, Item> {
        
        return UITableViewDiffableDataSource(tableView: tableView) {  tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: self.identifier, for: indexPath)
            cell.textLabel?.text = item.number
            return cell
        }
    }
    
    @objc func more() {
        items.append(Item.generate())
    }
    
    @objc func fewer() {
        items.removeLast()
    }
    

    /*
    // old style

    var items = ["eins", "zwei", "drei"]

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row]
        return cell
    }
     */

}

