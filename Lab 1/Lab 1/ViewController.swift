//
//  ViewController.swift
//  Lab 1
//
//  Created by Paul Angelo Sy on 2/22/23.
//

import UIKit

extension UIImage {
  convenience init?(url: URL?) {
    guard let url = url else { return nil }
            
    do {
      self.init(data: try Data(contentsOf: url))
    } catch {
      print("Cannot load image from url: \(url) with error: \(error)")
      return nil
    }
  }
}

struct Pokemon: Codable {
    var name: String
    var url: String
}

struct PokemonList: Codable{
    let results: [Pokemon]
}




class tableViewController: UITableViewController {
    var types : [String] = []
    var pokemonName: [String] = []
    var pokemonURL: [String] = []

    func decode(completion: @escaping () -> Void) {
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=151") else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            let decoder = JSONDecoder()
            if let data = data {
                do {
                    let tasks = try decoder.decode(PokemonList.self, from: data)
                    tasks.results.forEach { i in
                        self?.addPokemon(name: i.name, url: i.url)
                    }
                    completion()
                } catch {
                    print(error)
                }
            }
        }
        task.resume()
    }
    
    func getPokemonType(pokemonName: String, completion: @escaping ([String]?) -> Void) {
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon/\(pokemonName.lowercased())") else {
            print("Invalid URL")
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                let types = json["types"] as! [[String: Any]]
                let typeNames = types.map { $0["type"] as! [String: Any] } .map { $0["name"] as! String }
                completion(typeNames)
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
                completion(nil)
            }
        }
        
        task.resume()
    }


        
    func addPokemon(name: String, url: String) {
        pokemonName.append(name)
        pokemonURL.append(url)
    }


    func getPokemon(completion: @escaping ([String]) -> Void) {
        decode {
            completion(self.pokemonName)
        }
    }
    


    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "tableViewCell", bundle: nil), forCellReuseIdentifier: "cellTemplate")
        tableView.delegate = self
        tableView.dataSource = self
        getPokemon { [weak self] pokemon in
            self?.pokemonName = pokemon
            self?.tableView.reloadData()
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellTemplate", for: indexPath) as? tableViewCell else {
            return UITableViewCell()
        }
        if (String(indexPath.row+1) != ""){
            cell.cellLabel.text = NSLocalizedString("pokemon-name-" + String(indexPath.row+1), comment: "")
        } else{
            let alert = UIAlertController(title: "An Error Occured", message: "Failed to load Pokemon. Please check your internet connection and try again.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            }))
            self.present(alert, animated: true, completion: nil)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let imageURL : String = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/" + String(indexPath.row + 1) + ".png"
        let selected = pokemonName[indexPath.row]
        
        // call getPokemonType asynchronously
        getPokemonType(pokemonName: selected) { typeString in
            if let typeString = typeString {
                // update types array with selected Pokemon's type
                self.types = typeString
                
                // push secondView onto navigation stack
                DispatchQueue.main.async {
                    let storyboard = UIStoryboard(name:"Main", bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier: "secondView") as? secondView
                    viewController?.name = NSLocalizedString("pokemon-name-" + String(indexPath.row+1), comment: "")
                    viewController?.img = imageURL
                    viewController?.types = self.types
                    self.navigationController?.pushViewController(viewController!, animated: true)
                }
            } else {
                let alert = UIAlertController(title: "An Error Occured", message: "Failed to load Pokemon. Please check your internet connection and try again.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pokemonName.count
    }
}
