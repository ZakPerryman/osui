package osui

import "core:math"
import "core:fmt"
import "core:testing"

epsilon_equals :: proc(a: f64, b: f64) -> bool {
    return (a <= b && a + math.F64_EPSILON >= b) || (a >= b && a - math.F64_EPSILON <= b)
}
@(test)
should_clear_finished_animations :: proc(t: ^testing.T) {
    al := Animation_List(8){}
    start(&al, 0, 0, 1, .easeInSine)

    assert(al.anim_item_count == 1)

    update_all(&al, 1.0)

    assert(al.anim_item_count == 0)
}

@(test)
should_reuse_same_id :: proc(test: ^testing.T) {
    al := Animation_List(8){}
    start(&al, 0, 0, 1, .easeInSine)

    assert(al.anim_item_count == 1)

    update_all(&al, 0.5)
    assert(get(&al, 0, 1.0) == _apply_easing(.easeInSine, 0.5))
    
    update_all(&al, 0.5)
    assert(al.anim_item_count == 0)

    start(&al, 0, 0, 1, .easeOutSine)

    assert(al.anim_items[0].type == .easeOutSine)
    assert(al.anim_item_count == 1)

    update_all(&al, 0.5)
    assert(get(&al, 0, 1.0) == _apply_easing(.easeOutSine, 0.5))
}

@(test)
should_handle_overful_id :: proc(test: ^testing.T) {
    al := Animation_List(2){}
    start(&al, 0, 0, 1, .easeInSine)
    start(&al, 1, 0, 1, .easeOutSine)
    start(&al, 2, 0, 1, .easeInOutSine)

    assert(al.anim_item_count == 2)

    update_all(&al, 0.5)
    assert(get(&al, 0, 1.0) == _apply_easing(.easeInSine, 0.5))
    assert(get(&al, 1, 1.0) == _apply_easing(.easeOutSine, 0.5))
    assert(get(&al, 2, 1.0) != _apply_easing(.easeInOutSine, 0.5))
    assert(get(&al, 2, 1.0) == 1.0)
}

@(test)
sanity_check_map_zero :: proc(test: ^testing.T) {
    for easing in Easing_Types {
        value := _apply_easing(easing, 0.0)
        assert(epsilon_equals(value, 0.0), fmt.tprintf("Easing type does not map zero: %v (Expected %v, Actual %v)", easing, 0.0, value))
    }
}

@(test)
sanity_check_map_one :: proc(test: ^testing.T) {
    for easing in Easing_Types {
        value := _apply_easing(easing, 1.0)
        assert(epsilon_equals(value, 1.0), fmt.tprintf("Easing type does not map one: %v, (Expected %v, Actual %v)", easing, 1.0, value))
    }
}