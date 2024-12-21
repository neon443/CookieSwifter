//
//  ContentView.swift
//  CookieSwifter
//
//  Created by Nihaal Sharma on 16/12/2024.
//

import SwiftUI

struct ContentView: View {
	@ObservedObject var gameManager: CookieGame
	@State private var selectedSave: String? = nil
	@State private var showSavedGames: Bool = false
	@State private var buyQuantity: Int = 1
	@State var gameName: String
	@State var showAchievemetns: Bool = false
	
	var body: some View {
		VStack(spacing: 10) {
			Text("\(gameManager.cookies)")
				.font(.largeTitle)
				.fontWeight(.bold)
			HStack {
				Text("Game Name")
					.font(.caption)
					.bold()
				TextField("", text: $gameName)
					.textFieldStyle(RoundedBorderTextFieldStyle())
			}
			.padding(.horizontal)
			
			Picker("Buy", selection: $buyQuantity) {
				ForEach([1, 10, 100], id: \.self) { option in
					Text("\(option)").tag(option)
				}
			}
			.pickerStyle(SegmentedPickerStyle())
			.padding(.horizontal)
			.padding(.top)
			ItemsListView(gameManager: gameManager, buyQuantity: $buyQuantity)
			UpgradesListView(gameManager: gameManager)
			
			Spacer()
			HStack {
				VStack {
					Button("Save Game") {
						let saveDate = "Saved \(Date().formatted())"
						gameManager.saveGame(name: gameName+saveDate)
					}
					.padding()
					.background(Color.green)
					.foregroundColor(.white)
					.cornerRadius(10)
					
					Button("Load Game") {
						showSavedGames = true
					}
					.padding()
					.background(Color.blue)
					.foregroundColor(.white)
					.cornerRadius(10)
				}
				.sheet(isPresented: $showSavedGames) {
					SavedGamesListView(gameManager: gameManager, selectedSave: $selectedSave)
				}
				.onChange(of: selectedSave) { newValue in
					if let saveName = newValue {
						gameManager.loadGame(named: saveName)
					}
				}
				
				Spacer()
				
				VStack {
					CookieTapView(gameManager: gameManager)
					Text("CPS: \(gameManager.cps)")
						.font(.headline)
				}
				Spacer()
				
				AchievementButton(
					gameManager: gameManager,
					showAchievements: $showAchievemetns
				)
			}
			.padding(.horizontal)
		}
	}
}

struct SavedGamesListView: View {
	@ObservedObject var gameManager: CookieGame
	@Binding var selectedSave: String?
	
	var body: some View {
		NavigationView {
			List {
				ForEach(gameManager.savedGames, id: \ .name) { save in
					HStack {
						VStack(alignment: .leading) {
							Text(save.name).font(.headline)
							Text("Cookies: \(save.cookies), CPS: \(save.cps)").font(.subheadline)
							Text("Items: \(save.items.count), Achievements: \(save.achievements.count)").font(.footnote)
						}
						Spacer()
						Button("Load") {
							selectedSave = save.name
						}
						.padding(5)
						.background(Color.orange)
						.foregroundColor(.white)
						.cornerRadius(5)
					}
				}
				.onDelete { indexSet in
					indexSet.map { gameManager.savedGames[$0].name }.forEach(gameManager.deleteGame(named:))
				}
			}
			.navigationTitle("Saved Games")
		}
	}
}

struct CookieTapView: View {
	@ObservedObject var gameManager: CookieGame
	
	var body: some View {
		VStack(spacing: 10) {
			Button(action: {
				gameManager.cookies += 1
				gameManager.checkAchievements()
			}) {
				Text("🍪")
					.font(.system(size: 75))
			}
		}
	}
}
struct ItemsListView: View {
	@ObservedObject var gameManager: CookieGame
	@Binding var buyQuantity: Int
	
	var body: some View {
		HStack {
			Text("Buy")
				.font(.footnote)
			Spacer()
			Text("Items")
				.font(.footnote)
			Spacer()
			Text("Sell")
				.font(.footnote)
		}
		.padding(.horizontal, 5)
		VStack(spacing: 10) {
			ForEach(gameManager.items.indices, id: \.self) { index in
				HStack(spacing: 10) {
					Button(action: {
						gameManager.buyItem(at: index, quantity: buyQuantity)
					}) {
						HStack {
							Text("\(gameManager.items[index].count) x \(gameManager.items[index].name)")
							Spacer()
							Text("🍪 \(gameManager.totalCost(of: index, quantity: buyQuantity))")
								.font(.caption2)
						}
						.padding(5)
						.background(Color.blue.opacity(0.2))
						.cornerRadius(10)
					}
					.disabled(gameManager.cookies < gameManager.totalCost(of: index, quantity: buyQuantity))
					//					if gameManager.cookies < gameManager.totalCost(of: index, quantity: buyQuantity) {
					//						Gauge(
					//							value: gameManager.cookies,
					//							in: 1..<gameManager
					//								.totalCost(of: index, quantity: buyQuantity),
					//							label: Text("d")
					//						)
					//					}
					
					SellButton(
						gameManager: gameManager,
						index: index,
						buyQuantity: buyQuantity
					)
				}
			}
		}
	}
}
struct SellButton: View {
	@ObservedObject var gameManager: CookieGame
	@State var index: Int
	@State var buyQuantity: Int
	
	var body: some View {
		Button(action: {
			gameManager.sellItem(at: index, quantity: buyQuantity)
		}) {
			Text("🍪 \(gameManager.totalCost(of: index, quantity: buyQuantity) / 2)")
				.padding(5)
				.background(Color.red.opacity(0.2))
				.cornerRadius(10)
		}
		.disabled(gameManager.items[index].count < buyQuantity)
	}
}
struct UpgradesListView: View {
	@ObservedObject var gameManager: CookieGame
	
	var body: some View {
		VStack(spacing: 10) {
			Text("Upgrades")
				.font(.footnote)
			ForEach(gameManager.upgrades.indices, id: \.self) { index in
				Button(action: {
					gameManager.purchaseUpgrade(at: index)
				}) {
					HStack {
						Text(gameManager.upgrades[index].name)
						Text(gameManager.upgrades[index].description)
						Spacer()
						Text("🍪 \(gameManager.upgrades[index].cost)")
					}
					.padding(5)
					.background(gameManager.upgrades[index].isPurchased ? Color.green.opacity(0.2) : Color.gray.opacity(0.2))
					.cornerRadius(10)
				}
				.disabled(gameManager.cookies < gameManager.upgrades[index].cost || gameManager.upgrades[index].isPurchased)
			}
		}
	}
}
struct AchievementButton: View {
	@ObservedObject var gameManager: CookieGame
	@Binding var showAchievements: Bool
	
	var body: some View {
		VStack(spacing: 10) {
			Button(action: {
				showAchievements.toggle()
			}) {
				Text("\(gameManager.achievements.count) Achievements")
					.font(.title3)
					.padding(5)
					.background(Color.purple.opacity(0.2))
					.cornerRadius(10)
			}
			.sheet(isPresented: $showAchievements) {
				AchievementsView(achievements: gameManager.achievements)
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

