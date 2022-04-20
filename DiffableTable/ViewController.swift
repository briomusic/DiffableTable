//
//  ViewController.swift
//  DiffableTable
//
//  Created by Brio Taliaferro on 20.04.22.
//

import UIKit

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
    var items = [Item]()
    private lazy var datasource = makeDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(more))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(fewer))

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: identifier)
        tableView.dataSource = datasource
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
        update()
    }
    
    @objc func fewer() {
        items.removeLast()
        update()
    }
    
    func update() {
        var snapshot = datasource.snapshot()
        snapshot.deleteAllItems()
        snapshot.appendSections([0])
        snapshot.appendItems(items, toSection: 0)
        datasource.apply(snapshot, animatingDifferences: true)
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

