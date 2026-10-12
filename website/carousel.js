document.querySelectorAll('[data-carousel]').forEach((carousel) => {
  const viewport = carousel.querySelector('[data-carousel-viewport]');
  const track = carousel.querySelector('[data-carousel-track]');
  const slides = [...carousel.querySelectorAll('[data-slide]')];
  const dotsContainer = carousel.querySelector('[data-carousel-dots]');
  const currentLabel = carousel.querySelector('[data-current-slide]');
  const reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)');
  let index = 0;
  let timer = null;
  let pointerStart = null;

  const dots = slides.map((slide, slideIndex) => {
    const dot = document.createElement('button');
    dot.type = 'button';
    dot.setAttribute('aria-label', `Show feature ${slideIndex + 1}: ${slide.querySelector('h3').textContent}`);
    dot.addEventListener('click', () => goTo(slideIndex, true));
    dotsContainer.append(dot);
    return dot;
  });

  const restartProgress = () => {
    dots.forEach((dot, dotIndex) => {
      dot.classList.remove('active', 'paused');
      if (dotIndex === index) {
        void dot.offsetWidth;
        dot.classList.add('active');
        if (reducedMotion.matches) dot.classList.add('paused');
      }
    });
  };

  const render = () => {
    const slide = slides[index];
    const centeredLeft = slide.offsetLeft - (viewport.clientWidth - slide.offsetWidth) / 2;
    track.style.transform = `translate3d(${-centeredLeft}px, 0, 0)`;
    slides.forEach((slide, slideIndex) => {
      slide.classList.toggle('is-active', slideIndex === index);
      slide.classList.toggle('is-next', slideIndex === (index + 1) % slides.length);
      slide.setAttribute('aria-hidden', String(slideIndex !== index));
    });
    currentLabel.textContent = String(index + 1).padStart(2, '0');
    restartProgress();
  };

  const schedule = () => {
    clearTimeout(timer);
    if (reducedMotion.matches || document.hidden) return;
    timer = setTimeout(() => goTo(index + 1), 1800);
  };

  function goTo(nextIndex, initiatedByUser = false) {
    index = (nextIndex + slides.length) % slides.length;
    render();
    schedule();
    if (initiatedByUser) viewport.focus({ preventScroll: true });
  }

  carousel.querySelector('[data-carousel-prev]').addEventListener('click', () => goTo(index - 1, true));
  carousel.querySelector('[data-carousel-next]').addEventListener('click', () => goTo(index + 1, true));
  viewport.addEventListener('keydown', (event) => {
    if (event.key === 'ArrowRight') goTo(index + 1, true);
    if (event.key === 'ArrowLeft') goTo(index - 1, true);
  });
  viewport.addEventListener('pointerdown', (event) => { pointerStart = event.clientX; });
  viewport.addEventListener('pointerup', (event) => {
    if (pointerStart === null) return;
    const distance = event.clientX - pointerStart;
    pointerStart = null;
    if (Math.abs(distance) > 45) goTo(index + (distance < 0 ? 1 : -1), true);
  });
  document.addEventListener('visibilitychange', schedule);
  reducedMotion.addEventListener('change', () => { render(); schedule(); });
  window.addEventListener('resize', render);

  render();
  schedule();
});
