//
//  ToneKnowsTests.swift
//  ToneKnowsTests
//
//  Created by anilkumar on 24/03/25.
//

import Testing
import UIKit
@testable import ToneKnows

struct ToneKnowsTests {
    
    // MARK: - HeaderView Tests
    
    @Test func headerView_init_setsUpUI() {
        let headerView = HeaderView(frame: .zero)
        
        #expect(headerView.backgroundColor == .containerBackground)
        #expect(headerView.subviews.contains(headerView.backImageView))
        #expect(headerView.subviews.contains(headerView.titleLabel))
        #expect(!headerView.backImageView.translatesAutoresizingMaskIntoConstraints)
        #expect(!headerView.titleLabel.translatesAutoresizingMaskIntoConstraints)
    }
    
    @Test func headerView_constraints_areCorrect() {
        let headerView = HeaderView(frame: .zero)
        
        let constraints = headerView.constraints
        #expect(constraints.contains { $0.firstAnchor == headerView.backImageView.leadingAnchor && $0.constant == 15 })
        #expect(constraints.contains { $0.firstAnchor == headerView.backImageView.widthAnchor && $0.constant == 30 })
        #expect(constraints.contains { $0.firstAnchor == headerView.backImageView.heightAnchor && $0.constant == 30 })
        #expect(constraints.contains { $0.firstAnchor == headerView.titleLabel.centerXAnchor })
    }
    
    @Test func headerView_backButtonTapped_callsDelegate() {
        let headerView = HeaderView(frame: .zero)
        let mockDelegate = MockBackButtonDelegate()
        headerView.delegate = mockDelegate
        
        headerView.backButtonTapped()
        
        #expect(mockDelegate.backButtonActionCalled)
    }
    
    @Test func headerView_setTitle_updatesLabel() {
        let headerView = HeaderView(frame: .zero)
        
        headerView.setTitle("Test Title")
        
        #expect(headerView.titleLabel.text == "Test Title")
    }
    
    // MARK: - SearchTextFieldView Tests
    
    @Test func searchTextFieldView_init_setsUpUI() {
        let searchView = SearchTextFieldView(frame: .zero)
        
        #expect(searchView.backgroundColor == .containerBackground)
        #expect(searchView.layer.cornerRadius == 6)
        #expect(searchView.layer.borderWidth == 0.8)
        #expect(searchView.layer.borderColor == UIColor.lightGray.cgColor)
        #expect(searchView.subviews.contains(searchView.searchTextField))
        #expect(searchView.subviews.contains(searchView.clearButton))
        #expect(!searchView.searchTextField.translatesAutoresizingMaskIntoConstraints)
        #expect(!searchView.clearButton.translatesAutoresizingMaskIntoConstraints)
    }
    
    @Test func searchTextFieldView_constraints_areCorrect() {
        let searchView = SearchTextFieldView(frame: .zero)
        
        let constraints = searchView.constraints
        #expect(constraints.contains { $0.firstAnchor == searchView.searchTextField.leadingAnchor && $0.constant == 10 })
        #expect(constraints.contains { $0.firstAnchor == searchView.clearButton.trailingAnchor && $0.constant == -10 })
        #expect(constraints.contains { $0.firstAnchor == searchView.clearButton.widthAnchor && $0.constant == 40 })
        #expect(constraints.contains { $0.firstAnchor == searchView.heightAnchor && $0.constant == 45 })
    }
    
    @Test func searchTextFieldView_textFieldDidChange_showsClearButton() {
        let searchView = SearchTextFieldView(frame: .zero)
        
        searchView.searchTextField.text = "Test"
        searchView.textFieldDidChange(searchView.searchTextField)
        
        #expect(!searchView.clearButton.isHidden)
    }
    
    @Test func searchTextFieldView_textFieldDidChange_hidesClearButtonWhenEmpty() {
        let searchView = SearchTextFieldView(frame: .zero)
        
        searchView.searchTextField.text = ""
        searchView.textFieldDidChange(searchView.searchTextField)
        
        #expect(searchView.clearButton.isHidden)
    }
}

class MockBackButtonDelegate: BackButtonDelegate {
    var backButtonActionCalled = false
    
    func backButtonAction() {
        backButtonActionCalled = true
    }
}
