import UIKit

var CompanyName: String = "Aperture Laboratories"
var capital: Double = 13848392.12
var profit: Double = 0.00
var employees: [String: String] = [
    "Cave Johnson": "CEO",
    "Caroline Johnson": "Assistant to CEO",
    "Doug Rattman": "Researcher"
]
var Patents: [String] = [
    "Portal Gun", "Repulsion Gel", "Propulsion Gel", "Conversion Gel",
    "Personality Core", "GLaDOS", "Sentry Turret"
]
var recentlyUsedTestChambers: Set<Int> = [124, 4772, 2, 1, 4822, 222, 135, 4738, 5543]
var isProfitable: Bool = false
var daysSinceAccident: Int = 12
var inventory: [String: Int] = [
    "Portal Gun": 5,
    "Moon Rocks (crate)": 573984,
    "Repulsion Gel (barrel)": 12345
]
var salePricing: [String: Double] = [
    "Portal Gun": 750000000.00,
    "Repulsion Gel (barrel)": 999999.99
]

// Function to hire employees
@MainActor func hire(name: String, title: String) {
    print("-- Hiring (\(name)) as (\(title)) --")
    employees[name] = title
}

// Function to fire employees
@MainActor func fire(name: String, reason: String = "Unspecified Reason") {
    if let removedTitle = employees.removeValue(forKey: name) {
        print("-- Firing \(name) (\(removedTitle)) for \(reason) --.")
    } else {
        print("--< Fire Error: Employee \(name) not found >--")
    }
}

// Function to log a used test chamber
@MainActor func useChamber(num: Int) {
    recentlyUsedTestChambers.insert(num)
    print("-- Running test in chamber \(num). --")
}

@MainActor func cleanChamber(num: Int) {
    if recentlyUsedTestChambers.contains(num) {
        recentlyUsedTestChambers.remove(num)
        print("-- Chamber \(num) cleaned --")
    }
}

// Returns pluralized words for better formatting
@MainActor func Plurality(action: String, qty: Int, item: String, container: String) -> [String] {
    var plurality: [String] = []
    
    let pluralItem = qty == 1 ? item : (item.hasSuffix("s") ? item : item + "s")
    plurality.append(pluralItem)
    
    let pluralContainer = container.isEmpty ? "" : (container.hasSuffix("s") ? container + " of " : container + "s of ")
    plurality.append(pluralContainer)
    
    return plurality
}

// Function to purchase items
@MainActor func purchase(item: String, price: Double, qty: Int = 1, container: String = "") {
    let plurality = Plurality(action: "Purchased", qty: qty, item: item, container: container)
    
    print("-- Purchased \(qty) \(plurality[1])\(plurality[0]) --")
    
    capital -= price * Double(qty)
    profit -= price * Double(qty)
    
    let itemKey = container.isEmpty ? item : "\(item) (\(container))"
    
    if let existingQty = inventory[itemKey] {
        inventory[itemKey] = existingQty + qty
    } else {
        inventory[itemKey] = qty
    }
}

@MainActor func sell(item: String, qty: Int) {
    // Find exact inventory key (handles items with containers)
    let matchingKeys = inventory.keys.filter { $0.contains(item) }
    
    guard let matchedItem = matchingKeys.first else {
        print("--< Sale Error: \(item) not found in inventory >--")
        return
    }
    
    guard let price = salePricing[item] else {
        print("--< Sale Error: price not specified for \(item) >--")
        return
    }
    
    guard let stock = inventory[matchedItem], stock >= qty else {
        print("--< Sale Error: Not enough \(item) in stock >--")
        return
    }
    
    // Extract container name from inventory key
    let containerRegex = "\\((.*?)\\)"
    var container = ""
    
    if let match = matchedItem.range(of: containerRegex, options: .regularExpression) {
        container = String(matchedItem[match]).replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "")
    }
    
    // Get correct plural forms
    let plurality = Plurality(action: "Sold", qty: qty, item: item, container: container)
    
    print("-- Sold \(qty) \(plurality[1])\(plurality[0]) --")
    
    capital += Double(qty) * price
    profit += Double(qty) * price
    inventory[matchedItem]! -= qty
    
    // Remove from inventory if stock is depleted
    if inventory[matchedItem]! <= 0 {
        inventory.removeValue(forKey: matchedItem)
    }
}

// Function to advance the business by one day
@MainActor func advanceDay(hadAccident: Bool = false) {
    print("-- Advancing To Next Day")
    if hadAccident {
        print("|  Accident Occured -- Resetting Count")
        daysSinceAccident = 0
    } else {
        print("|  No Accident Occured -- Incrementing Count")
        daysSinceAccident += 1
    }
    
    print("|  Adding Profit to Capital")
    capital += profit
    print("|  Checking Profitability")
    isProfitable = profit > 0
    print("|  Resetting Profit For The Next Day")
    profit = 0.00 //
}

// Function to print company report
@MainActor func printReport() {
    print("\n\n\n======== \(CompanyName) ========")
    print("| Capital: $\(capital)")
    print("| Profitable: \(isProfitable ? "Yes" : "No")")
    print("| Days Since Last Accident: \(daysSinceAccident)")
    print("| Recently Used Test Chambers: \(recentlyUsedTestChambers.sorted())")

    print("\nEmployee List:")
    for (name, title) in employees {
        print("|  \(name) - \(title)")
    }

    print("\nPatents:")
    for patent in Patents {
        print("|  \(patent)")
    }

    print("\nInventory:")
    for (item, qty) in inventory {
        print("|  \(item): \(qty)")
    }

    print("\nSale Prices:")
    for (item, price) in salePricing {
        print("|  \(item): $\(price)")
    }

    print("======== End of Report ========\n\n")
}

// --------- RUNNING TEST CASES --------- //

print("======== Starting Info ========")
printReport()

hire(name: "Alice", title: "Engineer")

purchase(item: "Asbestos", price: 494.44, qty: 1000, container: "Barrel")
sell(item: "Portal Gun", qty: 1)

useChamber(num: 5)
useChamber(num: 19)
useChamber(num: 582)
useChamber(num: 139)
useChamber(num: 892)
useChamber(num: 111)
useChamber(num: 5)
useChamber(num: 582)

advanceDay(hadAccident: true)

printReport()
