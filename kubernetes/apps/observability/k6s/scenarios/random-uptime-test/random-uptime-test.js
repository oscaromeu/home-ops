import http from 'k6/http';
import { check } from 'k6';
import { Gauge } from 'k6/metrics';

const uptime_check = new Gauge('uptime_check');

export const options = {
  iterations: 1,
};

export default function () {
  let uptime = 0; // default = down

  // Randomly decide to pass or fail (50% chance each)
  const shouldPass = Math.random() < 0.5;

  console.log(`Random test: ${shouldPass ? 'PASS (1)' : 'FAIL (0)'}`);

  if (shouldPass) {
    uptime = 1;
  }

  uptime_check.add(uptime);
}
