import {defineConfig, devices} from '@playwright/test';

const localChannel = process.env.CI ? undefined : 'chrome';

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
    baseURL: 'http://127.0.0.1:3000',
    trace: 'retain-on-failure',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  },
  projects,
  webServer: {
    command: 'pnpm serve --port 3000 --no-open',
    url: 'http://127.0.0.1:3000',
    reuseExistingServer: !process.env.CI,
    timeout: 120_000,
  },
});
