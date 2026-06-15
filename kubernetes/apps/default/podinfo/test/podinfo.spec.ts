import { expect, test } from '@probe/playwright'

// Per-step JSON line, same shape as the runner's reporter (and the Flanks
// helpers/login `log`). When the shared @probe/playwright module lands, this is
// imported instead of inlined.
const log = (message: string, extra: Record<string, unknown> = {}): void => {
  console.log(JSON.stringify({ level: 'info', message, ts: new Date().toISOString(), ...extra }))
}

const TIMEOUTS = {
  navigation: 30_000,
  heading: 15_000,
  action: 15_000,
} as const

// podinfo is a public, unauthenticated service — no login/beforeAll guard. The
// target comes from PW_BASE_URL (https://podinfo.<domain>).
test('podinfo: web UI is served', async ({ page }) => {
  await test.step('step 1: load the home page', async () => {
    log('step 1: load the home page', { url: process.env.PW_BASE_URL ?? '' })
    const resp = await page.goto('/', { waitUntil: 'load', timeout: TIMEOUTS.navigation })
    expect(resp?.ok(), 'home page should return a 2xx status').toBeTruthy()
  })

  await test.step('step 2: the page renders content', async () => {
    log('step 2: the page renders content')
    const body = await page.locator('body').innerText()
    expect(body.trim().length, 'body should not be blank').toBeGreaterThan(0)
  })
})

// Uses context.request (not the standalone `request` fixture) so these API
// calls flow through the browser context that records the HAR — they then land
// in e2e.net_timing with a dns/tcp/tls/server/transfer breakdown instead of
// showing 0 ms. A standalone APIRequestContext is not HAR-recorded.
test('podinfo: API endpoints are healthy', async ({ context }) => {
  await test.step('step 1: GET /healthz returns 200', async () => {
    log('step 1: GET /healthz returns 200')
    const res = await context.request.get('/healthz', { timeout: TIMEOUTS.action })
    expect(res.status()).toBe(200)
  })

  await test.step('step 2: GET /api/info reports a version', async () => {
    log('step 2: GET /api/info reports a version')
    const res = await context.request.get('/api/info', { timeout: TIMEOUTS.action })
    expect(res.ok(), '/api/info should return a 2xx status').toBeTruthy()
    const body = await res.json()
    expect(body.version, 'response should carry a version field').toBeTruthy()
    log('version reported', { version: body.version })
  })
})

// Chaos generator — exercises the full dashboard palette so every color/tier is
// validated: ~15% fail (red), ~40% slow-but-pass (HIGH/CRITICAL/FATAL runtime
// tiers = yellow/orange/dark-red + SLA bands), rest fast pass (green). Remove
// this test for a real probe.
test('podinfo: chaos — pass / slow / fail', async ({ page }) => {
  const roll = Math.random()
  const willFail = roll < 0.15
  const slowMs = !willFail && roll < 0.55 ? 1500 + Math.floor(Math.random() * 8000) : 0
  log('chaos roll', { roll: Number(roll.toFixed(2)), will_fail: willFail, slow_ms: slowMs })

  await test.step('step 1: warm up (always ok)', async () => {
    expect(1 + 1).toBe(2)
  })

  await test.step('step 2: variable latency', async () => {
    log('step 2: variable latency', { slow_ms: slowMs })
    if (slowMs) await page.waitForTimeout(slowMs)
    expect(true).toBe(true)
  })

  await test.step('step 3: random assertion', async () => {
    log('step 3: random assertion', { will_fail: willFail })
    expect(willFail, 'chaos: this step fails ~15% of runs').toBe(false)
  })
})
