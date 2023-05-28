//
//  Layer.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/7/19.
//

import Foundation

// MARK: - LayerType + ClassFamily

/// Used for mapping a heterogeneous list to classes for parsing.
extension LayerType: ClassFamily {
  static var discriminator: Discriminator = .type

  func getType() -> AnyObject.Type {
    switch self {
    case .precomp:
      return PreCompLayerModel.self
    case .solid:
      return SolidLayerModel.self
    case .image:
      return ImageLayerModel.self
    case .null:
      return LayerModel.self
    case .shape:
      return ShapeLayerModel.self
    case .text:
      return TextLayerModel.self
    }
  }
}

// MARK: - LayerType

public enum LayerType: Int, Codable {
  case precomp
  case solid
  case image
  case null
  case shape
  case text

  public init(from decoder: Decoder) throws {
    self = try LayerType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .null
  }
}

// MARK: - MatteType

public enum MatteType: Int, Codable {
  case none
  case add
  case invert
  case unknown
}

// MARK: - BlendMode

public enum BlendMode: Int, Codable {
  case normal
  case multiply
  case screen
  case overlay
  case darken
  case lighten
  case colorDodge
  case colorBurn
  case hardLight
  case softLight
  case difference
  case exclusion
  case hue
  case saturation
  case color
  case luminosity
}

// MARK: - LayerModel

/// A base top container for shapes, images, and other view objects.
public class LayerModel: Codable, DictionaryInitializable {
  
  public final class MetaInfo: Codable, DictionaryInitializable {
    enum CodingKeys: String, CodingKey {
      case type = "cur"
      case st = "st"
    }
    
    public struct St: Codable, DictionaryInitializable {
      public struct Sub: Codable, DictionaryInitializable {
        enum CodingKeys: String, CodingKey {
          case force_disable_col
        }
        public let force_disable_col: Bool
        
        init(dictionary: [String : Any]) throws {
          force_disable_col = try dictionary.value(for: CodingKeys.force_disable_col)
        }
      }
      
      enum CodingKeys: String, CodingKey {
        case sub
        case movable
        case tintable
        case monochrome
        case add_lib
        case pro
        case lib_tint
        case lib_col
      }
      
      public let sub: Sub?
      public let movable: Bool?
      public let tintable: Bool?
      public let monochrome: Bool?
      public let add_lib: Bool?
      public let pro: Bool?
      public let lib_tint: Bool?
      public let lib_col: String?

      init(dictionary: [String : Any]) throws {
        let subDictionary: [String: Any]? = try? dictionary.value(for: CodingKeys.sub)
        sub = try subDictionary.map { try Sub(dictionary: $0) }
        movable = try? dictionary.value(for: CodingKeys.movable)
        tintable = try? dictionary.value(for: CodingKeys.tintable)
        monochrome = try? dictionary.value(for: CodingKeys.monochrome)
        add_lib = try? dictionary.value(for: CodingKeys.add_lib)
        pro = try? dictionary.value(for: CodingKeys.pro)
        lib_tint = try? dictionary.value(for: CodingKeys.lib_tint)
        lib_col = try? dictionary.value(for: CodingKeys.lib_col)
      }
    }
    
    let type: String
    let st: St
    
    init(dictionary: [String : Any]) throws {
      type = try dictionary.value(for: CodingKeys.type)
      let stDictionary: [String: Any] = try dictionary.value(for: CodingKeys.st)
      st = try St(dictionary: stDictionary)
    }
    
  }

  // MARK: Lifecycle

