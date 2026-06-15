import { expect, test } from '@probe/playwright'

// Per-step JSON line, same shape as the runner's reporter.
const log = (message: string, extra: Record<string, unknown> = {}): void => {
  console.log(JSON.stringify({ level: 'info', message, ts: new Date().toISOString(), ...extra }))
}

const TIMEOUTS = {
  navigation: 30_000,
  heading: 15_000,
  action: 15_000,
} as const

// filebrowser runs with FB_NOAUTH=true — no login. Target from PW_BASE_URL
// (https://fb.<domain>). Selectors are best-effort for the Vue SPA; verify
// against the live app after the first run if step 2 fails.
test('filebrowser: web UI is served', async ({ page }) => {
  await test.step('step 1: load the file manager', async () => {
    log('step 1: load the file manager', { url: process.env.PW_BASE_URL ?? '' })
    const resp = await page.goto('/', { waitUntil: 'load', timeout: TIMEOUTS.navigation })
    expect(resp?.ok(), 'UI should return a 2xx status').toBeTruthy()
  })

  await test.step('step 2: the app shell renders', async () => {
    log('step 2: the app shell renders')
    // Filebrowser is a Vue SPA mounted into #app.
    await expect(page.locator('#app')).toBeVisible({ timeout: TIMEOUTS.heading })
    const body = await page.locator('body').innerText()
    expect(body.trim().length, 'body should not be blank').toBeGreaterThan(0)
  })
})

// Uses context.request so the call flows through the HAR-recorded browser
// context → lands in e2e.net_timing.
test('filebrowser: health endpoint is healthy', async ({ context }) => {
  await test.step('step 1: GET /health returns 200', async () => {
    log('step 1: GET /health returns 200')
    const res = await context.request.get('/health', { timeout: TIMEOUTS.action })
    expect(res.status()).toBe(200)
  })
})
