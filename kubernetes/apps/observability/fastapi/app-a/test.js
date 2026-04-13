import http from "k6/http";
import { check, sleep } from "k6";

// Test configuration
export const options = {
  thresholds: {
    // Assert that 99% of requests finish within 3000ms.
    http_req_duration: ["p(99) < 30000"],
  },
  // Ramp the number of virtual users up and down
  stages: [
    { duration: "30s", target: 15 },
    { duration: "1m", target: 15 },
    { duration: "20s", target: 0 },
  ],
};

export default function () {

  let res1 = http.get("http://app-a.observability.svc.cluster.local:8000");
  check(res1, { "status was 200": (r) => r.status == 200 });

  let res2 = http.get("http://app-a.observability.svc.cluster.local:8000/io_task");
  check(res2, { "status was 200": (r) => r.status == 200 });

  let res3 = http.get("http://app-a.observability.svc.cluster.local:8000/cpu_task");
  check(res3, { "status was 200": (r) => r.status == 200 });

  //let res4 = http.get("http://app-a.observability.svc.cluster.local:8000/random_sleep");
  //check(res4, { "status was 200": (r) => r.status == 200 });

  let res5 = http.get("http://app-a.observability.svc.cluster.local:8000/random_status");
  check(res5, { "status was 200": (r) => r.status == 200 });

  let res6 = http.get("http://app-a.observability.svc.cluster.local:8000/chain");
  check(res6, { "status was 200": (r) => r.status == 200 });

  let res7 = http.get("http://app-a.observability.svc.cluster.local:8000/error_test");
  check(res7, { "status was 200": (r) => r.status == 200 });

}
