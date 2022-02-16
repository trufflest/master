public enum Jumping {
    case
    none,
    start,
    first,
    second
    
    var next: Self {
        switch self {
        case .none:
            return self
        case .start:
            return .first
        case .first:
            return .second
        case .second:
            return .start
        }
    }
}
