//
//  SeededRandomGenerator.swift
//  Dex
//
//  Created by Olivier Sbg on 19/10/2026.
//

import Foundation

struct SeededRandomGenerator: RandomNumberGenerator {
    private var state: UInt64
    
    init(seedDate: Date) {
        // Convert date to half-hours since 2001 (get no more than one seed every 30 min)
        let seed = UInt64(seedDate.timeIntervalSinceReferenceDate / 1800)
        
        // Avoid a seed of 0 if using ciphers that break on 0;
        // LCGs handle 0 fine depending on the constants, but a fallback is safe.
        self.state = seed == 0 ? 0xDEADC0DE : seed
    }
    
    /// Generates the next pseudo-random UInt64 value.
    mutating func next() -> UInt64 {
        // Knuth's MMIX LCG constants
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state
    }
}
