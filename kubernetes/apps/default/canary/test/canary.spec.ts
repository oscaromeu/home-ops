import { expect, test } from '@probe/playwright'

const log = (message: string, extra: Record<string, unknown> = {}): void => {
  console.log(JSON.stringify({ level: 'info', message, ts: new Date().toISOString(), ...extra }))
}

// Deterministic canary: hits podinfo's /status/<code> echo endpoint. The code
// comes from the UNMANAGED `canary-knob` ConfigMap, so failures happen exactly
// when — and for as long as — you decide:
//   kubectl -n default patch cm canary-knob --type merge -p '{"data":{"status":"500"}}'
const status = process.env.CANARY_STATUS?.trim() || '200'

test('canary: controlled endpoint returns 2xx', async ({ page }) => {
  await test.step(`step 1: GET /status/${status}`, async () => {
    log(`step 1: GET /status/${status}`, { url: process.env.PW_BASE_URL ?? '' })
    const resp = await page.goto(`/status/${status}`, { waitUntil: 'load', timeout: 30_000 })
    expect(resp?.ok(), `expected 2xx from /status/${status}`).toBeTruthy()
  })
})
