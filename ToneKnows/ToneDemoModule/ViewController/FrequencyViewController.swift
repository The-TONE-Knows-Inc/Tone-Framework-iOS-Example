//
//  FrequencyViewController.swift
//  ToneDemo
//
//  Created by Balan iOS on 20/02/25.
//

import UIKit

class FrequencyViewController: BaseViewController {
    
    override func initView() {
        super.initView()
        frequencyTableView.dataSource       = self
        frequencyTableView.delegate         = self
    }
    
    override func initAppearView() {
        super.initAppearView()
        self.emptyLabel.isHidden            = !toneSequences.isEmpty
        self.frequencyTableView.isHidden    = toneSequences.isEmpty
        self.frequencyTableView.reloadData()
        
        if !(UserDefaults.isFrameworkRunning ?? false) {
            toneFramework.start()
            enableToneFrameworkFeatures()
            UserDefaults.isFrameworkRunning = true
        }
    }
    
    override func setupLayout() {
        view.addSubview(frequencyTableView)
        view.addSubview(emptyLabel)
        
        NSLayoutConstraint.activate([
            frequencyTableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            frequencyTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            frequencyTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            frequencyTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func didUpdateToneSequences(_ toneSequences: [String]) {
        self.toneSequences = toneSequences
        DispatchQueue.main.async {
            self.emptyLabel.isHidden = !toneSequences.isEmpty
            self.frequencyTableView.isHidden = toneSequences.isEmpty
            self.frequencyTableView.reloadData()
        }
    }
}

extension FrequencyViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toneSequences.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FrequencyListCell", for: indexPath) as? FrequencyListCell else {
            return UITableViewCell()
        }
        cell.configure(with: toneSequences[indexPath.row])
        return cell
    }
}
