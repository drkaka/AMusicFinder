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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // init View-Model
        viewModel = ResultsViewViewModel()
        viewModel.delegate = self
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
        return viewModel.musicCount
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath) as! SongCell
        
        let (trackName, artistName, _) = viewModel.musicDetail(row: indexPath.row)
        
        cell.trackLabel.text = trackName
        cell.artistLabel.text = artistName
        
        // request the artwork
        viewModel.requestMusicPreview(row: indexPath.row)

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let (_, _, previewURL) = viewModel.musicDetail(row: indexPath.row)
        
        guard let url = URL(string: previewURL) else {
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
    /// music is reloaded
    func musicReloaded() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    /// music priview is downloaded
    func previewDownloaded(row: Int, imageData: Data) {
        DispatchQueue.main.async {
            if let cell = self.tableView.cellForRow(at: IndexPath(row: row, section: 0)) as? SongCell {
                // cell still displaying
                cell.artwork.image = UIImage(data: imageData)
            }
        }
    }
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
        
        viewModel.searchMusic(term: term) { err in
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
            
            // no error, return to normal status
            DispatchQueue.main.async {
                self.inactivate(searchBar: searchBar)
            }
        }
    }
}
