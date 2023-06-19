//
//  LottieAnimation.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/7/19.
//

import Foundation

// MARK: - CoordinateSpace

public enum CoordinateSpace: Int, Codable {
  case type2d
  case type3d
}

// MARK: - LottieAnimation

/// The `LottieAnimation` model is the top level model object in Lottie.
///
/// A `LottieAnimation` holds all of the animation data backing a Lottie Animation.
/// Codable, see JSON schema [here](https://github.com/airbnb/lottie-web/tree/master/docs/json).
public class LottieAnimation: Codable, DictionaryInitializable {
    public init(
        startFrame: AnimationFrameTime,
        endFrame: AnimationFrameTime,
        framerate: Double,
        version: String,
        type: CoordinateSpace,
        width: Double,
        height: Double,
        layers: [LayerModel],
        glyphs: [Glyph]?,
        fonts: FontList?,
        assetLibrary: AssetLibrary?,
        markers: [Marker]?,
        markerMap: [String : Marker]?,
        meta: LottieAnimation.MetaInfo?
    ) {
        self.startFrame = startFrame
        self.endFrame = endFrame
        self.framerate = framerate
        self.version = version
        self.type = type
        self.width = width
        self.height = height
        self.layers = layers
        self.glyphs = glyphs
        self.fonts = fonts
        self.assetLibrary = assetLibrary
        self.markers = markers
        self.markerMap = markerMap
        self.meta = meta
    }
    

  // MARK: Lifecycle

  required public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: LottieAnimation.CodingKeys.self)
    version = try container.decode(String.self, forKey: .version)
    type = try container.decodeIfPresent(CoordinateSpace.self, forKey: .type) ?? .type2d
    startFrame = try container.decode(AnimationFrameTime.self, forKey: .startFrame)
    endFrame = try container.decode(AnimationFrameTime.self, forKey: .endFrame)
    framerate = try container.decode(Double.self, forKey: .framerate)
    width = try container.decode(Double.self, forKey: .width)
    height = try container.decode(Double.self, forKey: .height)
    layers = try container.decode([LayerModel].self, ofFamily: LayerType.self, forKey: .layers)
    glyphs = try container.decodeIfPresent([Glyph].self, forKey: .glyphs)
    fonts = try container.decodeIfPresent(FontList.self, forKey: .fonts)
    assetLibrary = try container.decodeIfPresent(AssetLibrary.self, forKey: .assetLibrary)
    markers = try container.decodeIfPresent([Marker].self, forKey: .markers)

    if let markers = markers {
      var markerMap: [String: Marker] = [:]
      for marker in markers {
        markerMap[marker.name] = marker
      }
      self.markerMap = markerMap
    } else {
      markerMap = nil
    }
    
    meta = try container.decodeIfPresent(MetaInfo.self, forKey: .meta)
  }

  required public init(dictionary: [String: Any]) throws {
    version = try dictionary.value(for: CodingKeys.version)
    if
      let typeRawValue = dictionary[CodingKeys.type.rawValue] as? Int,
      let type = CoordinateSpace(rawValue: typeRawValue)
    {
      self.type = type
    } else {
      type = .type2d
    }
    startFrame = try dictionary.value(for: CodingKeys.startFrame)
    endFrame = try dictionary.value(for: CodingKeys.endFrame)
    framerate = try dictionary.value(for: CodingKeys.framerate)
    width = try dictionary.value(for: CodingKeys.width)
    height = try dictionary.value(for: CodingKeys.height)
    let layerDictionaries: [[String: Any]] = try dictionary.value(for: CodingKeys.layers)
    layers = try [LayerModel].fromDictionaries(layerDictionaries)
    if let glyphDictionaries = dictionary[CodingKeys.glyphs.rawValue] as? [[String: Any]] {
      glyphs = try glyphDictionaries.map { try Glyph(dictionary: $0) }
    } else {
      glyphs = nil
    }
    if let fontsDictionary = dictionary[CodingKeys.fonts.rawValue] as? [String: Any] {
      fonts = try FontList(dictionary: fontsDictionary)
    } else {
      fonts = nil
    }
    if let assetLibraryDictionaries = dictionary[CodingKeys.assetLibrary.rawValue] as? [[String: Any]] {
      assetLibrary = try AssetLibrary(value: assetLibraryDictionaries)
    } else {
      assetLibrary = nil
    }
    if let markerDictionaries = dictionary[CodingKeys.markers.rawValue] as? [[String: Any]] {
      let markers = try markerDictionaries.map { try Marker(dictionary: $0) }
      var markerMap: [String: Marker] = [:]
      for marker in markers {
        markerMap[marker.name] = marker
      }
      self.markers = markers
      self.markerMap = markerMap
    } else {
      markers = nil
      markerMap = nil
    }
    
    if let metaDictionary = dictionary[CodingKeys.meta.rawValue] as? [String: Any] {
      meta = try MetaInfo(dictionary: metaDictionary)
    } else {
      meta = nil
    }
  }

  // MARK: Public

  /// The start time of the composition in frameTime.
  public let startFrame: AnimationFrameTime

  /// The end time of the composition in frameTime.
  public let endFrame: AnimationFrameTime

  /// The frame rate of the composition.
  public let framerate: Double

  /// Return all marker names, in order, or an empty list if none are specified
  public var markerNames: [String] {
    guard let markers = markers else { return [] }
    return markers.map { $0.name }
  }

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case version = "v"
    case type = "ddd"
    case startFrame = "ip"
    case endFrame = "op"
    case framerate = "fr"
    case width = "w"
    case height = "h"
    case layers
    case glyphs = "chars"
    case fonts
    case assetLibrary = "assets"
    case markers
    case meta
  }

  /// The version of the JSON Schema.
  public let version: String

  /// The coordinate space of the composition.
  public let type: CoordinateSpace

  /// The height of the composition in points.
  public let width: Double

  /// The width of the composition in points.
  public let height: Double

  /// The list of animation layers
  public var layers: [LayerModel]

  /// The list of glyphs used for text rendering
  public let glyphs: [Glyph]?

  /// The list of fonts used for text rendering
  public let fonts: FontList?

  /// Asset Library
  public let assetLibrary: AssetLibrary?

  /// Markers
  public let markers: [Marker]?
  public let markerMap: [String: Marker]?
  
  public let meta: MetaInfo?
}

extension LottieAnimation {
  public final class MetaInfo: Codable, DictionaryInitializable {
    public enum CodingKeys: String, CodingKey {
      case pack = "ct"
    }
    
    init(dictionary: [String : Any]) throws {
      pack = try? dictionary.value(for: CodingKeys.pack)
    }

    public let pack: String?
  }
}