  required public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: LayerModel.CodingKeys.self)
    name = try container.decodeIfPresent(String.self, forKey: .name) ?? "Layer"
    index = try container.decodeIfPresent(Int.self, forKey: .index) ?? .random(in: Int.min...Int.max)
    type = try container.decode(LayerType.self, forKey: .type)
    coordinateSpace = try container.decodeIfPresent(CoordinateSpace.self, forKey: .coordinateSpace) ?? .type2d
    inFrame = try container.decode(Double.self, forKey: .inFrame)
    outFrame = try container.decode(Double.self, forKey: .outFrame)
    startTime = try container.decode(Double.self, forKey: .startTime)
    transform = try container.decode(Transform.self, forKey: .transform)
    parent = try container.decodeIfPresent(Int.self, forKey: .parent)
    blendMode = try container.decodeIfPresent(BlendMode.self, forKey: .blendMode) ?? .normal
    masks = try container.decodeIfPresent([Mask].self, forKey: .masks)
    timeStretch = try container.decodeIfPresent(Double.self, forKey: .timeStretch) ?? 1
    matte = try container.decodeIfPresent(MatteType.self, forKey: .matte)
    hidden = try container.decodeIfPresent(Bool.self, forKey: .hidden) ?? false
    meta = try container.decodeIfPresent(MetaInfo.self, forKey: .meta)
  }

  required public init(dictionary: [String: Any]) throws {
    name = (try? dictionary.value(for: CodingKeys.name)) ?? "Layer"
    index = try dictionary.value(for: CodingKeys.index) ?? .random(in: Int.min...Int.max)
    type = LayerType(rawValue: try dictionary.value(for: CodingKeys.type)) ?? .null
    if
      let coordinateSpaceRawValue = dictionary[CodingKeys.coordinateSpace.rawValue] as? Int,
      let coordinateSpace = CoordinateSpace(rawValue: coordinateSpaceRawValue)
    {
      self.coordinateSpace = coordinateSpace
    } else {
      coordinateSpace = .type2d
    }
    inFrame = try dictionary.value(for: CodingKeys.inFrame)
    outFrame = try dictionary.value(for: CodingKeys.outFrame)
    startTime = try dictionary.value(for: CodingKeys.startTime)
    transform = try Transform(dictionary: try dictionary.value(for: CodingKeys.transform))
    parent = try? dictionary.value(for: CodingKeys.parent)
    if
      let blendModeRawValue = dictionary[CodingKeys.blendMode.rawValue] as? Int,
      let blendMode = BlendMode(rawValue: blendModeRawValue)
    {
      self.blendMode = blendMode
    } else {
      blendMode = .normal
    }
    if let maskDictionaries = dictionary[CodingKeys.masks.rawValue] as? [[String: Any]] {
      masks = try maskDictionaries.map { try Mask(dictionary: $0) }
    } else {
      masks = nil
    }
    timeStretch = (try? dictionary.value(for: CodingKeys.timeStretch)) ?? 1
    if let matteRawValue = dictionary[CodingKeys.matte.rawValue] as? Int {
      matte = MatteType(rawValue: matteRawValue)
    } else {
      matte = nil
    }
    hidden = (try? dictionary.value(for: CodingKeys.hidden)) ?? false
    
    if let metaDictionary = dictionary[CodingKeys.meta.rawValue] as? [String: Any] {
      meta = try MetaInfo(dictionary: metaDictionary)
    } else {
      meta = nil
    }
  }

  // MARK: Internal

  /// The readable name of the layer
  let name: String

  /// The index of the layer
  let index: Int

  /// The type of the layer.
  let type: LayerType

  /// The coordinate space
  let coordinateSpace: CoordinateSpace

  /// The in time of the layer in frames.
  let inFrame: Double
  /// The out time of the layer in frames.
  let outFrame: Double

  /// The start time of the layer in frames.
  let startTime: Double

  /// The transform of the layer
  let transform: Transform

  /// The index of the parent layer, if applicable.
  let parent: Int?

  /// The blending mode for the layer
  let blendMode: BlendMode

  /// An array of masks for the layer.
  let masks: [Mask]?

  /// A number that stretches time by a multiplier
  let timeStretch: Double

  /// The type of matte if any.
  let matte: MatteType?

  let hidden: Bool
  
  public let meta: MetaInfo?

  // MARK: Fileprivate

  fileprivate enum CodingKeys: String, CodingKey {
    case name = "nm"
    case index = "ind"
    case type = "ty"
    case coordinateSpace = "ddd"
    case inFrame = "ip"
    case outFrame = "op"
    case startTime = "st"
    case transform = "ks"
    case parent
    case blendMode = "bm"
    case masks = "masksProperties"
    case timeStretch = "sr"
    case matte = "tt"
    case hidden = "hd"
    case meta = "meta"
  }
}

extension Array where Element == LayerModel {

  static func fromDictionaries(_ dictionaries: [[String: Any]]) throws -> [LayerModel] {
    try dictionaries.compactMap { dictionary in
      let layerType = dictionary[LayerModel.CodingKeys.type.rawValue] as? Int
      switch LayerType(rawValue: layerType ?? LayerType.null.rawValue) {
      case .precomp:
        return try PreCompLayerModel(dictionary: dictionary)
      case .solid:
        return try SolidLayerModel(dictionary: dictionary)
      case .image:
        return try ImageLayerModel(dictionary: dictionary)
      case .null:
        return try LayerModel(dictionary: dictionary)
      case .shape:
        return try ShapeLayerModel(dictionary: dictionary)
      case .text:
        return try TextLayerModel(dictionary: dictionary)
      case .none:
        return nil
      }
    }
  }
}
