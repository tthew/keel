/**
 * Colour maths for the Story 1.13 WCAG AA contrast gate.
 *
 * Zero runtime dependencies. Implements OKLCH → OkLab → linear sRGB → sRGB
 * conversion via the Ottosson 2020 matrix, in-gamut mapping (reduce chroma
 * with a 3-iteration ceiling then hard-clamp), WCAG 2.1 § 1.4.3 relative
 * luminance, and the (L1 + 0.05) / (L2 + 0.05) contrast ratio.
 *
 * Reference:
 *   - Björn Ottosson, "A perceptual color space for image processing" (2020)
 *     https://bottosson.github.io/posts/oklab/
 *   - WCAG 2.1 § 1.4.3 / 1.4.11 — https://www.w3.org/TR/WCAG21/#contrast-minimum
 */

export type Oklch = { L: number; C: number; H: number };
export type LinearRgb = [number, number, number];
export type Srgb = [number, number, number];

/** Parse an `oklch(L%? C H [/ alpha])` literal. Returns `null` on malformed input. */
export function parseOklch(value: string): Oklch | null {
  const m = value
    .trim()
    .match(/^oklch\(\s*([\d.]+)(%?)\s+([\d.]+)\s+([\d.]+)(?:\s*\/\s*[\d.]+%?)?\s*\)$/);
  if (!m) return null;
  const lRaw = Number(m[1]);
  const isPercent = m[2] === '%';
  const C = Number(m[3]);
  const H = Number(m[4]);
  if (!Number.isFinite(lRaw) || !Number.isFinite(C) || !Number.isFinite(H)) return null;
  const L = isPercent ? lRaw / 100 : lRaw;
  return { L, C, H };
}

/**
 * OKLCH (polar) → linear sRGB via OkLab cartesian.
 * Output may contain out-of-[0,1] channels when the colour is outside the sRGB gamut.
 */
export function oklchToLinearRgb({ L, C, H }: Oklch): LinearRgb {
  const hRad = (H * Math.PI) / 180;
  const a = C * Math.cos(hRad);
  const b = C * Math.sin(hRad);

  // OkLab → LMS^(1/3) per Ottosson; LMS = cubed
  const l_ = L + 0.3963377774 * a + 0.2158037573 * b;
  const m_ = L - 0.1055613458 * a - 0.0638541728 * b;
  const s_ = L - 0.0894841775 * a - 1.291485548 * b;

  const lms_l = l_ * l_ * l_;
  const lms_m = m_ * m_ * m_;
  const lms_s = s_ * s_ * s_;

  // LMS → linear sRGB
  const r = +4.0767416621 * lms_l - 3.3077115913 * lms_m + 0.2309699292 * lms_s;
  const g = -1.2684380046 * lms_l + 2.6097574011 * lms_m - 0.3413193965 * lms_s;
  const blue = -0.0041960863 * lms_l - 0.7034186147 * lms_m + 1.707614701 * lms_s;

  return [r, g, blue];
}

function isInGamut([r, g, b]: LinearRgb): boolean {
  return r >= 0 && r <= 1 && g >= 0 && g <= 1 && b >= 0 && b <= 1;
}

/**
 * Map out-of-gamut linear-RGB back inside sRGB by iteratively reducing chroma
 * (preserving hue), then hard-clamp. Returns in-gamut linear RGB.
 */
export function gamutMap(oklch: Oklch): LinearRgb {
  let current: Oklch = { ...oklch };
  let rgb = oklchToLinearRgb(current);
  for (let i = 0; i < 3 && !isInGamut(rgb); i++) {
    current = { ...current, C: current.C * 0.9 };
    rgb = oklchToLinearRgb(current);
  }
  return [
    Math.max(0, Math.min(1, rgb[0])),
    Math.max(0, Math.min(1, rgb[1])),
    Math.max(0, Math.min(1, rgb[2])),
  ];
}

/** Linear sRGB → gamma-encoded sRGB (per-channel piecewise transfer). */
export function linearRgbToSrgb([r, g, b]: LinearRgb): Srgb {
  const f = (x: number): number =>
    x <= 0.0031308 ? 12.92 * x : 1.055 * Math.pow(x, 1 / 2.4) - 0.055;
  return [f(r), f(g), f(b)];
}

/** Encode sRGB floats in [0,1] as `#RRGGBB`. */
export function srgbToHex([r, g, b]: Srgb): string {
  const toHex = (x: number): string =>
    Math.max(0, Math.min(255, Math.round(x * 255)))
      .toString(16)
      .padStart(2, '0');
  return `#${toHex(r)}${toHex(g)}${toHex(b)}`;
}

/** WCAG 2.1 § 1.4.3 relative luminance against LINEAR sRGB. */
export function relativeLuminance([r, g, b]: LinearRgb): number {
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

export type ContrastResult = {
  ratio: number;
  fgHex: string;
  bgHex: string;
};

/**
 * Compute the WCAG contrast ratio for a fg/bg pair of OKLCH literals.
 * Parses, gamut-maps to in-gamut linear sRGB, computes relative luminance,
 * and returns both the ratio and the gamut-mapped hex strings (the colours
 * a browser/terminal would actually render).
 *
 * Throws on malformed OKLCH input.
 */
export function contrastRatio(fg: string, bg: string): ContrastResult {
  const fgOklch = parseOklch(fg);
  const bgOklch = parseOklch(bg);
  if (!fgOklch) throw new Error(`oklch-parse-error: ${fg}`);
  if (!bgOklch) throw new Error(`oklch-parse-error: ${bg}`);
  const fgLinear = gamutMap(fgOklch);
  const bgLinear = gamutMap(bgOklch);
  const fgLum = relativeLuminance(fgLinear);
  const bgLum = relativeLuminance(bgLinear);
  const L1 = Math.max(fgLum, bgLum);
  const L2 = Math.min(fgLum, bgLum);
  const ratio = (L1 + 0.05) / (L2 + 0.05);
  return {
    ratio,
    fgHex: srgbToHex(linearRgbToSrgb(fgLinear)),
    bgHex: srgbToHex(linearRgbToSrgb(bgLinear)),
  };
}
