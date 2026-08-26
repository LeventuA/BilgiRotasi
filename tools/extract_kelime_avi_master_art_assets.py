"""Extract binding Başlangıç Limanı assets from Issue #109 MASTER ART.

This tool never draws or synthesizes art. RGB pixels always come directly from
`reports/MASTER_ART_REFERENCE.png`; only crop, segmentation-derived alpha,
edge feathering and lossless WebP export are applied.
"""

from __future__ import annotations

import hashlib
import json
import math
from pathlib import Path

from PIL import Image, ImageChops, ImageFilter


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "reports" / "MASTER_ART_REFERENCE.png"
OUTPUT = ROOT / "assets" / "word_hunt" / "baslangic_limani"
MANIFEST = ROOT / "reports" / "master_art_extraction_manifest.json"
EXPECTED_SOURCE_SHA256 = (
    "faf8a4a2598e7e63fc857e694483a923fd3d3994e242b9f1b83554693ed52160"
)


SPECS = {
    "node_challenge.webp": {
        "crop": (290, 798, 434, 942),
        "center": (72.0, 72.0),
        "outer_radius": 56.0,
        "inner_radius": 43.0,
        "feather": 3.0,
        "segment": "gold",
    },
    "node_final.webp": {
        "crop": (430, 1432, 626, 1628),
        "center": (98.0, 98.0),
        "outer_radius": 78.0,
        "inner_radius": 65.0,
        "feather": 3.0,
        "segment": "gold",
        "min_y": 46,
    },
    "book_button.webp": {
        "crop": (850, 1669, 1040, 1859),
        "center": (95.0, 95.0),
        "outer_radius": 86.0,
        "inner_radius": 72.0,
        "feather": 3.0,
        "segment": "gold",
    },
}


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def radial_alpha(
    size: tuple[int, int],
    center: tuple[float, float],
    outer_radius: float,
    feather: float,
) -> Image.Image:
    width, height = size
    cx, cy = center
    alpha = bytearray(width * height)
    solid_radius = outer_radius - feather
    for y in range(height):
        for x in range(width):
            distance = math.hypot((x + 0.5) - cx, (y + 0.5) - cy)
            if distance <= solid_radius:
                value = 255
            elif distance >= outer_radius:
                value = 0
            else:
                value = round(255 * (outer_radius - distance) / feather)
            alpha[y * width + x] = value
    return Image.frombytes("L", size, bytes(alpha))


def source_segmentation(crop: Image.Image, segment: str) -> Image.Image:
    """Select source metal/glow pixels without creating replacement artwork."""
    if segment != "gold":
        raise ValueError(f"Unsupported source segment: {segment}")
    rgb = crop.convert("RGB")
    mask = bytearray(rgb.width * rgb.height)
    for index, (red, green, blue) in enumerate(rgb.get_flattened_data()):
        warm_metal = (
            red >= 72
            and green >= 42
            and red >= blue * 1.18
            and green >= blue * 0.92
        )
        bright_detail = red >= 150 and green >= 115 and blue >= 58
        mask[index] = 255 if warm_metal or bright_detail else 0
    selected = Image.frombytes("L", rgb.size, bytes(mask))
    # Edge cleanup only: include anti-aliased pixels adjacent to selected source.
    return selected.filter(ImageFilter.MaxFilter(7)).filter(
        ImageFilter.GaussianBlur(1.2)
    )


def inner_face_alpha(
    size: tuple[int, int], center: tuple[float, float], radius: float
) -> Image.Image:
    return radial_alpha(size, center, radius, 2.0)


