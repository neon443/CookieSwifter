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
					List {
						Text("Game Name")
							.font(.caption)
							.bold()
						TextField("", text: $gameName)
							.textFieldStyle(RoundedBorderTextFieldStyle())
						Button("Save Game") {
							let saveDate = "Saved \(Date().formatted())"
							game.saveGame(name: gameName+saveDate)
						}
						
						Button("Load Game") {
							showSavedGames = true
						}
						.sheet(isPresented: $showSavedGames) {
							SavedGamesListView(game: game, selectedSave: $selectedSave)
						}
						.onChange(of: selectedSave) { newValue in
							if let saveName = newValue {
								game.loadGame(named: saveName)
							}
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
					Text("Achievements")
				}
				.badge(game.achievements.count)
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
				ItemView(game: game, buyQuantity: $buyQuantity, index: index)
			}
		}
	}
}

struct ItemView: View {
	@ObservedObject var game: CookieGame
	@Binding var buyQuantity: Int
	@State var index: Int
	
	var body: some View {
		let canBuy = !(game.cookies < game.totalCost(of: index, quantity: buyQuantity))
		let thisItem = game.items[index]
		HStack(spacing: 5) {
			Button(action: {
				game.buyItem(at: index, quantity: buyQuantity)
			}) {
				HStack {
					Text("\(thisItem.count) x")
					Text("\(thisItem.name)")
						.bold()
					Text("🍪\(thisItem.cps) per second")
					Spacer()
					Text("🍪\(game.totalCost(of: index, quantity: buyQuantity))")
						.font(.caption)
				}
				.padding(5)
				.background(Color.blue.opacity(canBuy ? 0.5 : 0.2))
				.cornerRadius(10)
			}
			.disabled(!canBuy)
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
		let canSell = !(game.items[index].count < buyQuantity)
		Button(action: {
			game.sellItem(at: index, quantity: buyQuantity)
		}) {
			Text("🍪\(game.totalCost(of: index, quantity: buyQuantity) / 2)")
				.padding(5)
				.background(Color.red.opacity(canSell ? 0.5 : 0.2))
				.cornerRadius(10)
				.font(.caption)
		}
		.disabled(!canSell)
	}
}


struct UpgradesListView: View {
	@ObservedObject var game: CookieGame
	
	var body: some View {
		VStack(spacing: 10) {
			ForEach(game.upgrades.indices, id: \.self) { index in
				let thisUpgrade = game.upgrades[index]
				Button(action: {
					game.purchaseUpgrade(at: index)
				}) {
					HStack {
						Text(thisUpgrade.name)
							.bold()
						Text(thisUpgrade.description)
						Spacer()
						Text("🍪\(thisUpgrade.cost)")
					}
					.padding(5)
					.background(thisUpgrade.isPurchased ? Color.green.opacity(0.2) : Color.gray.opacity(0.2))
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
