(() => {
  const SUPABASE_URL = 'https://vxexidxdoghdmzvkvgqk.supabase.co';
  // Supabase anon keys are public browser credentials. Provider secrets remain
  // exclusively inside the rupantor-pay Edge Function.
  const PROJECT_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ4ZXhpZHhkb2doZG16dmt2Z3FrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODU5ODYzMTcsImV4cCI6MjEwMTU2MjMxN30.hp1ZatmQpCXDFClWlOQEpSJhUwh8bfvspWYKXnXcMY4';
  const SESSION_KEY = 'tutors_desk_web_session_v1';
  const dialog = document.querySelector('[data-checkout-dialog]');
  const form = document.querySelector('[data-checkout-form]');
  if (!dialog || !form) return;

  const planName = dialog.querySelector('[data-checkout-plan]');
  const title = dialog.querySelector('#checkout-title');
  const lede = dialog.querySelector('[data-checkout-lede]');
  const submitText = dialog.querySelector('[data-checkout-submit]');
  const status = dialog.querySelector('[data-checkout-status]');
  const modeButton = dialog.querySelector('[data-checkout-mode]');
  const summary = dialog.querySelector('[data-account-summary]');
  const accountEmail = dialog.querySelector('[data-account-email]');
  const accountPlan = dialog.querySelector('[data-account-plan]');
  const accountAvatar = dialog.querySelector('[data-account-avatar]');
  const accountCheckout = dialog.querySelector('[data-account-checkout]');
  let plan = '';
  let createMode = false;
  let busy = false;
  let session = loadSession();

  function loadSession() {
    try {
      const value = JSON.parse(localStorage.getItem(SESSION_KEY) || 'null');
      return value?.access_token && value?.user?.email ? value : null;
    } catch (_) { return null; }
  }
  const saveSession = (value) => {
    session = value;
    if (value) localStorage.setItem(SESSION_KEY, JSON.stringify(value));
    else localStorage.removeItem(SESSION_KEY);
    updateHeader();
  };
  const message = (text, error = false) => {
    status.textContent = text;
    status.classList.toggle('is-error', error);
  };
  const updateHeader = () => {
    document.querySelectorAll('[data-account-label]').forEach((el) => {
      el.textContent = session ? session.user.email.split('@')[0] : 'Account';
    });
    document.querySelectorAll('.account-dot').forEach((el) => el.classList.toggle('is-online', Boolean(session)));
  };
  const request = async (path, options = {}) => {
    const response = await fetch(`${SUPABASE_URL}${path}`, {
      ...options,
      headers: { apikey: PROJECT_ANON_KEY, 'Content-Type': 'application/json', ...(options.headers || {}) },
    });
    const body = await response.json().catch(() => ({}));
    if (!response.ok) throw new Error(body.msg || body.message || body.error || 'Request failed. Please try again.');
    return body;
  };
  const showSignedOut = () => {
    summary.hidden = true;
    form.hidden = false;
    modeButton.hidden = false;
    submitText.textContent = createMode ? 'Create account' : 'Sign in & continue';
  };
  const showSignedIn = async () => {
    if (!session) return showSignedOut();
    form.hidden = true;
    modeButton.hidden = true;
    summary.hidden = false;
    accountCheckout.hidden = !plan;
    accountEmail.textContent = session.user.email;
    accountAvatar.textContent = session.user.email.slice(0, 2).toUpperCase();
    accountPlan.textContent = 'Checking subscription…';
    try {
      const rows = await request(`/rest/v1/profiles?select=subscription_plan,subscription_status,subscription_expires_at&id=eq.${encodeURIComponent(session.user.id)}&limit=1`, {
        headers: { Authorization: `Bearer ${session.access_token}` },
      });
      const profile = Array.isArray(rows) ? rows[0] : null;
      const name = profile?.subscription_plan || 'free';
      accountPlan.textContent = `${name.charAt(0).toUpperCase()}${name.slice(1)} plan`;
    } catch (_) {
      accountPlan.textContent = 'Tutor’s Desk account';
    }
  };
  const openDialog = async (selectedPlan = '', label = '') => {
    plan = selectedPlan;
    createMode = false;
    planName.textContent = label || 'account';
    title.firstChild.textContent = selectedPlan ? 'Continue with ' : 'Your Tutor’s Desk ';
    lede.textContent = selectedPlan
      ? 'Sign in to the same Tutor’s Desk account you use in the app. Your plan activates there after verified payment.'
      : 'Sign in to manage the account shared by your Android and Windows apps.';
    message('');
    dialog.showModal();
    await showSignedIn();
  };
  const startCheckout = async () => {
    if (!session || !plan || busy) return;
    busy = true;
    accountCheckout.disabled = true;
    message('Creating your secure checkout…');
    try {
      const payment = await request('/functions/v1/rupantor-pay', {
        method: 'POST',
        headers: { Authorization: `Bearer ${session.access_token}` },
        body: JSON.stringify({ action: 'initiate', plan }),
      });
      const url = payment.checkoutUrl;
      if (!payment.ok || typeof url !== 'string' || !url.startsWith('https://')) throw new Error(payment.error || 'Secure checkout is unavailable.');
      message('Checkout ready. Redirecting to RupantorPay…');
      window.location.assign(url);
    } catch (error) {
      message(error instanceof Error ? error.message : 'Checkout could not start.', true);
    } finally {
      busy = false;
      accountCheckout.disabled = false;
    }
  };

  document.querySelectorAll('[data-buy-plan]').forEach((button) => button.addEventListener('click', () => openDialog(button.dataset.buyPlan || '', button.dataset.planLabel || '')));
  document.querySelectorAll('[data-account-open]').forEach((button) => button.addEventListener('click', () => openDialog()));
  dialog.querySelector('[data-checkout-close]').addEventListener('click', () => dialog.close());
  dialog.addEventListener('click', (event) => { if (event.target === dialog) dialog.close(); });
  accountCheckout.addEventListener('click', startCheckout);
  dialog.querySelector('[data-account-signout]').addEventListener('click', () => {
    saveSession(null); message('Signed out.'); showSignedOut();
  });
  modeButton.addEventListener('click', () => {
    createMode = !createMode;
    submitText.textContent = createMode ? 'Create account' : 'Sign in & continue';
    modeButton.textContent = createMode ? 'Already have an account? Sign in' : 'New to Tutor’s Desk? Create an account';
    message('');
  });
  form.addEventListener('submit', async (event) => {
    event.preventDefault();
    if (busy) return;
    busy = true;
    form.querySelector('button[type="submit"]').disabled = true;
    const data = new FormData(form);
    const credentials = { email: data.get('email'), password: data.get('password') };
    message(createMode ? 'Creating your account…' : 'Signing in securely…');
    try {
      if (createMode) {
        const signup = await request('/auth/v1/signup', { method: 'POST', body: JSON.stringify(credentials) });
        if (!signup.access_token) {
          message('Account created. Confirm your email, then return and sign in.');
          createMode = false; submitText.textContent = 'Sign in & continue'; return;
        }
        saveSession(signup);
      } else {
        saveSession(await request('/auth/v1/token?grant_type=password', { method: 'POST', body: JSON.stringify(credentials) }));
      }
      await showSignedIn();
      message(plan ? 'Signed in. Continue to secure checkout.' : 'Signed in successfully.');
    } catch (error) {
      message(error instanceof Error ? error.message : 'Account request failed.', true);
    } finally {
      busy = false;
      form.querySelector('button[type="submit"]').disabled = false;
    }
  });
  updateHeader();
})();
