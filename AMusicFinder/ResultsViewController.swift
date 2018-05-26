//
//  ResultsViewController.swift
//  AMusicFinder
//
//  Created by Kaka on 25/5/2018.
//  Copyright © 2018 Kaka. All rights reserved.
//

import UIKit
import AVKit

class ResultsViewController: UITableViewController {
    var viewModel: ResultsViewViewModel!
    
    /// music information to show
    var musics = [MusicInfo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // init View-Model
        viewModel = ResultsViewViewModel()
        viewModel.delegate = self
        
        tableView.accessibilityIdentifier = UITestingID.tableID
    }
    
    private func downloadArtwork(indexPath: IndexPath) {
        guard let url = URL(string: musics[indexPath.row].artworkUrl60) else {
            return
        }

        let task = URLSession.shared.dataTask(with: url) { responseData, responseUrl, err in
            if let error = err {
                // handle error that is not recognized
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            // image data
            if let data = responseData {
                // back to main thread
                DispatchQueue.main.async {
                    if let cell = self.tableView.cellForRow(at: indexPath) as? SongCell {
                        // cell still displaying
                        cell.artwork.image = UIImage(data: data)
                    }
                }
            }
        }
        
        // Run task
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return musics.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath) as! SongCell
        cell.accessibilityIdentifier = UITestingID.cellID(row: indexPath.row)
        
        let music = musics[indexPath.row]
        
        cell.trackLabel.text = music.trackName
        cell.artistLabel.text = music.artistName
        
        // download the artwork
        downloadArtwork(indexPath: indexPath)

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let url = URL(string: musics[indexPath.row].previewUrl) else {
            // preview URL can not be found
            let alert = UIAlertController(title: "Sorry", message: "No preview.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        // create the AVPlayer and present the play controller
        let avPlayer = AVPlayer(url: url)
        let avPlayerController = AVPlayerViewController()
        avPlayerController.player = avPlayer
        
        present(avPlayerController, animated: true, completion: nil)
    }
}

/**
 Implementation of `ResultViewDelegate`
 */
extension ResultsViewController: ResultViewDelegate {
    
}

/**
 Implementation of `UISearchBarDelegate`
 */
extension ResultsViewController: UISearchBarDelegate {
    /// inactivate the searchBar
    private func inactivate(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    /// show "cancel" when editing
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    /// return to original state
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        inactivate(searchBar: searchBar)
    }
    
    /// search action
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // get the search term
        guard let term = searchBar.text else {
            return
        }
        
        viewModel.searchMusic(term: term) { searchResult, err in
            if let error = err {
                // Got an Error
                if let searchErr = error as? SearchError {
                    // handle SearchError
                    switch searchErr {
                    case .termKeyNotSet:
                        let alert = UIAlertController(title: "Error", message: "Search keywords should be entered.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    return
                }
                
                // handle error that is not recognized
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
                
            }
            
            if let result = searchResult {
                // if got a searchResult, reload the tableview from Main thread
                DispatchQueue.main.async {
                    self.musics = result.results
                    self.tableView.reloadData()
                    
                    self.inactivate(searchBar: searchBar)
                }
            }
        }
    }
}
