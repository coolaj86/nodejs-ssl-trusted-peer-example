nodejs-self-signed-certificate-example
======================================

An example that works.

The end off all your self-signed certificate woes (in node.js at least)

Test for yourself
---

This is an easy-as-git-clone example that will get you on your way without
any `DEPTH_ZERO_SELF_SIGNED_CERT` or `SSL certificate problem: Invalid certificate chain` headaches.

### Get the repo

```bash
git clone git@github.com:coolaj86/nodejs-self-signed-certificate-example.git
pushd nodejs-self-signed-certificate-example
npm install
```

**For the super impatient**:

```bash
bash test.sh
```

### Create certificates for `local.ldsconnect.org`

`local.ldsconnect.org` points to `localhost`, so it's ideal for your first test.

```bash
bash make-root-ca-and-certificates.sh 'local.ldsconnect.org'
```

### Run the server

```bash
node ./serve.js 4443 &
# use `fg` and `ctrl+c` to kill
```


### Test in a client

Visit in a web browser

<https://local.ldsconnect.org>

Test (warning free) in node.js

```bash
node ./request-without-warnings.js 4443
```

Test (warning free) with cURL

```bash
curl -v https://local.ldsconnect.org \
  --cacert client/my-private-root-ca.crt.pem
```

Now season to taste
---

You can poke around in the files for generating the certificates, 
but all you really have to do is replace `local.ldsconnect.org`
with your very own domain name.

But where's the magic?
====

Who's the man behind the curtain you ask?

Well... I lied. This demo doesn't use self-signed certificates.
It uses a self-signed Root CA and a signed certificate.

It turns out that self-signed certificates were designed to be
used by the Root Certificate Authorities, not by web servers.

So instead of trying to work through eleventeen brazillion errors
about self-signed certs, you can just create an authority and then
add the authority to your chain (viola, now it's trusted).
