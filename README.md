# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

## Image storage (lemon drop)

Lemon drop images are processed with ImageMagick through `mini_magick`
(`brew install imagemagick` locally; Heroku's heroku-24 stack already includes
it). Development and test store
files on disk under `storage/` and `tmp/storage/`.

Production stores them in a public AWS S3 bucket (see
`docs/adr/0005-images-stored-on-aws-s3.md`). Until `AWS_S3_BUCKET` is set,
production falls back to local disk, which Heroku wipes on every restart, so
set these before anyone uploads images:

```
AWS_S3_BUCKET=          # bucket name
AWS_REGION=             # e.g. us-east-2
AWS_ACCESS_KEY_ID=      # IAM user limited to the bucket
AWS_SECRET_ACCESS_KEY=
```

```
heroku config:set AWS_S3_BUCKET=... AWS_REGION=... AWS_ACCESS_KEY_ID=... AWS_SECRET_ACCESS_KEY=...
```

Bucket setup, once:

1. **Create the bucket** in the region you'll set as `AWS_REGION`.
2. **Object Ownership: "Bucket owner preferred" (ACLs enabled).** New buckets
   disable ACLs, and Active Storage's public mode sends a `public-read` ACL
   with every upload, so with ACLs disabled every upload fails.
3. **Block Public Access: turn off** "Block public access to buckets and
   objects granted through new public bucket policies" and the ACL settings,
   so objects can be read publicly.
4. **Bucket policy** allowing anyone to read objects:
   ```json
   {
     "Version": "2012-10-17",
     "Statement": [{
       "Effect": "Allow",
       "Principal": "*",
       "Action": "s3:GetObject",
       "Resource": "arn:aws:s3:::BUCKET_NAME/*"
     }]
   }
   ```
5. **IAM user** for the app with access to this bucket only, and use its
   access key for `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY`:
   ```json
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Effect": "Allow",
         "Action": ["s3:ListBucket"],
         "Resource": "arn:aws:s3:::BUCKET_NAME"
       },
       {
         "Effect": "Allow",
         "Action": ["s3:GetObject", "s3:PutObject", "s3:PutObjectAcl", "s3:DeleteObject"],
         "Resource": "arn:aws:s3:::BUCKET_NAME/*"
       }
     ]
   }
   ```

Uploads accept JPEG, PNG and WebP up to 15 MB, with the type checked from the
file's contents (`active_storage_validations` with `spoofing_protection`,
which uses the `file` command). Originals are stored as uploaded, including
any location data, so pages must only ever show variants saved with
`saver: { strip: true }`, never the original.
