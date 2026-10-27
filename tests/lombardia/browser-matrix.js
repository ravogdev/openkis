// Real-browser pass over a disposable OpenKIS site (never production): for a
// desktop browser and an emulated Android phone (Pixel 7, touch) and for
// anonymous and each test account of tests/regional/site-checks.sh (run that
// first: it creates them), opens the main pages and fails on an HTTP error,
// PHP error text, a JavaScript error, or a lost login. On the phone it also
// taps the menu button. Screenshots and results.json go to $OUT.
//
//   BASE=http://localhost:8098 node tests/lombardia/browser-matrix.js
//
// Settings: BASE (required), TEST_PASS [Regional-Test-2026], OUT [a temp dir]
const { chromium, devices } = require('playwright');
const fs = require('fs');
const os = require('os');
const path = require('path');

const BASE = (process.env.BASE || '').replace(/\/$/, '') + '/';
if (BASE === '/') { console.error('BASE must be set'); process.exit(2); }
if (/speleolombardia/i.test(BASE)) { console.error(`refusing to run against production (${BASE})`); process.exit(2); }
const PASS = process.env.TEST_PASS || 'Regional-Test-2026';
const OUT = process.env.OUT || fs.mkdtempSync(path.join(os.tmpdir(), 'openkis-browser-'));
fs.mkdirSync(OUT, { recursive: true });

const roles = [['anonymous', ''], ['read-only', 'test_ro'], ['read-write', 'test_rw'], ['curator', 'test_cur'], ['admin', 'test_admin']];
const devs = [['desktop', { viewport: { width: 1366, height: 900 } }], ['android', devices['Pixel 7']]];
const pages = [['home', 'index.php'], ['caves', 'index.php?mod=caves'], ['map', 'index.php?mod=map_caves'],
  ['survey', 'index.php?mod=survey'], ['controlcenter', 'index.php?fnapp=controlcenter']];

(async () => {
  const browser = await chromium.launch();
  const results = [];
  let failures = 0;
  const check = (ok, what) => { if (!ok) { failures++; console.log(`FAIL - ${what}`); } };
  for (const [dname, dopt] of devs) for (const [role, user] of roles) {
    const ctx = await browser.newContext({ ...dopt });
    const page = await ctx.newPage();
    let jsErrors = [];
    page.on('pageerror', e => jsErrors.push(e.message));
    await page.goto(BASE + 'index.php');
    if (user) {
      // the login form fields are not always visible (menus, phone layout): fill and submit in the page
      await page.goto(BASE + 'index.php?mod=login');
      const form = page.locator('form:has([name=username])').first();
      await form.evaluate((f, [u, p]) => {
        f.querySelector('[name=username]').value = u;
        f.querySelector('[name=password]').value = p;
      }, [user, PASS]);
      await Promise.all([page.waitForNavigation(), form.evaluate(f => f.submit())]);
    }
    for (const [pname, p] of pages) {
      jsErrors = [];
      const resp = await page.goto(BASE + p, { waitUntil: 'load' });
      const r = await page.evaluate(() => ({
        loggedIn: document.documentElement.outerHTML.includes('fnlogin=logout'),
        phpError: /(Fatal error|Warning:|Notice:|Deprecated:|Uncaught)/.test(document.body.innerText),
      }));
      if (dname === 'android') {
        const toggler = await page.$('.navbar-toggler');
        if (toggler && await toggler.isVisible()) { await toggler.tap(); await page.waitForTimeout(300); r.menuTapped = true; }
      }
      await page.screenshot({ path: path.join(OUT, `${dname}-${role}-${pname}.png`) });
      const where = `${dname} ${role} ${pname}`;
      check(resp.status() === 200, `${where}: HTTP ${resp.status()}`);
      check(!r.phpError, `${where}: PHP error text`);
      check(jsErrors.length === 0, `${where}: JavaScript errors: ${jsErrors.join(' | ')}`);
      // the control center refuses non-administrators with its own page, without the site menu
      if (pname !== 'controlcenter' || role === 'admin' || !user)
        check(r.loggedIn === Boolean(user), `${where}: logged in = ${r.loggedIn}`);
      results.push({ device: dname, role, page: pname, status: resp.status(), jsErrors: jsErrors.slice(), ...r });
    }
    await ctx.close();
  }
  await browser.close();
  fs.writeFileSync(path.join(OUT, 'results.json'), JSON.stringify(results, null, 1));
  console.log(`browser checks: ${results.length} pages, ${failures} failed (screenshots in ${OUT})`);
  process.exit(failures ? 1 : 0);
})();
