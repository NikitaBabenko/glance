# Glance on VibeNest — acceptance candidate

[![Deploy to VibeNest](https://vibenest.net/deploy-to-vibenest.svg)](https://vibenest.net/deploy?repo=https%3A%2F%2Fgithub.com%2FNikitaBabenko%2Fglance&branch=vibenest)

This fork is being tested. Free-tier compatibility and the complete button-to-login-to-deploy flow have **not yet been verified**. It is not a published VibeNest catalog template. There is no verified demo yet.

Glance combines RSS feeds and bookmarks into a personal dashboard. Unlike a shared public dashboard, this configuration requires your own password. Compared with Dashy, this example focuses on reading feeds alongside a small set of personal links. It does not provide a browser-based YAML editor.

## Guided setup

1. The Deploy button opens a repository preview. **Continuing from that preview through sign-in/sign-up can automatically request a deployment.** This candidate needs manual setup first; the complete button flow remains unverified. For guided setup, open the Dashboard directly and create a **Draft** with the repository field empty, or use your existing draft. Creating a project with a repository can enqueue preparation. Do not use preview **Continue**, the automatic launch page, or **Deploy Now** before secrets and persistent storage are ready.
2. Before launching, add the two required secrets in the project's **Environment** settings: `GLANCE_SECRET_KEY` (64 cryptographically random bytes encoded as base64) and `GLANCE_PASSWORD_HASH` (bcrypt hash, cost 10–14). Use a unique password. The login username is `owner`. The helper below reads a password through a hidden prompt; never put passwords in command arguments, a URL, or Git.
3. Set optional `GLANCE_RSS_URL` to a public HTTPS RSS/Atom feed and `GLANCE_BOOKMARK_URL` to your own HTTPS bookmark. Omitted values use Hacker News RSS and the Glance upstream repository. URLs must be single-line and contain no quotes or spaces. Credentials and private feed tokens do not belong in these example URLs.
4. In the draft's **Settings → Deployment**, set **Git Repository URL** to `https://github.com/NikitaBabenko/glance`. Under **Show Advanced Settings**, set **Branch** to `vibenest`, **Internal Port** to **8080**, and **Build Pack** to **Dockerfile**; keep the repository root as the build context and the root `Dockerfile`. Use **Save Configuration** to save without requesting deployment. In **Storage**, the required mount is **`/app/data`**. **Attaching a volume saves its path and requests a deployment; attaching hardware from the Dashboard can also request a deployment.** Treat these as launch actions, after configuring secrets and selecting the intended source. Ensure the volume path is saved before the first successful launch. `/app/data/pages.yml` and `/app/data/assets` are persistent; never mount the public assets directory over the entire data directory.
5. During this pilot, hardware, storage and every deployment request are restricted to the coordinator-assigned test window. Attach the `/app/data` volume through the normal Storage controls and inspect the resulting gated request. If hardware is still required, attach the assigned eligible inventory and inspect that request too. Do not submit a duplicate launch if one is already active. If the project remains idle after setup, explicitly use **Deploy Now** in **Settings → Deployment**. Free support remains unverified until the real 256 MiB / 0.5 CPU / 4 GiB test passes; build memory is a separate requirement.
6. Open the application and confirm it asks for a login before displaying the dashboard. Sign in as `owner`, inspect the feed and bookmark, then change an optional URL in Environment and perform a normal redeploy. Confirm the changed feed/link remains after another redeploy.

### Create secrets locally

With Python and the `bcrypt` package available, run:

```text
python vibenest/create-secrets.py /absolute/private/path/glance.env
```

The helper refuses to write within this repository or overwrite a file. Store the output in a private folder accessible only to you. Import the file's values into VibeNest Environment, then remove the local copy when no longer needed. Do not upload it as an application asset, print it in reports, or commit it.

### Configuration and persistence

The first launch copies the example pages into `/app/data/pages.yml` only if that file does not exist. Later image updates preserve it. Change the two Environment URLs for the basic guided customization; VibeNest retains the encrypted Environment values across redeploys. Advanced users can edit the persistent YAML using an authorized file-management route, if available. Editing the fork's example alone does **not** replace an already-seeded volume. Do not delete a volume to force an update. Back up and inspect existing configuration before reusing storage from another installation.

Authentication is loaded from `/app/vibenest/glance.yml`, outside the persistent pages. Missing or malformed secrets stop startup before the HTTP server opens. No password is supplied in this repository. Keep the secret key unchanged to preserve login sessions; changing the key invalidates them.

No Docker socket, host metrics, database, Redis, or mandatory paid API is used by this example. RSS availability and rate limits depend on the source. Reddit, YouTube and other widgets are not covered by this pilot's acceptance.

## Build and source identity

The root Dockerfile packages a checked-in static Linux/amd64 executable without `RUN` instructions or a compiler stage. It uses the immutable linux/amd64 manifest for official Alpine 3.24.4, verified to include `/bin/sh` and a CA certificate bundle for HTTPS feeds. Other CPU architectures are not supported by this package.

The executable was compiled once from clean fork commit `fffc32ab7e778cc376dcd81a92f091da6ca40306` (tree `a5a27406dbd643d60c7971941feee18d5cfe5de0`) with Go 1.27.3, CGO disabled, and Go parallelism limited to one. Its SHA-256 is `7aa1d7cabf169b32063073c082ca517bd11ec6aa6d553e32287b76798e1b32d8` (15,806,624 bytes). Build metadata records that source commit and `vcs.modified=false`. The binary was inspected without executing it. Compilation does not establish image, runtime, security-gate, or Free-tier acceptance.

The compiled source commit, this packaging commit/tree, the base image digest, and any future serving image identity are distinct. See [provenance.json](provenance.json) for public build inputs and hashes. The complete source remains at its existing paths. The previous source-building Dockerfile is preserved unchanged at [source-build/Dockerfile](source-build/Dockerfile); it uses the repository root as its context and needs an authorized compiler. It is not the default packaging recipe.

The upstream base is `97b17de3be4ccc9e6b768a702ee31491fd94e7cd`. Upstream release v0.8.7 belongs to a different revision; its binary is not substituted here. No Git LFS pointer or runtime downloader is used.

The upstream AGPL-3.0 license and notices are retained in this fork and image. The application footer links to the corresponding open source and adaptation. Preserve that link and the source for the revision you deploy. See [LICENSE](../LICENSE).
