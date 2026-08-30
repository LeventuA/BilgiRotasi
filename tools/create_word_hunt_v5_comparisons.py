#!/usr/bin/env python3
"""Create deterministic reference-vs-Android gameplay comparisons."""

from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parent.parent
REFERENCE = ROOT / "tools" / "qa" / "kelime_avi_v5_gameplay_reference.jpg"
REPORTS = ROOT / "reports" / "word_hunt_v5_gameplay"
CANVAS = (1080, 1920)


def normalized_reference() -> Image.Image:
    with Image.open(REFERENCE) as source:
        return source.convert("RGB").resize(CANVAS, Image.Resampling.LANCZOS)


def comparison(reference: Image.Image, screenshot_name: str, output_name: str) -> None:
    screenshot_path = REPORTS / screenshot_name
    with Image.open(screenshot_path) as source:
        screenshot = source.convert("RGB")
        if screenshot.size != CANVAS:
            raise ValueError(
                f"{screenshot_name} expected {CANVAS}, received {screenshot.size}"
            )

    output = Image.new("RGB", (CANVAS[0] * 2, CANVAS[1]), "black")
    output.paste(reference, (0, 0))
    output.paste(screenshot, (CANVAS[0], 0))
    output.save(REPORTS / output_name, format="PNG", optimize=False)


def main() -> None:
    REPORTS.mkdir(parents=True, exist_ok=True)
    reference = normalized_reference()
    reference.save(REPORTS / "V5_GAMEPLAY_REFERENCE_1080x1920.png", format="PNG")
    comparison(reference, "01_B1_INITIAL.png", "REFERENCE_VS_B1.png")
    comparison(reference, "04_B10_INITIAL.png", "REFERENCE_VS_B10.png")


if __name__ == "__main__":
    main()
