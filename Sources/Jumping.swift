public enum Jumping {
    case
    none,
    start,
    first,
    second,
    third
    
    var next: Self {
        switch self {
        case .none:
            return self
        case .start:
            return .first
        case .first:
            return .second
        case .second:
            return .third
        case .third:
            return .start
        }
    }
}
