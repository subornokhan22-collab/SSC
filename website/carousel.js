document.querySelectorAll('[data-carousel]').forEach((carousel) => {
  const viewport = carousel.querySelector('[data-carousel-viewport]');
  const track = carousel.querySelector('[data-carousel-track]');
  const slides = [...carousel.querySelectorAll('[data-slide]')];
  const dotsContainer = carousel.querySelector('[data-carousel-dots]');
  const currentLabel = carousel.querySelector('[data-current-slide]');
  const totalLabel = carousel.querySelector('[data-total-slides]');
  const reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)');
  let index = 0;
  let visualIndex = 1;
  let timer = null;
  let pointerStart = null;

  totalLabel.textContent = String(slides.length).padStart(2, '0');

  // Bookend clones let the last card move naturally into the first card (and
  // vice versa). After that short transition, the track silently resets to
  // its equivalent real slide, creating one continuous circular rail.
  const beforeClone = slides.at(-1).cloneNode(true);
  const afterClone = slides[0].cloneNode(true);
  [beforeClone, afterClone].forEach((clone) => {
    clone.removeAttribute('data-slide');
    clone.setAttribute('aria-hidden', 'true');
    clone.classList.add('carousel-clone');
  });
  track.prepend(beforeClone);
  track.append(afterClone);
  const rail = [beforeClone, ...slides, afterClone];

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

  const render = ({ animate = true, updateProgress = true } = {}) => {
    track.classList.toggle('no-transition', !animate);
    const focusedCard = rail[visualIndex];
    const centeredLeft = focusedCard.offsetLeft - (viewport.clientWidth - focusedCard.offsetWidth) / 2;
    track.style.transform = `translate3d(${-centeredLeft}px, 0, 0)`;
    rail.forEach((slide, railIndex) => {
      slide.classList.toggle('is-active', railIndex === visualIndex);
      slide.classList.toggle('is-next', railIndex === visualIndex + 1);
    });
    slides.forEach((slide, slideIndex) => slide.setAttribute('aria-hidden', String(slideIndex !== index)));
    currentLabel.textContent = String(index + 1).padStart(2, '0');
    if (updateProgress) restartProgress();
  };

  const schedule = () => {
    clearTimeout(timer);
    if (reducedMotion.matches || document.hidden) return;
    timer = setTimeout(() => goTo(index + 1), 1800);
  };

  function goTo(nextIndex, initiatedByUser = false) {
    if (nextIndex >= slides.length) {
      index = 0;
      visualIndex = slides.length + 1;
    } else if (nextIndex < 0) {
      index = slides.length - 1;
      visualIndex = 0;
    } else {
      index = nextIndex;
      visualIndex = index + 1;
    }
    render();
    schedule();
    if (initiatedByUser) viewport.focus({ preventScroll: true });
  }

  track.addEventListener('transitionend', (event) => {
    if (event.propertyName !== 'transform') return;
    if (visualIndex === slides.length + 1) {
      visualIndex = 1;
      render({ animate: false, updateProgress: false });
      requestAnimationFrame(() => track.classList.remove('no-transition'));
    } else if (visualIndex === 0) {
      visualIndex = slides.length;
      render({ animate: false, updateProgress: false });
      requestAnimationFrame(() => track.classList.remove('no-transition'));
    }
  });

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
  reducedMotion.addEventListener('change', () => { render({ animate: false }); schedule(); });
  window.addEventListener('resize', () => {
    render({ animate: false, updateProgress: false });
    requestAnimationFrame(() => track.classList.remove('no-transition'));
  });

  render({ animate: false });
  requestAnimationFrame(() => requestAnimationFrame(() => track.classList.remove('no-transition')));
  schedule();
});
