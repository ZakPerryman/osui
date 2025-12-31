// Based off of https://rxi.github.io/a_simple_ui_animation_system.html
// Easing types and constants from https://easings.net/
package osui

import "core:math"

// Implemented easings, based on easings.net
Easing_Types :: enum {
    easeInSine,
    easeOutSine,
    easeInOutSine,
    
    easeInQuad,
    easeOutQuad,
    easeInOutQuad,

    easeInCubic,
    easeOutCubic,
    easeInOutCubic,
    
    easeInQuart,
    easeOutQuart,
    easeInOutQuart,

    easeInQuint,
    easeOutQuint,
    easeInOutQuint,
    
    easeInExpo,
    easeOutExpo,
    easeInOutExpo,
    
    easeInCirc,
    easeOutCirc,
    easeInOutCirc,
    
    easeInBack,
    easeOutBack,
    easeInOutBack,

    easeInElastic,
    easeOutElastic,
    easeInOutElastic,

    easeInBounce,
    easeOutBounce,
    easeInOutBounce,
}

// Animation type
Animation_Item :: struct {
    id: u64,
    type: Easing_Types,
    progress, time, initial, prev: f64,
}

// Animation controller storage type
Animation_List :: struct($N: int) {
    anim_items: [N]Animation_Item,
    anim_item_count: int,    
}

update_all :: proc(al: ^Animation_List($N), delta: f64) {
    for i := al.anim_item_count - 1; i >= 0; i -= 1 {
        item := &al.anim_items[i]

        item.progress += delta / item.time

        if(item.progress >= 1.0) {
            item^ = al.anim_items[al.anim_item_count - 1]
            al.anim_item_count -= 1
        }
    }
}

start :: proc(al: ^Animation_List($N), id: u64, initial: f64, time: f64, type: Easing_Types) {
    for i in 0..<al.anim_item_count {
        item := &al.anim_items[i]
        if(item.id == id) {
            item.initial = initial
            item.type = type
            item.time = time
            item.progress = 0
            return
        }
    }

    if(al.anim_item_count < len(al.anim_items)) {
        al.anim_item_count += 1
        al.anim_items[al.anim_item_count - 1] = Animation_Item{
            id = id,
            type = type,
            initial = initial,
            prev = initial,
            time = time,
        }
    }
}

get :: proc(al: ^Animation_List($N), id: u64, target: f64) -> (out: f64) {
    out = target
    
    for i in 0..<al.anim_item_count {
        item := &al.anim_items[i]
        if(item.id == id) {
            p := item.progress
            out *= _apply_easing(item.type, p)
            return
        }
    }

    return
}

@(private="file")
_easeOutBounce :: proc(p: f64) -> f64 {
    n1 :: 7.5625
    d1 :: 2.75

    if p < 1 / d1 {
        return n1 * p * p
    } else if p < 2 / d1 {
        return n1 * (p - 1.5 / d1) * (p - 1.5 / d1) + 0.75
    } else if p < 2.5 / d1 {
        return n1 * (p - 2.25 / d1) * (p - 2.25 / d1) + 0.9375
    } else {
        return n1 * (p - 2.625 / d1) * (p - 2.625 / d1) + 0.984375
    }
}

