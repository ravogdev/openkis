// Base layer of a map link on a disposable OpenKIS site (never production):
// bs_map.htm opens on the base layer named by ?basemap= or ?baselayer= (the
// section pages use baselayer=, issue #117), and on the first base layer of
// the region's layers file when the link names none or a layer that does not
// exist. For a desktop browser and an emulated Android phone (Pixel 7, touch)
// and for anonymous and each test account of tests/regional/site-checks.sh,
// it checks which base layer is visible and which radio button of the layer
// menu is selected. Tiles are not needed: only the layer state is read.
//
//   BASE=http://localhost:8098 node tests/lombardia/map-baselayer.js
//
// Settings: BASE (required), TEST_PASS [Regional-Test-2026]
const { chromium, devices } = require('playwright');

const BASE = (process.env.BASE || '').replace(/\/$/, '') + '/';
if (BASE === '/') { console.error('BASE must be set'); process.exit(2); }
if (/speleolombardia/i.test(BASE)) { console.error(`refusing to run against production (${BASE})`); process.exit(2); }
const PASS = process.env.TEST_PASS || 'Regional-Test-2026';
const roles = [['anonymous', ''], ['read-only', 'test_ro'], ['read-write', 'test_rw'], ['curator', 'test_cur'], ['admin', 'test_admin']];
const devs = [['desktop', { viewport: { width: 1280, height: 900 } }], ['android', devices['Pixel 7']]];

(async () => {
  const browser = await chromium.launch();
  let fails = 0, runs = 0;
  for (const [dn, dopt] of devs) for (const [role, user] of roles) {
    const ctx = await browser.newContext({ ...dopt });
    // no tile server is needed (and none may be reachable): answer tile requests with nothing
    await ctx.route(/^https?:\/\/(?!localhost|127\.0\.0\.1)/, r => r.abort());
    const page = await ctx.newPage();
    const errs = [];
    page.on('pageerror', e => errs.push(e.message));
    if (user) {
      await page.goto(BASE + 'index.php?mod=login');
      const form = page.locator('form:has([name=username])').first();
      await form.evaluate((f, [u, p]) => { f.querySelector('[name=username]').value = u; f.querySelector('[name=password]').value = p; }, [user, PASS]);
      await Promise.all([page.waitForNavigation(), form.evaluate(f => f.submit())]);
    }
    const state = async (query) => {
      await page.goto(BASE + 'bs_map.htm?mod=caves' + query);
      await page.waitForFunction(() => window.OPS_Map && OPS_Map.baselayers && OPS_Map.baselayers.length && document.querySelector('#ops_baselayerswitcher input[name=layer]'), null, { timeout: 30000 });
      return page.evaluate(() => ({
        names: OPS_Map.baselayers.map(l => l.get('name')),
        visible: OPS_Map.baselayers.filter(l => l.getVisible()).map(l => l.get('name')),
        checked: (document.querySelector('#ops_baselayerswitcher input[name=layer]:checked') || {}).value || null,
      }));
    };
    const out = [];
    const first = (await state('')).names[0];
    const cases = [
      ['no parameter', '', first],
      ['baselayer=Topo', '&baselayer=Topo', 'Topo'],
      ['baselayer=OSM Landscape (%20)', '&baselayer=OSM%20Landscape', 'OSM Landscape'],
      ['baselayer=OSM+Landscape', '&baselayer=OSM+Landscape', 'OSM Landscape'],
      ['basemap=Topo', '&basemap=Topo', 'Topo'],
      ['unknown layer', '&baselayer=No%20such%20layer', first],
    ];
    for (const [label, q, want] of cases) {
      const s = await state(q);
      const ok = s.visible.length === 1 && s.visible[0] === want && s.checked === want;
      if (!ok) fails++;
      out.push(`${label}: ${ok ? 'ok' : `FAIL (visible ${JSON.stringify(s.visible)}, checked ${s.checked}, wanted ${want})`}`);
    }
    if (errs.length) { fails++; out.push('JS errors: ' + errs.join(' | ')); }
    console.log(`${dn} ${role}: ${out.join('; ')}`);
    runs++;
    await ctx.close();
  }
  await browser.close();
  console.log(`map base layer checks: ${runs} device/role runs, ${fails} failed`);
  process.exit(fails ? 1 : 0);
})();
