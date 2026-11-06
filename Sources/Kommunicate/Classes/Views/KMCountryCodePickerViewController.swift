//
//  KMCountryCodePickerViewController.swift
//  Kommunicate
//

import UIKit

class KMCountryCodePickerViewController: UITableViewController, UISearchResultsUpdating, Localizable {
    private static let cellIdentifier = "KMCountryCodeCell"

    private let selectedIsoCode: String?
    private let localizationFileName: String
    private let onSelect: (KMCountryCode) -> Void
    private var filteredCountries = KMCountryCodeHelper.countries

    init(selectedCountry: KMCountryCode?, localizationFileName: String, onSelect: @escaping (KMCountryCode) -> Void) {
        selectedIsoCode = selectedCountry?.isoCode
        self.localizationFileName = localizationFileName
        self.onSelect = onSelect
        super.init(style: .plain)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Light mode only, with explicit white backgrounds so the sheet never shows grey or dark surfaces.
        overrideUserInterfaceStyle = .light
        let themeColor = KMPreChatFormStyle.themeColor
        view.backgroundColor = .white
        tableView.backgroundColor = .white
        tableView.separatorColor = KMPreChatFormStyle.borderColor
        tableView.tintColor = themeColor

        title = localizedString(forKey: "PreChatSelectCountryTitle", fileName: localizationFileName)
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        cancelButton.tintColor = themeColor
        navigationItem.leftBarButtonItem = cancelButton

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [
            .foregroundColor: KMPreChatFormStyle.textColor,
            .font: UIFont(name: "HelveticaNeue-Medium", size: 17) ?? UIFont.systemFont(ofSize: 17, weight: .medium)
        ]
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance

        let searchController = UISearchController(searchResultsController: nil)
        searchController.overrideUserInterfaceStyle = .light
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.tintColor = themeColor
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true

        tableView.keyboardDismissMode = .onDrag
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Scroll before the sheet animates in, so the list doesn't visibly jump to the selected country afterwards.
        if let index = filteredCountries.firstIndex(where: { $0.isoCode == selectedIsoCode }) {
            tableView.layoutIfNeeded()
            tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .middle, animated: false)
        }
    }

    @objc private func cancelTapped() {
        // Dismiss from the presenter so an active search controller is dismissed along with the picker.
        presentingViewController?.dismiss(animated: true)
    }

    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text?.trimmingCharacters(in: .whitespaces) ?? ""
        filteredCountries = searchText.isEmpty ? KMCountryCodeHelper.countries : KMCountryCodeHelper.countries.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
                || $0.dialCode.contains(searchText)
                || $0.isoCode.caseInsensitiveCompare(searchText) == .orderedSame
        }
        tableView.reloadData()
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        filteredCountries.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellIdentifier) ?? makeCell()
        let country = filteredCountries[indexPath.row]
        cell.textLabel?.text = "\(country.flag)  \(country.name)"
        cell.detailTextLabel?.text = country.dialCode
        cell.accessoryType = country.isoCode == selectedIsoCode ? .checkmark : .none
        return cell
    }

    /// Styled once on creation; reused cells keep their styling.
    private func makeCell() -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: Self.cellIdentifier)
        cell.backgroundColor = .white
        cell.textLabel?.font = KMPreChatFormStyle.inputFont
        cell.textLabel?.textColor = KMPreChatFormStyle.textColor
        cell.detailTextLabel?.font = KMPreChatFormStyle.inputFont
        cell.detailTextLabel?.textColor = KMPreChatFormStyle.labelColor
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let country = filteredCountries[indexPath.row]
        presentingViewController?.dismiss(animated: true) { [onSelect] in
            onSelect(country)
        }
    }
}
