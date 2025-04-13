import SwiftUI

// MARK: - Модель ограничения и целевой функции

struct Constraint {
    let a: Double
    let b: Double
    let c: Double
    let sign: InequalitySign
}

enum InequalitySign {
    case lessThanOrEqual, greaterThanOrEqual
}

struct ObjectiveFunction {
    let a: Double
    let b: Double
    let mode: OptimizationMode
}

enum OptimizationMode {
    case max, min
}

// MARK: - Пример задач

/// Задача А
let exampleAConstraints = [
    Constraint(a: 1, b: 2, c: 8, sign: .lessThanOrEqual),
    Constraint(a: 1, b: 1, c: 6, sign: .lessThanOrEqual),
    Constraint(a: 1, b: 3, c: 3, sign: .greaterThanOrEqual),
    Constraint(a: 1, b: 0, c: 0, sign: .greaterThanOrEqual),
    Constraint(a: 0, b: 1, c: 0, sign: .greaterThanOrEqual)
]
let exampleAObjective = ObjectiveFunction(a: 2, b: 5, mode: .max)

/// Задача B
let exampleBConstraints = [
    Constraint(a: 1, b: 1, c: 8, sign: .lessThanOrEqual),
    Constraint(a: 1, b: 3, c: 6, sign: .lessThanOrEqual),
    Constraint(a: 1, b: 3, c: 3, sign: .greaterThanOrEqual),
    Constraint(a: 1, b: 0, c: 0, sign: .greaterThanOrEqual),
    Constraint(a: 0, b: 1, c: 0, sign: .greaterThanOrEqual)
]
let exampleBObjective = ObjectiveFunction(a: 1, b: 3, mode: .min)

/// Задача C
let exampleCConstraints = [
    Constraint(a: 1, b: 2, c: 9, sign: .greaterThanOrEqual),
    Constraint(a: 1, b: 4, c: 8, sign: .greaterThanOrEqual),
    Constraint(a: 2, b: 1, c: 3, sign: .greaterThanOrEqual),
    Constraint(a: 1, b: 0, c: 0, sign: .greaterThanOrEqual),
    Constraint(a: 0, b: 1, c: 0, sign: .greaterThanOrEqual),
    Constraint(a: 1, b: 0, c: 100, sign: .lessThanOrEqual),
    Constraint(a: 0, b: 1, c: 100, sign: .lessThanOrEqual)
]
let exampleCObjective = ObjectiveFunction(a: 1, b: 3, mode: .max)

/// Задача D
let exampleDConstraints = [
    Constraint(a: 1, b: 2, c: 10, sign: .lessThanOrEqual),
    Constraint(a: 3, b: 1, c: 6, sign: .lessThanOrEqual),
    Constraint(a: 1, b: 1, c: 16, sign: .lessThanOrEqual),
    Constraint(a: 1, b: 0, c: 0, sign: .greaterThanOrEqual),
    Constraint(a: 0, b: 1, c: 0, sign: .greaterThanOrEqual)
]
let exampleDObjective = ObjectiveFunction(a: -5, b: 3, mode: .min)

// MARK: - Представление графика

struct LPGraphView: View {
    let constraints: [Constraint]
    let objective: ObjectiveFunction
    let cValue: Double
    let scale: CGFloat
    let size: CGSize

    var body: some View {
        Canvas { context, size in
            drawAxes(in: context, size: size)
            drawTicksAndLabels(in: context, size: size)
            drawFeasibleRegion(in: context, size: size)
            drawConstraints(in: context, size: size)
            drawObjectiveLine(in: context, size: size)
        }
        .background(Color.white)
    }

    func drawAxes(in context: GraphicsContext, size: CGSize) {
        let midX = size.width / 2
        let midY = size.height / 2

        var path = Path()
        path.move(to: CGPoint(x: 0, y: midY))
        path.addLine(to: CGPoint(x: size.width, y: midY))
        path.move(to: CGPoint(x: midX, y: 0))
        path.addLine(to: CGPoint(x: midX, y: size.height))

        context.stroke(path, with: .color(.gray), lineWidth: 1)
    }

    func drawTicksAndLabels(in context: GraphicsContext, size: CGSize) {
        let midX = size.width / 2
        let midY = size.height / 2
        let spacing: CGFloat = scale

        let font = Font.system(size: 10)

        for i in -10...10 {
            let x = midX + CGFloat(i) * spacing
            let y = midY - CGFloat(i) * spacing

            if x >= 0 && x <= size.width {
                var tick = Path()
                tick.move(to: CGPoint(x: x, y: midY - 3))
                tick.addLine(to: CGPoint(x: x, y: midY + 3))
                context.stroke(tick, with: .color(.black))

                if i != 0 {
                    let label = Text("\(i)").font(font)
                    context.draw(label, at: CGPoint(x: x, y: midY + 12), anchor: .top)
                }
            }

            if y >= 0 && y <= size.height {
                var tick = Path()
                tick.move(to: CGPoint(x: midX - 3, y: y))
                tick.addLine(to: CGPoint(x: midX + 3, y: y))
                context.stroke(tick, with: .color(.black))

                if i != 0 {
                    let label = Text("\(i)").font(font)
                    context.draw(label, at: CGPoint(x: midX - 6, y: y), anchor: .trailing)
                }
            }
        }
    }

    func drawConstraints(in context: GraphicsContext, size: CGSize) {
        for constraint in constraints {
            drawLine(a: constraint.a, b: constraint.b, c: constraint.c, color: .blue, in: context, size: size)
        }
    }

    func drawObjectiveLine(in context: GraphicsContext, size: CGSize) {
        drawLine(a: objective.a, b: objective.b, c: cValue, color: .red, in: context, size: size)
    }