def extract(source: Image.Image, name: str, spec: dict[str, object]) -> dict[str, object]:
    requested_crop_box = tuple(spec["crop"])
    crop = source.crop(requested_crop_box).convert("RGBA")
    center = tuple(spec["center"])
    radial = radial_alpha(
        crop.size,
        center,
        float(spec["outer_radius"]),
        float(spec["feather"]),
    )
    segmented = source_segmentation(crop, str(spec["segment"]))
    face = inner_face_alpha(crop.size, center, float(spec["inner_radius"]))
    alpha = ImageChops.multiply(ImageChops.lighter(segmented, face), radial)
    min_y = int(spec.get("min_y", 0))
    max_y = int(spec.get("max_y", crop.height))
    if min_y or max_y != crop.height:
        alpha_bytes = bytearray(alpha.tobytes())
        for y in range(crop.height):
            if min_y <= y < max_y:
                continue
            start = y * crop.width
            alpha_bytes[start : start + crop.width] = bytes(crop.width)
        alpha = Image.frombytes("L", crop.size, bytes(alpha_bytes))
    crop.putalpha(alpha)

    # Remove only fully transparent padding. This preserves the binding-source
    # pixels and makes Flutter's BoxFit.contain scale the visible medallion or
    # control to its measured contract diameter instead of shrinking it because
    # of unused transparent canvas around the extraction.
    if alpha.getbbox() is None:
        raise RuntimeError(f"Empty alpha mask for {name}")
    outer_radius = float(spec["outer_radius"])
    alpha_bounds = (
        max(0, math.floor(center[0] - outer_radius)),
        max(0, math.floor(center[1] - outer_radius)),
        min(crop.width, math.ceil(center[0] + outer_radius)),
        min(crop.height, math.ceil(center[1] + outer_radius)),
    )
    crop = crop.crop(alpha_bounds)
    crop_box = (
        requested_crop_box[0] + alpha_bounds[0],
        requested_crop_box[1] + alpha_bounds[1],
        requested_crop_box[0] + alpha_bounds[2],
        requested_crop_box[1] + alpha_bounds[3],
    )

    destination = OUTPUT / name
    crop.save(destination, format="WEBP", lossless=True, method=6, exact=True)

    decoded = Image.open(destination).convert("RGBA")
    if decoded.size != crop.size:
        raise RuntimeError(f"Unexpected output size for {name}: {decoded.size}")
    source_rgb = crop.convert("RGB")
    decoded_rgb = decoded.convert("RGB")
    decoded_alpha = decoded.getchannel("A")
    source_pixels = list(source_rgb.get_flattened_data())
    decoded_pixels = list(decoded_rgb.get_flattened_data())
    alpha_pixels = list(decoded_alpha.get_flattened_data())
    mismatches = sum(
        1
        for original, exported, alpha_value in zip(
            source_pixels, decoded_pixels, alpha_pixels
        )
        if alpha_value > 0 and original != exported
    )
    if mismatches:
        raise RuntimeError(
            f"{name} contains {mismatches} non-source RGB pixels after export"
        )

    return {
        "source_crop": list(crop_box),
        "requested_source_crop": list(requested_crop_box),
        "transparent_padding_trim": list(alpha_bounds),
        "dimensions": [crop.width, crop.height],
        "mask": {
            "kind": "source-segmentation-plus-inner-face-radial-edge",
            "center": list(center),
            "outer_radius": spec["outer_radius"],
            "inner_radius": spec["inner_radius"],
            "feather": spec["feather"],
            "min_y": min_y,
            "max_y": max_y,
        },
        "sha256": sha256(destination),
        "source_pixel_identity": True,
        "generated_art": False,
    }


def main() -> None:
    actual_source_sha = sha256(SOURCE)
    if actual_source_sha != EXPECTED_SOURCE_SHA256:
        raise RuntimeError(
            "Binding MASTER ART hash mismatch: "
            f"expected {EXPECTED_SOURCE_SHA256}, got {actual_source_sha}"
        )
    source = Image.open(SOURCE).convert("RGBA")
    if source.size != (1080, 1920):
        raise RuntimeError(f"Binding MASTER ART must be 1080x1920, got {source.size}")

    assets = {
        name: extract(source, name, spec)
        for name, spec in SPECS.items()
    }
    manifest = {
        "source": "Issue #109 Photo 1.jpg",
        "source_path": "reports/MASTER_ART_REFERENCE.png",
        "source_sha256": actual_source_sha,
        "source_dimensions": [source.width, source.height],
        "method": "direct-source-pixels-crop-mask-alpha",
        "forbidden_sources_used": [],
        "assets": assets,
    }
    MANIFEST.write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(json.dumps(manifest, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
