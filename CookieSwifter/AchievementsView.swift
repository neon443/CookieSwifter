//
//  AchievementsView.swift
//  CookieSwifter
//
//  Created by Nihaal Sharma on 28/12/2024.
//

import SwiftUI

struct AchievementButton: View {
	@ObservedObject var game: CookieGame
	@Binding var showAchievements: Bool
	
	var body: some View {
		VStack(spacing: 10) {
			Button(action: {
				showAchievements.toggle()
			}) {
				Text("\(game.achievements.count) Achievements")
					.font(.title3)
					.padding(5)
					.background(Color.purple.opacity(0.2))
					.cornerRadius(10)
			}
			.sheet(isPresented: $showAchievements) {
				AchievementsView(achievements: game.achievements)
			}
		}
	}
}
struct AchievementsView: View {
	let achievements: [Achievement]
	
	var body: some View {
		NavigationView {
			List(achievements, id: \.title) { achievement in
				VStack(alignment: .leading) {
					Text(achievement.title)
						.font(.headline)
					Text(achievement.description)
						.font(.subheadline)
						.foregroundColor(.gray)
				}
			}
			.navigationTitle("Achievements")
		}
	}
}

#Preview {
	AchievementsView(
		achievements: [
			Achievement(
				title: "Cookie Beginner",
				description: "Earn 100 cookies."
			)
		]
	)
}
