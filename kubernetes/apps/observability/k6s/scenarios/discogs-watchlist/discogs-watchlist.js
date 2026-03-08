import http from 'k6/http';
import { check } from 'k6';
import { Gauge } from 'k6/metrics';
import { sleep } from 'k6';

const discogs_for_sale = new Gauge('discogs_for_sale');
const discogs_lowest_price_usd = new Gauge('discogs_lowest_price_usd');

const TOKEN = __ENV.DISCOGS_TOKEN || '';
const releases = JSON.parse(__ENV.RELEASES_CONFIG || '[]');
const CH_URL = __ENV.CLICKHOUSE_URL || 'http://clickhouse-clickhouse-headless.databases.svc.cluster.local:8123';
const CH_USER = __ENV.CLICKHOUSE_USER || 'default';
const CH_PASSWORD = __ENV.CLICKHOUSE_PASSWORD || '';

export const options = {
  vus: 1,
  iterations: 1,
};

function log(level, message, extra = {}) {
  console.log(JSON.stringify({ level, message, ...extra }));
}

function insertClickHouse(release_id, title, num_for_sale, lowest_price) {
  const query = `INSERT INTO discogs.watchlist (release_id, title, num_for_sale, lowest_price) FORMAT JSONEachRow`;
  const row = JSON.stringify({ release_id, title, num_for_sale, lowest_price });

  const params = {
    headers: {
      'X-ClickHouse-User': CH_USER,
      ...(CH_PASSWORD && { 'X-ClickHouse-Key': CH_PASSWORD }),
    },
  };

  try {
    const res = http.post(`${CH_URL}/?query=${encodeURIComponent(query)}`, row, params);
    if (res.status !== 200) {
      log('warn', 'ClickHouse insert failed', { status: res.status, body: res.body });
    } else {
      log('info', 'ClickHouse insert ok', { release_id });
    }
  } catch (e) {
    log('warn', 'ClickHouse unreachable', { error: e.message });
  }
}

export default function () {
  for (const release of releases) {
    const url = `https://api.discogs.com/marketplace/stats/${release.id}`;
    const params = {
      headers: {
        'User-Agent': 'HomeOpsWatchlist/1.0',
        ...(TOKEN && { Authorization: `Discogs token=${TOKEN}` }),
      },
    };

    const res = http.get(url, params);

    const ok = check(res, {
      'status is 200': (r) => r.status === 200,
    });

    if (!ok) {
      log('error', 'Failed to fetch marketplace stats', {
        release_id: release.id,
        status: res.status,
      });
      sleep(2);
      continue;
    }

    let body;
    try {
      body = res.json();
    } catch (e) {
      log('error', 'Failed to parse response', { release_id: release.id, error: e.message });
      sleep(2);
      continue;
    }

    const labels = { release_id: release.id, title: release.title };
    const numForSale = body.num_for_sale || 0;
    const lowestPrice = body.lowest_price ? body.lowest_price.value : 0;

    discogs_for_sale.add(numForSale, labels);
    discogs_lowest_price_usd.add(lowestPrice, labels);

    log('info', 'Marketplace stats', {
      ...labels,
      num_for_sale: numForSale,
      lowest_price: lowestPrice,
    });

    insertClickHouse(release.id, release.title, numForSale, lowestPrice);

    sleep(2);
  }
}
