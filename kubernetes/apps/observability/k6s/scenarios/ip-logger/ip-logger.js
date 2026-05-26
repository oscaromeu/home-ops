import { check } from 'k6';
import http from 'k6/http';
import { Gauge } from 'k6/metrics';

const ip_check = new Gauge('ip_check');
const expected_ip = __ENV.EXPECTED_IP;

export default function () {
  const res = http.get(`https://${__ENV.MY_HOSTNAME}`);

  check(res, {
    'status is 200': (r) => r.status === 200,
  });

  const body = JSON.parse(res.body);
  const ip = body.ip_addr;

  ip_check.add(1, { ip_addr: ip });
  console.log(`IP: ${ip}`);

  if (expected_ip && ip !== expected_ip) {
    console.log(JSON.stringify({
      event: 'ip_change',
      expected: expected_ip,
      actual: ip,
      message: `Home IP changed from ${expected_ip} to ${ip}`,
    }));
  }
}
