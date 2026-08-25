import {defineConfig, devices} from '@playwright/test';

const localChannel = process.env.CI ? undefined : 'chrome';
const sitePort = Number.parseInt(process.env.PTO_SITE_PORT ?? '3000', 10);

if (!Number.isInteger(sitePort) || sitePort < 1 || sitePort > 65_535) {
  throw new Error(`PTO_SITE_PORT must be an integer from 1 to 65535; received ${process.env.PTO_SITE_PORT}`);
}

const siteURL = `http://127.0.0.1:${sitePort}`;

const projects = [
  {
    name: 'desktop-chromium',
    use: {
      ...devices['Desktop Chrome'],
      channel: localChannel,
    },
  },
  {
    name: 'tablet-chromium',
    use: {
      ...devices['Desktop Chrome'],
      channel: localChannel,
      viewport: {width: 820, height: 1180},
      hasTouch: true,
    },
  },
  {
    name: 'mobile-chromium',
    use: {
      ...devices['Pixel 7'],
      channel: localChannel,
    },
  },
  ...(process.env.PTO_SITE_CROSS_BROWSER === '1'
    ? [
        {name: 'desktop-firefox', use: {...devices['Desktop Firefox']}},
        {name: 'desktop-webkit', use: {...devices['Desktop Safari']}},
      ]
    : []),
];

export default defineConfig({
  testDir: './tests',
  outputDir: './test-results',
  fullyParallel: true,
  forbidOnly: Boolean(process.env.CI),
  retries: process.env.CI ? 2 : 0,
  reporter: process.env.CI
    ? [['line'], ['html', {open: 'never'}]]
    : 'line',
  use: {
    baseURL: siteURL,
    trace: 'retain-on-failure',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  },
  projects,
  webServer: {
    command: `python3 -m http.server ${sitePort} --bind 127.0.0.1 --directory build`,
    url: siteURL,
    reuseExistingServer: !process.env.CI,
    timeout: 30_000,
  },
});
