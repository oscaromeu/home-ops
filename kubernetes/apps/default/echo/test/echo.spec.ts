import { expect, test } from '@probe/playwright'

// Per-step JSON line, same shape as the runner's reporter.
const log = (message: string, extra: Record<string, unknown> = {}): void => {
  console.log(JSON.stringify({ level: 'info', message, ts: new Date().toISOString(), ...extra }))
}

const TIMEOUTS = {
  navigation: 30_000,
  action: 15_000,
} as const

// echo (mendhak/http-https-echo) is public & unauthenticated — it reflects the
// request back as JSON. Target comes from PW_BASE_URL (https://echo.<domain>).
test('echo: web endpoint is served', async ({ page }) => {
  await test.step('step 1: load the root', async () => {
    log('step 1: load the root', { url: process.env.PW_BASE_URL ?? '' })
    const resp = await page.goto('/', { waitUntil: 'load', timeout: TIMEOUTS.navigation })
    expect(resp?.ok(), 'root should return a 2xx status').toBeTruthy()
  })

  await test.step('step 2: response echoes JSON with the request path', async () => {
    log('step 2: response echoes JSON with the request path')
    const body = await page.locator('body').innerText()
    const json = JSON.parse(body)
    expect(json.path, 'echo JSON should carry a path field').toBeTruthy()
  })
})

// Uses context.request (not the standalone `request` fixture) so the call flows
// through the HAR-recorded browser context → lands in e2e.net_timing.
test('echo: reflects a custom header', async ({ context }) => {
  await test.step('step 1: GET / echoes a sent header', async () => {
    log('step 1: GET / echoes a sent header')
    const res = await context.request.get('/', { headers: { 'x-probe': 'e2e' }, timeout: TIMEOUTS.action })
    expect(res.status()).toBe(200)
    const body = await res.json()
    // mendhak/http-https-echo lowercases header names under `headers`.
    expect(body.headers?.['x-probe'], 'sent header should be echoed back').toBe('e2e')
  })
})
