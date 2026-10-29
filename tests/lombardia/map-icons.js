// Map icon size check on a disposable OpenKIS site (never production): the
// KML point icons of the caves map grow with the zoom (bs_map/js/OPS_Map.js,
// scaleIconsWithZoom). For a desktop browser and an emulated Android phone
// (Pixel 7, touch) and for anonymous and each test account of
// tests/regional/site-checks.sh (run that first: it creates them), it opens the
// caves map section, hides the base layers (no tile server can change the
// result) and, for zoom 11 to 19:
//   - reads the drawn size of every cave icon in view (icon size x scale): up
//     to zoom 13 it is the KML size; each level above adds 0.3 times that size,
//     up to 3 times and never above 40 px (a bigger KML icon stays as it is);
//   - where the map shows the cave names (layers with names "auto", from zoom
//     17), the name starts beside the icon (the offset follows the bigger icon);
//   - on screenshots with only one cave drawn, its icon is as wide at zoom 15
//     and 18, compared with zoom 12, as its size says;
//   - at zoom 18 clicks the cave (a tap on the phone): its popup opens;
//   - on the map of selected caves (filter_code, the cave sheet map), which
//     shows the names, the name starts beside the icon at every zoom.
// A role that may not get the caves map data (OPENKIS_MAP_ACCESS, #99) has no
// cave layer: that is checked and the role is reported as skipped.
// Screenshots at zoom 12, 15 and 18 and results.json go to $OUT.
//
//   BASE=http://localhost:8098 node tests/lombardia/map-icons.js
//
// Settings: BASE (required), TEST_PASS [Regional-Test-2026], OUT [a temp dir],
// ICON_CAVE: name prefix of the cave to zoom on [the first cave in the layer]
const { chromium, devices } = require('playwright');
const fs = require('fs');
const os = require('os');
const path = require('path');

const BASE = (process.env.BASE || '').replace(/\/$/, '') + '/';
if (BASE === '/') { console.error('BASE must be set'); process.exit(2); }
if (/speleolombardia/i.test(BASE)) { console.error(`refusing to run against production (${BASE})`); process.exit(2); }
const PASS = process.env.TEST_PASS || 'Regional-Test-2026';
const OUT = process.env.OUT || fs.mkdtempSync(path.join(os.tmpdir(), 'openkis-icons-'));
const ICON_CAVE = process.env.ICON_CAVE || '';
fs.mkdirSync(OUT, { recursive: true });

// the rule of OPS_Map.setIconZoomScale, written out again so that the test
// does not read it from the code under test
const ZOOM_MIN = 13, STEP = 0.3, MAX_FACTOR = 3, MAX_PX = 40;
const expectedPx = (basePx, zoom) => {
  const factor = Math.min(1 + Math.max(0, zoom - ZOOM_MIN) * STEP, MAX_FACTOR);
  return Math.min(basePx * factor, Math.max(MAX_PX, basePx));
};
const ZOOMS = [11, 12, 13, 14, 15, 16, 17, 18, 19];
const SHOTS = [12, 15, 18];

const roles = [['anonymous', ''], ['read-only', 'test_ro'], ['read-write', 'test_rw'], ['curator', 'test_cur'], ['admin', 'test_admin']];
const devs = [['desktop', { viewport: { width: 1366, height: 900 } }], ['android', devices['Pixel 7']]];

// in the map frame: the cave layer and its loaded point features
const caveLayerState = () => {
  const layers = (OPS_Map.kmllayers || []).filter(l => /openkis_kml\.php/.test(l.path) && /mod=caves|^openkis_kml\.php\?(?!.*mod=)/.test(l.path));
  const layer = layers.find(l => l.getVisible());
  const n = layer ? layer.getSource().getFeatures().filter(f => f.getGeometry() && f.getGeometry().getType() === 'Point').length : 0;
  return { access: typeof OPENKIS_MAP_ACCESS === 'object' ? OPENKIS_MAP_ACCESS.caves : undefined, layers: layers.length, features: n };
};

