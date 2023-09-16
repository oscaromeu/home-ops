import http from "k6/http";
import { check, sleep } from "k6";

// Test configuration
export const options = {
  thresholds: {
    // Assert that 99% of requests finish within 3000ms.
    http_req_duration: ["p(99) < 3000"],
  },
  // Ramp the number of virtual users up and down
  stages: [
    { duration: "30s", target: 15 },
    { duration: "1m", target: 15 },
    { duration: "20s", target: 0 },
  ],
};

export default function () {
  // First HTTP request
  let res1 = http.get("http://google.com");
  check(res1, { "status was 200": (r) => r.status == 200 });

  // Second HTTP request
  let res2 = http.get("http://google.com");
  check(res2, { "status was 200": (r) => r.status == 200 });

  // Second HTTP request
  let res3 = http.get("http://google.com");
  check(res3, { "status was 200": (r) => r.status == 200 });

  // Second HTTP request
  let res4 = http.get("http://google.com");
  check(res4, { "status was 200": (r) => r.status == 200 });

  // Second HTTP request
  let res5 = http.get("http://google.com");
  check(res5, { "status was 200": (r) => r.status == 200 });

  // Second HTTP request
  let res6 = http.get("http://google.com");
  check(res6, { "status was 200": (r) => r.status == 200 });

  // Second HTTP request
  let res7 = http.get("http://google.com");
  check(res7, { "status was 200": (r) => r.status == 200 });

  // Second HTTP request
  let res8 = http.get("http://google.com");
  check(res8, { "status was 200": (r) => r.status == 200 });

  sleep(1);
}
