//
//  GameManager.swift
//  CookieSwifter
//
//  Created by Nihaal Sharma on 16/12/2024.
//


import Foundation

class CookieGame: ObservableObject {
	@Published var cookies: Int = 0
	@Published var cps: Int = 0
	@Published var savedGames: [SavedGame] = []
	@Published var items: [Item] = [
		Item(name: "Finger", cps: 1, baseCost: 10, count: 0),
		Item(name: "Chef", cps: 4, baseCost: 50, count: 0),
		Item(name: "Farm", cps: 16, baseCost: 200, count: 0),
		Item(name: "Mine", cps: 64, baseCost: 800, count: 0),
		Item(name: "Factory", cps: 256, baseCost: 3200, count: 0),
		Item(name: "Bank", cps: 1024, baseCost: 12800, count: 0)
	]
	@Published var upgrades: [Upgrade] = [
		Upgrade(name: "Golden Finger", description: "Double the CPS of fingers.", cost: 500, appliesTo: "Finger", isPurchased: false),
		Upgrade(name: "Farm Efficiency", description: "Farms are 50% more efficient.", cost: 2000, appliesTo: "Farm", isPurchased: false),
		Upgrade(name: "Double the Dough", description: "Doubles the CPS of all items.", cost: 10000, appliesTo: "All", isPurchased: false),
		Upgrade(name: "Banker’s Delight", description: "Banks generate 2x cookies.", cost: 50000, appliesTo: "Bank", isPurchased: false),
		Upgrade(name: "Efficient Farms", description: "Farms are 10% cheaper.", cost: 15000, appliesTo: "Farm", isPurchased: false),
		Upgrade(name: "Factory Booster", description: "Factories are 50% more efficient.", cost: 100000, appliesTo: "Factory", isPurchased: false),
		Upgrade(name: "Golden Era", description: "Triple CPS for 30 seconds.", cost: 200000, appliesTo: "Temporary", isPurchased: false)
	]
	@Published var achievements: [Achievement] = []

	private let saveKey = "CookieGameSave"
	var timer: Timer?
	
	func saveGame(name: String) {
		let save = SavedGame(
			name: name,
			cookies: cookies,
			cps: cps,
			items: items,
			achievements: achievements
		)
		savedGames.append(save)
		persistSavedGames()
	}

	func loadGame(named name: String) {
		guard let save = savedGames.first(where: { $0.name == name }) else { return }
		cookies = save.cookies
		cps = save.cps
		items = save.items
		achievements = save.achievements
	}

	func deleteGame(named name: String) {
		savedGames.removeAll { $0.name == name }
		persistSavedGames()
	}

	private func persistSavedGames() {
		if let data = try? JSONEncoder().encode(savedGames) {
			UserDefaults.standard.set(data, forKey: saveKey)
		}
	}

	func loadSavedGames() {
		guard let data = UserDefaults.standard.data(forKey: saveKey),
			  let saves = try? JSONDecoder().decode([SavedGame].self, from: data) else { return }
		savedGames = saves
	}

	init() {
		//FLAG: DONT REMOVE
		//im so stupid
		startTimer()
		loadSavedGames()
	}

	func startTimer() {
		if timer == nil {
			timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
				DispatchQueue.main.async {
					self.cookies += self.cps
					self.checkAchievements()
				}
			}
		}
	}

	func buyItem(at index: Int, quantity: Int) {
		let cost = totalCost(of: index, quantity: quantity)
		guard cookies >= cost else { return }

		cookies -= cost
		items[index].count += quantity
		cps += items[index].cps * quantity
	}

	func sellItem(at index: Int, quantity: Int) {
		guard items[index].count >= quantity else { return }

		items[index].count -= quantity
		cps -= items[index].cps * quantity
		let sellValue = totalCost(of: index, quantity: quantity) / 2
		cookies += sellValue
	}

	func purchaseUpgrade(at index: Int) {
		let upgrade = upgrades[index]
		guard cookies >= upgrade.cost, !upgrade.isPurchased else { return }

		if upgrade.appliesTo == "All" {
			for i in items.indices {
				items[i].cps *= 2
			}
			cps = items.reduce(0) { $0 + $1.cps * $1.count }
		} else if upgrade.appliesTo == "Temporary" {
			DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
				self.cps /= 3
			}
			cps *= 3
		} else if let itemIndex = items.firstIndex(where: { $0.name == upgrade.appliesTo }) {
			var item = items[itemIndex]
			if upgrade.name.contains("Efficien") {
				item.cps = Int(Double(item.cps) * 1.5)
			} else {
				item.cps *= 2
			}
		}

		cookies -= upgrade.cost
		upgrades[index].isPurchased = true
	}

	func totalCost(of index: Int, quantity: Int) -> Int {
		var total = 0
		for i in 0..<quantity {
			total += Int(Double(items[index].baseCost) * pow(1.1, Double(items[index].count + i)))
		}
		return total
	}

	func checkAchievements() {
		let achievementList = [
			Achievement(title: "Cookie Beginner", description: "Earn 100 cookies."),
			Achievement(title: "Cookie Enthusiast", description: "Earn 10,000 cookies."),
			Achievement(title: "Master Baker", description: "Earn 1,000,000 cookies."),
			Achievement(title: "Quick Clicker", description: "Tap the cookie 100 times in under 10 seconds."),
			Achievement(title: "Investment Master", description: "Own 10 of every item type."),
			Achievement(title: "Upgrade Collector", description: "Purchase all available upgrades."),
			Achievement(title: "Ultimate Tycoon", description: "Earn 10 billion cookies.")
		]

		for achievement in achievementList {
			if !achievements.contains(where: { $0.title == achievement.title }) {
				switch achievement.title {
				case "Cookie Beginner" where cookies >= 100,
					 "Cookie Enthusiast" where cookies >= 10000,
					 "Master Baker" where cookies >= 1000000,
					 "Quick Clicker" where cps >= 100,
					 "Investment Master" where items.allSatisfy({ $0.count >= 10 }),
					 "Upgrade Collector" where upgrades.allSatisfy({ $0.isPurchased }),
					 "Ultimate Tycoon" where cookies >= 10000000000:
					achievements.append(achievement)
				default:
					continue
				}
			}
		}
	}
}

// MARK: - Game State for Saving
struct GameState: Codable {
	let cookies: Int
	let cps: Int
	let items: [Item]
	let upgrades: [Upgrade]
	let achievements: [Achievement]
}

struct Item: Codable {
	let name: String
	var cps: Int
	let baseCost: Int
	var count: Int
}

struct Upgrade: Codable {
	let name: String
	let description: String
	let cost: Int
	let appliesTo: String
	var isPurchased: Bool
}

struct Achievement: Codable {
	let title: String
	let description: String
}

struct SavedGame: Codable {
	let name: String
	let cookies: Int
	let cps: Int
	let items: [Item]
	let achievements: [Achievement]
}
