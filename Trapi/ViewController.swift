//
//  ViewController.swift
//  Trapi
//
//  Created by Dani Ximenez on 8/2/22.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
        
    @IBOutlet weak var tableView: UITableView!
    var traperos: [Trapero]?
    
    let url = URL(string: "https://private-ff2081-trapi1.apiary-mock.com/trappers")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
//        traperos = [Trapero(name: "Juan", genre: "POP", pic: nil),Trapero(name: "Juan", genre: "POP", pic: nil)]
        getData()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let trapero = traperos{
            return trapero.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celda = tableView.dequeueReusableCell(withIdentifier: "celdaID", for:
        indexPath) as? TrapiTableViewCell
        
        celda?.nameLabel.text = traperos![indexPath.row].name
        celda?.genreLabel.text = traperos![indexPath.row].genre

        DispatchQueue.global().async {
            do {
                let data = try Data(contentsOf: URL(string: self.traperos![indexPath.row].pic!)!)
                DispatchQueue.main.async {
                    celda?.imageVIew.image = UIImage(data: data)
                }
            } catch {
            }
        }
        
        return celda!
    }
    

    func getData(){
        let alert = UIAlertController(title: "Error", message: "Error de conexión", preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "Aceptar", style: .default, handler: nil))
        let session = URLSession.shared
        session.dataTask(with: url!) { data, response, error in
            guard let data = data, let response = response as? HTTPURLResponse, error == nil else {
                if let error = error {
                    DispatchQueue.main.async {
                        self.present(alert, animated: true, completion: nil)
                    }
                    print(error.localizedDescription)
                }
                return
            }
 
            if response.statusCode == 200 {
                let decoder = JSONDecoder()
                do {
                    let trapero = try decoder.decode([Trapero].self, from: data)
                    DispatchQueue.main.async {
                        print(trapero)
                        self.traperos = trapero
                        self.tableView.reloadData()
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }.resume()
    }

}

struct Trapero: Decodable {
    var name: String?
    var genre: String?
    var pic: String?
}