// @(private="file")
_apply_easing :: proc(easing: Easing_Types, p: f64) -> f64 {
    // constants
    c1 :: 1.70158
    c2 :: 2.59491
    c3 :: 2.70158
    c4 :: math.TAU / 3
    c5 :: math.TAU / 4.5

    // bounce constants
    

    switch(easing) {
        case .easeInSine: { return 1 - math.cos((p * math.PI) / 2) }
        case .easeOutSine: { return math.sin((p * math.PI) / 2) }
        case .easeInOutSine: { return -((math.cos(p * math.PI) - 1) / 2) }
        
        case .easeInQuad: { return p * p }
        case .easeOutQuad: { return 1 - ((1 - p) * (1 - p)) }
        case .easeInOutQuad: { 
            if(p < 0.5) {
                return 2 * p * p
            } else {
                return 1 - math.pow(-2 * p + 2, 2) / 2
            }
        }

        case .easeInCubic: { return p * p * p }
        case .easeOutCubic: { return 1 - math.pow(1 - p, 3)}
        case .easeInOutCubic: { 
            if(p < 0.5) {
                return 4 * p * p * p
            } else {
                return 1 - math.pow(-2 * p + 2, 3) / 2
            }
        }

        case .easeInQuart: { return math.pow(p, 4) }
        case .easeOutQuart: { return 1 - math.pow(1-p, 4) }
        case .easeInOutQuart: {
            if(p < 0.5) {
                return 8 * p * p * p * p
            } else {
                return 1 - math.pow(-2 * p + 2, 4) / 2
            }
        }

        case .easeInQuint: { return math.pow(p, 5) }
        case .easeOutQuint: { return 1 - math.pow(1-p, 5) }
        case .easeInOutQuint: {
            if(p < 0.5) {
                return 16 * p * p * p * p * p
            } else {
                return 1 - math.pow(-2 * p + 2, 5) / 2
            }
        }

        case .easeInExpo: {
            if p == 0 {
                return 0
            } else {
                return math.pow(2, 10 * p - 10)
            }
        }
        case .easeOutExpo: {
            if p == 1 {
                return 1
            } else {
                return 1 - math.pow(2, -10 * p)
            }
        }
        case .easeInOutExpo: {
            if(p == 0) {
                return 0
            } else if( p == 1 ) {
                return 1
            } else if( p < 0.5 ) {
                return math.pow(2, 20 * p - 10) / 2
            } else {
                return (2 - math.pow(2, -20 * p + 10)) / 2
            }
        }

        case .easeInCirc: {
            return 1 - math.sqrt(1 - math.pow(p, 2))
        }
        case .easeOutCirc: {
            return math.sqrt(1 - math.pow(p - 1, 2))
        }
        case .easeInOutCirc: {
            if p < 0.5 {
                return (1 - math.sqrt(1 - math.pow(2 * p, 2))) / 2
            } else {
                return (math.sqrt(1 - math.pow(-2 * p + 2, 2)) + 1) / 2
            }
        }

        case .easeInBack: { return (c3 * p * p * p) - (c1 * p * p) }
        case .easeOutBack: { return 1 + ((c3 * math.pow(p - 1, 3)) + (c1 * math.pow(p - 1, 2))) }
        case .easeInOutBack: {
            if p < 0.5 {
                return math.pow(2 * p, 2) * ((c2 + 1) * 2 * p - c2) / 2
            } else {
                return (math.pow(2 * p - 2, 2) * ((c2 + 1) * (p * 2 - 2) + c2) + 2) / 2
            }
        }

        case .easeInElastic: {
            if p == 0 {
                return 0
            } else if p == 1 {
                return 1
            } else {
                return -math.pow(2, 10 * p - 10) * math.sin(p * 10 - 10.75) * c4
            }
        }
        case .easeOutElastic: {
            if p == 0 {
                return 0
            } else if p == 1 {
                return 1
            } else {
                return math.pow(2, -10 * p) * math.sin(p * 10 - 10.75) * c4 + 1
            }
        }
        case .easeInOutElastic: {
            if p == 0 {
                return 0
            } else if p == 1 {
                return 1
            } else if p < 0.5 {
                return (-math.pow(2, 20 * p - 10) * math.sin(p * 20 - 11.75) * c5) / 2
            } else {
                return (math.pow(2, -20 * p) * math.sin(p * 20 - 11.75) * c5) / 2 + 1
            }
        }

        case .easeInBounce: {
            return 1 - _easeOutBounce(1 - p)
        }
        case .easeOutBounce: { //TODO: Test me
            return _easeOutBounce(p)
        }
        case .easeInOutBounce: {
            if p < 0.5 {
                return (1 - _easeOutBounce(1 - 2 * p)) / 2
            } else {
                return (1 + _easeOutBounce(2 * p - 1)) / 2
            }
        }
    }

    panic("Failed to process an easing type. Memory corruption?")
}