    func drawLine(a: Double, b: Double, c: Double, color: Color, in context: GraphicsContext, size: CGSize) {
        guard b != 0 else { return }

        let width = size.width
        let height = size.height
        let toScreenX: (Double) -> CGFloat = { CGFloat($0) * scale + width / 2 }
        let toScreenY: (Double) -> CGFloat = { height / 2 - CGFloat($0) * scale }

        let x1 = -100.0
        let x2 = 100.0
        let y1 = (c - a * x1) / b
        let y2 = (c - a * x2) / b

        var path = Path()
        path.move(to: CGPoint(x: toScreenX(x1), y: toScreenY(y1)))
        path.addLine(to: CGPoint(x: toScreenX(x2), y: toScreenY(y2)))

        context.stroke(path, with: .color(color), lineWidth: 1.5)
    }

    func drawFeasibleRegion(in context: GraphicsContext, size: CGSize) {
        let width = size.width
        let height = size.height
        let toScreenX: (Double) -> CGFloat = { CGFloat($0) * scale + width / 2 }
        let toScreenY: (Double) -> CGFloat = { height / 2 - CGFloat($0) * scale }

        let points = feasibleRegionVertices()

        guard points.count >= 3 else { return }

        var path = Path()
        let first = points[0]
        path.move(to: CGPoint(x: toScreenX(first.x), y: toScreenY(first.y)))
        for point in points.dropFirst() {
            path.addLine(to: CGPoint(x: toScreenX(point.x), y: toScreenY(point.y)))
        }
        path.closeSubpath()

        context.fill(path, with: .color(Color.blue.opacity(0.2)))
    }

    func feasibleRegionVertices() -> [CGPoint] {
        var vertices: [CGPoint] = []

        for i in 0..<constraints.count {
            for j in i+1..<constraints.count {
                let c1 = constraints[i]
                let c2 = constraints[j]

                let det = c1.a * c2.b - c2.a * c1.b
                guard det != 0 else { continue }

                let x = (c1.c * c2.b - c2.c * c1.b) / det
                let y = (c1.a * c2.c - c2.a * c1.c) / det
                let point = CGPoint(x: x, y: y)

                if constraints.allSatisfy({ satisfies($0, point: point) }) {
                    vertices.append(point)
                }
            }
        }

        return convexHull(vertices)
    }

    func satisfies(_ constraint: Constraint, point: CGPoint) -> Bool {
        let lhs = constraint.a * point.x + constraint.b * point.y
        switch constraint.sign {
        case .lessThanOrEqual: return lhs <= constraint.c + 1e-6
        case .greaterThanOrEqual: return lhs >= constraint.c - 1e-6
        }
    }

    func convexHull(_ points: [CGPoint]) -> [CGPoint] {
        let sorted = points.sorted { $0.x != $1.x ? $0.x < $1.x : $0.y < $1.y }
        var lower: [CGPoint] = []

        for p in sorted {
            while lower.count >= 2 && cross(lower[lower.count - 2], lower.last!, p) <= 0 {
                lower.removeLast()
            }
            lower.append(p)
        }

        var upper: [CGPoint] = []
        for p in sorted.reversed() {
            while upper.count >= 2 && cross(upper[upper.count - 2], upper.last!, p) <= 0 {
                upper.removeLast()
            }
            upper.append(p)
        }

        return Array(lower.dropLast() + upper.dropLast())
    }

    func cross(_ o: CGPoint, _ a: CGPoint, _ b: CGPoint) -> Double {
        return (a.x - o.x) * (b.y - o.y) - (a.y - o.y) * (b.x - o.x)
    }
}

// MARK: - Основное представление

struct ContentView: View {
    @State private var selectedProblem = "A"
    @State private var scale: CGFloat = 20.0
    @State private var cValue: Double = 0.0
    
    var infoText: String {
        let modeText = currentObjective.mode == .max ? "максимум" : "минимум"
        let a = currentObjective.a
        let b = currentObjective.b
        let aStr = String(format: "%.1f", a)
        let bStr = String(format: "%.1f", b)
        
        let signB = b >= 0 ? "+" : "-"
        let bAbs = String(format: "%.1f", abs(b))
        
        return "Необходимо найти \(modeText)\nФункция: z = \(aStr)x \(signB) \(bAbs)y"
    }

    var currentConstraints: [Constraint] {
        switch selectedProblem {
        case "B": return exampleBConstraints
        case "C": return exampleCConstraints
        case "D": return exampleDConstraints
        default: return exampleAConstraints
        }
    }

    var currentObjective: ObjectiveFunction {
        switch selectedProblem {
        case "B": return exampleBObjective
        case "C": return exampleCObjective
        case "D": return exampleDObjective
        default: return exampleAObjective
        }
    }

    var body: some View {
        VStack {
            HStack {
                Picker("Выберите задачу", selection: $selectedProblem) {
                    Text("A").tag("A")
                    Text("B").tag("B")
                    Text("C").tag("C")
                    Text("D").tag("D")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                Text(infoText)
                    .font(.headline)
                    .padding()
            }

            GeometryReader { geo in
                LPGraphView(
                    constraints: currentConstraints,
                    objective: currentObjective,
                    cValue: cValue,
                    scale: scale,
                    size: geo.size
                )
            }

            VStack(spacing: 10) {
                Text("Масштаб: \(scale, specifier: "%.1f")")
                Slider(value: $scale, in: 5...100, step: 1)

                Text("Значение целевой функции: \(cValue, specifier: "%.1f")")
                Slider(value: $cValue, in: -50...50, step: 1)
            }
            .padding()
        }
        .frame(minWidth: 600, minHeight: 600)
    }
}

