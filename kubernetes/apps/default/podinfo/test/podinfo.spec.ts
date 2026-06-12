import { expect, test } from '@playwright/test'

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

test('podinfo: API endpoints are healthy', async ({ request }) => {
  await test.step('step 1: GET /healthz returns 200', async () => {
    log('step 1: GET /healthz returns 200')
    const res = await request.get('/healthz', { timeout: TIMEOUTS.action })
    expect(res.status()).toBe(200)
  })

  await test.step('step 2: GET /api/info reports a version', async () => {
    log('step 2: GET /api/info reports a version')
    const res = await request.get('/api/info', { timeout: TIMEOUTS.action })
    expect(res.ok(), '/api/info should return a 2xx status').toBeTruthy()
    const body = await res.json()
    expect(body.version, 'response should carry a version field').toBeTruthy()
    log('version reported', { version: body.version })
  })
})

// Chaos test — exercises the FAIL/red path in the dashboards. Fails randomly
// (~50% of runs). Remove this test once you've seen the red cells, or gate it
// behind an env if you want to keep it.
test('podinfo: chaos — randomly fails ~50%', async () => {
  await test.step('step 1: roll the dice', async () => {
    const roll = Math.random()
    log('step 1: roll the dice', { roll: Number(roll.toFixed(3)) })
    expect(roll, `roll ${roll.toFixed(3)} must be < 0.5 (chaos)`).toBeLessThan(0.5)
  })
})
