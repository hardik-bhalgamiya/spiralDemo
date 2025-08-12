//
//  SpiralViewController.swift
//  VPracticalTask
//
//  Created by Hardik Bhalgamiya on 13/08/25.
//

import UIKit


class SpiralViewController: UIViewController {
   
    let spiralView = SpiralView()
       let numberField = UITextField()
       let startButton = UIButton(type: .system)
       
       override func viewDidLoad() {
           super.viewDidLoad()
           view.backgroundColor = .white
           
           // Spiral view
           spiralView.translatesAutoresizingMaskIntoConstraints = false
           self.view.addSubview(spiralView)
           
           // Controls container
           let controls = UIStackView()
           controls.axis = .horizontal
           controls.spacing = 12
           controls.alignment = .center
           controls.translatesAutoresizingMaskIntoConstraints = false
           
           numberField.placeholder = "Enter number (e.g. 25)"
           numberField.borderStyle = .roundedRect
           numberField.keyboardType = .numberPad
           numberField.widthAnchor.constraint(equalToConstant: 150).isActive = true
           
           startButton.setTitle("START", for: .normal)
           startButton.addTarget(self, action: #selector(startTapped), for: .touchUpInside)
           startButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
           startButton.layer.borderColor = UIColor.systemBlue.cgColor
           startButton.layer.borderWidth = 1
           startButton.layer.cornerRadius = 6
           startButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
           
           controls.addArrangedSubview(numberField)
           controls.addArrangedSubview(startButton)
           self.view.addSubview(controls)
           
           // layout
           NSLayoutConstraint.activate([
               spiralView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
               spiralView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 20),
               spiralView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.88),
               spiralView.heightAnchor.constraint(equalTo: spiralView.widthAnchor),
               
               controls.centerXAnchor.constraint(equalTo: view.centerXAnchor),
               controls.bottomAnchor.constraint(equalTo: spiralView.topAnchor, constant: -18),
           ])
           
           // default
           spiralView.count = 25
           numberField.text = "25"
           
           // dismiss keyboard tap
           let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
           view.addGestureRecognizer(tap)
       }
       
       @objc func dismissKeyboard() {
           view.endEditing(true)
       }
       
       @objc func startTapped() {
           dismissKeyboard()
           guard let txt = numberField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                 let n = Int(txt), n > 0 else {
               let alert = UIAlertController(title: "Invalid", message: "Enter a positive integer", preferredStyle: .alert)
               alert.addAction(UIAlertAction(title: "OK", style: .default))
               present(alert, animated: true)
               return
           }
           spiralView.count = n
       }
}
class SpiralView: UIView {
    var count: Int = 25 {
        didSet { setNeedsDisplay() }
    }

    // visual config
    var cellPadding: CGFloat = 6.0
    var numberFont: UIFont = .systemFont(ofSize: 14, weight: .semibold)
    var lineWidth: CGFloat = 3.0

    override func draw(_ rect: CGRect) {
        guard count > 0 else { return }
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.clear(rect)

        // compute spiral coordinates & grid size
        let (positions, cols, rows) = computeSpiralGrid(count: count)
        let gridSize = max(cols, rows)

        // layout: cell size (square cells), center grid in view
        let minSide = min(rect.width, rect.height)
        let cellSize = (minSide - 2*cellPadding) / CGFloat(gridSize)
        let totalGridSize = CGFloat(gridSize) * cellSize
        // origin to draw the square grid centred in the view
        let originX = (rect.width - totalGridSize) / 2.0
        let originY = (rect.height - totalGridSize) / 2.0

        // convert grid indices to CGPoint centers
        let centers: [CGPoint] = positions.map { col, row in
            let x = originX + CGFloat(col) * cellSize + cellSize/2
            let y = originY + CGFloat(row) * cellSize + cellSize/2
            return CGPoint(x: x, y: y)
        }

        // draw connecting path
        if centers.count > 1 {
            let path = UIBezierPath()
            path.lineWidth = lineWidth
            path.lineJoinStyle = .round
            path.lineCapStyle = .round
            UIColor.systemBlue.setStroke()
            path.move(to: centers[0])
            for p in centers.dropFirst() {
                path.addLine(to: p)
            }
            path.stroke()
        }

        // draw circles and numbers
        for (i, center) in centers.enumerated() {
            let r = min(cellSize, 44) * 0.28
            let circleRect = CGRect(x: center.x - r, y: center.y - r, width: 2*r, height: 2*r)
            let circlePath = UIBezierPath(ovalIn: circleRect)
            UIColor.white.setFill()
            circlePath.fill()
            UIColor.systemGreen.setStroke()
            circlePath.lineWidth = 1.2
            circlePath.stroke()

            let number = "\(i+1)"
            let attributes: [NSAttributedString.Key: Any] = [
                .font: numberFont,
                .foregroundColor: UIColor.systemGreen
            ]
            (number as NSString).draw(at: CGPoint(x: center.x - (number as NSString).size(withAttributes: attributes).width / 2,
                                                 y: center.y - (number as NSString).size(withAttributes: attributes).height / 2),
                                      withAttributes: attributes)
        }

        // optional outer border
        let borderRect = CGRect(x: originX, y: originY, width: totalGridSize, height: totalGridSize)
        let borderPath = UIBezierPath(rect: borderRect)
        borderPath.lineWidth = 1
        UIColor(white: 0.85, alpha: 1).setStroke()
        borderPath.stroke()
    }

    /// Generates `count` spiral coordinates on an unbounded integer grid,
    /// then normalizes them into a minimal bounding box and centers them inside a square grid.
    /// returns: (normalized positions [col,row], cols, rows) where cols==rows==square grid size used for drawing
    private func computeSpiralGrid(count: Int) -> (positions: [(Int, Int)], cols: Int, rows: Int) {
        if count == 1 { return ([(0,0)], 1, 1) }

        // build spiral on an infinite integer grid starting at (0,0)
        var pts: [(Int, Int)] = []
        var x = 0, y = 0
        pts.append((x, y))

        let dirs = [(1,0), (0,1), (-1,0), (0,-1)] // right, down, left, up (clockwise outward)
        var stepSize = 1
        var dirIndex = 0

        while pts.count < count {
            for _ in 0..<2 {
                let d = dirs[dirIndex % 4]
                for _ in 0..<stepSize {
                    if pts.count >= count { break }
                    x += d.0
                    y += d.1
                    pts.append((x, y))
                }
                dirIndex += 1
            }
            stepSize += 1
        }

        // compute bounding box of the generated coordinates
        let xs = pts.map { $0.0 }
        let ys = pts.map { $0.1 }
        guard let minX = xs.min(), let maxX = xs.max(), let minY = ys.min(), let maxY = ys.max() else {
            return (pts, 1, 1)
        }

        let cols = maxX - minX + 1
        let rows = maxY - minY + 1
        let square = max(cols, rows)

        // normalize and center inside a square grid (so we can draw square cells)
        let colOffset = (square - cols) / 2
        let rowOffset = (square - rows) / 2

        var normalized: [(Int, Int)] = []
        for (px, py) in pts {
            let col = (px - minX) + colOffset
            let row = (py - minY) + rowOffset
            normalized.append((col, row))
        }

        return (normalized, square, square)
    }
}
