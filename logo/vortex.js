// Source geometry for the Max vortex. Coordinates are centered in a 100-unit square.
// The approved mockup's six arms were aligned, averaged, and fitted with smooth
// cubic curves. Repeating this single outline makes the rotational symmetry exact.
(function (root) {
  "use strict";

  const points = [
    [10.32181, -45.24972],
    [12.92447, -45.44447],
    [15.73923, -45.38896],
    [17.9263, -44.52665],
    [20.08534, -43.6754],
    [21.63267, -42.0379],
    [22.23133, -39.85861],
    [22.83, -37.67932],
    [22.47999, -34.95824],
    [21.01608, -33.49925],
    [19.55217, -32.04026],
    [16.97435, -31.84336],
    [14.31879, -31.71701],
    [11.62874, -31.58901],
    [8.85891, -31.5334],
    [6.59402, -30.88873],
    [4.35816, -30.25232],
    [2.61437, -29.04185],
    [1.02243, -27.7155],
    [-0.56951, -26.38915],
    [-2.00961, -24.9469],
    [-2.85973, -22.91961],
    [-3.2903, -21.8928],
    [-3.56953, -20.71591],
    [-3.72054, -19.41969],
    [-3.86769, -18.15672],
    [-3.89311, -16.78046],
    [-4.19522, -15.60317],
    [-4.50528, -14.3949],
    [-5.10679, -13.3962],
    [-6.03528, -12.85094],
    [-6.96378, -12.30569],
    [-8.21927, -12.21388],
    [-9.25223, -12.57003],
    [-11.29168, -13.2732],
    [-12.46373, -15.72256],
    [-13.03796, -18.15474],
    [-14.18642, -23.01911],
    [-12.9436, -27.81479],
    [-10.95682, -31.79432],
    [-6.97035, -39.7792],
    [0.01131, -44.47822],
    [10.32181, -45.24972],
  ];
  const armCount = 6;
  const dotRadius = 4;
  const curveCount = (points.length - 1) / 3;
  const dotPoints = [[0, -dotRadius]];

  for (let i = 0; i < curveCount; i += 1) {
    const a = -Math.PI / 2 + i * 2 * Math.PI / curveCount;
    const b = -Math.PI / 2 + (i + 1) * 2 * Math.PI / curveCount;
    const handle = 4 / 3 * Math.tan((b - a) / 4) * dotRadius;
    const start = [Math.cos(a) * dotRadius, Math.sin(a) * dotRadius];
    const end = [Math.cos(b) * dotRadius, Math.sin(b) * dotRadius];
    dotPoints.push(
      [start[0] - Math.sin(a) * handle, start[1] + Math.cos(a) * handle],
      [end[0] + Math.sin(b) * handle, end[1] - Math.cos(b) * handle],
      end
    );
  }

  const format = value => String(Number(value.toFixed(5)));

  function pathData(collapse = 0) {
    const progress = Math.max(0, Math.min(1, collapse));
    const pairs = points.map((point, i) => point.map((value, axis) =>
      format(value + (dotPoints[i][axis] - value) * progress)).join(" "));
    let path = `M ${pairs[0]}`;
    for (let i = 1; i < pairs.length; i += 3) {
      path += ` C ${pairs[i]} ${pairs[i + 1]} ${pairs[i + 2]}`;
    }
    return `${path} Z`;
  }

  function svg({ id = "vortex-arm", color = "currentColor", size = 1024 } = {}) {
    return `<svg xmlns="http://www.w3.org/2000/svg" width="${size}" height="${size}" viewBox="-50 -50 100 100" role="img" aria-label="Max vortex">
  <defs><path id="${id}" d="${pathData()}"/></defs>
  <g class="vortex-rotor" fill="${color}">
${Array.from({length: armCount}, (_, i) => `    <use href="#${id}" transform="rotate(${i * 60})"/>`).join("\n")}
  </g>
</svg>`;
  }

  const geometry = Object.freeze({ points, dotPoints, armCount, dotRadius, pathData, svg });
  if (typeof module !== "undefined" && module.exports) module.exports = geometry;
  else root.MaxVortexGeometry = geometry;
})(globalThis);
