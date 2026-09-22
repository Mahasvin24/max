(() => {
  "use strict";

  const STORAGE_KEY = "max-logo-lab-v4";
  const SVG_NS = "http://www.w3.org/2000/svg";
  const defaults = Object.freeze({
    blades: 6,
    lineLength: 37,
    centerDistance: 18,
    curvature: 92,
    innerTaper: 0,
    thickness: 9.5,
    rotation: 0,
    lightInk: "#11131a",
    lightBg: "#f7f7fa",
    darkInk: "#f4f2ff",
    darkBg: "#15131c",
    surface: "transparent",
    motion: "still"
  });

  const numericKeys = ["blades", "lineLength", "centerDistance", "curvature", "innerTaper", "thickness", "rotation"];
  const colorKeys = ["lightInk", "lightBg", "darkInk", "darkBg"];
  const state = loadState();
  let toastTimer;
  let svgSerial = 0;

  const $ = (selector, root = document) => root.querySelector(selector);
  const $$ = (selector, root = document) => [...root.querySelectorAll(selector)];
  const round = (value, places = 3) => Number(value.toFixed(places));
  const radians = degrees => degrees * Math.PI / 180;

  function loadState() {
    try {
      const stored = JSON.parse(localStorage.getItem(STORAGE_KEY) || "null");
      return { ...defaults, ...(stored || {}) };
    } catch (_) {
      return { ...defaults };
    }
  }

  function saveState() {
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
    } catch (_) {
      // The lab still works when a browser blocks storage for local files.
    }
    const indicator = $("#save-state");
    indicator.textContent = "Saved locally";
  }

  function polar(radius, angle) {
    const a = radians(angle);
    return { x: 50 + radius * Math.cos(a), y: 50 + radius * Math.sin(a) };
  }

  function bladeGeometry(config = state) {
    // The inner endpoint is the radial anchor. Its distance from the logo center
    // never changes when length or curvature changes.
    const anchorAngle = -133;
    const p0 = polar(config.centerDistance, anchorAngle);
    // At zero curvature the tangent equals the anchor's radial direction, so
    // every blade points directly away from the center. Half the requested bend
    // is added as the curve grows to preserve the approved pinwheel stance.
    const startAngle = radians(anchorAngle + config.curvature / 2);
    const tangent = { x: Math.cos(startAngle), y: Math.sin(startAngle) };
    const normal = { x: -tangent.y, y: tangent.x };
    const theta = radians(config.curvature);

    if (Math.abs(theta) < 0.0001) {
      const p3 = {
        x: p0.x + tangent.x * config.lineLength,
        y: p0.y + tangent.y * config.lineLength
      };
      const c1 = {
        x: p0.x + tangent.x * config.lineLength / 3,
        y: p0.y + tangent.y * config.lineLength / 3
      };
      const c2 = {
        x: p3.x - tangent.x * config.lineLength / 3,
        y: p3.y - tangent.y * config.lineLength / 3
      };
      return { p0, c1, c2, p3, radius: Infinity, tangent, normal, theta };
    }

    const radius = config.lineLength / theta;
    const p3 = {
      x: p0.x + tangent.x * radius * Math.sin(theta) + normal.x * radius * (1 - Math.cos(theta)),
      y: p0.y + tangent.y * radius * Math.sin(theta) + normal.y * radius * (1 - Math.cos(theta))
    };
    const endTangent = {
      x: tangent.x * Math.cos(theta) + normal.x * Math.sin(theta),
      y: tangent.y * Math.cos(theta) + normal.y * Math.sin(theta)
    };
    const handle = (4 / 3) * radius * Math.tan(theta / 4);
    const c1 = {
      x: p0.x + tangent.x * handle,
      y: p0.y + tangent.y * handle
    };
    const c2 = {
      x: p3.x - endTangent.x * handle,
      y: p3.y - endTangent.y * handle
    };
    return { p0, c1, c2, p3, radius, tangent, normal, theta };
  }

  function pathData(config = state) {
    const { p0, p3, radius } = bladeGeometry(config);
    if (!Number.isFinite(radius)) {
      return `M ${round(p0.x)} ${round(p0.y)} L ${round(p3.x)} ${round(p3.y)}`;
    }
    return `M ${round(p0.x)} ${round(p0.y)} A ${round(radius)} ${round(radius)} 0 0 1 ${round(p3.x)} ${round(p3.y)}`;
  }

  function taperedBladePoints(config = state) {
    const geometry = bladeGeometry(config);
    const sideA = [];
    const sideB = [];
    const samples = 48;
    const capSamples = 12;
    const taperStartScale = 1 - config.innerTaper / 100;

    const sample = u => {
      let center;
      let direction;
      if (!Number.isFinite(geometry.radius)) {
        center = {
          x: geometry.p0.x + geometry.tangent.x * config.lineLength * u,
          y: geometry.p0.y + geometry.tangent.y * config.lineLength * u
        };
        direction = geometry.tangent;
      } else {
        const phi = geometry.theta * u;
        center = {
          x: geometry.p0.x + geometry.tangent.x * geometry.radius * Math.sin(phi) + geometry.normal.x * geometry.radius * (1 - Math.cos(phi)),
          y: geometry.p0.y + geometry.tangent.y * geometry.radius * Math.sin(phi) + geometry.normal.y * geometry.radius * (1 - Math.cos(phi))
        };
        direction = {
          x: geometry.tangent.x * Math.cos(phi) + geometry.normal.x * Math.sin(phi),
          y: geometry.tangent.y * Math.cos(phi) + geometry.normal.y * Math.sin(phi)
        };
      }
      const taperProgress = Math.min(u / 0.42, 1);
      const easedProgress = taperProgress * taperProgress * (3 - 2 * taperProgress);
      const widthScale = taperStartScale + (1 - taperStartScale) * easedProgress;
      return { center, direction, halfWidth: config.thickness * widthScale / 2 };
    };

    for (let index = 0; index <= samples; index += 1) {
      const current = sample(index / samples);
      const offset = { x: -current.direction.y * current.halfWidth, y: current.direction.x * current.halfWidth };
      sideA.push({ x: current.center.x + offset.x, y: current.center.y + offset.y });
      sideB.push({ x: current.center.x - offset.x, y: current.center.y - offset.y });
    }

    const end = sample(1);
    const endAngle = Math.atan2(end.direction.y, end.direction.x);
    const endCap = [];
    for (let index = 1; index <= capSamples; index += 1) {
      const angle = endAngle + Math.PI / 2 - Math.PI * index / capSamples;
      endCap.push({ x: end.center.x + Math.cos(angle) * end.halfWidth, y: end.center.y + Math.sin(angle) * end.halfWidth });
    }

    const start = sample(0);
    const startAngle = Math.atan2(start.direction.y, start.direction.x);
    const startCap = [];
    for (let index = 1; index <= capSamples; index += 1) {
      const angle = startAngle - Math.PI / 2 - Math.PI * index / capSamples;
      startCap.push({ x: start.center.x + Math.cos(angle) * start.halfWidth, y: start.center.y + Math.sin(angle) * start.halfWidth });
    }

    return [...sideA, ...endCap, ...sideB.reverse(), ...startCap];
  }

  function taperedPathData(config = state) {
    const points = taperedBladePoints(config);
    return points.map((point, index) => `${index === 0 ? "M" : "L"} ${round(point.x)} ${round(point.y)}`).join(" ") + " Z";
  }

  function svgElement({ ink = "currentColor", tile = null, className = "" } = {}) {
    const svg = document.createElementNS(SVG_NS, "svg");
    const bladeId = `max-logo-blade-${svgSerial += 1}`;
    const isTapered = state.innerTaper > 0;
    svg.setAttribute("viewBox", "0 0 100 100");
    svg.setAttribute("role", "img");
    svg.setAttribute("aria-label", "Max pinwheel mark");
    if (className) svg.setAttribute("class", className);

    if (tile) {
      const rect = document.createElementNS(SVG_NS, "rect");
      rect.setAttribute("width", "100");
      rect.setAttribute("height", "100");
      rect.setAttribute("rx", "22");
      rect.setAttribute("fill", tile);
      svg.append(rect);
    }

    const definitions = document.createElementNS(SVG_NS, "defs");
    const masterBlade = document.createElementNS(SVG_NS, "path");
    masterBlade.setAttribute("id", bladeId);
    masterBlade.setAttribute("d", isTapered ? taperedPathData() : pathData());
    definitions.append(masterBlade);
    svg.append(definitions);

    const rotor = document.createElementNS(SVG_NS, "g");
    rotor.setAttribute("class", "logo-rotor");
    rotor.setAttribute("fill", isTapered ? ink : "none");
    rotor.setAttribute("stroke", isTapered ? "none" : ink);
    if (!isTapered) {
      rotor.setAttribute("stroke-width", state.thickness);
      rotor.setAttribute("stroke-linecap", "round");
      rotor.setAttribute("stroke-linejoin", "round");
    }

    for (let index = 0; index < state.blades; index += 1) {
      const position = document.createElementNS(SVG_NS, "g");
      const angle = state.rotation + index * (360 / state.blades);
      position.setAttribute("transform", `rotate(${round(angle)} 50 50)`);
      const blade = document.createElementNS(SVG_NS, "use");
      blade.setAttribute("class", "logo-blade");
      blade.setAttribute("style", `--blade-index:${index}`);
      blade.setAttribute("href", `#${bladeId}`);
      position.append(blade);
      rotor.append(position);
    }
    svg.append(rotor);
    return svg;
  }

  function svgString(assetStyle = "mark") {
    const isLight = assetStyle === "lightTile";
    const isDark = assetStyle === "darkTile";
    const ink = isLight ? state.lightInk : isDark ? state.darkInk : "#000000";
    const tile = isLight ? state.lightBg : isDark ? state.darkBg : null;
    const svg = svgElement({ ink, tile });
    svg.setAttribute("xmlns", SVG_NS);
    svg.setAttribute("width", "1024");
    svg.setAttribute("height", "1024");
    return `<?xml version="1.0" encoding="UTF-8"?>\n${new XMLSerializer().serializeToString(svg)}\n`;
  }

  function renderInto(container, ink) {
    container.replaceChildren(svgElement({ ink }));
    container.className = container.className.replace(/\bmotion-\w+\b/g, "").trim();
    container.classList.add(`motion-${state.motion}`);
  }

  function updateUI() {
    renderInto($("#hero-mark"), "currentColor");
    renderInto($("#light-card [data-logo-preview]"), "currentColor");
    renderInto($("#dark-card [data-logo-preview]"), "currentColor");

    const lightCard = $("#light-card");
    lightCard.style.background = state.lightBg;
    lightCard.style.color = state.lightInk;
    const darkCard = $("#dark-card");
    darkCard.style.background = state.darkBg;
    darkCard.style.color = state.darkInk;

    const stage = $("#stage");
    const hero = $("#hero-mark");
    if (state.surface === "light") {
      stage.style.backgroundColor = state.lightBg;
      stage.style.backgroundImage = "none";
      hero.style.color = state.lightInk;
    } else if (state.surface === "dark") {
      stage.style.backgroundColor = state.darkBg;
      stage.style.backgroundImage = "none";
      hero.style.color = state.darkInk;
    } else {
      stage.style.backgroundColor = "#f7f7fa";
      stage.style.backgroundImage = "";
      hero.style.color = state.lightInk;
    }

    $$("#surface-control button").forEach(button => button.setAttribute("aria-pressed", button.dataset.surface === state.surface));
    $$("#motion-control button").forEach(button => button.setAttribute("aria-pressed", button.dataset.motion === state.motion));
    $("#geometry-readout").textContent = `${state.blades}-fold · ${state.lineLength} length · ${state.centerDistance} radius · ${state.curvature}° bend · ${state.innerTaper}% taper`;
    renderSizes();
    saveState();
  }

  function renderSizes() {
    const row = $("#size-row");
    row.replaceChildren();
    [16, 24, 32, 48, 64, 96, 128].forEach(size => {
      const sample = document.createElement("div");
      sample.className = "size-sample";
      const image = document.createElement("div");
      image.style.width = `${size}px`;
      image.style.height = `${size}px`;
      image.append(svgElement({ ink: "currentColor" }));
      const label = document.createElement("span");
      label.textContent = `${size}px`;
      sample.append(image, label);
      row.append(sample);
    });
  }

  function initialiseInputs() {
    [...numericKeys, ...colorKeys].forEach(key => {
      const input = $(`#${key}`);
      input.value = state[key];
      input.addEventListener("input", () => {
        state[key] = numericKeys.includes(key) ? Number(input.value) : input.value;
        updateOutput(key);
        updateUI();
      });
      updateOutput(key);
    });
    $$("#surface-control button").forEach(button => button.addEventListener("click", () => {
      state.surface = button.dataset.surface;
      updateUI();
    }));
    $$("#motion-control button").forEach(button => button.addEventListener("click", () => {
      state.motion = button.dataset.motion;
      updateUI();
    }));
  }

  function updateOutput(key) {
    const output = $(`#${key}-value`);
    if (!output) return;
    const suffix = key === "curvature" || key === "rotation" ? "°" : key === "innerTaper" ? "%" : "";
    output.textContent = `${state[key]}${suffix}`;
  }

  function download(blob, filename) {
    const url = URL.createObjectURL(blob);
    const anchor = document.createElement("a");
    anchor.href = url;
    anchor.download = filename;
    document.body.append(anchor);
    anchor.click();
    anchor.remove();
    setTimeout(() => URL.revokeObjectURL(url), 1000);
  }

  function selectedAssetStyle() {
    return $("#asset-style").value;
  }

  async function downloadPNG() {
    const size = Number($("#png-size").value);
    const markup = svgString(selectedAssetStyle()).replace('width="1024"', `width="${size}"`).replace('height="1024"', `height="${size}"`);
    const source = URL.createObjectURL(new Blob([markup], { type: "image/svg+xml" }));
    const image = new Image();
    image.onload = () => {
      const canvas = document.createElement("canvas");
      canvas.width = size;
      canvas.height = size;
      canvas.getContext("2d").drawImage(image, 0, 0, size, size);
      canvas.toBlob(blob => {
        download(blob, `max-logo-${selectedAssetStyle()}-${size}.png`);
        URL.revokeObjectURL(source);
        showToast(`Downloaded ${size} × ${size} PNG`);
      }, "image/png");
    };
    image.onerror = () => {
      URL.revokeObjectURL(source);
      showToast("PNG rendering failed");
    };
    image.src = source;
  }

  function swiftSource() {
    const geometry = bladeGeometry();
    const point = p => `CGPoint(x: ${round(p.x)}, y: ${round(p.y)})`;
    if (state.innerTaper > 0) return taperedSwiftSource();
    return `// Generated by Max Logo Lab. The 100 × 100 geometry is resolution-independent.\nimport SwiftUI\n\nstruct MaxLogoMark: View {\n    var color: Color = .primary\n\n    var body: some View {\n        Canvas { context, size in\n            let side = min(size.width, size.height)\n            let offset = CGPoint(x: (size.width - side) / 2, y: (size.height - side) / 2)\n            context.translateBy(x: offset.x, y: offset.y)\n            context.scaleBy(x: side / 100, y: side / 100)\n\n            for blade in 0..<${state.blades} {\n                var path = Path()\n                path.move(to: ${point(geometry.p0)})\n                path.addCurve(\n                    to: ${point(geometry.p3)},\n                    control1: ${point(geometry.c1)},\n                    control2: ${point(geometry.c2)}\n                )\n\n                let angle = Angle.degrees(${round(state.rotation)} + Double(blade) * (360 / ${state.blades}))\n                let transform = CGAffineTransform(translationX: 50, y: 50)\n                    .rotated(by: angle.radians)\n                    .translatedBy(x: -50, y: -50)\n                context.stroke(\n                    path.applying(transform),\n                    with: .color(color),\n                    style: StrokeStyle(lineWidth: ${round(state.thickness)}, lineCap: .round, lineJoin: .round)\n                )\n            }\n        }\n        .aspectRatio(1, contentMode: .fit)\n        .accessibilityHidden(true)\n    }\n}\n\n#Preview {\n    HStack(spacing: 24) {\n        MaxLogoMark().frame(width: 24, height: 24)\n        MaxLogoMark(color: .indigo).frame(width: 64, height: 64)\n    }\n    .padding()\n}\n`;
  }

  function taperedSwiftSource() {
    const points = taperedBladePoints();
    const point = value => `CGPoint(x: ${round(value.x)}, y: ${round(value.y)})`;
    const segments = points.slice(1).map(value => `            bladePath.addLine(to: ${point(value)})`).join("\n");
    return `// Generated by Max Logo Lab. The tapered outline is resolution-independent.
import SwiftUI

struct MaxLogoMark: View {
    var color: Color = .primary

    var body: some View {
        Canvas { context, size in
            let side = min(size.width, size.height)
            let offset = CGPoint(x: (size.width - side) / 2, y: (size.height - side) / 2)
            context.translateBy(x: offset.x, y: offset.y)
            context.scaleBy(x: side / 100, y: side / 100)

            var bladePath = Path()
            bladePath.move(to: ${point(points[0])})
${segments}
            bladePath.closeSubpath()

            for blade in 0..<${state.blades} {
                let angle = Angle.degrees(${round(state.rotation)} + Double(blade) * (360 / ${state.blades}))
                let transform = CGAffineTransform(translationX: 50, y: 50)
                    .rotated(by: angle.radians)
                    .translatedBy(x: -50, y: -50)
                context.fill(bladePath.applying(transform), with: .color(color))
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityHidden(true)
    }
}
`;
  }

  async function copyText(text, successMessage) {
    try {
      await navigator.clipboard.writeText(text);
      showToast(successMessage);
    } catch (_) {
      const area = document.createElement("textarea");
      area.value = text;
      area.style.position = "fixed";
      area.style.opacity = "0";
      document.body.append(area);
      area.select();
      document.execCommand("copy");
      area.remove();
      showToast(successMessage);
    }
  }

  function showToast(message) {
    const toast = $("#toast");
    toast.textContent = message;
    toast.classList.add("is-visible");
    clearTimeout(toastTimer);
    toastTimer = setTimeout(() => toast.classList.remove("is-visible"), 1800);
  }

  function wireActions() {
    $("#download-svg").addEventListener("click", () => {
      download(new Blob([svgString(selectedAssetStyle())], { type: "image/svg+xml" }), `max-logo-${selectedAssetStyle()}.svg`);
      showToast("Downloaded SVG master");
    });
    $("#download-png").addEventListener("click", downloadPNG);
    $("#copy-svg").addEventListener("click", () => copyText(svgString(selectedAssetStyle()), "SVG copied"));
    $("#download-swift").addEventListener("click", () => {
      download(new Blob([swiftSource()], { type: "text/plain" }), "MaxLogoMark.swift");
      showToast("Downloaded SwiftUI source");
    });
    $("#copy-config").addEventListener("click", () => copyText(JSON.stringify(state, null, 2), "Settings copied"));
    $("#reset-button").addEventListener("click", () => {
      Object.assign(state, defaults);
      [...numericKeys, ...colorKeys].forEach(key => {
        $(`#${key}`).value = state[key];
        updateOutput(key);
      });
      updateUI();
      showToast("Reset to the reference study");
    });
  }

  initialiseInputs();
  wireActions();
  updateUI();
})();
