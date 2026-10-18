# Images are stored on AWS S3, in a public bucket

The app runs on Heroku, whose filesystem is wiped on every restart, so Active Storage can't use the `:local` service that production was configured with. Lemon drop images go to an AWS S3 bucket through Active Storage's native S3 service. The bucket is **public** (`public: true`) and images are served from plain S3 URLs (`https://<bucket>.s3.<region>.amazonaws.com/...`), so URLs are permanent and cacheable. Active Storage's default signed URLs expire after a few minutes, which breaks Open Graph previews and browser caching, and proxying images through Heroku dynos would be slow. Every image is public content anyway. At this size S3 costs pennies a month: storage is about $0.023/GB-month and AWS includes 100 GB of free outbound transfer each month. Uploads accept JPEG, PNG and WebP only. HEIC is left out because Heroku's libvips can't be relied on to decode it.

## Considered Options

- **Cloudflare R2**: free egress and a one-click custom domain, but only when the domain's DNS is on Cloudflare, and ours isn't. Moving DNS would put the site's and email's records at risk.
- **Backblaze B2**: free first 10 GB, but public buckets require a one-off payment, the free egress allowance scales with storage, and newer AWS SDKs need a checksum workaround.
- **DigitalOcean Spaces**: simple, with a built-in CDN, but a flat $5/month minimum for a handful of images.

## Consequences

- No custom image domain in v1. CloudFront with `images.lemonandbasil.co` can be added later via a CNAME at the current DNS provider; image URLs are generated at render time, so switching only changes URLs going forward.
- New S3 buckets have ACLs disabled by default, which rejects the `public-read` ACL Active Storage sends in public mode. The bucket needs ACLs enabled (Object Ownership: "Bucket owner preferred") alongside a public-read bucket policy, or uploads fail.
