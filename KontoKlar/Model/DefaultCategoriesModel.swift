import Foundation

func makeDefaultCategories() -> [Category] {
    return [
        // Expense
        Category(name: "Car", icon: "car", color: "colorBlue", type: .expense),
        Category(name: "Bank", icon: "creditcard", color: "colorBlue1", type: .expense),
        Category(name: "Business services", icon: "person.2", color: "colorBlue2", type: .expense),
        Category(name: "Charity", icon: "figure.roll", color: "colorGreen", type: .expense),
        Category(name: "State", icon: "network.badge.shield.half.filled", color: "colorGreen1", type: .expense),
        Category(name: "Children", icon: "figure.2.and.child.holdinghands", color: "colorGreen2", type: .expense),
        Category(name: "House", icon: "house", color: "colorYellow", type: .expense),
        Category(name: "Pets", icon: "fish", color: "colorYellow1", type: .expense),
        Category(name: "Eating out", icon: "popcorn", color: "colorYellow2", type: .expense),
        Category(name: "Health", icon: "heart", color: "colorRed", type: .expense),
        Category(name: "Beauty", icon: "fleuron", color: "colorRed1", type: .expense),
        Category(name: "Mobile connection", icon: "wifi", color: "colorRed2", type: .expense),
        Category(name: "Education", icon: "book", color: "colorBrown", type: .expense),
        Category(name: "Clothing and footwear", icon: "backpack", color: "colorBrown1", type: .expense),
        Category(name: "Present", icon: "gift", color: "colorBrown2", type: .expense),
        Category(name: "Food", icon: "cart", color: "colorPurple", type: .expense),
        Category(name: "Trips", icon: "airplane", color: "colorPurple1", type: .expense),
        Category(name: "Entertainment", icon: "music.mic", color: "colorPurple2", type: .expense),
        Category(name: "Technique", icon: "display", color: "colorGray", type: .expense),
        Category(name: "Transport", icon: "bus.fill", color: "colorGray1", type: .expense),

        // Income
        Category(name: "Rent", icon: "key", color: "colorBlue", type: .income),
        Category(name: "Exchange", icon: "arrow.triangle.2.circlepath", color: "colorBlue1", type: .income),
        Category(name: "Dividends", icon: "chart.xyaxis.line", color: "colorBlue2", type: .income),
        Category(name: "Wage", icon: "dollarsign", color: "colorGreen", type: .income),
        Category(name: "Present", icon: "shippingbox.circle", color: "colorGreen1", type: .income),
        Category(name: "Part time job", icon: "person.fill.checkmark", color: "colorGreen2", type: .income),
        Category(name: "Interest on accounts", icon: "percent", color: "colorYellow", type: .income)
    ]
}