(async () => {
  const browser = await chromium.launch();
  const results = [];
  let failures = 0;
  const check = (ok, what) => { if (!ok) { failures++; console.log(`FAIL - ${what}`); } return ok; };
  for (const [dname, dopt] of devs) for (const [role, user] of roles) {
    const where = `${dname} ${role}`;
    const ctx = await browser.newContext({ ...dopt });
    const page = await ctx.newPage();
    page.setDefaultTimeout(60000);
    const jsErrors = [];
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
    const r = { device: dname, role, zooms: {} };
    await page.goto(BASE + 'index.php?mod=map_caves', { waitUntil: 'load' });
    const iframe = page.locator('#iframemap');
    await iframe.scrollIntoViewIfNeeded();
    const frame = await (await iframe.elementHandle()).contentFrame();
    await frame.waitForFunction(() => typeof OPS_Map === 'object' && OPS_Map.map && OPS_Map.kmllayers);
    // the cave layer, once its KML is in (or no layer: the role may not get it)
    let state;
    for (let i = 0; i < 60; i++) {
      state = await frame.evaluate(caveLayerState);
      if (state.features > 0 || (state.layers === 0 && i > 4)) break;
      await page.waitForTimeout(500);
    }
    r.access = state.access;
    if (state.layers === 0) {
      check(state.access === '', `${where}: no cave layer, but the map access says "${state.access}"`);
      r.skipped = 'no cave layer for this role';
      console.log(`ok - ${where}: no cave layer (map access "${state.access}"), skipped`);
      results.push(r);
      await ctx.close();
      continue;
    }
    if (!check(state.features > 0, `${where}: the cave layer has no points`)) { results.push(r); await ctx.close(); continue; }

    // no base layers, no tile servers; the cave to zoom on
    const hideBaseLayers = (fr) => fr.evaluate(() => {
      const hide = (layers) => layers.forEach(l => {
        if (l instanceof ol.layer.Group) hide(l.getLayers().getArray());
        else if (!(l.getSource() instanceof ol.source.Vector)) l.setVisible(false);
      });
      hide(OPS_Map.map.getLayers().getArray());
    });
    await hideBaseLayers(frame);
    const target = await frame.evaluate((prefix) => {
      const layer = OPS_Map.kmllayers.find(l => /openkis_kml\.php/.test(l.path) && l.getVisible());
      const points = layer.getSource().getFeatures().filter(f => f.getGeometry() && f.getGeometry().getType() === 'Point');
      const f = points.find(p => prefix && String(p.get('name') || '').indexOf(prefix) !== -1) || points[0];
      return { name: f.get('name'), coordinate: f.getGeometry().getCoordinates() };
    }, ICON_CAVE);
    r.cave = target.name;

    // drawn icon size of the caves in view at the current zoom
    const measure = (fr = frame) => fr.evaluate((coord) => {
      const map = OPS_Map.map, view = map.getView();
      const res = view.getResolution(), extent = view.calculateExtent(map.getSize());
      const layer = OPS_Map.kmllayers.find(l => /openkis_kml\.php/.test(l.path) && l.getVisible());
      const out = { zoom: view.getZoom(), icons: {}, target: null };
      layer.getSource().forEachFeatureInExtent(extent, f => {
        const g = f.getGeometry();
        if (!g || g.getType() !== 'Point') return;
        const fn = f.getStyleFunction();
        if (!fn) return;
        let styles = fn(f, res);
        styles = Array.isArray(styles) ? styles : [styles];
        const st = styles.find(s => s && s.getImage() instanceof ol.style.Icon);
        if (!st) return;
        const img = st.getImage(), size = img.getSize(), scale = img.getScale();
        if (!size || typeof scale !== 'number') return; // image not loaded yet
        const text = styles.map(s => s.getText()).find(t => t && t.getText());
        const c = g.getCoordinates();
        const v = { px: Math.max(size[0], size[1]) * scale, label: text ? text.getOffsetX() : null };
        const key = f.get('name') + '|' + c.join(',');
        out.icons[key] = v;
        if (c[0] === coord[0] && c[1] === coord[1]) { out.target = v; out.targetKey = key; }
      });
      // in the frame: the map sits below the toolbar
      const p = map.getPixelFromCoordinate(coord), r = map.getTargetElement().getBoundingClientRect();
      out.pixel = p ? [r.left + p[0], r.top + p[1]] : null;
      return out;
    }, target.coordinate);
    // zoom on the cave and wait for the drawing (from zoom 17 the layer is
    // loaded again with the names)
    const zoomTo = async (z, fr = frame) => {
      await fr.evaluate(([z, coord]) => new Promise(resolve => {
        const map = OPS_Map.map;
        map.once('rendercomplete', () => resolve());
        map.getView().setCenter(coord);
        map.getView().setZoom(z);
      }), [z, target.coordinate]);
      for (let i = 0; i < 40; i++) {
        const m = await measure(fr);
        if (m.target) return m;
        await page.waitForTimeout(250);
      }
      return measure(fr);
    };

    // the drawn width of the cave's icon on a screenshot, in CSS pixels: the
    // other caves are hidden for it, and the map background without base
    // layers is plain
    const iconWidth = async (m) => {
      await frame.evaluate((coord) => new Promise(resolve => {
        const layer = OPS_Map.kmllayers.find(l => /openkis_kml\.php/.test(l.path) && l.getVisible());
        OPS_Map.testHidden = [];
        layer.getSource().getFeatures().forEach(f => {
          const c = f.getGeometry() && f.getGeometry().getCoordinates();
          if (c && c[0] === coord[0] && c[1] === coord[1]) return;
          OPS_Map.testHidden.push([f, f.getStyle()]);
          f.setStyle(new ol.style.Style({}));
        });
        OPS_Map.map.once('rendercomplete', () => resolve());
        OPS_Map.map.render();
      }), target.coordinate);
      // the clip is in page coordinates, the box in viewport coordinates
      const box = await iframe.boundingBox();
      const scroll = await page.evaluate(() => [window.scrollX, window.scrollY]);
      const half = 45;
      const clip = { x: scroll[0] + box.x + m.pixel[0] - half, y: scroll[1] + box.y + m.pixel[1] - half, width: 2 * half, height: 2 * half };
      const png = await page.screenshot({ clip });
      await frame.evaluate(() => new Promise(resolve => {
        OPS_Map.testHidden.forEach(([f, st]) => f.setStyle(st));
        OPS_Map.map.once('rendercomplete', () => resolve());
        OPS_Map.map.render();
      }));
      return page.evaluate(([b64, cssWidth]) => new Promise(resolve => {
        const im = new Image();
        im.onload = () => {
          const c = document.createElement('canvas'); c.width = im.width; c.height = im.height;
          const g = c.getContext('2d'); g.drawImage(im, 0, 0);
          const d = g.getImageData(0, 0, c.width, c.height).data;
          // the background is the colour of the corners
          const bg = [d[0], d[1], d[2]];
          let x0 = c.width, x1 = -1;
          for (let y = 0; y < c.height; y++) for (let x = 0; x < c.width; x++) {
            const i = (y * c.width + x) * 4;
            if (Math.abs(d[i] - bg[0]) + Math.abs(d[i + 1] - bg[1]) + Math.abs(d[i + 2] - bg[2]) > 60) { x0 = Math.min(x0, x); x1 = Math.max(x1, x); }
          }
          resolve(x1 < 0 ? 0 : (x1 - x0 + 1) * cssWidth / c.width);
        };
        im.src = 'data:image/png;base64,' + b64;
      }), [png.toString('base64'), clip.width]);
    };

    let base = null;
    const pixels = {}, drawnPx = {};
    for (const z of ZOOMS) {
      const m = await zoomTo(z);
      if (!check(m.target, `${where}: zoom ${z}: the cave "${target.name}" is not drawn`)) continue;
      if (base === null) base = m.icons;
      let checked = 0, wrong = [];
      for (const [key, v] of Object.entries(m.icons)) {
        if (!base[key]) continue;
        checked++;
        const want = expectedPx(base[key].px, z);
        if (Math.abs(v.px - want) > 0.5) wrong.push(`${v.px.toFixed(1)} px instead of ${want.toFixed(1)}`);
        // a name shown on the map (layers with names "auto", from zoom 17)
        // starts beside the icon, not on it
        if (v.label !== null && v.label < v.px / 2 - 1) wrong.push(`label at ${v.label.toFixed(1)} px, icon half width ${(v.px / 2).toFixed(1)}`);
      }
      const t = m.target, tw = base[m.targetKey];
      r.zooms[z] = { icons: checked, targetPx: +t.px.toFixed(2), expectedPx: tw ? +expectedPx(tw.px, z).toFixed(2) : null, label: t.label, wrong: wrong.length };
      check(checked > 0, `${where}: zoom ${z}: no icon to compare with zoom 11`);
      check(wrong.length === 0, `${where}: zoom ${z}: ${wrong.length} of ${checked} icons have the wrong size or label (${wrong.slice(0, 3).join('; ')})`);
      if (SHOTS.includes(z)) {
        pixels[z] = +(await iconWidth(m)).toFixed(1);
        drawnPx[z] = m.target.px;
        await iframe.screenshot({ path: path.join(OUT, `${dname}-${role}-z${z}.png`) });
      }
      if (z === 18) {
        // the cave's popup opens with a click (a tap on the phone) on the icon
        const box = await iframe.boundingBox();
        const x = box.x + m.pixel[0], y = box.y + m.pixel[1];
        if (dname === 'android') await page.touchscreen.tap(x, y); else await page.mouse.click(x, y);
        const popup = frame.locator('.popover').first();
        let opened = false;
        try { await popup.waitFor({ state: 'visible', timeout: 5000 }); opened = true; } catch (e) { /* not opened */ }
        const title = opened ? (await popup.locator('.popover-title, .popover-header').first().innerText().catch(() => '')) : '';
        const name = await frame.evaluate((n) => OPS_Map.decodeEntities ? OPS_Map.decodeEntities(n) : n, target.name);
        r.popup = { opened, title: title.trim() };
        check(opened && title.indexOf(String(name).trim()) !== -1, `${where}: zoom 18: ${dname === 'android' ? 'tap' : 'click'} on the cave: popup ${opened ? `"${title.trim()}"` : 'not opened'}`);
        await iframe.screenshot({ path: path.join(OUT, `${dname}-${role}-z18-popup.png`) });
        await frame.evaluate(() => OPS_Map.popUpClose && OPS_Map.popUpClose());
      }
    }
    // the map of selected caves (cave sheet, "map" links) shows the names:
    // the name starts beside the bigger icon
    const code = String(target.name).split('-')[0];
    await page.goto(BASE + `bs_map.htm?mod=caves&filter_code=${encodeURIComponent(code)}`, { waitUntil: 'load' });
    const sel = page.mainFrame();
    await sel.waitForFunction(() => typeof OPS_Map === 'object' && OPS_Map.kmllayers &&
      OPS_Map.kmllayers.some(l => l.getVisible() && l.getSource().getFeatures().length > 0), null, { timeout: 60000 });
    await hideBaseLayers(sel);
    r.labels = {};
    for (const z of [13, 16, 19]) {
      const m = await zoomTo(z, sel);
      if (!check(m.target, `${where}: selected caves map, zoom ${z}: the cave is not drawn`)) continue;
      r.labels[z] = { px: +m.target.px.toFixed(2), label: m.target.label };
      check(m.target.label !== null && m.target.label >= m.target.px / 2 - 1,
        `${where}: selected caves map, zoom ${z}: name at ${m.target.label} px for a ${m.target.px.toFixed(1)} px icon`);
      if (z === 19) await page.screenshot({ path: path.join(OUT, `${dname}-${role}-selected-z19.png`) });
    }
    r.pixels = pixels;
    // on the screen the icon grows as much as its size says (within 15%)
    for (const z of SHOTS.filter(k => k !== 12)) {
      const want = pixels[12] * drawnPx[z] / drawnPx[12];
      check(pixels[12] > 0 && Math.abs(pixels[z] - want) <= want * 0.15,
        `${where}: icon width on the screen: ${pixels[12]} px at zoom 12, ${pixels[z]} px at zoom ${z} (expected about ${want.toFixed(1)})`);
    }
    r.jsErrors = jsErrors.slice();
    check(jsErrors.length === 0, `${where}: JavaScript errors: ${jsErrors.join(' | ')}`);
    const z = r.zooms;
    console.log(`${where}: ${Object.values(z).reduce((a, v) => a + v.icons, 0)} icon checks; cave icon ${[11, 14, 16, 18, 19].map(k => z[k] ? z[k].targetPx : '?').join(' / ')} px at zoom 11/14/16/18/19; on screen ${pixels[12]} / ${pixels[15]} / ${pixels[18]} px at zoom 12/15/18; names ${Object.values(r.labels).every(l => l.label !== null) ? 'beside the icon' : 'MISSING'}; popup ${r.popup && r.popup.opened ? 'opened' : 'NOT opened'}`);
    results.push(r);
    await ctx.close();
  }
  await browser.close();
  fs.writeFileSync(path.join(OUT, 'results.json'), JSON.stringify(results, null, 1));
  console.log(`map icon checks: ${results.length} device/role runs, ${failures} failed (screenshots in ${OUT})`);
  process.exit(failures ? 1 : 0);
})();
