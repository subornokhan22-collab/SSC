(() => {
  const SUPABASE_URL = 'https://vxexidxdoghdmzvkvgqk.supabase.co';
  // Supabase anon keys are intentionally public browser credentials. Payment
  // provider secrets remain exclusively inside the rupantor-pay Edge Function.
  const PROJECT_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ4ZXhpZHhkb2doZG16dmt2Z3FrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODU5ODYzMTcsImV4cCI6MjEwMTU2MjMxN30.hp1ZatmQpCXDFClWlOQEpSJhUwh8bfvspWYKXnXcMY4';

  const dialog = document.querySelector('[data-checkout-dialog]');
  const form = document.querySelector('[data-checkout-form]');
  if (!dialog || !form) return;
  const planName = dialog.querySelector('[data-checkout-plan]');
  const submitText = dialog.querySelector('[data-checkout-submit]');
  const status = dialog.querySelector('[data-checkout-status]');
  const modeButton = dialog.querySelector('[data-checkout-mode]');
  let plan = '';
  let createMode = false;
  let busy = false;

  const message = (text, error = false) => {
    status.textContent = text;
    status.classList.toggle('is-error', error);
  };

  document.querySelectorAll('[data-buy-plan]').forEach((button) => {
    button.addEventListener('click', () => {
      plan = button.dataset.buyPlan || '';
      planName.textContent = button.dataset.planLabel || 'your plan';
      createMode = false;
      submitText.textContent = 'Sign in & continue';
      modeButton.textContent = 'New to Tutor’s Desk? Create an account';
      message('');
      dialog.showModal();
    });
  });

  dialog.querySelector('[data-checkout-close]').addEventListener('click', () => dialog.close());
  dialog.addEventListener('click', (event) => {
    if (event.target === dialog) dialog.close();
  });
  modeButton.addEventListener('click', () => {
    createMode = !createMode;
    submitText.textContent = createMode ? 'Create account' : 'Sign in & continue';
    modeButton.textContent = createMode
      ? 'Already have an account? Sign in'
      : 'New to Tutor’s Desk? Create an account';
    message('');
  });

  const request = async (path, options = {}) => {
    const response = await fetch(`${SUPABASE_URL}${path}`, {
      ...options,
      headers: {
        apikey: PROJECT_ANON_KEY,
        'Content-Type': 'application/json',
        ...(options.headers || {}),
      },
    });
    const body = await response.json().catch(() => ({}));
    if (!response.ok) throw new Error(body.msg || body.message || body.error || 'Request failed. Please try again.');
    return body;
  };

  form.addEventListener('submit', async (event) => {
    event.preventDefault();
    if (busy || !plan) return;
    busy = true;
    form.querySelector('button[type="submit"]').disabled = true;
    message(createMode ? 'Creating your account…' : 'Signing in securely…');
    const data = new FormData(form);
    const credentials = { email: data.get('email'), password: data.get('password') };
    try {
      if (createMode) {
        const signup = await request('/auth/v1/signup', {
          method: 'POST',
          body: JSON.stringify(credentials),
        });
        if (!signup.access_token) {
          message('Account created. Confirm the email we sent you, then return here and sign in.');
          createMode = false;
          submitText.textContent = 'Sign in & continue';
          modeButton.textContent = 'New to Tutor’s Desk? Create an account';
          return;
        }
      }
      const session = await request('/auth/v1/token?grant_type=password', {
        method: 'POST',
        body: JSON.stringify(credentials),
      });
      if (!session.access_token) throw new Error('Sign-in did not return a valid session.');
      message('Creating your secure checkout…');
      const payment = await request('/functions/v1/rupantor-pay', {
        method: 'POST',
        headers: { Authorization: `Bearer ${session.access_token}` },
        body: JSON.stringify({ action: 'initiate', plan }),
      });
      const checkoutUrl = payment.checkoutUrl;
      if (!payment.ok || typeof checkoutUrl !== 'string' || !checkoutUrl.startsWith('https://')) {
        throw new Error(payment.error || 'The payment server did not return a secure checkout link.');
      }
      message('Checkout ready. Redirecting to RupantorPay…');
      window.location.assign(checkoutUrl);
    } catch (error) {
      message(error instanceof Error ? error.message : 'Checkout could not start.', true);
    } finally {
      busy = false;
      form.querySelector('button[type="submit"]').disabled = false;
    }
  });
})();
