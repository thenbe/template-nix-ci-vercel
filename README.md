# template-nix-ci-vercel

This template showcases how to take advantage of nix to smooth out some rough edges when working with CI (Github Actions) and deploying to a cloud provider (Vercel).

## Features

- ☮️ Simplifies your CI workflow using nix. ([example](./.github/workflows/ci.yml))
- 😩 Avoids the dreaded slow feedback loop of debugging CI.
- 🤹 Avoids having to tiptoe around three different environments (your local dev environment, Github Actions runner, Vercel's build environment) by using a single, locally reproducible one.
- ♻️ Auto deploys to vercel on push/PR and comments with the URL to the preview deployment using [`vercel-action`](https://github.com/amondnet/vercel-action).

## Why

### The problem

To illustrate the issue, let's assume we have a web app that we want to:

1. Build and test in CI
1. Deploy from CI

#### Step 1 (build and test in CI)

For our web app, `playwright` makes step 1 tricky in CI since it uses real browsers for testing. This does make it a powerful tool for testing, however that comes at the cost of some increased setup complexity as the browsers need to be downloaded before tests can run. This can get hairy in CI.

**Configuration**: For example, it's not clear to how to best setup playwright when working with pnpm. Specifically, should we use the `npx playwright install` with the `--with-deps` flag as instructed by playwright's [docs](https://playwright.dev/docs/ci#github-actions)? Or should we [set](https://github.com/sveltejs/kit/blob/a7f8bdcfabce5cda85dd073a21d0afb6138a7a08/.github/workflows/ci.yml#L10C1-L11C40) `PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1` and then run `playwright install` (without the flag) to download the browsers? What about caching? Do we need a [manual](https://github.com/vitejs/vite/blob/227d56d37fbfcd1af4b5d93182770b4e650511ee/.github/workflows/ci.yml#L85-L111) workaround for that?

Figuring out the answers to all of those questions is hard enough. Having that magnified by the slow feedback loop of CI is just painful. Even if we're currently familiar with playwright and have figured out the current best approach, we will still need to debug future issues against the same frustratingly slow feedback loop. Essentially, the issue is that we are dealing with an environment that will always be different than our local environment.

#### Step 2 (deploy from CI)

Admittedly, for simple projects, the best approach to deploy to vercel is to use vercel's pipeline. It requires zero configuration, does what we expect, and stays out of the way -- until it doesn't.

As a rule of thumb, I know I've reached this stage when I need to make changes to my project just to make the build exit successfully in vercel's build environment. For example, assume our app uses a codegen tool that is incompatible with vercel's build environment. Should we concede and begin committing the generated code into git? That would "fix" the immediate issue but would leave us with an entirely different set of problems.

### The solution

The nix approach used in this template addresses the previous concerns by making all environments identical. Instead of dealing with three different environments (local, Github Actions runner, Vercel build environment), we now get to work with a single environment that:

1. Can be debugged locally
1. Has immediate access to some 80,000 packages (Nixpkgs is the [current](https://repology.org/repositories/graphs) largest and most up to date package repository in the world)

**If it works on your machine, it will work in CI.**

## Usage

### Requirements

- [nix](https://github.com/DeterminateSystems/nix-installer)
- [direnv](https://github.com/nix-community/nix-direnv)
- The required Github Action secrets can be found in [deploy.yml](./.github/workflows/deploy.yml).
