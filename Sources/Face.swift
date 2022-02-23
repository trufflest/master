public enum Face: Equatable {
    case
    none,
    jump,
    dead,
    walk1(Int),
    walk2(Int)
    
    public var key: String {
        switch self {
        case .walk1:
            return "walk1"
        case .walk2:
            return "walk2"
        default:
            return "\(self)"
        }
    }
}
