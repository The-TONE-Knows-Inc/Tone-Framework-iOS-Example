//
//  SpectrumAnalyzerView.swift
//  ToneDemo
//
//  Created by Balan iOS on 20/02/25.
//

import UIKit

class SpectrumAnalyzerView: UIView {
    private var magnitudeData: [CGFloat] = []
    private let barColor: UIColor = .cyan
    private let barSpacing: CGFloat = 2.0
    private let maxMagnitude: CGFloat = 200.0
    private let barWidthFactor: CGFloat = 10.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    /// Updates the spectrum with normalized magnitude data
    func updateMagnitudeData(_ magnitudes: [Float]) {
        let logMagnitudes = magnitudes.map { CGFloat(logScale($0)) }
        magnitudeData = normalize(logMagnitudes)
        setNeedsDisplay()
    }
    
    /// Normalizes an array of magnitudes between 0 and `maxMagnitude`
    private func normalize(_ values: [CGFloat]) -> [CGFloat] {
        guard let minVal = values.min(), let maxVal = values.max(), maxVal != minVal else {
            return values
        }
        
        return values.map { ($0 - minVal) / (maxVal - minVal) * maxMagnitude }
    }
    
    override func draw(_ rect: CGRect) {
        guard !magnitudeData.isEmpty, let context = UIGraphicsGetCurrentContext() else { return }
        context.clear(rect)
        
        let barWidth = (rect.width / CGFloat(magnitudeData.count)) * barWidthFactor
        let height = rect.height
        
        for (index, magnitude) in magnitudeData.enumerated() {
            let barHeight = height * (magnitude / maxMagnitude)
            let xPosition = CGFloat(index) * (rect.width / CGFloat(magnitudeData.count))
            let yPosition = height - barHeight
            
            let barRect = CGRect(x: xPosition, y: yPosition, width: barWidth - barSpacing, height: barHeight)
            context.setFillColor(barColor.cgColor)
            context.fill(barRect)
        }
    }
    
    /// Applies logarithmic scaling to magnitude values
    private func logScale(_ magnitude: Float) -> Float {
        let minMagnitude: Float = 1e-10
        return 20 * log10(max(magnitude, minMagnitude))
    }
}
