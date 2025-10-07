//
//  SwipeView.swift
//  NeoLed
//
//  Created by Purvi Sancheti on 25/09/25.
//


import Foundation
import SwiftUI

struct SwipeView: View {
    
    @State private var currentIndex = 0
    @State private var shownextScreen = false
    let totalScreens = 7
    var showPaywall: () -> Void
    @State private var selections: Set<String> = []
    @AppStorage("currentOnboardingIndex") private var currentOnboardingIndex: Int = 0
    
    var screens: [AnyView] {
        [
            AnyView(WelcomeView()),
            AnyView(OnboardingView(imageName: "intro1",
                                   title: "Choose From\n Templates",)),
            AnyView(OnboardingView(imageName: "intro2",
                                   title: "Create Custom\n Designs",)),
            AnyView(OnboardingView(imageName: "intro3",
                                   title: "Preview & Share\n Instantly",)),
            AnyView(OnboardingView(imageName: "intro4",
                                   title: "Save & Edit Your\n Designs",)),
            AnyView(RatingView()),
            AnyView(UserCommentsView()),

        ]
    }

    
    let notificationfeedback = UINotificationFeedbackGenerator()
    let impactfeedback = UIImpactFeedbackGenerator(style: .medium)
    let selectionfeedback = UISelectionFeedbackGenerator()
    
    var body: some View {
        PagingTabView(selectedIndex: $currentIndex, tabCount: totalScreens, spacing: 0) {
            Group {
                
                WelcomeView()
                    .tag(0)
                
                OnboardingView(imageName: "intro1",
                                       title: "Choose From\n Templates")
                               .tag(1)
                
                OnboardingView(imageName: "intro2",
                                       title: "Create Custom\n Designs")
                              .tag(2)
                
                OnboardingView(imageName: "intro3",
                                       title: "Preview & Share\n Instantly")
                               .tag(3)
                
                OnboardingView(imageName: "intro4",
                                       title: "Save & Edit Your\n Designs")
                                        .tag(4)
            
                
                RatingView()
                    .tag(5)
                
                UserCommentsView()
                    .tag(6)
                

                
            }
        } buttonAction: {
            handleButtonPress()
        }
        .animation(.easeInOut(duration: 0.3), value: currentIndex)
        .onChange(of: currentIndex) { _, newValue in
            currentOnboardingIndex = newValue // This tracks both button presses and swipes
        }
        .onAppear {
            // Ensure AppStorage is initialized on first launch
            currentOnboardingIndex = currentIndex
            print("SwipeView appeared, initialized currentOnboardingIndex to: \(currentOnboardingIndex)")
        }

    }
    
    // MARK: - Button Press Logic
    private func handleButtonPress() {
        // Add haptic feedback first
        if currentIndex == 6 {
               showPaywall()
           }
           else {
               self.currentIndex += 1
               currentOnboardingIndex = currentIndex // Add this single line
           }
    }

  }

