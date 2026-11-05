# Glance on VibeNest — acceptance candidate

[![Deploy to VibeNest](https://vibenest.net/deploy-to-vibenest.svg)](https://vibenest.net/deploy?repo=https%3A%2F%2Fgithub.com%2FNikitaBabenko%2Fglance&branch=vibenest)

This fork is being tested. Free-tier compatibility and the complete button-to-login-to-deploy flow have **not yet been verified**. It is not a published VibeNest catalog template. There is no verified demo yet.

Glance combines RSS feeds and bookmarks into a personal dashboard. Unlike a shared public dashboard, this configuration requires your own password. Compared with Dashy, this example focuses on reading feeds alongside a small set of personal links. It does not provide a browser-based YAML editor.

## Guided setup

1. Open the Deploy button, sign in to VibeNest, and check that the repository is `NikitaBabenko/glance`, branch `vibenest`. Create a **Draft** project. Creating metadata is separate from attaching hardware and starting the application.
2. Before launching, add the two required secrets in the project's **Environment** settings: `GLANCE_SECRET_KEY` (64 cryptographically random bytes encoded as base64) and `GLANCE_PASSWORD_HASH` (bcrypt hash, cost 10–14). Use a unique password. The login username is `owner`. The helper below reads a password through a hidden prompt; never put passwords in command arguments, a URL, or Git.
3. Set optional `GLANCE_RSS_URL` to a public HTTPS RSS/Atom feed and `GLANCE_BOOKMARK_URL` to your own HTTPS bookmark. Omitted values use Hacker News RSS and the Glance upstream repository. URLs must be single-line and contain no quotes or spaces. Credentials and private feed tokens do not belong in these example URLs.
4. Configure Dockerfile build, port **8080**, and persistent storage mounted at **`/app/data`** through VibeNest. Storage must be attached before the first launch. `/app/data/pages.yml` and `/app/data/assets` are persistent; never mount the public assets directory over the entire data directory.
5. Select suitable hardware and deploy using the normal VibeNest controls. During this pilot, hardware, storage and deployment are restricted to the coordinator-assigned test window. Free support remains unverified until the real 256 MiB / 0.5 CPU / 4 GiB test passes; build memory is a separate requirement.
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

The source base is upstream `97b17de3be4ccc9e6b768a702ee31491fd94e7cd`. The root Dockerfile compiles this checkout with Go parallelism limited to one; it still needs a healthy authorized builder. No build has been performed for this candidate.

Upstream's release v0.8.7 belongs to `698db7126f8e744263cb7f4ed6301c248f7a3d9c`, not this source base. Its Linux asset must not be used as evidence that this checkout was built. A host requiring packaging without Dockerfile `RUN` needs an independently built, verified Linux artifact from this exact fork revision before a packaging recipe can be finalized. No binary-only branch or unverified image substitution is provided.

The upstream AGPL-3.0 license and notices are retained in this fork and image. The application footer links to the corresponding open source and adaptation. Preserve that link and the source for the revision you deploy. See [LICENSE](../LICENSE).
