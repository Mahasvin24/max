(() => {
  "use strict";

  const geometry = window.MaxVortexGeometry;
  const reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)");
  const hero = document.querySelector("#hero-mark");
  const rotate = document.querySelector("#rotate");
  const collapse = document.querySelector("#collapse");
  let serial = 0;
  let progress = 0;
  let collapsed = false;
  let animation;

  function draw(container) {
    container.innerHTML = geometry.svg({ id: `vortex-arm-${serial++}` });
  }

  draw(hero);
  const heroPath = hero.querySelector("defs path");
  document.querySelectorAll("[data-size-strip]").forEach(strip => {
    for (const size of [16, 20, 24, 32, 48, 64, 96, 128]) {
      const sample = document.createElement("div");
      sample.className = "size-sample";
      const box = document.createElement("div");
      box.className = "size-box";
      box.style.setProperty("--size", `${size}px`);
      draw(box);
      const label = document.createElement("span");
      label.textContent = `${size} px`;
      sample.append(box, label);
      strip.append(sample);
    }
  });

  function render(value) {
    progress = value;
    heroPath.setAttribute("d", geometry.pathData(progress));
  }

  rotate.addEventListener("click", () => {
    const active = rotate.getAttribute("aria-pressed") !== "true";
    rotate.setAttribute("aria-pressed", String(active));
    rotate.textContent = active ? "Pause rotation" : "Rotate";
    hero.classList.toggle("is-rotating", active);
  });

  collapse.addEventListener("click", () => {
    collapsed = !collapsed;
    collapse.setAttribute("aria-pressed", String(collapsed));
    collapse.textContent = collapsed ? "Expand vortex" : "Collapse to dot";
    cancelAnimationFrame(animation);
    const target = collapsed ? 1 : 0;
    if (reducedMotion.matches) return render(target);
    const from = progress;
    const start = performance.now();
    const duration = 650 * Math.abs(target - from);
    function tick(now) {
      const t = duration === 0 ? 1 : Math.min(1, (now - start) / duration);
      const ease = t * t * (3 - 2 * t);
      render(from + (target - from) * ease);
      if (t < 1) animation = requestAnimationFrame(tick);
    }
    animation = requestAnimationFrame(tick);
  });

  reducedMotion.addEventListener("change", () => {
    if (!reducedMotion.matches) return;
    cancelAnimationFrame(animation);
    render(collapsed ? 1 : 0);
  });
})();
