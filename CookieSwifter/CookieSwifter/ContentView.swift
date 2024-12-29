//
//  ContentView.swift
//  CookieSwifter
//
//  Created by Nihaal Sharma on 16/12/2024.
//

import SwiftUI

struct ContentView: View {
	@ObservedObject var game: CookieGame
	@State private var selectedSave: String? = nil
	@State private var showSavedGames: Bool = false
	@State private var buyQuantity: Int = 1
	@State var gameName: String
	@State var showAchievemetns: Bool = false
	
	var body: some View {
		VStack {
			HStack {
				Text("Game Name")
					.font(.caption)
					.bold()
				TextField("", text: $gameName)
					.textFieldStyle(RoundedBorderTextFieldStyle())
			}
			HStack {
				Text("\(game.cookies)")
					.font(.largeTitle)
					.fontWeight(.bold)
				Spacer()
				VStack {
					CookieTapView(game: game)
					Text("CPS: \(game.cps)")
						.font(.headline)
				}
			}
			TabView {
				Tab {
					Picker("Buy", selection: $buyQuantity) {
						ForEach([1, 10, 100], id: \.self) { option in
							Text("\(option)").tag(option)
						}
					}
					.pickerStyle(SegmentedPickerStyle())
					.padding(.top)
					ScrollView(.vertical) {
						ItemsListView(game: game, buyQuantity: $buyQuantity)
					}
//					Spacer()
				} label: {
					Image(systemName: "star.fill")
					Text("Items")
				}
				
				Tab {
					ScrollView(.vertical) {
						UpgradesListView(game: game)
					}
				} label: {
					Image(systemName: "wand.and.stars")
					Text("Upgrades")
				}
				
				Tab {
					HStack {
						VStack {
							Button("Save Game") {
								let saveDate = "Saved \(Date().formatted())"
								game.saveGame(name: gameName+saveDate)
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
							SavedGamesListView(game: game, selectedSave: $selectedSave)
						}
						.onChange(of: selectedSave) { newValue in
							if let saveName = newValue {
								game.loadGame(named: saveName)
							}
						}
						
						Spacer()
						
						VStack {
							CookieTapView(game: game)
							Text("CPS: \(game.cps)")
								.font(.headline)
						}
					}

				} label: {
					Image(systemName: "gear")
					Text("Settings")
				}
				Tab {
					ScrollView(.vertical) {
						AchievementsView(achievements: game.achievements)
					}
				} label: {
					Image(systemName: "trophy.fill")
						.badge(game.achievements.count)
					Text("hi")
				}
			}
		}
	}
}

struct SavedGamesListView: View {
	@ObservedObject var game: CookieGame
	@Binding var selectedSave: String?
	
	var body: some View {
		NavigationView {
			List {
				ForEach(game.savedGames, id: \ .name) { save in
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
					indexSet.map { game.savedGames[$0].name }.forEach(game.deleteGame(named:))
				}
			}
			.navigationTitle("Saved Games")
		}
	}
}

struct CookieTapView: View {
	@ObservedObject var game: CookieGame
	
	var body: some View {
		VStack {
			Button(action: {
				game.cookies += 1
				game.checkAchievements()
			}) {
				Text("🍪")
					.font(.system(size: 75))
			}
		}
	}
}
struct ItemsListView: View {
	@ObservedObject var game: CookieGame
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
		VStack {
			ForEach(game.items.indices, id: \.self) { index in
				ItemView(game: game, buyQuantity: buyQuantity, index: index)
			}
		}
	}
}

struct ItemView: View {
	@ObservedObject var game: CookieGame
	@State var buyQuantity: Int
	@State var index: Int
	
	var body: some View {
		HStack(spacing: 5) {
			Button(action: {
				game.buyItem(at: index, quantity: buyQuantity)
			}) {
				HStack {
					Text("\(game.items[index].count) x \(game.items[index].name)")
						.bold()
					Spacer()
					Text("🍪 \(game.totalCost(of: index, quantity: buyQuantity))")
						.font(.caption2)
				}
				.padding(5)
				.background(Color.blue.opacity(0.2))
				.cornerRadius(10)
			}
			.disabled(game.cookies < game.totalCost(of: index, quantity: buyQuantity))
			SellButton(
				game: game,
				index: $index,
				buyQuantity: $buyQuantity
			)
		}
	}
}

struct SellButton: View {
	@ObservedObject var game: CookieGame
	@Binding var index: Int
	@Binding var buyQuantity: Int
	
	var body: some View {
		Button(action: {
			game.sellItem(at: index, quantity: buyQuantity)
		}) {
			Text("🍪 \(game.totalCost(of: index, quantity: buyQuantity) / 2)")
				.padding(5)
				.background(Color.red.opacity(0.2))
				.cornerRadius(10)
		}
		.disabled(game.items[index].count < buyQuantity)
	}
}


struct UpgradesListView: View {
	@ObservedObject var game: CookieGame
	
	var body: some View {
		VStack(spacing: 10) {
			Text("Upgrades")
				.font(.footnote)
			ForEach(game.upgrades.indices, id: \.self) { index in
				Button(action: {
					game.purchaseUpgrade(at: index)
				}) {
					HStack {
						Text(game.upgrades[index].name)
							.bold()
						Text(game.upgrades[index].description)
						Spacer()
						Text("🍪 \(game.upgrades[index].cost)")
					}
					.padding(5)
					.background(game.upgrades[index].isPurchased ? Color.green.opacity(0.2) : Color.gray.opacity(0.2))
					.cornerRadius(10)
				}
				.disabled(game.cookies < game.upgrades[index].cost || game.upgrades[index].isPurchased)
			}
		}
	}
}

#Preview {
	ContentView(game: CookieGame(), gameName: "Preview Bakery")
}
