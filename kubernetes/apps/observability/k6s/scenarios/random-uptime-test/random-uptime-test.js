import { Gauge, Trend } from 'k6/metrics';

// Gauges para timestamps
const last_success = new Gauge('uptime_check_last_success_timestamp_seconds');
const last_failure = new Gauge('uptime_check_last_failure_timestamp_seconds');

// Trend acumulativo para contar ejecuciones
const runs_total = new Trend('uptime_check_runs_total', true); // cumulative=true

export const options = {
  vus: 1,
  iterations: 1, // job efímero de 1 iteración
};

export default function () {
  const now = Math.floor(Date.now() / 1000);

  // Eliminamos la aleatoriedad: el job siempre pasa
  const shouldPass = true;

  // Incrementar el contador acumulativo por resultado
  runs_total.add(1, { result: shouldPass ? 'success' : 'failure' });

  // Actualizar timestamps
  if (shouldPass) {
    last_success.add(now);
  } else {
    last_failure.add(now);
  }

  console.log(`Check result: ${shouldPass ? 'SUCCESS' : 'FAILURE'}, timestamp: ${now}`);
}
