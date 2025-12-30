// Reown AppKit integration helper
// This helper attempts to dynamically import the official Reown AppKit SDK
// (if installed as a dependency) and exposes simple init/login/getUser helpers.

let reownInstance = null;

export async function initReown(apiKey) {
  if (!apiKey) {
    console.warn('VITE_REOWN_API_KEY not set; skipping Reown init');
    return null;
  }

  // Try dynamic import of common package name. If you use a different package
  // name, adjust the import path or install the official SDK per Reown docs.
  try {
    const mod = await import('reown-appkit');
    const Reown = mod.default || mod.Reown || mod.ReownSDK || mod;
    if (typeof Reown === 'function') {
      reownInstance = new Reown({ apiKey });
    } else if (Reown && typeof Reown.init === 'function') {
      reownInstance = Reown;
      await reownInstance.init({ apiKey });
    } else {
      console.warn('Reown module loaded but has unexpected shape');
    }
    console.info('Reown AppKit initialized')
    return reownInstance;
  } catch (err) {
    console.warn('Reown AppKit not installed or failed to import:', err.message || err);
    // Fallback: if the SDK was added via a script tag and exposes window.Reown
    if (typeof window !== 'undefined' && window.Reown) {
      reownInstance = window.Reown;
      try { await reownInstance.init({ apiKey }); } catch(_) {}
      console.info('Using window.Reown instance')
      return reownInstance;
    }
    return null;
  }
}

export async function reownLogin() {
  if (!reownInstance) throw new Error('Reown not initialized');
  if (typeof reownInstance.login === 'function') return reownInstance.login();
  throw new Error('Reown instance has no login method');
}

export async function reownGetUser() {
  if (!reownInstance) return null;
  if (typeof reownInstance.getUser === 'function') return reownInstance.getUser();
  return null;
}

export async function reownLogout() {
  if (!reownInstance) return;
  if (typeof reownInstance.logout === 'function') return reownInstance.logout();
}

