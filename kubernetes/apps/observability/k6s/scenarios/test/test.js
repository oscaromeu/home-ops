import { check } from 'k6';
import http from 'k6/http';
import { Gauge } from 'k6/metrics';

const ip_check = new Gauge('ip_check');

export default function () {
  const res = http.get('https://ifconfig.me/all.json');

  check(res, {
    'status is 200': (r) => r.status === 200,
  });

  const body = JSON.parse(res.body);
  const ip = body.ip_addr;

  // Add numeric value with IP as tag
  ip_check.add(1, { ip_addr: ip });

  console.log(`IP: ${ip}`);
}
