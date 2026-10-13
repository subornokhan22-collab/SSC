const header = document.querySelector('[data-header]');
const menuButton = document.querySelector('[data-menu-button]');
const mobileNav = document.querySelector('[data-mobile-nav]');

const updateHeader = () => header.classList.toggle('scrolled', window.scrollY > 24);
updateHeader();
window.addEventListener('scroll', updateHeader, { passive: true });

menuButton.addEventListener('click', () => {
  const open = mobileNav.classList.toggle('open');
  menuButton.setAttribute('aria-expanded', String(open));
  menuButton.setAttribute('aria-label', open ? 'Close navigation' : 'Open navigation');
});

mobileNav.querySelectorAll('a').forEach((link) => link.addEventListener('click', () => {
  mobileNav.classList.remove('open');
  menuButton.setAttribute('aria-expanded', 'false');
}));

const observer = new IntersectionObserver((entries) => {
  entries.forEach((entry) => {
    if (entry.isIntersecting) {
      entry.target.classList.add('visible');
      observer.unobserve(entry.target);
    }
  });
}, { threshold: 0.12, rootMargin: '0px 0px -40px' });

document.querySelectorAll('.reveal').forEach((element) => observer.observe(element));

// Keep only one FAQ expanded, making the page easier to scan.
document.querySelectorAll('details').forEach((detail) => {
  detail.addEventListener('toggle', () => {
    if (!detail.open) return;
    document.querySelectorAll('details[open]').forEach((other) => {
      if (other !== detail) other.open = false;
    });
  });
});

// Reflect the section currently in view in the navigation without changing
// the URL or interrupting the reading position.
const sectionLinks = [...document.querySelectorAll('.desktop-nav a, .mobile-nav a')];
const trackedSections = ['features', 'workflow', 'plans', 'downloads', 'questions']
  .map((id) => document.getElementById(id))
  .filter(Boolean);
const navigationObserver = new IntersectionObserver((entries) => {
  const visible = entries
    .filter((entry) => entry.isIntersecting)
    .sort((a, b) => b.intersectionRatio - a.intersectionRatio)[0];
  if (!visible) return;
  sectionLinks.forEach((link) => {
    const active = link.getAttribute('href') === `#${visible.target.id}`;
    link.classList.toggle('active', active);
    if (active) link.setAttribute('aria-current', 'location');
    else link.removeAttribute('aria-current');
  });
}, { rootMargin: '-30% 0px -55%', threshold: [0, 0.15, 0.5] });
trackedSections.forEach((section) => navigationObserver.observe(section));

const backToTop = document.querySelector('[data-back-to-top]');
const updateBackToTop = () => backToTop.classList.toggle('visible', window.scrollY > 700);
updateBackToTop();
window.addEventListener('scroll', updateBackToTop, { passive: true });
backToTop.addEventListener('click', () => window.scrollTo({ top: 0, behavior: 'smooth' }));
