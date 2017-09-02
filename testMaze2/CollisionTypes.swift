

import Foundation

enum CollisionTypes: Int {
    case none = 0
    case player = 1
    case coin = 2
  //  case box = 4
    case monster = 8
    case weapon = 16
    case pickup = 32
    case fireball = 64
    // any of solid nature, should reflect projectiles
    case solid = 128
    case fence = 4
}
